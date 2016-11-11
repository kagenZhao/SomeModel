//
//  KZQRDecodeUI.swift
//  KZQRManager
//
//  Created by Kagen Zhao on 2016/11/9.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit
import AVFoundation

private var kz_sessionKey: Void?
private var kz_previewLayerKey: Void?
private var kz_outputDelegateKey: Void?
private var kz_decodeNotifierKey: Void?


private class _KZOutputDelegate: NSObject {
    fileprivate var value: ((String) -> Void)?
    
    fileprivate init(_ obj: ((String) -> Void)?) {
        super.init()
        self.value = obj
    }
}

public extension KZQRManager where Type: KZQRDecodeUIProtocol {
    
    private var kz_session: AVCaptureSession? {
        set {
            objc_setAssociatedObject(base, &kz_sessionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
             return objc_getAssociatedObject(base, &kz_sessionKey) as? AVCaptureSession
        }
    }
    
    private var kz_previewLayer: AVCaptureVideoPreviewLayer? {
        set {
            objc_setAssociatedObject(base, &kz_previewLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(base, &kz_previewLayerKey) as? AVCaptureVideoPreviewLayer
        }
    }
    
    private var kz_outputDelegate: _KZOutputDelegate? {
        set {
            objc_setAssociatedObject(base, &kz_outputDelegateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(base, &kz_outputDelegateKey) as? _KZOutputDelegate
        }
    }
    
    private func setupInput() -> AVCaptureDeviceInput {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch {
            fatalError("can't create input")
        }
        return input
    }
    
    private func setupOutput() -> AVCaptureMetadataOutput {
        let output = AVCaptureMetadataOutput()
        return output
    }
    
    private func checkAVAuthorizationStatus() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        return status == .authorized
    }
    
    private func setupSession() {
        
        let input = setupInput()
        let output = setupOutput()
        let session = AVCaptureSession()
        
        guard session.canAddInput(input) else {
            fatalError("can't add input")
        }
        
        guard session.canAddOutput(output) else {
            fatalError("can't add output")
        }
        
        session.addInput(input)
        session.addOutput(output)
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        kz_session = session
    }
    
    private func setupLayer(in superLayer: CALayer) {
        guard let previewLayer = AVCaptureVideoPreviewLayer(session: kz_session) else {
            fatalError("can't create previewLayer")
        }
        previewLayer.frame = superLayer.bounds
        kz_previewLayer = previewLayer
        superLayer.insertSublayer(kz_previewLayer!, at: 0)
    }
    
    @discardableResult
    public func setupQRUIInSelf() -> Self? {
        return setupQRUI(in: base.decodeUISuperLayer)
    }
    
    @discardableResult
    public func setupQRUI(in superLayer: CALayer) -> Self? {
        guard checkAVAuthorizationStatus() else {
            print("not authorized");
            return nil
        }
        setupSession()
        setupLayer(in: superLayer)
        return self
    }
    
    /// default is superLayer.bouns
    ///
    @discardableResult
    public func setPreviewLayerFrameInSuperLayer(_ rect: CGRect) -> Self {
        assert(kz_session != nil, "not call function setupQRUI")
        kz_previewLayer?.frame = rect
        return self
    }
    
    
    /// default is (0,0,1,1)
    ///
    @discardableResult
    public func setOutputRectOfInterest(_ rect: CGRect) -> Self {
        assert(kz_session != nil, "not call function setupQRUI")
        kz_session!.outputs.forEach { (output) in
            guard let output = output as? AVCaptureMetadataOutput else { return }
            output.rectOfInterest = rect
        }
        return self
    }
    
    @discardableResult
    public func startRunning(decodeNotifier: @escaping (String) -> Void) -> Self {
        assert(kz_session != nil, "not call function setupQRUI")
        self.kz_outputDelegate = _KZOutputDelegate(decodeNotifier)
        kz_session!.outputs.forEach {[weak self] (output) in
            guard let self_strong = self else { return }
            guard let output = output as? AVCaptureMetadataOutput else { return }
            output.setMetadataObjectsDelegate(self_strong.kz_outputDelegate, queue: .main)
        }
        kz_session?.startRunning()
        return self
    }
    
    @discardableResult
    public func stopRunning() -> Self {
        assert(kz_session != nil, "not call function setupQRUI")
        kz_session?.stopRunning()
        return self
    }
}

extension _KZOutputDelegate: AVCaptureMetadataOutputObjectsDelegate {
    fileprivate func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        guard let obj = metadataObjects.last as? AVMetadataMachineReadableCodeObject else { return }
        guard !obj.stringValue.isEmpty else { return }
        value?(obj.stringValue)
    }
}



