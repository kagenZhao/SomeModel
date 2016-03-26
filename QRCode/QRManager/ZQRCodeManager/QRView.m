//
//  QRView.m
//  QRManager
//
//  Created by zhaoguoqing on 16/3/21.
//  Copyright © 2016年 赵国庆. All rights reserved.
//

#import "QRView.h"
#import <AVFoundation/AVFoundation.h>

#define Is_Up_iOS(a) ([[[UIDevice currentDevice] systemVersion] floatValue] >= a)

@interface QRView ()
<
AVCaptureMetadataOutputObjectsDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
>
@property (weak, nonatomic) IBOutlet UIButton *libraryBtn;

@property (weak, nonatomic     ) IBOutlet NSLayoutConstraint         *containerHeightConstraint;
@property (weak, nonatomic     ) IBOutlet NSLayoutConstraint         *scanLineTopConstraint;
@property (weak, nonatomic     ) IBOutlet UIImageView                *scanLineImageView;
@property (weak, nonatomic     ) IBOutlet UILabel                    *customLabel;
@property (weak, nonatomic     ) IBOutlet UIView                     *customContainerView;

@property ( strong , nonatomic ) AVCaptureDevice            * device;
@property ( strong , nonatomic ) AVCaptureDeviceInput       * input;
@property ( strong , nonatomic ) AVCaptureMetadataOutput    * output;
@property ( strong , nonatomic ) AVCaptureSession           * session;
@property ( strong , nonatomic ) AVCaptureVideoPreviewLayer * previewLayer;
@property ( strong , nonatomic ) CAShapeLayer               *maskLayer;

@end

@implementation QRView

- (void)setController:(UIViewController *)controller {
  _controller = controller;
  BOOL x = Is_Up_iOS(8);
  self.libraryBtn.hidden = !x;
  [self startScan];
}

- (AVCaptureDevice *)device
{
  if (_device == nil) {
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  }
  return _device;
}

- (AVCaptureDeviceInput *)input
{
  if (_input == nil) {
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
  }
  return _input;
}

- (AVCaptureSession *)session
{
  if (_session == nil) {
    _session = [[AVCaptureSession alloc] init];
  }
  return _session;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
  if (_previewLayer == nil) {
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
  }
  return _previewLayer;
}
- (CAShapeLayer *)maskLayer {
  if (_maskLayer == nil) {
    _maskLayer = [CAShapeLayer layer];
    _maskLayer.frame = self.bounds;
    _maskLayer.backgroundColor = [UIColor blackColor].CGColor;
  }
  return _maskLayer;
}

- (AVCaptureMetadataOutput *)output
{
  if (_output == nil) {
    _output = [[AVCaptureMetadataOutput alloc] init];
    CGRect viewRect = self.bounds;
    CGRect containerRect = CGRectMake(self.bounds.size.width / 2.0 - 150, self.bounds.size.height / 2.0 - 150, 300, 300);
    CGFloat x = containerRect.origin.y / viewRect.size.height;
    CGFloat y = containerRect.origin.x / viewRect.size.width;
    CGFloat width = containerRect.size.height / viewRect.size.height;
    CGFloat height = containerRect.size.width / viewRect.size.width;
    _output.rectOfInterest = CGRectMake(x, y, width, height);
  }
  return _output;
}

- (void)startScan
{
  if (![self.session canAddInput:self.input]) return;
  
  [self.session addInput:self.input];
  
  if (![self.session canAddOutput:self.output]) return;
  
  [self.session addOutput:self.output];
  
  self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
  
  [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
  
  [self.layer insertSublayer:self.previewLayer atIndex:0];
  
  self.previewLayer.frame = self.bounds;
  
  [self.layer insertSublayer:self.maskLayer above:self.previewLayer];
  
  [self.session startRunning];
}

#pragma mark --------AVCaptureMetadataOutputObjectsDelegate ---------
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
  AVMetadataMachineReadableCodeObject *object = [metadataObjects lastObject];
  if (object == nil) return;
  if (self.delegate && [self.delegate respondsToSelector:@selector(decodeMessage:)]) {
    [self.delegate decodeMessage:object.stringValue];
  }
  [self stopRunning];
}

- (void)stopRunning {
  self.maskLayer.backgroundColor = [UIColor blackColor].CGColor;
  [self.session stopRunning];
}

- (void)startRunning {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    self.maskLayer.backgroundColor = [UIColor clearColor].CGColor;
  });
  [self.session startRunning];
  [self startAnimation];
}

// 开启冲击波动画
- (void)startAnimation
{
  self.scanLineTopConstraint.constant = - self.containerHeightConstraint.constant;
  [self layoutIfNeeded];
  [UIView animateWithDuration:2.0 animations:^{
    [UIView setAnimationRepeatCount:MAXFLOAT];
    self.scanLineTopConstraint.constant = self.containerHeightConstraint.constant;
    [self layoutIfNeeded];
  } completion:nil];
}

- (IBAction)close:(id)sender {
  if (self.delegate && [self.delegate respondsToSelector:@selector(cancel)]) {
    [self.delegate cancel];
  }
}

- (IBAction)imagePicker:(id)sender {
  if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
  UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
  ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  ipc.delegate = self;
  [self.controller presentViewController:ipc animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
  UIImage *pickImage = info[UIImagePickerControllerOriginalImage];
  NSData *imageData = UIImagePNGRepresentation(pickImage);
  CIImage *ciImage = [CIImage imageWithData:imageData];
  CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
  NSArray *feature = [detector featuresInImage:ciImage];
  CIQRCodeFeature *result = feature.firstObject;
  [picker dismissViewControllerAnimated:YES completion:nil];
  if (self.delegate && [self.delegate respondsToSelector:@selector(decodeMessage:)]) {
    [self.delegate decodeMessage:result.messageString];
  }
}

@end
