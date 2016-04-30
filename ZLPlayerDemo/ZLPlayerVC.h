//
//  ZLPlayerVC.h
//  ZLPlayerDemo
//
//  Created by zhaolei on 16/4/29.
//  Copyright © 2016年 zhaolei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class MyAVPlayerItem;

@interface ZLPlayerVC : UIViewController


- (void)createAVPlayerWithTitleItem:(MyAVPlayerItem *)titleItem  andNormalItem:(MyAVPlayerItem *)normalItem;

- (instancetype)initView;

@end
