//
//  KZBacktraceLogger.swift
//  KZBacktraceLogger
//
//  Created by Kagen Zhao on 2016/10/10.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit
import MachO
import Darwin

struct KZStackFrame {
    var previous: UnsafePointer<KZStackFrame>
    let returnAddress: uintptr_t = 0
    init() {
        var a = 0
        previous = withUnsafeMutablePointer(to: &a) {
            $0.withMemoryRebound(to: KZStackFrame.self, capacity: MemoryLayout<KZStackFrame>.size, { pointer in
                return UnsafePointer<KZStackFrame>.init(pointer)
            })
        }
    }
}

#if arch(arm64) || arch(x86_64)
    typealias KZ_STRUCT_MCONTEXT = __darwin_mcontext64
    typealias KZ_NLST = nlist_64
let TRACE_FMT         = "%-4d%-31s 0x%016lx %s + %lu"
let POINTER_FMT       = "0x%016lx"
let POINTER_SHORT_FMT = "0x%lx"
#else
    typealias KZ_STRUCT_MCONTEXT = __darwin_mcontext32
    typealias KZ_NLST = nlist
let TRACE_FMT         = "%-4d%-31s 0x%08lx %s + %lu"
let POINTER_FMT       = "0x%08lx"
let POINTER_SHORT_FMT = "0x%lx"
#endif

#if arch(arm64)
let KZ_THREAD_STATE_COUNT: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<__darwin_arm_thread_state64>.size / MemoryLayout<UInt32>.size)
let KZ_THREAD_STATE: thread_state_flavor_t = 6
    func KZ_FRAME_POINTER(k:KZ_STRUCT_MCONTEXT) -> UInt64 { return k.__ss.__fp }
    func KZ_STACK_POINTER(k:KZ_STRUCT_MCONTEXT) -> UInt64 { return k.__ss.__sp }
    func KZ_INSTRUCTION_ADDRESS(k:KZ_STRUCT_MCONTEXT) -> UInt64 { return k.__ss.__pc }
    func DETAG_INSTRUCTION_ADDRESS(a: Int) -> Int{ return (a & ~Int(3)) }
    
#elseif arch(arm)
let KZ_THREAD_STATE_COUNT: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<__darwin_arm_thread_state>.size / MemoryLayout<UInt32>.size)
let KZ_THREAD_STATE: thread_state_flavor_t = 1
    func KZ_FRAME_POINTER(k:KZ_STRUCT_MCONTEXT) -> UInt32 { return k.__ss.__r.7 }
    func KZ_STACK_POINTER(k:KZ_STRUCT_MCONTEXT) -> UInt32 { return k.__ss.__sp }
    func KZ_INSTRUCTION_ADDRESS(k:KZ_STRUCT_MCONTEXT) -> UInt32 { return k.__ss.__pc }
    func DETAG_INSTRUCTION_ADDRESS(a: Int) -> Int{ return (a & ~Int(1)) }
    
#elseif arch(x86_64)
let KZ_THREAD_STATE_COUNT: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<x86_thread_state64_t>.size / MemoryLayout<Int>.size)
let KZ_THREAD_STATE: thread_state_flavor_t = 4
    func KZ_FRAME_POINTER(k:KZ_STRUCT_MCONTEXT) -> UInt64 { return k.__ss.__rbp }
    func KZ_STACK_POINTER(k:KZ_STRUCT_MCONTEXT) -> UInt64 { return k.__ss.__rsp }
    func KZ_INSTRUCTION_ADDRESS(k:KZ_STRUCT_MCONTEXT) -> UInt64 { return k.__ss.__rip }
    func DETAG_INSTRUCTION_ADDRESS(a: Int) -> Int{ return a }
    
#elseif arch(i386)
let KZ_THREAD_STATE_COUNT: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<x86_thread_state32_t>.size / MemoryLayout<Int>.size)
let KZ_THREAD_STATE: thread_state_flavor_t = 1
    func KZ_FRAME_POINTER(k:KZ_STRUCT_MCONTEXT) -> UInt32 { return k.__ss.__ebp }
    func KZ_STACK_POINTER(k:KZ_STRUCT_MCONTEXT) -> UInt32 { return k.__ss.__esp }
    func KZ_INSTRUCTION_ADDRESS(k:KZ_STRUCT_MCONTEXT) -> UInt32 { return k.__ss.__eip }
    func DETAG_INSTRUCTION_ADDRESS(a: Int) -> Int{ return a }
    
