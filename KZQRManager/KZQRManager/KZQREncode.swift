//
//  KZQREncode.swift
//  KZQRManager
//
//  Created by Kagen Zhao on 2016/11/8.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import UIKit

public extension KZQRManager where Type: KZQREncodeProtocol {
    func encodeQR(to size: CGFloat = 200.0,
                  color: UIColor = .black,
                  centerImg: UIImage? = nil) -> UIImage? {
        guard let ciimage = createCiimage() else { return nil }
        return createUIImage(from: ciimage, size: size)
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
    
}
