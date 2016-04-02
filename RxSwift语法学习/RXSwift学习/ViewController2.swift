//
//  ViewController2.swift
//  RXSwift学习
//
//  Created by zhaoguoqing on 16/3/12.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

import UIKit
import RxSwift

class ViewController2: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        example("PublishSubject") {
            let subject = PublishSubject<String>()
            self.writeSequenceToConsole("1", squence: subject)
            subject.onNext("a")
            subject.onNext("b")
            self.writeSequenceToConsole("2", squence: subject)
            subject.onNext("c")
            subject.onNext("d")
        }
        
        
        
        example("ReplaySubject") {
            let subject = ReplaySubject<String>.create(bufferSize: 2)
            self.writeSequenceToConsole("1", squence: subject)
            subject.onNext("a")
            subject.onNext("b")
            self.writeSequenceToConsole("2", squence: subject)
            subject.onNext("c")
            subject.onNext("d")
        }
        
        example("BehaviorSubject") {
            let subject = BehaviorSubject<String>(value: "z")
            self.writeSequenceToConsole("1", squence: subject)
            subject.onNext("a")
            subject.onNext("b")
            self.writeSequenceToConsole("2", squence: subject)
            subject.onNext("c")
            subject.onCompleted()
        }
        
        
        example("Variable") {
            let variable = Variable("z")
            self.writeSequenceToConsole("1", squence: variable.asObservable())
            variable.value = "a"
            variable.value = "b"
            self.writeSequenceToConsole("2", squence: variable.asObservable())
            variable.value = "c"
        }
        
        example("map") {
            let originalSequence = Observable.of(1, 2, 3)
            _ = originalSequence
                .map{$0 * 2}
                .subscribe{ print($0)}
        }
        
        // 改变输出类型
        example("flatMap") { () -> () in
            let sequenceInt = Observable.of(1, 2, 3)
            let sequenceString = Observable.of("A", "B", "--")
            _ = sequenceInt.flatMap{ _ in
                sequenceString
                }.subscribe{
                    print($0)
            }
        }
        
        // 组合出新的数据
        example("scan") { () -> () in
            let sequenceToSum = Observable.of(0,1,2,3,4,5)
            _ = sequenceToSum.scan(100, accumulator: { a, b in // a为上次组合出来的数据  100 为 首次的数据
                a + b
            }).subscribe{
                print($0)
            }
        }
        
        // 过滤
        example("filter") { () -> () in
            let subscription = Observable.of(0,1,2,3,4,5,6,7,8,9)
            _ = subscription.filter({
                $0 % 2 == 0
            }).subscribe {
                print($0)
            }
        }
        
        // 去掉 连续重复的
        example("distinctUntilChanged") {
            _ = Observable.of(1, 2, 3, 1, 1, 1, 1, 1, 1, 1, 4)
                .distinctUntilChanged()
                .subscribe {
                    print($0)
            }
        }
        
        // 拦截次数
        example("take") { () -> () in
            let subscription = Observable.of(1, 2, 3, 4, 5, 6)
            _ = subscription
                .take(3)
                .subscribe({ (event) -> Void in
                    print(event)
                })
        }
        
        // 组合输出
        example("Combining") { () -> () in
            let sub1 = Observable.of(1, 2)
            let sub2 = Observable.of("a", "b", "c", "d", "e", "f")
            let sub3 = Observable.of("!", "@", "#", "$", "^", "&")
            _ = Observable.combineLatest(sub1, sub2, sub3) { a, b, c in
                "\(a)" + b + c
                }.subscribe {
                    print($0)
            }
        }
        
        // 改变开始 时 的数据
        example("startWith") {
            
            _ = Observable.of(4, 5, 6, 7, 8, 9)
                .startWith(3)
                .startWith(2)
                .startWith(1)
                .startWith(0)
                .subscribe {
                    print($0)
            }
        }
        
        
        // 压缩组合
        example("zip 1") { () -> () in
            let intOb1 = PublishSubject<String>()
            let intOb2 = PublishSubject<Int>()
            _ = Observable.zip(intOb1, intOb2, resultSelector: {
                "\($0)  \($1)"
            }).subscribe {
                print($0)
            }
            
            intOb1.onNext("a")
            intOb2.onNext(1)
            intOb1.onNext("b")
            intOb1.onNext("c")
            intOb2.on(.Next(2))
        }
        
        example("zip 2") {
            let intOb1 = Observable.just(2)
            
            let intOb2 = Observable.of(0, 1, 2, 3, 4)
            
            _ = Observable.zip(intOb1, intOb2) {
                $0 * $1
                }
                .subscribe {
                    print($0)
            }
        }
        
        example("zip 3") {
            let intOb1 = Observable.of(0, 1)
            let intOb2 = Observable.of(0, 1, 2, 3)
            let intOb3 = Observable.of(0, 1, 2, 3, 4)
            
            _ = Observable.zip(intOb1, intOb2, intOb3) {
                ($0 + $1) * $2
                }
                .subscribe {
                    print($0)
            }
        }
        
        // 插入
        example("merge 1") {
            let subject1 = PublishSubject<Int>()
            let subject2 = PublishSubject<Int>()
            
            _ = Observable.of(subject1, subject2)
                .merge()
                .subscribeNext { int in
                    print(int)
            }
            
            subject1.on(.Next(20))
            subject1.on(.Next(40))
            subject1.on(.Next(60))
            subject2.on(.Next(1))
            subject1.on(.Next(80))
            subject1.on(.Next(100))
            subject2.on(.Next(1))
        }
        
        example("merge 2") {
            let subject1 = PublishSubject<Int>()
            let subject2 = PublishSubject<Int>()
            let subject3 = PublishSubject<Int>()
            
            _ = Observable.of(subject1, subject2, subject3)
                .merge(maxConcurrent: 2) // 默认 操作个数  2 的意思是 只subject1和subject2
                .subscribe {
                    print($0)
            }
            subject1.on(.Next(20))
            subject1.on(.Next(40))
            subject1.on(.Next(60))
            subject2.on(.Next(1))
            subject1.on(.Next(80))
            subject1.on(.Next(100))
            subject2.on(.Next(1))
            subject3.on(.Next(12312312))
        }
        
        example("switchLatest") {
            let var1 = Variable(0)
            
            let var2 = Variable(200)
            
            // var3 is like an Observable<Observable<Int>>
            let var3 = Variable(var1.asObservable())
            
            let d = var3
                .asObservable()
                .switchLatest() // 返回 (self.element as Observable).element  并 只返回最新数据
                .subscribe {
                    print($0)
            }
            
            var1.value = 1
            var1.value = 2
            var1.value = 3
            var1.value = 4
            
            var3.value = var2.asObservable()
            
            var2.value = 201
            
            var1.value = 5
            var1.value = 6
            var1.value = 7
        }
        
        // 拦截错误信息
        example("catchError") { () -> () in
            let sequenceThatFails = PublishSubject<Int>()
            let recoverySequence = Observable.of(100, 200, 300, 400)
            
            _ = sequenceThatFails
                .catchError({ (error) -> Observable<Int> in
                    return recoverySequence
                })
                .subscribe {
                    print($0)
            }
            sequenceThatFails.onNext(1)
            sequenceThatFails.onNext(2)
            sequenceThatFails.onError(NSError(domain: "错误了", code: 100, userInfo: nil))
            
            
        }
        
        example("catchError 2") {
            let sequenceThatFails = PublishSubject<Int>()
            
            _ = sequenceThatFails
                .catchErrorJustReturn(100)
                .subscribe {
                    print($0)
            }
            
            sequenceThatFails.on(.Next(1))
            sequenceThatFails.on(.Next(2))
            sequenceThatFails.on(.Next(3))
            sequenceThatFails.on(.Next(4))
            sequenceThatFails.on(.Error(NSError(domain: "Test", code: 0, userInfo: nil)))
        }
        
        
        // 遇到错误后 重新尝试
        example("retry") {
            var count = 1 // bad practice, only for example purposes
            let funnyLookingSequence = Observable<Int>.create { observer in
                let error = NSError(domain: "Test", code: 0, userInfo: nil)
                observer.on(.Next(0))
                observer.on(.Next(1))
                observer.on(.Next(2))
                if count < 2 {
                    observer.on(.Error(error))
                    count += 1
                }
                observer.on(.Next(3))
                observer.on(.Next(4))
                observer.on(.Next(5))
                observer.on(.Completed)
                
                return NopDisposable.instance
            }
            
            _ = funnyLookingSequence
                .retry()
                .subscribe {
                    print($0)
            }
        }
        
        // 订阅任何类型
        example("subscribe") {
            let sequenceOfInts = PublishSubject<Int>()
            
            _ = sequenceOfInts
                .subscribe {
                    print($0)
            }
            
            sequenceOfInts.on(.Next(1))
            sequenceOfInts.on(.Completed)
        }
        
        // 只订阅 next类型
        example("subscribeNext") {
            let sequenceOfInts = PublishSubject<Int>()
            
            _ = sequenceOfInts
                .subscribeNext {
                    print($0)
            }
            
            sequenceOfInts.on(.Next(1))
            sequenceOfInts.on(.Completed)
        }
        
        // 只订阅 completed 类型
        example("subscribeCompleted") {
            let sequenceOfInts = PublishSubject<Int>()
            
            _ = sequenceOfInts
                .subscribeCompleted {
                    print("It's completed")
            }
            
            sequenceOfInts.on(.Next(1))
            sequenceOfInts.on(.Completed)
        }
        
        // 只订阅 error 类型
        example("subscribeError") {
            let sequenceOfInts = PublishSubject<Int>()
            
            _ = sequenceOfInts
                .subscribeError { error in
                    print(error)
            }
            
            sequenceOfInts.on(.Next(1))
            sequenceOfInts.on(.Error(NSError(domain: "Examples", code: -1, userInfo: nil)))
        }
        
        // 再订阅执行之前  另外执行的 任务
        example("doOn") {
            let sequenceOfInts = PublishSubject<Int>()
            
            _ = sequenceOfInts
                .doOn {
                    print("Intercepted event \($0)")
                }
                .subscribe {
                    print($0)
            }
            
            sequenceOfInts.on(.Next(1))
            sequenceOfInts.on(.Completed)
        }
        
        
        
        // 拦截指定的输出  然后停止订阅
        example("takeUntil") {
            let originalSequence = PublishSubject<Int>()
            let whenThisSendsNextWorldStops = PublishSubject<Int>()
            
            _ = originalSequence
                .takeUntil(whenThisSendsNextWorldStops)
                .subscribe {
                    print($0)
            }
            
            originalSequence.on(.Next(1))
            originalSequence.on(.Next(2))
            originalSequence.on(.Next(3))
            originalSequence.on(.Next(4))
            
            whenThisSendsNextWorldStops.on(.Next(1))
            
            originalSequence.on(.Next(5))
        }
        // 同上
        example("takeWhile") {
            
            let sequence = PublishSubject<Int>()
            
            _ = sequence
                .takeWhile { int in
                    int < 4
                }
                .subscribe {
                    print($0)
            }
            
            sequence.on(.Next(1))
            sequence.on(.Next(2))
            sequence.on(.Next(3))
            sequence.on(.Next(4))
            sequence.on(.Next(5))
        }
        
        example("concat") {
            let var1 = BehaviorSubject(value: 0)
            let var2 = BehaviorSubject(value: 200)
            
            // var3 is like an Observable<Observable<Int>>
            let var3 = BehaviorSubject(value: var1)
            
            let d = var3
                .concat()
                .subscribe {
                    print($0)
            }
            
            var1.on(.Next(1))
            var1.on(.Next(2))
            var1.on(.Next(3))
            var1.on(.Next(4))
            
            var3.on(.Next(var2))
            
            var2.on(.Next(20010)) // 再completed之前 可以改变初始值
            var2.on(.Next(2343242))
            var1.on(.Next(5))
            var1.on(.Next(6))
            var1.on(.Next(7))
            var1.on(.Completed)
            
            var2.on(.Next(202))
            var2.on(.Next(203))
            var2.on(.Next(204))
        }
        
        
        // 类似scan
        example("reduce") {
            _ = Observable.of(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
                .reduce(0, accumulator: { (a, b) -> Int in
                    print(a)
                    return a + b
                })
                .subscribe {
                    print($0)
            }
        }
        
        /*
        example("sampleWithoutConnectableOperators") { () -> () in
        let int1 = Observable<Int>.interval(1, scheduler: MainScheduler.instance) // 定时器 秒一个
        
        _ = int1
        .subscribe {
        print("first subscription \($0)")
        }
        
        self.delay(5) {  // 5 秒后 再订阅
        _ = int1
        .subscribe {
        print("second subscription \($0)")
        }
        }
        }
        */
        /*
        // 连接  连接两个信号同时输出 , 数据 相同
        example("sampleWithMulticast") { () -> () in
        let subject1 = PublishSubject<Int64>()
        
        _ = subject1
        .subscribe {
        print("Subject \($0)")
        }
        let int1 = Observable<Int64>.interval(1, scheduler: MainScheduler.instance)
        .multicast(subject1)
        _ = int1
        .subscribe {
        print("first subscription \($0)")
        }
        self.delay(2) {
        int1.connect()
        }
        self.delay(4) {
        _ = subject1
        .subscribe {
        print("second subscription \($0)")
        }
        }
        self.delay(6) {
        _ = subject1
        .subscribe {
        print("third subscription \($0)")
        }
        }
        }
        */
        /*
        example("replay") { () -> () in
        
        let int1 = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        .replay(2) // 数字为 最多重复数     2 ---  后一个订阅者 会多接收到 前两次发出的信号
        _ = int1
        .subscribe {
        print("first subscription \($0)")
        }
        
        delay(2) {
        int1.connect()
        }
        
        delay(4) {
        _ = int1
        .subscribe {
        print("second subscription \($0)")
        }
        }
        
        delay(6) {
        _ = int1
        .subscribe {
        print("third subscription \($0)")
        }
        }
        }
        */

        /*
        example("publish") { () -> () in
            let int1 = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
                .publish()
            
            _ = int1
                .subscribe {
                    print("first subscription \($0)")
            }
            
            self.delay(2) {
                int1.connect()
            }
            
            self.delay(4) {
                _ = int1
                    .subscribe {
                        print("second subscription \($0)")
                }
            }
            
            self.delay(6) {
                _ = int1
                    .subscribe {
                        print("third subscription \($0)")
                }
            }
        }
        */
        
        
        
        
        
        
        
    }
    
    func writeSequenceToConsole<O: ObservableType>(name: String, squence: O) {
        _ = squence.subscribe { e in
            print("Subscription: \(name), event: \(e)")
        }
        //            .addDisposableTo(disposBag)
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func sampleWithoutConnectableOperators() {
        
        
        
    }
    
}
