//
//  ViewController.m
//  HTTP解析
//
//  Created by zhaoguoqing on 16/4/9.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

#import "ViewController.h"

#import "TFHpple.h"


@interface ViewController ()
@property (nonatomic, strong) NSMutableDictionary *titleDic;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlStr = @"http://www.bttiantang.com/?PageNo=1";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSData *htmlData = [NSData dataWithContentsOfURL:url];
    NSString *title = @"//div[@class='hd_B']/div[@class='Btitle']/a";
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements1 = [xpathParser searchWithXPathQuery:title];
    NSLog(@"%@", [elements1[1] objectForKey:@"title"]);
    
}







@end
