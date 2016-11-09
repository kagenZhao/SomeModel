//
//  DXRouterUrlHandler.h
//  Pods
//
//  Created by wangyang on 2016/9/29.
//
//

#import <Foundation/Foundation.h>

@interface DXRouterUrlHandler : NSObject
+ (DXRouterUrlHandler *)shared;

- (void)registerUrl:(NSString *)url forRouters:(NSArray *)routers;
- (void)handleUrl:(NSURL *)url;
@end
