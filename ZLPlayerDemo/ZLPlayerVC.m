//
//  ZLPlayerVC.m
//  ZLPlayerDemo
//
//  Created by zhaolei on 16/4/29.
//  Copyright © 2016年 zhaolei. All rights reserved.
//

#import "ZLPlayerVC.h"
#import "Masonry.h"
#import "Common.h"
#import "MyAVPlayerItem.h"

// 竖屏 bar的高度
#define TopBarH_N 30
#define BottomBarH_N 35

// 横屏 bar的高度
#define TopBarH_H 34
#define BottomBarH_H 50

// 播放 全屏按钮的大小  横屏
#define Button_Width 35

//切换视频方向的动画时间
#define Video_Animation_Duration 0.3

#define ToolView_Show_Time 10

#define ToolView_Hidden_duration 1



@interface ZLPlayerVC ()

//topView  bottomView
@property (nonatomic, strong) UIView * topView;

@property (nonatomic, strong) UIView * bottomView;

//播放按钮   全屏按钮
@property (nonatomic, strong) UIButton * playBtn;

@property (nonatomic, strong) UIButton * fullScreenBtn;;

//当前时间  剩余时间
@property (nonatomic, strong) UILabel * currentTimeLabel;

@property (nonatomic, strong) UILabel * remainTimeLabel;

//缓冲条  进度条
@property (nonatomic, strong) UIProgressView * videoProgressView;
@property (nonatomic, strong) UISlider * videoSlider;

//视频标题
@property (nonatomic, strong) UILabel * videoTitleLabel;

//下载 收藏  分享
@property (nonatomic, strong) UIButton * downloadBtn;
@property (nonatomic, strong) UIButton * collectionBtn;
@property (nonatomic, strong) UIButton * shareButton;

@property (nonatomic, assign) UIDeviceOrientation currentOrientation;


@property (nonatomic, strong) AVQueuePlayer * queuePlayer;

@property (nonatomic, strong) AVPlayerItem * adPlayerItem;
@property (nonatomic, strong) AVPlayerItem * normalPlayerItem;

@property (nonatomic, strong) AVPlayerLayer * playLayer;

@property (nonatomic, assign) NSInteger movieLength;

@property (nonatomic, strong) id timeObserver;

@end

@implementation ZLPlayerVC


- (instancetype)initView{
    self = [super init];
    if (self) {
        [self loadBottomBar];
        [self loadTopbar];
        [self addNoti];
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}


#pragma mark |-- add Noti
- (void)addNoti{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}


#pragma mark |-- load View
- (void)loadTopbar{
    self.topView = ({
        UIView * view = [[UIView alloc] init];
        view.backgroundColor = [UIColor yellowColor];
        view.hidden = YES;
        [self.view addSubview:view];
        view.userInteractionEnabled = YES;
        view.frame = CGRectMake(0, 0, PHONE_WIDTH, TopBarH_N);
        view;
    });
    
    self.shareButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [self.topView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.top.bottom.equalTo(self.topView);
            make.width.equalTo(@Button_Width);
        }];
        button;
    });
    
    self.downloadBtn = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"download"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"download_white"] forState:UIControlStateSelected];
        [self.topView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.topView);
            make.trailing.equalTo(self.shareButton.mas_leading);
            make.width.equalTo(@Button_Width);
        }];
        button;
    });
    
    self.collectionBtn = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"collection"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"heart_white"] forState:UIControlStateSelected];
        [self.topView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.topView);
            make.trailing.equalTo(self.downloadBtn.mas_leading);
            make.width.equalTo(@Button_Width);
        }];
        button;

    });
    
    self.videoTitleLabel = ({
        UILabel * label = [[UILabel alloc] init];
        label.text = @"视频标题";
        label.backgroundColor = [UIColor greenColor];
        [self.topView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.collectionBtn.mas_leading);
            make.centerY.equalTo(self.topView.mas_centerY);
            make.leading.equalTo(self.topView.mas_leading);
        }];
        label;
    });
    
}

