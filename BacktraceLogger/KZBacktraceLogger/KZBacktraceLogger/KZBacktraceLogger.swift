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
    let previous: UnsafePointer<KZStackFrame>
    let returnAddress: uintptr_t
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
    
#elseif arch(arm)
    let KZ_THREAD_STATE_COUNT: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<__darwin_arm_thread_state>.size / MemoryLayout<UInt32>.size)
    let KZ_THREAD_STATE: thread_state_flavor_t = 1
    func KZ_FRAME_POINTER(k:KZ_STRUCT_MCONTEXT) -> UInt32 { return k.__ss.__r.7 }
    func KZ_STACK_POINTER(k:KZ_STRUCT_MCONTEXT) -> UInt32 { return k.__ss.__sp }
    func KZ_INSTRUCTION_ADDRESS(k:KZ_STRUCT_MCONTEXT) -> UInt32 { return k.__ss.__pc }
    
#elseif arch(x86_64)
    let KZ_THREAD_STATE_COUNT: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<x86_thread_state64_t>.size / MemoryLayout<Int>.size)
    let KZ_THREAD_STATE: thread_state_flavor_t = 4
    func KZ_FRAME_POINTER(k:KZ_STRUCT_MCONTEXT) -> UInt64 { return k.__ss.__rbp }
    func KZ_STACK_POINTER(k:KZ_STRUCT_MCONTEXT) -> UInt64 { return k.__ss.__rsp }
    func KZ_INSTRUCTION_ADDRESS(k:KZ_STRUCT_MCONTEXT) -> UInt64 { return k.__ss.__rip }
    
#elseif arch(i386)
    let KZ_THREAD_STATE_COUNT: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<x86_thread_state32_t>.size / MemoryLayout<Int>.size)
    let KZ_THREAD_STATE: thread_state_flavor_t = 1
    func KZ_FRAME_POINTER(k:KZ_STRUCT_MCONTEXT) -> UInt32 { return k.__ss.__ebp }
    func KZ_STACK_POINTER(k:KZ_STRUCT_MCONTEXT) -> UInt32 { return k.__ss.__esp }
    func KZ_INSTRUCTION_ADDRESS(k:KZ_STRUCT_MCONTEXT) -> UInt32 { return k.__ss.__eip }
    
#endif



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
    typealias kz_thread_state_data_t = (UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64, UInt64)
    
    class func kz_backtraceThread(thread: thread_t) -> Int {
        
        var mcontext = KZ_STRUCT_MCONTEXT();
        
        var state:kz_thread_state_data_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        
        guard !kz_fillThreadStateIntoMachineContext(thread: thread, machineContext: &mcontext, state: &state) else { return 0 }
        
        
        
        return 1;
    }
    
    class func kz_fillThreadStateIntoMachineContext(thread: thread_t, machineContext: UnsafeMutablePointer<KZ_STRUCT_MCONTEXT>, state: UnsafeMutablePointer<kz_thread_state_data_t>) -> Bool {
        var state_count = KZ_THREAD_STATE_COUNT
        var a: thread_state_data_t = state.pointee
        let kr : kern_return_t = thread_get_state(thread, KZ_THREAD_STATE,  &a.0, &state_count)
        return kr == KERN_SUCCESS
        
//        let a = __darwin_mcontext64(__es: __darwin_arm_exception_state64.init(__far: __uint64_t(state.0), __esr: state.1, __exception: state.2),
//                                    __ss: __darwin_arm_thread_state64.init(__x: (__uint64_t(state.3), __uint64_t(state.4), __uint64_t(state.5), __uint64_t(state.6), __uint64_t(state.7), __uint64_t(state.8), __uint64_t(state.9), __uint64_t(state.10), __uint64_t(state.11), __uint64_t(state.12), __uint64_t(state.13), __uint64_t(state.14), __uint64_t(state.15), __uint64_t(state.16), __uint64_t(state.17), __uint64_t(state.18), __uint64_t(state.19), __uint64_t(state.20), __uint64_t(state.21), __uint64_t(state.22), __uint64_t(state.23), __uint64_t(state.24), __uint64_t(state.25), __uint64_t(state.26), __uint64_t(state.27), __uint64_t(state.28), __uint64_t(state.29), __uint64_t(state.30), __uint64_t(state.31)), __fp: __uint64_t(state.32), __lr: __uint64_t(state.33), __sp: __uint64_t(state.34), __pc: __uint64_t(state.35), __cpsr: state.36, __pad: state.37),
//                                    __ns: __darwin_arm_neon_state64.init())
        
        
        
    }
    
    class func getInt(fromData data: Data, start: Int) -> Int32 {
        let intBits = data.withUnsafeBytes({(bytePointer: UnsafePointer<UInt8>) -> Int32 in
            bytePointer.advanced(by: start).withMemoryRebound(to: Int32.self, capacity: 4) { pointer in
                return pointer.pointee
            }
        })
        return Int32(littleEndian: intBits)
    }

    
}
