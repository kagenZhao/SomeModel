//
//  DXRouterUrlHandler.m
//  Pods
//
//  Created by wangyang on 2016/9/29.
//
//

#import "DXRouterUrlHandler.h"
#import "DXRouter.h"

@interface DXRouterUrlHandler ()

@property (strong, nonatomic) NSMutableDictionary *registeredUrls;

@end

@implementation DXRouterUrlHandler
+ (DXRouterUrlHandler *)shared {
    static DXRouterUrlHandler *_shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shared = [DXRouterUrlHandler new];
    });
    return _shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.registeredUrls = [NSMutableDictionary new];
    }
    return self;
}

- (void)registerUrl:(NSString *)url forRouters:(NSArray *)routers {
    [self.registeredUrls setObject:routers forKey:url];
}

- (void)handleUrl:(NSURL *)url {
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    NSString *host = components.host;
    NSMutableDictionary *arguments = [NSMutableDictionary new];
    for (NSURLQueryItem *item in components.queryItems) {
        arguments[item.name] = item.value;
    }
    NSArray *routers = self.registeredUrls[host];
    if (routers) {
        [[DXRouter shared] navigateWithArguments:arguments fullRouter:routers];
    }
}
@end
