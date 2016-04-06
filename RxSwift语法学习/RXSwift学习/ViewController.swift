//
//  ViewController.swift
//  RXSwift学习
//
//  Created by zhaoguoqing on 16/2/29.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public func example(description: String, action: () -> ()) {
    print("\n--- \(description) example ---")
    action()
}

public func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        example("empty", action: {
            let emptySequence: Observable<Int> = Observable<Int>.empty()
            let _ = emptySequence
                .subscribe { event in
                    print(event)
            }
        })
        
        example("never") {
            let neverSequence: Observable<Int> = Observable<Int>.never()
            let _ = neverSequence
                .subscribe { _ in
                    print("This block is never called.")
            }
        }
        
        example("just") {
            let singleElementSequence:Observable<[String]>  = Observable.just(["aaa", "bbb"])
            let _ = singleElementSequence
                .subscribe { event in
                    print(event)
            }
        }
        
        
        example("sequenceOf") {
            let sequenceOfElements = Observable.of(["aaa", "bbb"], ["ccc", "ddd"], ["eee", "fff"], ["ggg", "hhh"])
            let _ = sequenceOfElements
                .subscribe { event in
                    print(event)
            }
            
        }
        
        example("toObservable") {
            let sequenceFromArray = [1, 2, 3, 4, 5].toObservable()
            let _ = sequenceFromArray
                .subscribe { event in
                    print(event)
            }
        }

        
        example("create") {
            
            let myJust = { (singleElement: Int) -> Observable<Int> in
                print("createing")
                return Observable.create { observer in
                    print("emmiting")
                    let error = NSError(domain: "aaaaaa", code: 10000, userInfo: nil)
                    observer.on(.Next(singleElement))
                    if singleElement % 2 == 0 {
                        observer.onError(error)
                    } else {
                        observer.on(.Completed)
                    }
                    return NopDisposable.instance
                }
            }
            
            let _ = myJust(6)
                .subscribe { event in
                    print(event)
            }
            let _ = myJust(5)
                .subscribe { event in
                    print(event)
            }
        }
        
        
        example("failWith") {
            let error = NSError(domain: "Test", code: -1, userInfo: nil)
            let erroredSequence: Observable<Int> = Observable.error(error)
            let _ = erroredSequence
                .subscribe { event in
                    print(event)
            }
        }

        example("generate") {
            let generated = Observable.generate(
                initialState: 0,      // 初始状态
                condition: { $0 < 3 }, // 条件
                iterate: { $0 + 1 } // 重复
            )
            let _ = generated
                .subscribe { event in
                    print(event)
            }
        }
        
        
        example("deferred") {
            var value = 1;
            let normalCreate: Observable<Int> = Observable.just(value)
            let deferredSequence: Observable<Int> = Observable.deferred {
                return Observable.create { observer in
                    observer.on(.Next(value))
                    observer.on(.Completed)
                    return NopDisposable.instance
                }
            }
            value = 10
            _ = normalCreate
                .subscribe{
                    print("normal-\($0)")
            }
            _ = deferredSequence
                .subscribe {
                    print("defer-\($0)")
            }
        }
    
        
    }

}