#else
    
    
#endif

func CALL_INSTRUCTION_FROM_RETURN_ADDRESS(a: uintptr_t) -> uintptr_t {
    return uintptr_t(DETAG_INSTRUCTION_ADDRESS(a: Int(a)))
}



class KZBacktraceLogger: NSObject {
    
    class func kz_backtraceOfAllThread() -> String {
        var threads: thread_act_array_t?;
        var thread_count: mach_msg_type_number_t = 0;
        let this_task = mach_task_self_
        let kr = task_threads(this_task, &threads, &thread_count)
        guard kr == KERN_SUCCESS else { return "Fail to get information of all threads" }
        
        _ = kz_backtraceThread(thread: threads![0])
        return "------------"
    }
    
    
    class func kz_backtraceThread(thread: thread_t) -> String {
        
        var backtraceBuffer: [uintptr_t] = Array<uintptr_t>(repeating: 0, count: 50)
        var mcontext = KZ_STRUCT_MCONTEXT();
        var i = 0
        guard !kz_fill(thread: thread, into: &mcontext) else {
            return "Fail to get infomation ablout thread: \(thread)"
        }
        
        let address: uintptr_t = kz_match_instructionAddress(machineContext: &mcontext)
        backtraceBuffer[i] = address
        i += 1
        
        let linkRegister = kz_match_linkRegister(machineContext: &mcontext)
        if  linkRegister != 0 {
            backtraceBuffer[i] = linkRegister
            i += 1
        }
        
        guard address != 0 else { return "Fail to get instruction address"}
        
        var frame: KZStackFrame = KZStackFrame()
        var framePtr = kz_match_framePointer(machineContext: &mcontext)
        var a = withUnsafePointer(to: &frame, { return $0 })
        if framePtr == 0 || kz_mach_copyMem0(src: &framePtr, dst: &a, numBytes: MemoryLayout<KZStackFrame>.size) != KERN_SUCCESS {
            return "Fail to get frame pointer"
        }
        
        for w in i..<Int.max {
            backtraceBuffer[w] = frame.returnAddress
            if backtraceBuffer[w] == 0 ||
                withUnsafePointer(to: &frame.previous, {
                    $0.withMemoryRebound(to: vm_address_t.self, capacity: MemoryLayout<vm_address_t>.size, {
                        $0.pointee == 0
                    })
                }) ||
                kz_mach_copyMem1(src: &frame.previous, dst: &a, numBytes: MemoryLayout<KZStackFrame>.size) != KERN_SUCCESS
            {
                break
            }
        }
        
        let backtraceLength = i
        let symbolicated: [Dl_info] = []
        
        
        
        
        return "";
    }
    
    class func kz_fill(thread: thread_t, into machineContext: UnsafeMutablePointer<KZ_STRUCT_MCONTEXT>) -> Bool {
        var state_count = KZ_THREAD_STATE_COUNT
        let kr : kern_return_t = withUnsafeMutablePointer(to: &(machineContext.pointee.__ss)) {
            $0.withMemoryRebound(to: natural_t.self, capacity: MemoryLayout<natural_t>.size, {
                thread_get_state(thread, KZ_THREAD_STATE,  $0, &state_count)
            })
        }
        return kr == KERN_SUCCESS
    }
    
    class func kz_match_framePointer(machineContext: UnsafeMutablePointer<KZ_STRUCT_MCONTEXT>) -> uintptr_t {
        return uintptr_t(KZ_FRAME_POINTER(k: machineContext.pointee))
    }
    
    class func kz_match_stackPointer(machineContext: UnsafeMutablePointer<KZ_STRUCT_MCONTEXT>) -> uintptr_t {
        return uintptr_t(KZ_STACK_POINTER(k: machineContext.pointee))
    }
    
