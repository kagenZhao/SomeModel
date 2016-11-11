//
//  KZQREncode.swift
//  KZQRManager
//
//  Created by Kagen Zhao on 2016/11/8.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit

public extension KZQRManager where Type: KZQREncodeProtocol {
    func encodeQR(to size: CGFloat = 200.0) -> UIImage? {
        guard let ciimage = createCiimage() else { return nil }
        guard let defaultImage = createUIImage(from: ciimage, size: size) else { return nil }
        return transparent(with: defaultImage, to: CIColor(color: UIColor.red))
    }
    
    private func createCiimage() -> CIImage? {
        guard let data = base.encodeMessage.data(using: .utf8) else { return nil }
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        return filter.outputImage
    }
    
    private func createUIImage(from image: CIImage, size: CGFloat) -> UIImage? {
        let extent = image.extent.integral;
        let scale = min(size / extent.width, size / extent.height)
        let width = extent.width * scale
        let height = extent.height * scale
        let cs = CGColorSpaceCreateDeviceGray()
        guard let bitmap = CGContext.init(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: cs, bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return nil }
        let context = CIContext(options: nil)
        guard let bitmapImage = context.createCGImage(image, from: extent) else { return nil }
        bitmap.interpolationQuality = .none
        bitmap.scaleBy(x: scale, y: scale)
        bitmap.draw(bitmapImage, in: extent)
        guard let scaledImage = bitmap.makeImage() else { return nil }
        return UIImage(cgImage: scaledImage)
    }
    
    func transparent(with image: UIImage, to cicolor: CIColor) -> UIImage? {
        let w = Int(image.size.width)
        let h = Int(image.size.height)
        let bytePerRow = w * 4
        let rgbimageBuf: UnsafeMutablePointer<UInt32> = malloc(bytePerRow * h).bindMemory(to: UInt32.self, capacity: 1)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext.init(data: rgbimageBuf, width: w, height: h, bitsPerComponent: 8, bytesPerRow: bytePerRow, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipLast.rawValue) else { return nil }
        guard let cgimage = image.cgImage else { return nil }
        context.draw(cgimage, in: CGRect(origin: CGPoint.zero, size: CGSize(width: w, height: h)))
        for i in 0..<(w * h) {
           let pCurPtr = rgbimageBuf.advanced(by: i)
            if (pCurPtr.pointee & 0xffffff00) < 0x99999900 {
                let ptr = pCurPtr.withMemoryRebound(to: UInt8.self, capacity: 4, { return $0 })
                ptr[3] = UInt8(cicolor.red * 255)
                ptr[2] = UInt8(cicolor.green * 255)
                ptr[1] = UInt8(cicolor.blue * 255)
            } else {
                let ptr = pCurPtr.withMemoryRebound(to: UInt8.self, capacity: 4, { return $0 })
                ptr[0] = 0
            }
        }
        guard let dataProvider = CGDataProvider.init(dataInfo: nil, data: rgbimageBuf, size: w * h, releaseData: {info, data, size in
            let d = UnsafeMutableRawPointer.init(mutating: data)
            free(d)
        }) else { return nil }
        guard let imageRef = CGImage.init(width: w, height: h, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: bytePerRow, space: colorSpace, bitmapInfo: [.byteOrder32Little, .init(rawValue: CGImageAlphaInfo.last.rawValue)], provider: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else { return nil }
        let resultImage = UIImage(cgImage: imageRef)
        return redraw(image: resultImage)
    }
    
    // 解决 不能存到相册的问题 不知道为什么....
    func redraw(image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
}
