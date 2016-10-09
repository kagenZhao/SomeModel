//
//  EPMLogger.m
//  Pods
//
//  Created by wangyang on 16/7/19.
//
//

#import "EPMLogger.h"

#if DEBUG
    #define ddLogLevel DDLogLevelVerbose
#else
    #define ddLogLevel DDLogLevelInfo
#endif

@implementation EPMLogger

+ (void)setup
{
    [DDRemoteAccess configLogger];
}

+ (void)enableRemoteAccess
{
    [DDRemoteAccess enableRemoteAccessWithCompleteBlock:^(BOOL isSuccess, NSString *visitUrl) {
        NSLog(@"%@",visitUrl);
    }];
}

+ (void)enableCrashReport
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}

void uncaughtExceptionHandler(NSException *exception) {
    EPMLogError(@"CRASH: %@", exception);
    EPMLogError(@"Stack Trace: %@", [exception callStackSymbols]);
}
@end
