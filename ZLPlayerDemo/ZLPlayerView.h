//
//  ZLPlayerView.h
//  ZLPlayerDemo
//
//  Created by zhaolei on 16/4/30.
//  Copyright © 2016年 zhaolei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ZLPlayerView : UIView

@property (nonatomic, strong) AVQueuePlayer * player;

@property (nonatomic, readonly) AVPlayerLayer * playerLayer;

@end
