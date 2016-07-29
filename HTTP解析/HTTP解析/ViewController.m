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
    
    NSString *urlStr = @"https://movie.douban.com/explore#!type=movie&tag=%E7%83%AD%E9%97%A8&sort=recommend&page_limit=20&page_start=0";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSData *htmlData = [NSData dataWithContentsOfURL:url];
    NSString *title = @"//*[@id='gaia_frm']/div[1]/div[1]/label[1]/input";
//    NSString *title = @"//div[@class='hd_B']/div[@class='Btitle']/a";
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements1 = [xpathParser searchWithXPathQuery:title];
    TFHppleElement *t = elements1[0];
    
    NSLog(@"%@", [elements1[0] objectForKey:@"activate"]);
    
}







@end