- (void)loadBottomBar{
    self.bottomView = ({
        UIView * view = [[UIView alloc] init];
        view.backgroundColor = [UIColor purpleColor];
        [self.view addSubview:view];
        view.frame = CGRectMake(0, PHONE_WIDTH * 9 / 16 - BottomBarH_N, PHONE_WIDTH, BottomBarH_N);
        view.userInteractionEnabled = YES;
        view;
    });
    
    
    
    self.playBtn = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(playButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.bottom.equalTo(self.bottomView);
            make.width.equalTo(@Button_Width);
        }];
        button;
    });
    
    
    self.fullScreenBtn = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateSelected];
        [self.bottomView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.top.bottom.equalTo(self.bottomView);
            make.width.equalTo(@Button_Width);
        }];
        button;
    });
    
    self.currentTimeLabel = ({
        UILabel * label = [[UILabel alloc] init];
        label.text = @"00:00";
        label.backgroundColor = [UIColor greenColor];
        [self.bottomView addSubview:label];
        [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.playBtn.mas_trailing);
            make.centerY.equalTo(self.bottomView.mas_centerY);
        }];
        label;
    });
    
    
    self.remainTimeLabel= ({
        UILabel * label = [[UILabel alloc] init];
        label.text = @"00:00";
        label.backgroundColor = [UIColor greenColor];
        [self.bottomView addSubview:label];
        [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self.fullScreenBtn.mas_leading);
            make.centerY.equalTo(self.bottomView.mas_centerY);
        }];
        label;
    });

    self.videoProgressView = ({
        UIProgressView * progressView = [[UIProgressView alloc] init];
        progressView.trackTintColor = [UIColor colorWithRed:0.49f green:0.48f blue:0.49f alpha:1.00f];
        progressView.progressTintColor = [UIColor whiteColor];
        [self.bottomView addSubview:progressView];
        [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.currentTimeLabel.mas_trailing);
            make.trailing.equalTo(self.remainTimeLabel.mas_leading);
            make.centerY.equalTo(self.bottomView.mas_centerY);
        }];
        progressView;
    });
    
    self.videoSlider = ({
        UISlider * slider = [[UISlider alloc] init];
        slider.enabled = YES;
        [slider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
        
        UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
        UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [slider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
        [slider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
        [slider setMinimumTrackTintColor:[UIColor colorWithRed:248/255.0f green:156/255.0f blue:82/255.0f alpha:1.00f]];
        [slider setMaximumTrackTintColor:[UIColor colorWithRed:0.49f green:0.48f blue:0.49f alpha:1.00f]];
        [slider setThumbImage:[UIImage imageNamed:@"thumbImage"] forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(scrubbingDidBegin) forControlEvents:UIControlEventTouchDown];
        [slider addTarget:self action:@selector(scrubbingDidChange) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(scrubbingDidEnd) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchCancel)];
        [self.bottomView addSubview:slider];
        [slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.videoProgressView);
            make.top.bottom.equalTo(self.bottomView);
        }];
        slider;
    });
    
    
}

#pragma mark |-- deviceOrientationDidChange
- (void)deviceOrientationDidChange:(NSNotification *)noti{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    [self roationViewWithOrientation:orientation];
}

- (void)roationViewWithOrientation:(UIDeviceOrientation)orientation{
    if (orientation == _currentOrientation) {
        return;
    }
    _currentOrientation = orientation;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:{
            //显示 bottomView
            [self showTopAndBottomView];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            [UIView animateWithDuration:Video_Animation_Duration animations:^{
                self.view.transform = CGAffineTransformMakeRotation(0);
                self.view.frame = CGRectMake(0, 0, PHONE_WIDTH,PHONE_WIDTH * 9 / 16);
                self.bottomView.frame = CGRectMake(0, PHONE_WIDTH * 9 / 16 - BottomBarH_N, PHONE_WIDTH, BottomBarH_N);
                self.topView.frame = CGRectMake(0, 0, PHONE_WIDTH, TopBarH_N);
                if (_playLayer) {
                    _playLayer.frame = CGRectMake(0, 0, PHONE_WIDTH,PHONE_WIDTH * 9 / 16);
                }
            } completion:^(BOOL finished) {
                
            }];
        }
            
            break;
        case UIDeviceOrientationLandscapeLeft:{
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            //显示 bottomView  和  topView
            [self showTopAndBottomView];
            [UIView animateWithDuration:Video_Animation_Duration animations:^{
                self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                self.view.frame = CGRectMake(0, 0, PHONE_WIDTH,PHONE_HEIGHT);
                self.bottomView.frame = CGRectMake(0, PHONE_WIDTH - BottomBarH_H, PHONE_HEIGHT, BottomBarH_H);
                self.topView.frame = CGRectMake(0, 0, PHONE_HEIGHT, TopBarH_H);
                if (_playLayer) {
                    _playLayer.frame = CGRectMake(0, -PHONE_WIDTH/2 + BottomBarH_N, PHONE_HEIGHT,PHONE_HEIGHT);
                }
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
            
        case UIDeviceOrientationLandscapeRight:{
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            //显示 bottomView  和  topView
            [self showTopAndBottomView];
            [UIView animateWithDuration:Video_Animation_Duration animations:^{
                self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
                self.view.frame = CGRectMake(0, 0, PHONE_WIDTH,PHONE_HEIGHT);
                
                self.bottomView.frame = CGRectMake(0, PHONE_WIDTH - BottomBarH_H, PHONE_HEIGHT, BottomBarH_H);
                self.topView.frame = CGRectMake(0, 0, PHONE_HEIGHT, TopBarH_H);
                if (_playLayer) {
                    _playLayer.frame = CGRectMake(0, 0, PHONE_WIDTH,PHONE_HEIGHT);
                }

            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        default:
            break;
    }

    
    NSLog(@"frame  ---->  %@   %@ ", NSStringFromCGRect(_playLayer.frame), NSStringFromCGRect(_playLayer.bounds));
    
}

#pragma mark |---- touchBegin  touchMoved  touchEnd
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.bottomView.hidden) {
        [self showTopAndBottomView];
    }else{
        [self hiddenTopAndBottomView];
    }
}

#pragma mark |---- sliderAction
- (void)scrubbingDidBegin{
    NSLog(@"%s", __func__);
}

- (void)scrubbingDidChange{
    NSLog(@"%s", __func__);
}

- (void)scrubbingDidEnd{
    NSLog(@"%s", __func__);
}

- (void)hiddenTopAndBottomView{
//    [UIView animateWithDuration:ToolView_Hidden_duration animations:^{
//        self.topView.hidden = self.bottomView.hidden = YES;
//    }];
}

- (void)showTopAndBottomView{
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setHidden:) object:[NSNumber numberWithBool:YES]];//可以取消成功。
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [UIView animateWithDuration:ToolView_Hidden_duration animations:^{
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
            self.topView.hidden = NO;
        }else{
            self.topView.hidden = YES;
        }
         self.bottomView.hidden = NO;
    }];
    [self.topView performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:ToolView_Show_Time];
    [self.bottomView performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:ToolView_Show_Time];
}




