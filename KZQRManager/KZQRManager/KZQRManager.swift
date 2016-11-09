//
//  KZQRManager.swift
//  KZQRManager
//
//  Created by Kagen Zhao on 2016/11/8.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit

public final class KZQRManager<Type> {
    let base: Type
    init(_ base: Type) {
        self.base = base
    }
}

public protocol KZQRManagerCompatible {
    associatedtype CompatibleType
    var kqr: CompatibleType { get }
}

public extension KZQRManagerCompatible {
    public var kqr: KZQRManager<Self> {
        get { return KZQRManager(self) }
    }
}

/// you can set another Type to conform this protocol
public protocol KZQRDecodeUIProtocol: KZQRManagerCompatible, NSObjectProtocol {
    var decodeUISuperLayer: CALayer { get }
}

/// you can set another Type to conform this protocol
public protocol KZQRDecodeProtocol: KZQRManagerCompatible {
    var decodeImage: UIImage { get }
}

/// you can set another Type to conform this protocol
public protocol KZQREncodeProtocol: KZQRManagerCompatible {
    var encodeMessage:String { get }
}


extension UIImage: KZQRDecodeProtocol {
    public var decodeImage: UIImage { return self }
}

extension String: KZQREncodeProtocol {
    public var encodeMessage: String { return self }
}

extension NSString: KZQREncodeProtocol {
    public var encodeMessage: String { return self as String }
}

extension URL: KZQREncodeProtocol {
    public var encodeMessage: String { return self.absoluteString }
}

extension NSURL: KZQREncodeProtocol {
    public var encodeMessage: String { return self.absoluteString ?? "" }
}

extension UIView: KZQRDecodeUIProtocol {
    public var decodeUISuperLayer: CALayer { return self.layer }
}

extension UIViewController: KZQRDecodeUIProtocol {
    public var decodeUISuperLayer: CALayer { return self.view.layer }
}

