//
//  QRCodeViewController.m
//  QRCodeDemo
//
//  Created by KinkaidLau on 16/7/23.
//  Copyright © 2016年 KinkaidLau. All rights reserved.
//

#import "QRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

#define Height [UIScreen mainScreen].bounds.size.height
#define Width [UIScreen mainScreen].bounds.size.width
#define QRBorderWidth self.view.frame.size.width*2/3

@interface QRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>

@property (strong,nonatomic) AVCaptureDevice *device;

@property (strong,nonatomic) AVCaptureDeviceInput *input;

@property (strong,nonatomic) AVCaptureMetadataOutput *output;

@property (strong,nonatomic) AVCaptureSession *session;

@property (strong,nonatomic) AVCaptureVideoPreviewLayer *preview;

@property (nonatomic, strong) UIImageView *qrBorderImageView;

@property (nonatomic, strong) UIImageView *lineImageView;

@property (nonatomic, assign)  NSInteger linePositionChangeNum;

@property (nonatomic, assign) BOOL upOrdown;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation QRCodeViewController
#pragma mark -Accessor
- (AVCaptureMetadataOutput *)output {
    if (!_output) {
        _output  = [[AVCaptureMetadataOutput alloc] init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [_output setRectOfInterest:CGRectMake((Height-QRBorderWidth)/2/Height,
                                              (Width-QRBorderWidth)/2.0/Width,
                                              QRBorderWidth/Height,
                                              QRBorderWidth/Width)];
    }
    return _output;
}

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    return _session;
}

- (UIImageView *)qrBorderImageView {
    if (!_qrBorderImageView) {
        _qrBorderImageView = [[UIImageView alloc]initWithFrame:CGRectMake((Width-QRBorderWidth)/2, (Height-QRBorderWidth)/2, QRBorderWidth, QRBorderWidth)];
        _qrBorderImageView.image = [UIImage imageNamed:@"qrcode_border"];
    }
    return _qrBorderImageView;
}
- (UIImageView *)lineImageView {
    if (!_lineImageView) {
        _lineImageView =  [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(_qrBorderImageView.frame)+5, CGRectGetMinY(_qrBorderImageView.frame)+5, CGRectGetWidth(_qrBorderImageView.frame)-10,1)];
        _lineImageView.image = [UIImage imageNamed:@"line"];
    }
    return _lineImageView;
}
- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    }
    return _timer;
}
#pragma mark -life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫一扫";
    [self.view addSubview:self.qrBorderImageView];
    [self.view addSubview:self.lineImageView];
    _upOrdown = NO;
    _linePositionChangeNum =0;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status != AVAuthorizationStatusAuthorized) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"该设备暂时无权限访问相机" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    } else {
        [self setupCamera];
    }
}
- (void)setupCamera {
    [self.timer setFireDate:[NSDate distantPast]];
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (error) {//检测输入是否有错误
        NSLog(@"-----%@---",error);
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.output]) {
        [self.session addOutput:self.output];
    }
    // authorized
    _output.metadataObjectTypes = @[
                                    AVMetadataObjectTypeQRCode,
                                    AVMetadataObjectTypeEAN13Code,
                                    AVMetadataObjectTypeEAN8Code,
                                    AVMetadataObjectTypeCode128Code];
    self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    [self.view bringSubviewToFront:self.qrBorderImageView];
    [self setOverView];
    [self.session startRunning];
    
}
-(void)animation1
{
    if (self.upOrdown == NO) {
        self.linePositionChangeNum ++;
        _lineImageView.frame = CGRectMake(CGRectGetMinX(_qrBorderImageView.frame)+5,
                                          CGRectGetMinY(_qrBorderImageView.frame)+5+2*self.linePositionChangeNum,
                                          _qrBorderImageView.frame.size.width-10,
                                          1);
        if (self.linePositionChangeNum ==(int)(( _qrBorderImageView.frame.size.width-10)/2)) {
            self.upOrdown = YES;
        }
    } else {
        self.linePositionChangeNum --;
        _lineImageView.frame =CGRectMake(CGRectGetMinX(_qrBorderImageView.frame)+5,
                                         CGRectGetMinY(_qrBorderImageView.frame)+5+2*self.linePositionChangeNum,
                                         _qrBorderImageView.frame.size.width-10,
                                         1);
        if (self.linePositionChangeNum == 0) {
            self.upOrdown = NO;
        }
    }
}
#pragma mark - 添加模糊效果
- (void)setOverView {
    [self creatView:CGRectMake(0,
                               0,
                               Width,
                               (Height-QRBorderWidth) / 2)];
    [self creatView:CGRectMake(0,
                               (Height-QRBorderWidth) / 2,
                               (Width-QRBorderWidth) / 2,
                               QRBorderWidth)];
    [self creatView:CGRectMake(Width - (Width-QRBorderWidth) / 2,
                               (Height-QRBorderWidth) / 2,
                               (Width-QRBorderWidth) / 2,
                               QRBorderWidth)];
    [self creatView:CGRectMake(0,
                               Height-(Height-QRBorderWidth) / 2,
                               Width,
                               (Height-QRBorderWidth) / 2)];
}

- (void)creatView:(CGRect)rect {
    UIView *view = [[UIView alloc]initWithFrame:rect];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor blackColor];
    view.alpha = 0.8;
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection {
    if ([metadataObjects count]) {
        //停止扫描
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects firstObject];
        NSLog(@" %@", metadataObject.stringValue);
        // 获取到二维码的数据之后的后续操作
        [_timer setFireDate:[NSDate distantFuture]];
        [_timer invalidate];
        _timer = nil;
        [NSThread sleepForTimeInterval:0.5];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

