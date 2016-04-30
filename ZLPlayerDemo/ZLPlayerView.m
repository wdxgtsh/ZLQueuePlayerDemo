//
//  ZLPlayerView.m
//  ZLPlayerDemo
//
//  Created by zhaolei on 16/4/30.
//  Copyright © 2016年 zhaolei. All rights reserved.
//

#import "ZLPlayerView.h"

@implementation ZLPlayerView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

+ (Class)layerClass{
    return [AVPlayerLayer class];
}

- (AVQueuePlayer *)queuePlayer{
    return (AVQueuePlayer *)[(AVPlayerLayer *)[self layer] player];
}


- (void)setPlayer:(AVQueuePlayer *)queuePlayer{
    [(AVPlayerLayer *)[self layer] setPlayer:queuePlayer];
}

- (AVPlayerLayer *)playerLayer{
    return (AVPlayerLayer *)self.layer;
}

@end
