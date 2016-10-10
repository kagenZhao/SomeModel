//
//  ViewController.m
//  LockTest
//
//  Created by Kagen Zhao on 2016/10/9.
//  Copyright © 2016年 Kagen Zhao. All rights reserved.
//

#import "ViewController.h"
#import <pthread/pthread.h>
#import <libkern/OSSpinLockDeprecated.h>
#import <os/lock.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
//    NSObject *obj = [[NSObject alloc] init];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        @synchronized(obj) {
//            NSLog(@"需要线程同步的操作1 开始");
//            sleep(3);
//            NSLog(@"需要线程同步的操作1 结束");
//        }
//    });
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        sleep(1);
//        @synchronized(obj) {
//            NSLog(@"需要线程同步的操作2");
//        }
//    });
    
    
    
    
//    dispatch_semaphore_t signal = dispatch_semaphore_create(1);
//    dispatch_time_t overTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        dispatch_semaphore_wait(signal, overTime);
//        NSLog(@"需要线程同步的操作1 开始");
//        sleep(2);
//        NSLog(@"需要线程同步的操作1 结束");
//        dispatch_semaphore_signal(signal);
//    });
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        sleep(1);
//        dispatch_semaphore_wait(signal, overTime);
//        NSLog(@"需要线程同步的操作2");
//        dispatch_semaphore_signal(signal);
//    });
    
    
    
//    NSLock *lock = [[NSLock alloc] init];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        //[lock lock];
//        [lock lockBeforeDate:[NSDate date]];
//        NSLog(@"需要线程同步的操作1 开始");
//        sleep(2);
//        NSLog(@"需要线程同步的操作1 结束");
//        [lock unlock];
//        
//    });
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        sleep(1);
//        if ([lock tryLock]) {//尝试获取锁，如果获取不到返回NO，不会阻塞该线程
//            NSLog(@"锁可用的操作");
//            [lock unlock];
//        }else{
//            NSLog(@"锁不可用的操作");
//        }
//        
//        NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:3];
//        if ([lock lockBeforeDate:date]) {//尝试在未来的3s内获取锁，并阻塞该线程，如果3s内获取不到恢复线程, 返回NO,不会阻塞该线程
//            NSLog(@"没有超时，获得锁");
//            [lock unlock];
//        }else{
//            NSLog(@"超时，没有获得锁");
//        }
//        
//    });
    
    
    
    
    
    
//    //NSLock *lock = [[NSLock alloc] init];
//    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        static void (^RecursiveMethod)(int);
//        
//        RecursiveMethod = ^(int value) {
//            
//            [lock lock];
//            if (value > 0) {
//                
//                NSLog(@"value = %d", value);
//                sleep(1);
//                RecursiveMethod(value - 1);
//            }
//            [lock unlock];
//        };
//        
//        RecursiveMethod(5);
//    });
    
    
    
    
//    NSMutableArray *products = [NSMutableArray array];
//    NSConditionLock *lock = [[NSConditionLock alloc] init];
//    NSInteger shengchanzhejieshu_gaosuxiaofeizhe = 1;
//    NSInteger xiaofeizhejieshu_gaosushengchanzhe = 0;
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        while (1) {
//            [lock lockWhenCondition:xiaofeizhejieshu_gaosushengchanzhe];
//            [products addObject:[[NSObject alloc] init]];
//            NSLog(@"produce a product,总量:%zi",products.count);
//            [lock unlockWithCondition:shengchanzhejieshu_gaosuxiaofeizhe];
//            sleep(1);
//        }
//    });
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        while (1) {
//            NSLog(@"wait for product");
//            [lock lockWhenCondition:shengchanzhejieshu_gaosuxiaofeizhe];
//            [products removeObjectAtIndex:0];
//            NSLog(@"custome a product");
//            [lock unlockWithCondition:xiaofeizhejieshu_gaosushengchanzhe];
//        }
//    });
    
    
    
    
    
    
//    NSCondition *condition = [[NSCondition alloc] init];
//    
//    NSMutableArray *products = [NSMutableArray array];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        while (1) {
//            [condition lock];
//            if ([products count] == 0) {
//                NSLog(@"wait for product");
//                [condition wait];
//            }
//            [products removeObjectAtIndex:0];
//            NSLog(@"custome a product");
//            [condition unlock];
//        }
//        
//    });
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        while (1) {
//            [condition lock];
//            [products addObject:[[NSObject alloc] init]];
//            NSLog(@"produce a product,总量:%zi",products.count);
//            [condition signal];
//            [condition unlock];
//            sleep(1);
//        }
//        
//    });
    
    
    
    
//    __block pthread_mutex_t theLock;
//    pthread_mutex_init(&theLock, NULL);
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        int i = pthread_mutex_trylock(&theLock);
//        if (i != EBUSY) {
//            NSLog(@"需要线程同步的操作1 开始");
//            sleep(3);
//            NSLog(@"需要线程同步的操作1 结束");
//            pthread_mutex_unlock(&theLock);
//        }
//    });
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        sleep(1);
//        pthread_mutex_lock(&theLock);
//        NSLog(@"需要线程同步的操作2");
//        pthread_mutex_unlock(&theLock);
//        
//    });
    
    
    
    
    
    
//    __block pthread_mutex_t theLock;
//    //pthread_mutex_init(&theLock, NULL);
//    
//    pthread_mutexattr_t attr;
//    pthread_mutexattr_init(&attr);
//    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
//    pthread_mutex_init(&theLock, &attr);
//    pthread_mutexattr_destroy(&attr);
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        static void (^RecursiveMethod)(int);
//        
//        RecursiveMethod = ^(int value) {
//            
//            pthread_mutex_lock(&theLock);
//            if (value > 0) {
//                
//                NSLog(@"value = %d", value);
//                sleep(1);
//                RecursiveMethod(value - 1);
//            }
//            pthread_mutex_unlock(&theLock);
//        };
//        
//        RecursiveMethod(5);
//    });
    
    
    
    
    
#warning 不再安全
//    __block OSSpinLock theLock = OS_SPINLOCK_INIT;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        OSSpinLockLock(&theLock);
//        NSLog(@"需要线程同步的操作1 开始");
//        sleep(3);
//        NSLog(@"需要线程同步的操作1 结束");
//        OSSpinLockUnlock(&theLock);
//        
//    });
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        OSSpinLockLock(&theLock);
//        sleep(1);
//        NSLog(@"需要线程同步的操作2");
//        OSSpinLockUnlock(&theLock);
//    });
//    
//#warning OSSpinLock在iOS10中的替代品 貌似只能在swift中使用 oc中崩溃且有警告 ???
//#if 0
//    var theLock = os_unfair_lock()
//    DispatchQueue.global().async {
//        os_unfair_lock_lock(&theLock)
//        print("需要线程同步的操作1 开始")
//        sleep(3)
//        print("需要线程同步的操作1 结束")
//        os_unfair_lock_unlock(&theLock)
//    }
//    
//    DispatchQueue.global().async {
//        os_unfair_lock_lock(&theLock)
//        print("需要线程同步的操作2 开始")
//        sleep(1)
//        print("需要线程同步的操作2 结束")
//        os_unfair_lock_unlock(&theLock)
//    }
//#endif
    
    
    
    
    
    
    
    
}





@end