#pragma mark |---- load AVQueuePlayer

- (void)createAVPlayerWithTitleItem:(MyAVPlayerItem *)titleItem andNormalItem:(MyAVPlayerItem *)normalItem{
//    // Set AVAudioSession
//    NSError *sessionError = nil;
//    [[AVAudioSession sharedInstance] setDelegate:self];
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
//    
//    // Change the default output audio route
//    UInt32 doChangeDefaultRoute = 1;
//    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];

//    MyAVPlayerItem * item1 = [[MyAVPlayerItem alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"2" withExtension:@"mp4"]];
//    item1.type = 1;
//    
//    MyAVPlayerItem * item2 = [[MyAVPlayerItem alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"2" withExtension:@"mp4"]];
//    item2.type = 2;
    
    
     self.adPlayerItem = [[MyAVPlayerItem alloc] initWithURL:[NSURL URLWithString:@"http://mvideo.spriteapp.cn/video/2016/0228/56d2865c3865b_wpd.mp4"]];
     self.normalPlayerItem = [[MyAVPlayerItem alloc] initWithURL:[NSURL URLWithString:@"http://mvideo.spriteapp.cn/video/2016/0427/92710204-0c7f-11e6-be8e-d4ae5296039dcut_wpc.mp4"]];
    
    
    _queuePlayer = [[AVQueuePlayer alloc] initWithItems:@[self.adPlayerItem, self.normalPlayerItem]];
    _queuePlayer.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
    
    _playLayer = [AVPlayerLayer playerLayerWithPlayer:_queuePlayer];
    _playLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    _playLayer.frame = self.view.bounds;

//    _playLayer.anchorPoint = CGPointMake(0, 0);
    [self.view.layer addSublayer:_playLayer];
    
    [self.view bringSubviewToFront:self.topView];
    [self.view bringSubviewToFront:self.bottomView];
    
    [_queuePlayer addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:nil];
    

    [self.adPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    void (^observerBlock)(CMTime time) = ^(CMTime time){
        NSString *timeString = [NSString stringWithFormat:@"%02.2f", (float)time.value / (float)time.timescale];
        NSString * remainTime = [NSString stringWithFormat:@"%02.2f", (float) _movieLength - (float)time.value / (float)time.timescale];
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            self.currentTimeLabel.text = timeString;
            self.remainTimeLabel.text = remainTime;
        } else {
            NSLog(@"App is backgrounded. Time is: %@", timeString);
        }
    };
    
    self.timeObserver = [_queuePlayer addPeriodicTimeObserverForInterval:CMTimeMake(10, 1000)
                                                                   queue:dispatch_get_main_queue()
                                                              usingBlock:observerBlock];
    //监听视频播放结束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification{
    
    
    MyAVPlayerItem * item = (MyAVPlayerItem *)_queuePlayer.currentItem;
    NSLog(@"before ---->   %@", _queuePlayer.items);
    
    if (item.type == 1){
        [_queuePlayer advanceToNextItem];
    }
    
    
    if (item == self.normalPlayerItem) {
        [_queuePlayer seekToTime:kCMTimeZero];
    }

    NSLog(@"before ---->   %@", _queuePlayer.items);
}

#pragma mark |---- observeValueForKeyPath
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"currentItem"]) {
        MyAVPlayerItem *item = (MyAVPlayerItem*)((AVPlayer *)object).currentItem;
        if (item.type == 1) {
            NSLog(@"-------------------片头");
        }else if(item == self.normalPlayerItem){
            _movieLength = (item.asset.duration.value / item.asset.duration.timescale);
        }
    }
    else if([keyPath isEqualToString:@"status"]){
        MyAVPlayerItem *playerItem = (MyAVPlayerItem*)object;
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            [_queuePlayer play];
            if (_queuePlayer.currentItem == self.adPlayerItem) {
                [self.adPlayerItem removeObserver:self forKeyPath:@"status"];
            }
        }
    }
}

- (void)playButtonClicked:(UIButton *)button{
    if (_queuePlayer) {
        [self createAVPlayerWithTitleItem:nil andNormalItem:nil];
    }
}

@end
