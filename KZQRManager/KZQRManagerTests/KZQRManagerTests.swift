//
//  KZQRManagerTests.swift
//  KZQRManagerTests
//
//  Created by Kagen Zhao on 2016/11/14.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

import XCTest
import KZQRManager

class KZQRManagerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }

    func testCreateQRImage() {
        
        let qrMessage = "this is qr code"
        
        let image = qrMessage.kqr.encodeQR()
        
        let decodeMessage = image?.kqr.decodeQR()
        
        XCTAssertEqual(qrMessage, decodeMessage, "encodeMessage should equal to decodeMessage")
    }
    
    func testNIL() {
        
        let qrMessage: String? = nil
        
        let image = qrMessage?.kqr.encodeQR()
        
        XCTAssertNil(image, "should be nil")
        
        let decodeMessage = image?.kqr.decodeQR()
        
        XCTAssertNil(decodeMessage, "should be nil")
    }
}
