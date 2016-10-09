//
//  EPMLogger.h
//  Pods
//
//  Created by wangyang on 16/7/19.
//
//

#import <Foundation/Foundation.h>
#import "DDRemoteAccess.h"

#define DRStrMerge(str1,str2) [str1 stringByAppendingString:str2]
#define CurrentClsName  NSStringFromClass(self.class)
//使用时请定义宏
//TEST : #define ddLogLevel DDLogLevelVerbose
//Product: #define ddLogLevel DDLogLevelInfo
//为不同Level的log加上输出前缀
#define EPMLogError(fmt, ...) DDLogError(DRStrMerge(@"<<%@>> ",fmt),@"ERROR",##__VA_ARGS__)
#define EPMLogWarn(fmt, ...) DDLogWarn(DRStrMerge(@"<<%@>> ",fmt),@"WARN",##__VA_ARGS__)
#define EPMLogInfo(fmt, ...) DDLogInfo(DRStrMerge(@"<<%@>> ",fmt),@"INFO",##__VA_ARGS__)
#define EPMLogDBG(fmt, ...) DDLogDebug(DRStrMerge(@"<<%@>> ",fmt),@"DBG",##__VA_ARGS__)

//如果在OC的类中，使用C后缀的宏会自动记录当前的ClassName
#define EPMLogErrorC(fmt, ...) DDLogError(DRStrMerge(@"<<%@>> %@ => ",fmt),@"ERROR",CurrentClsName,##__VA_ARGS__)
#define EPMLogWarnC(fmt, ...) DDLogWarn(DRStrMerge(@"<<%@>> %@ => ",fmt),@"WARN",CurrentClsName, ##__VA_ARGS__)
#define EPMLogInfoC(fmt, ...) DDLogInfo(DRStrMerge(@"<<%@>> %@ => ",fmt),@"INFO",CurrentClsName, ##__VA_ARGS__)
#define EPMLogDBGC(fmt, ...) DDLogDebug(DRStrMerge(@"<<%@>> %@ => ",fmt),@"DBG",CurrentClsName, ##__VA_ARGS__)


@interface EPMLogger : NSObject
+ (void)setup;
+ (void)enableRemoteAccess;
+ (void)enableCrashReport;
@end
