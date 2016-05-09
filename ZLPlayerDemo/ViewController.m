//
//  ViewController.m
//  ZLPlayerDemo
//
//  Created by zhaolei on 16/4/29.
//  Copyright © 2016年 zhaolei. All rights reserved.
//

#import "ViewController.h"
#import "ZLPlayerVC.h"
#import "Common.h"



@interface ViewController ()

@property (nonatomic, strong) ZLPlayerVC * playerVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playerVC = [[ZLPlayerVC alloc] initView];
    self.playerVC.view.frame = CGRectMake(0, 20, PHONE_WIDTH, PHONE_WIDTH * 9 / 16);
    [self.view addSubview:self.playerVC.view];
    [self.playerVC createAVPlayerWithTitleItem:nil andNormalItem:nil];

    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark |-- deviceOrientationDidChange
//- (void)deviceOrientationDidChange{
//
//    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
//    switch (orientation) {
//        case UIDeviceOrientationPortrait:
//            self.playerVC.view.transform = CGAffineTransformMakeRotation(0);
//            self.playerVC.view.frame = CGRectMake(0, 0, PHONE_WIDTH,PHONE_WIDTH * 6 / 9);
//            break;
//        case UIDeviceOrientationLandscapeLeft:
//            self.playerVC.view.transform = CGAffineTransformMakeRotation(M_PI_2);
//            self.playerVC.view.frame = CGRectMake(0, 0, PHONE_WIDTH,PHONE_HEIGHT);
//            break;
//            
//        case UIDeviceOrientationLandscapeRight:
//            self.playerVC.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
//            self.playerVC.view.frame = CGRectMake(0, 0, PHONE_WIDTH,PHONE_HEIGHT);
//            break;
//        default:
//            break;
//    }
//    
//    
//    NSLog(@"self.view --- %zd --- > %@", orientation, NSStringFromCGRect(self.view.frame));
//    NSLog(@"playervc --- %zd --- > %@", orientation, NSStringFromCGRect(self.playerVC.view.frame));
//    NSLog(@"  %f    %f ", PHONE_WIDTH, PHONE_HEIGHT);
//    
//    
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
