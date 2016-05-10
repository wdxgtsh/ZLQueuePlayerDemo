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
#import "ZLPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>

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

// 当前时间与剩余时间的 lable的宽度
#define TimeLabel_W 70

//滑动的有效距离
#define kValueUseful                5
// 音量 +/-
#define kVolumeStep                 0.02f
// 亮度 +/-
#define kBrightnessStep             0.02f
//屏幕亮度View 的宽度
#define kBrightnessViewWidth        125


typedef NS_ENUM(NSInteger, GestureType){
    GestureTypeOfNone = 0,
    GestureTypeOfVolume,
    GestureTypeOfBrightness,
    GestureTypeOfProgress,
};



@interface ZLPlayerVC ()
//手势类型
@property (nonatomic,assign)GestureType gestureType;

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

//倒计时label
@property (nonatomic, strong) UILabel * countDownLabel;

@property (nonatomic, assign) UIDeviceOrientation currentOrientation;

@property (nonatomic, strong) AVPlayerItem * adPlayerItem;
@property (nonatomic, strong) AVPlayerItem * normalPlayerItem;

@property (nonatomic, strong) AVPlayerLayer * playLayer;

@property (nonatomic, assign) NSInteger videoTotalTime;

@property (nonatomic, strong) id timeObserver;

@property (nonatomic, strong) ZLPlayerView * playerView;

@property (nonatomic, weak) AVQueuePlayer * avQueuePlayer;

//是否是ad
@property (nonatomic, assign) BOOL isNormalVideoPlayer;

//锁定
@property (nonatomic, strong) UIControl * lockButton;

//是否锁定
@property (nonatomic, assign) BOOL isOriationLocked;

//手势起点
@property (nonatomic ,assign) CGPoint  startPoint;

//是否全屏
@property (nonatomic ,assign) BOOL isFullScreen;
//. 屏幕亮度
@property (nonatomic,strong) UIImageView * brightnessView;
@property (nonatomic,strong) UIProgressView * brightnessProgress;


@property (nonatomic, strong) UIImageView * coverImageView;

@end

@implementation ZLPlayerVC


- (instancetype)initView{
    self = [super init];
    if (self) {
            }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self loadTopbar];
    [self loadBottomBar];
    [self loadCountDownLabel];
    [self addNoti];
    [self loadLockButton];
    [self loadBrightnessView];
    [self loadCoverImageView];

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
        view.hidden = YES;
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
        view.hidden = YES;
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
        label.textAlignment = NSTextAlignmentRight;
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.playBtn.mas_trailing);
            make.centerY.equalTo(self.bottomView.mas_centerY);
            make.width.equalTo(@TimeLabel_W);
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
            make.width.equalTo(@TimeLabel_W);
        }];
        label;
    });

    self.videoProgressView = ({
        UIProgressView * progressView = [[UIProgressView alloc] init];
        progressView.trackTintColor = [UIColor colorWithRed:0.49f green:0.48f blue:0.49f alpha:1.00f];
        progressView.progressTintColor = [UIColor whiteColor];
        [self.bottomView addSubview:progressView];
        [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.currentTimeLabel.mas_trailing).offset(5);
            make.trailing.equalTo(self.remainTimeLabel.mas_leading).offset(-5);
            make.centerY.equalTo(self.bottomView.mas_centerY);
        }];
        progressView;
    });
    
    self.videoSlider = ({
        UISlider * slider = [[UISlider alloc] init];
        slider.enabled = NO;
        [slider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
        slider.value = 0;
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
        [slider addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
        [self.bottomView addSubview:slider];
        [slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.videoProgressView);
            make.top.bottom.equalTo(self.bottomView);
        }];
        slider;
    });
    
    
}
- (void)loadCountDownLabel{
    self.countDownLabel = ({
        UILabel * label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(20);
            make.trailing.equalTo(self.view.mas_trailing).offset(-20);
        }];
        label;
    });
}
- (void)loadLockButton{
    self.lockButton = ({
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        _lockButton.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.4f];
        [button setImage:[UIImage imageNamed:@"lock_open"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"lock_close"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(lockButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 44/2;
        button.layer.masksToBounds = YES;
        button.hidden = YES;
        button.backgroundColor = [UIColor redColor];
        [self.view addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.view.mas_leading).offset(30);
            make.width.height.equalTo(@44);
            make.centerY.equalTo(self.view.mas_centerY);
        }];
        button;
    });
    [self.view bringSubviewToFront:self.lockButton];
}
- (void)loadBrightnessView{
    _brightnessView = ({
        UIImageView * imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"Video_brightness_bg.png"];
        imageView.alpha = 0;
        [self.view addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.centerY.equalTo(self.view.mas_centerY);
        }];
        
        
        imageView;
    });
    
    _brightnessProgress = ({
        UIProgressView * progressView = [[UIProgressView alloc] init];
        progressView.trackImage = [UIImage imageNamed:@"Video_num_bg.png"];
        progressView.progressImage = [UIImage imageNamed:@"Video_num_front.png"];
        progressView.progress = [UIScreen mainScreen].brightness;
        [_brightnessView addSubview:progressView];
        [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_brightnessView.mas_centerX);
            make.width.equalTo(@80);
            make.bottom.equalTo(_brightnessView.mas_bottom).offset(-20);
            make.height.equalTo(@2);
        }];
        progressView;
    });
}
- (void)loadCoverImageView{
    self.coverImageView = ({
        UIImageView * imageView = [[UIImageView alloc] init];
        [self.view addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.width.height.equalTo(self.view);
        }];
        
        imageView.backgroundColor = [UIColor redColor];
        imageView;
    });
}

