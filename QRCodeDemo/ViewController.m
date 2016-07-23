//
//  ViewController.m
//  QRCodeDemo
//
//  Created by KinkaidLau on 16/7/23.
//  Copyright © 2016年 KinkaidLau. All rights reserved.
//

#import "ViewController.h"
#import "QRCodeViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *QRScanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    QRScanButton.frame = CGRectMake(100, 100, 60, 60);
    [QRScanButton addTarget:self action:@selector(pushQRCodeViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:QRScanButton];
    [QRScanButton setTitle:@"扫描" forState:UIControlStateNormal];
    QRScanButton.backgroundColor = [UIColor redColor];
    [QRScanButton setTintColor:[UIColor whiteColor]];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)pushQRCodeViewController {
    [self.navigationController pushViewController:[[QRCodeViewController alloc]init] animated:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