    class func kz_match_instructionAddress(machineContext: UnsafeMutablePointer<KZ_STRUCT_MCONTEXT>) -> uintptr_t {
        return uintptr_t(KZ_INSTRUCTION_ADDRESS(k: machineContext.pointee))
    }
    
    class func kz_match_linkRegister(machineContext: UnsafeMutablePointer<KZ_STRUCT_MCONTEXT>) -> uintptr_t {
        #if arch(i386) || arch(x86_64)
            return 0
        #else
            return uintptr_t(machineContext.pointee.__ss.__lr)
        #endif
    }
    
    class func kz_mach_copyMem0(src: inout uintptr_t, dst: inout UnsafePointer<KZStackFrame>, numBytes: size_t) -> kern_return_t {
        var bytesCopied: vm_size_t = 0
        let address = withUnsafeMutablePointer(to: &src) {
            $0.withMemoryRebound(to: vm_address_t.self, capacity: MemoryLayout<vm_address_t>.size, {
                $0.pointee
            })
        }
        let data = withUnsafeMutablePointer(to: &dst) {
            $0.withMemoryRebound(to: vm_address_t.self, capacity: MemoryLayout<vm_address_t>.size, {
                $0.pointee
            })
        }
        return vm_read_overwrite(mach_task_self_, address, vm_size_t(numBytes), data, &bytesCopied)
        
    }
    class func kz_mach_copyMem1(src: inout UnsafePointer<KZStackFrame>, dst: inout UnsafePointer<KZStackFrame>, numBytes: size_t) -> kern_return_t {
        var bytesCopied: vm_size_t = 0
        let address = withUnsafeMutablePointer(to: &src) {
            $0.withMemoryRebound(to: vm_address_t.self, capacity: MemoryLayout<vm_address_t>.size, {
                $0.pointee
            })
        }
        let data = withUnsafeMutablePointer(to: &dst) {
            $0.withMemoryRebound(to: vm_address_t.self, capacity: MemoryLayout<vm_address_t>.size, {
                $0.pointee
            })
        }
        return vm_read_overwrite(mach_task_self_, address, vm_size_t(numBytes), data, &bytesCopied)
    }
    
    class func kz_symbolicate(backtraceBuffer: inout [uintptr_t], symbolsBuffer: inout [Dl_info], numEntries: Int, skippedEntries: Int) {
        var i = 0
        if skippedEntries != 0 && i < numEntries {
            kz_dladdr(address: backtraceBuffer[i], info: &symbolsBuffer[i])
            i += 1
        }
        for w in i..<numEntries {
            kz_dladdr(address: CALL_INSTRUCTION_FROM_RETURN_ADDRESS(a: backtraceBuffer[w]), info: &symbolsBuffer[w])
        }
        
    }
    
    @discardableResult
    class func kz_dladdr(address: uintptr_t, info: inout Dl_info) -> Bool {
        info.dli_fbase = nil
        info.dli_fname = nil
        info.dli_saddr = nil
        info.dli_sname = nil
        
        let idx = kz_imageIndexContaining(address: address)
        if idx == UInt32.max {
            return false
        }
        let header: UnsafePointer<mach_header> = _dyld_get_image_header(idx)
        let imageVMAddrSlide = _dyld_get_image_vmaddr_slide(idx)
        let segmentBase = Int(kz_segmentBaseOf(index: idx)) + imageVMAddrSlide
        guard segmentBase != 0 else { return false }
        info.dli_fname = _dyld_get_image_name(idx)
        info.dli_fbase = UnsafeMutableRawPointer.init(mutating: header)
        
        let bestMatch:KZ_NLST = KZ_NLST()
        let bestDistance: uintptr_t = UInt.max
        let cmdPtr = kz_firstCmdAfter(header: header)
        guard cmdPtr != 0 else { return false }
        for i in 0..<header.pointee.ncmds {
//            let loadCmd = 
        }
        
        
        
        
    }
    
    class func kz_firstCmdAfter(header: UnsafePointer<mach_header>) -> uintptr_t {
        
    }
    
    
    class func kz_imageIndexContaining(address: uintptr_t) -> UInt32 {
        
    }
    
    class func kz_segmentBaseOf(index: UInt32) -> uintptr_t {
        
    }
    
}