#pragma mark |-- deviceOrientationDidChange
- (void)deviceOrientationDidChange:(NSNotification *)noti{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    [self roationViewWithOrientation:orientation];
}

- (void)roationViewWithOrientation:(UIDeviceOrientation)orientation{
    if (orientation == _currentOrientation || _isOriationLocked) {
        return;
    }
    _currentOrientation = orientation;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:{
            //是否全屏
            _isFullScreen = NO;
            //隐藏锁定按钮
            self.lockButton.hidden = YES;
            //显示 bottomView
            [self showTopAndBottomView];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
            [UIView animateWithDuration:Video_Animation_Duration animations:^{
                self.view.transform = CGAffineTransformMakeRotation(0);
                self.view.frame = CGRectMake(0, 0, PHONE_WIDTH,PHONE_WIDTH * 9 / 16);
                self.bottomView.frame = CGRectMake(0, PHONE_WIDTH * 9 / 16 - BottomBarH_N, PHONE_WIDTH, BottomBarH_N);
                self.topView.frame = CGRectMake(0, 0, PHONE_WIDTH, TopBarH_N);
                self.playerView.frame = self.view.bounds;
            } completion:^(BOOL finished) {
                
            }];
        }
            
            break;
        case UIDeviceOrientationLandscapeLeft:{
            _isFullScreen = YES;
            self.lockButton.hidden = NO;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            //显示 bottomView  和  topView
            [self showTopAndBottomView];
            [UIView animateWithDuration:Video_Animation_Duration animations:^{
                self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
                self.view.frame = CGRectMake(0, 0, PHONE_WIDTH,PHONE_HEIGHT);
                self.bottomView.frame = CGRectMake(0, PHONE_WIDTH - BottomBarH_H, PHONE_HEIGHT, BottomBarH_H);
                self.topView.frame = CGRectMake(0, 0, PHONE_HEIGHT, TopBarH_H);
                self.playerView.frame = self.view.bounds;
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
            
        case UIDeviceOrientationLandscapeRight:{
            _isFullScreen = YES;
            self.lockButton.hidden = NO;
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            //显示 bottomView  和  topView
            [self showTopAndBottomView];
            [UIView animateWithDuration:Video_Animation_Duration animations:^{
                self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
                self.view.frame = CGRectMake(0, 0, PHONE_WIDTH,PHONE_HEIGHT);
                
                self.bottomView.frame = CGRectMake(0, PHONE_WIDTH - BottomBarH_H, PHONE_HEIGHT, BottomBarH_H);
                self.topView.frame = CGRectMake(0, 0, PHONE_HEIGHT, TopBarH_H);
                self.playerView.frame = self.view.bounds;
            } completion:^(BOOL finished) {
                
            }];
        }
            break;
        default:
            break;
    }

}

#pragma mark |---- touchBegin  touchMoved  touchEnd
#pragma mark
#pragma mark - touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _startPoint = CGPointZero;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self.view];
    CGFloat offset_x = currentLocation.x - _startPoint.x;
    CGFloat offset_y = currentLocation.y - _startPoint.y;
    
    if (CGPointEqualToPoint(_startPoint,CGPointZero))
    {
        _startPoint = currentLocation;
        return;
    }
    _startPoint = currentLocation;
    
    if (_gestureType == GestureTypeOfNone)
    {
        // 横向 右侧 调整音量
        if ((currentLocation.x > self.view.frame.size.width * 0.5) &&
            (ABS(offset_x) <  ABS(offset_y)) &&
            _isFullScreen == YES)
        {
            _gestureType = GestureTypeOfVolume;
        }
        // 横向 左侧 调整音量
        else if ((currentLocation.x < self.view.frame.size.width*0.5) &&
                 (ABS(offset_x) <= ABS(offset_y)) &&
                 _isFullScreen == YES)
        {
            _gestureType = GestureTypeOfBrightness;
        }
        else if ((ABS(offset_x) > ABS(offset_y)))
        {
            _gestureType = GestureTypeOfProgress;
        }
    }
    if ((_gestureType == GestureTypeOfProgress) && (ABS(offset_x) > ABS(offset_y)))
    {
        if(_videoSlider.enabled == NO)
        {
            return;
        }
        
        
        if (offset_x > 0)
        {
            // debugLog(@"横向向右");
            _videoSlider.value += 0.005;
        }
        else
        {
            // debugLog(@"横向向左");
            _videoSlider.value -= 0.005;
        }
        
        NSLog(@"1----------> ", _videoSlider.value);
    }
    else if ((_gestureType == GestureTypeOfVolume) &&
             (currentLocation.x > self.view.frame.size.width*0.5) &&
             (ABS(offset_x) <= ABS(offset_y)) &&
             _isFullScreen == YES)
    {
        
        if (offset_y > kValueUseful )
        {
            [self volumeAdd:-kVolumeStep];
        }
        else if(offset_y < -kValueUseful)
        {
            [self volumeAdd:kVolumeStep];
        }
    }
    else if ((_gestureType == GestureTypeOfBrightness) &&
             (currentLocation.x < self.view.frame.size.width*0.5) &&
             (ABS(offset_x) <= ABS(offset_y)) &&
             _isFullScreen == YES)
    {
        if (offset_y > kValueUseful)
        {
            _brightnessView.alpha = 1;
            [self brightnessAdd:-kBrightnessStep];
        }
        else if(offset_y < -kValueUseful)
        {
            _brightnessView.alpha = 1;
            [self brightnessAdd:kBrightnessStep];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    [NSObject cancelPreviousPerformRequestsWithTarget:self];//可以成功取消全部。
    //    [[self class] cancelPreviousPerformRequestsWithTarget:self];//可以成功取消全部。
    //    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidenControlBar) object:nil];
    
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    
    if (_gestureType == GestureTypeOfNone &&
        !CGRectContainsPoint(_bottomView.frame, point) &&
        !CGRectContainsPoint(_topView.frame, point))
    {
        // 轻拍手势 隐藏/显示状态栏
        [UIView animateWithDuration:1 animations:^{
            if (self.bottomView.hidden) {
                [self showTopAndBottomView];
            }else{
                [self hiddenTopAndBottomView];
            }
        }];
    }
    else if (_gestureType == GestureTypeOfProgress)
    {
        _gestureType = GestureTypeOfNone;
        
        if(_videoSlider.enabled == NO)
        {
            return;
        }
        
//        if([self checkLocalVedioNoLog:_movieSlider] == NO)
//        {
//            return;
//        }
//        
        [self sliderScrollingEnded];
    }
    else
    {
        _gestureType = GestureTypeOfNone;
        
        if (_brightnessView.alpha != 0)
        {
            [UIView animateWithDuration:0.3 animations:^{
                _brightnessView.alpha = 0;
            }];
        }
    }
}


// 拖动播放进度条
-(void)sliderScrollingEnded
{

    
    NSLog(@"value -----> %f", _videoSlider.value);
    double currentTime = floor(_videoTotalTime *_videoSlider.value);
    
    NSLog(@"currentTime -----> %f", currentTime);
    // 转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime = CMTimeMake(currentTime, 1);


    __weak typeof (self) _weakSelf = self;
    [self.avQueuePlayer seekToTime:dragedCMTime completionHandler:
     ^(BOOL finish){
         if (finish) {
             [_weakSelf.avQueuePlayer play];
         }
     }];
}



/// 声音改变.
- (void)volumeAdd:(CGFloat)step
{
    [MPMusicPlayerController applicationMusicPlayer].volume += step;;
}

/// 屏幕亮度改变.
- (void)brightnessAdd:(CGFloat)step
{

    
    [UIScreen mainScreen].brightness += step;
    NSLog(@" --------- %f ------- %f",  _brightnessProgress.progress, step);
    
    _brightnessProgress.progress = [UIScreen mainScreen].brightness;
}


#pragma mark |---- sliderAction
- (void)scrubbingDidBegin{
    _gestureType = GestureTypeOfNone;
}

- (void)scrubbingDidChange{
    if (_videoSlider.enabled == NO) {
        return;
    }
    
    _gestureType = GestureTypeOfProgress;
    

}

- (void)scrubbingDidEnd{
    double currentTime = floor(_videoTotalTime*_videoSlider.value);
    CMTime dragedCMTime = CMTimeMake(currentTime, 1);
    __weak typeof (self) _weakSelf = self;
    [self.avQueuePlayer seekToTime:dragedCMTime completionHandler:
     ^(BOOL finish){
        [_weakSelf.avQueuePlayer play];
     }];
}

- (void)hiddenTopAndBottomView{
    [UIView animateWithDuration:ToolView_Hidden_duration animations:^{
        self.topView.hidden = self.bottomView.hidden = YES;
    }];
}

- (void)showTopAndBottomView{
    //如果不是正片  直接返回
    if(!_isNormalVideoPlayer) return;
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
    
    
     self.adPlayerItem = [[MyAVPlayerItem alloc] initWithURL:[NSURL URLWithString:@"http://mvvideo1.meitudata.com/571b6d81b9e3c5236.mp4"]];
     self.normalPlayerItem = [[MyAVPlayerItem alloc] initWithURL:[NSURL URLWithString:@"http://mvideo.spriteapp.cn/video/2016/0427/92710204-0c7f-11e6-be8e-d4ae5296039dcut_wpc.mp4"]];
    [self.normalPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    self.avQueuePlayer = [AVQueuePlayer queuePlayerWithItems:@[self.adPlayerItem, self.normalPlayerItem]];
    
    [self.avQueuePlayer addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:nil];
    
    self.playerView = [[ZLPlayerView alloc] init];
    self.playerView.queuePlayer = self.avQueuePlayer;
    
    self.playerView.frame = self.view.bounds;
    [self.view addSubview:self.playerView];
    // topView bottomView 靠前
    [self.view bringSubviewToFront:self.topView];
    [self.view bringSubviewToFront:self.bottomView];
    

    [self.adPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    __weak typeof (self) _weakSelf = self;
    void (^observerBlock)(CMTime time) = ^(CMTime time){
        if (_weakSelf.avQueuePlayer.currentItem == _weakSelf.adPlayerItem) {
            
            self.countDownLabel.text = [NSString stringWithFormat:@"%zds",  _weakSelf.videoTotalTime - (NSInteger)(time.value / time.timescale)];
            
            return ;
        }
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            _weakSelf.currentTimeLabel.text = [_weakSelf formatSecondToTimeWithSecond:(NSInteger)((float)time.value / (float)time.timescale) ];
            _weakSelf.remainTimeLabel.text = [NSString stringWithFormat:@"-%@", [_weakSelf formatSecondToTimeWithSecond:(NSInteger)((float) _weakSelf.videoTotalTime - (float)time.value / (float)time.timescale) ]];
            _weakSelf.videoSlider.value = ((float)time.value / (float)time.timescale)/_weakSelf.videoTotalTime;
        } else {
//            NSLog(@"App is backgrounded. Time is: %@", timeString);
        }
    };
    
    self.timeObserver = [self.playerView.queuePlayer addPeriodicTimeObserverForInterval:CMTimeMake(10, 1000)
                                                                   queue:dispatch_get_main_queue()
                                                              usingBlock:observerBlock];
    //监听视频播放结束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [self.view bringSubviewToFront:self.countDownLabel];
    [self.view bringSubviewToFront:self.lockButton];
    [self.view bringSubviewToFront:self.brightnessView];
    [self.view bringSubviewToFront:self.coverImageView];
}


- (void)playerItemDidReachEnd:(NSNotification *)notification{
    MyAVPlayerItem * item = (MyAVPlayerItem *)self.avQueuePlayer.currentItem;
    if (item == self.adPlayerItem) {
        self.countDownLabel.hidden = YES;
        self.isNormalVideoPlayer = YES;
        [self showTopAndBottomView];
    }else{
        self.isNormalVideoPlayer = NO;
        self.countDownLabel.text = @"";
        [self.avQueuePlayer seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [self pause];
        }];
    }
}

- (void)play{
    [self.playerView.queuePlayer play];
    self.playBtn.selected = YES;
}

- (void)pause{
    if (self.playerView.queuePlayer) {
        [self.playerView.queuePlayer pause];
    }
    self.playBtn.selected = NO;
}

#pragma mark |---- observeValueForKeyPath
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"currentItem"]) {
        AVQueuePlayer * queuePlayer = (AVQueuePlayer*)object;
        if(queuePlayer.currentItem == self.normalPlayerItem){
            _videoSlider.enabled = YES;
            _videoTotalTime = (self.normalPlayerItem.asset.duration.value / self.normalPlayerItem.asset.duration.timescale);
        }
    }else if([keyPath isEqualToString:@"status"]){
        MyAVPlayerItem *playerItem = (MyAVPlayerItem*)object;
        if (playerItem == self.adPlayerItem) {
            _videoTotalTime = (playerItem.asset.duration.value / playerItem.asset.duration.timescale);
        }
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
//            self.coverImageView.hidden = YES;
            [self play];
            if (self.avQueuePlayer.currentItem == self.adPlayerItem) {
                [self.adPlayerItem removeObserver:self forKeyPath:@"status"];
            }
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]){
        float bufferTime = [self availableDuration];
        float durationTime = CMTimeGetSeconds([self.normalPlayerItem duration]);
        [self.videoProgressView setProgress:bufferTime / durationTime animated:YES];
    }else if([keyPath isEqualToString:@"value"]){
        UISlider * slider = (UISlider *)object;
        
//        double currentTime = floor(_videoTotalTime * slider.value);
//        CMTime dragedCMTime = CMTimeMake(currentTime, 1);
//        [_avQueuePlayer seekToTime:dragedCMTime completionHandler:^(BOOL finished) {
//            if (finished) {
//                [self play];
//            }
//        }];
        
    }
}


