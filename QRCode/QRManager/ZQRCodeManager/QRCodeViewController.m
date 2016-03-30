//
//  ViewController.m
//  QRManager
//
//  Created by zhaoguoqing on 16/3/21.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

#import "QRCodeViewController.h"
#import "QRView.h"
@interface QRCodeViewController ()<QRViewDelegate>
@property (nonatomic, strong) QRView *qrView;
@end

@implementation QRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.qrView = [[NSBundle mainBundle] loadNibNamed:@"QRView" owner:nil options:nil].firstObject;
    self.qrView.frame = self.view.bounds;
    [self.qrView setNeedsLayout];
    self.qrView.controller = self;
    self.qrView.delegate = self;
    [self.view addSubview:_qrView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    NSLog(@"aa");
}

- (void)decodeMessage:(NSString *)message {
    if (self.qrDelegate && [self.qrDelegate respondsToSelector:@selector(decodeWithMessage:QRcontroller:)]) {
        [self.qrDelegate decodeWithMessage:message QRcontroller:self];
    } else if (self.decodeBlock) {
        self.decodeBlock(message, self);
    }
}
- (void)cancel {
    if (self.qrDelegate && [self.qrDelegate respondsToSelector:@selector(cancelWithContrller:)]) {
        [self.qrDelegate cancelWithContrller:self];
    } else if (self.cancelBlock) {
        self.cancelBlock(self);
    }
}

//注意，在界面消失的时候关闭session
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.qrView stopRunning];
}

// 界面显示,开始动画
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.qrView startRunning];
}

- (void)becomeActive {
    [self.qrView startRunning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
