//
//  VideoViewController.m
//  BiliBili
//
//  Created by apple-jd44 on 15/11/13.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "VideoViewController.h"
#import "VideoViewModel.h"
#import "DanMuModel.h"
#import "BarrageDescriptor+Tools.h"
#import "PlayerUIView.h"
#import <AVFoundation/AVFoundation.h>
@interface VideoViewController ()<PlayerUIViewDelegate>
@property (nonatomic, strong) VideoViewModel* vm;
@property (nonatomic, strong) BarrageRenderer* rander;
@property (nonatomic, strong) MBProgressHUD* hub;
@property (nonatomic, strong) PlayerUIView* playerView;
@property (nonatomic, strong) NSTimer* timer;
@property(nonatomic,strong) AVPlayer *player;
@property(nonatomic,strong) AVPlayerLayer *layer;

@property (nonatomic, assign, getter=isUserPause) BOOL userPause;
@property (nonatomic, assign, getter=isPlayerHidden) BOOL playerHidden;
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    //菊花
    [self.hub show:YES];
    
    [self.vm refreshDataCompleteHandle:^(NSError *error) {
        self.player = [AVPlayer playerWithURL:[self.vm videoURL]];
        self.layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        
        [self.view.layer insertSublayer:self.layer atIndex:0];
        //弹幕开始播放
        [self launchDanMu];
        //播放器
        [self.playerView setWithTitle:[self.vm videoTitle] videoTime:CMTimeGetSeconds(self.player.currentItem.duration)];
    }];
}


#pragma mark - 横屏代码
- (BOOL)shouldAutorotate{
    return NO;
} //NS_AVAILABLE_IOS(6_0);当前viewcontroller是否支持转屏

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskLandscape;
} //当前viewcontroller支持哪些转屏方向

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.layer.frame = self.view.bounds;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    [self playerPause];
    self.player = nil;
    self.layer = nil;
}

#pragma mark - 方法
- (instancetype)initWithAid:(NSString*)aid{
    if (self = [super init]) {
        self.vm = [[VideoViewModel alloc] initWithAid: aid];
    }
    return self;
}

- (void)launchDanMu{
    [self.rander start];
    
    self.timer = [NSTimer bk_scheduledTimerWithTimeInterval:1 block:^(NSTimer *timer) {
        //如果用户没点击暂停
        if (self.isUserPause == NO) {
            //没到达缓存时间应该播放
            if ([self isArriveBufferTime] == NO) {
                [self playerPlay];
                NSArray* model = [self.vm videoDanMu][@([self currentSecond])];
                //逐一发射
                [model enumerateObjectsUsingBlock:^(DanMuModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.rander receive: [BarrageDescriptor descriptorWithText:obj.text fontSize:obj.fontSize color:obj.textColor style:obj.style]];
                }];
                //更新当前时间
                [self.playerView updateCurrentTime:[self currentSecond] bufferTime:[self allBufferSecond] allTime:CMTimeGetSeconds(self.player.currentItem.duration)];
                
                //到达缓存时间应该暂停弹幕播放
            }else{
                [self playerPause];
            }
        }
        
    } repeats:YES];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    !self.isPlayerHidden?[self.playerView showPlayer]:[self.playerView hiddenPlayer];
     self.playerHidden = !self.isPlayerHidden;
}

/*
 *获取当前播放器播放时间
 */
- (NSInteger)currentSecond{
    return CMTimeGetSeconds([self.player currentTime]);
}
/*
 *获取已经缓存秒数
 */
- (NSInteger)currentBufferSecond{
    return CMTimeGetSeconds([self bufferTimeRange].duration);
}
- (NSInteger)allBufferSecond{
    CMTimeRange time = [self bufferTimeRange];
    return CMTimeGetSeconds(time.duration) + CMTimeGetSeconds(time.start);
}
/**
 *  获取总共缓存秒数
 *
 */
- (CMTimeRange)bufferTimeRange{
    return self.player.currentItem.loadedTimeRanges.firstObject.CMTimeRangeValue;
}

//判断是否到达缓存时间
- (BOOL)isArriveBufferTime{
    return [self currentBufferSecond] <= 2;
}
//播放器播放
- (void)playerPlay{
    [self.player play];
    [self.rander start];
    [self.hub hide:YES];
}
//播放器暂停
- (void)playerPause{
    [self.player pause];
    [self.rander pause];
}

#pragma mark - 懒加载


- (BarrageRenderer *)rander{
    if (_rander == nil) {
        _rander = [[BarrageRenderer alloc] init];
        [_rander setSpeed:1];
        [self.view insertSubview: _rander.view atIndex:1];
    }
    return _rander;
}

- (MBProgressHUD *)hub{
    if (_hub == nil) {
        _hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hub.mode = MBProgressHUDModeIndeterminate;
    }
    return _hub;
}

- (AVPlayerLayer *)layer{
    if (_layer == nil) {
        _layer = [[AVPlayerLayer alloc] init];
        _layer.frame = self.view.frame;
    }
    return _layer;
}


- (PlayerUIView *)playerView{
    if(_playerView == nil) {
        _playerView = [[PlayerUIView alloc] initWithTitle:[self.vm videoTitle] videoTime:[self.vm videoLength]];
        _playerView.alpha = 0;
        [_playerView updateValue:^{
           self.playerHidden = !self.isPlayerHidden;
        }];
        _playerView.delegate = self;
        [self.view insertSubview:_playerView atIndex:2];
        [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return _playerView;
}

#pragma mark - PlayUIView

- (void)playerTouchSlider:(PlayerUIView *)UIView slideValue:(CGFloat)value{
    CMTime time = [self.player currentTime];
    time.value = time.timescale * value * [self.vm videoLength];
    [self.player seekToTime:time];
}

- (void)playerTouchBackArrow:(PlayerUIView *)UIView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)playerTouchPlayerButton:(PlayerUIView *)UIView{
    if (self.isUserPause == NO) {
        [self playerPause];
    }else{
        [self playerPlay];
    }
    self.userPause = !self.isUserPause;
}

@end