#pragma mark |--- 播放按钮的点击事件
- (void)playButtonClicked:(UIButton *)button{

    [self.normalPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.avQueuePlayer removeObserver:self forKeyPath:@"currentItem"];
    [self.avQueuePlayer removeAllItems];
    
    //隐藏顶部底部工具栏
//    [self hiddenTopAndBottomView];
    if(self.avQueuePlayer.items.count == 0){
        self.countDownLabel.hidden = NO;
        [self createAVPlayerWithTitleItem:nil andNormalItem:nil];
    }
}

#pragma mark |--- 锁定按钮的点击事件
- (void)lockButtonClicked:(UIButton *)button{
    self.lockButton.selected = !self.lockButton.selected;
    if (self.lockButton.selected) {
        _isOriationLocked = YES;
    }else{
        _isOriationLocked = NO;
        [self roationViewWithOrientation:[UIDevice currentDevice].orientation];
    }
}

#pragma mark |-- 计算缓冲进度
// 计算缓冲进度
- (float)availableDuration
{
    NSArray *loadedTimeRanges = [self.normalPlayerItem loadedTimeRanges];
    
    if ([loadedTimeRanges count] > 0)
    {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        
        return (startSeconds + durationSeconds);
    }
    else
    {
        return 0.0f;
    }
}


- (NSString *)formatSecondToTimeWithSecond:(NSInteger)secondCount{
    NSString * h = nil;
    NSString * min = nil;
    NSString * second = nil;
    if (secondCount/3600 > 0) {
        h = [NSString stringWithFormat:@"%02zd:", secondCount/3600];
    }else{
        h = @"00:";
    }
    
    if (secondCount%3600/60 > 0) {
        min = [NSString stringWithFormat:@"%02zd:", secondCount%3600/60];
    }else{
        min = @"00:";
    }
    
    if (secondCount%60 >= 0) {
        second = [NSString stringWithFormat:@"%02zd", secondCount%60];
    }else{
        second = @"00";
    }
    
    NSString * resultTime = [NSString stringWithFormat:@"%@%@%@", h, min, second];
    if(_videoTotalTime >=  60 * 60){// 超过一小时
        return resultTime;
    }else{
        return [resultTime substringFromIndex:3];
    }
}


@end
