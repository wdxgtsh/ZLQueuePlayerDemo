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
    self.playerVC.view.frame = CGRectMake(0, 140, PHONE_WIDTH, PHONE_WIDTH * 9 / 16);
    [self.view addSubview:self.playerVC.view];
    [self.playerVC createAVPlayerWithTitleItem:nil andNormalItem:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
