//
//  PBChatInputBar.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/27.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBChatInputBar.h"
#import "HPGrowingTextView.h"

static const int PB_CHAT_INPUT_LINE_MIN                     =       1;//input min line num
//static const int PB_CHAT_INPUT_LINE_MAX                     =       5;//input max line num
static const int PB_CHAT_INPUT_PADDING                      =       3;//textView padding
static const int PB_CHAT_INPUT_BTN_SIZE                     =       30;
static const int PB_CHAT_INPUT_CHARS_MAX                    =       300;//input char's max count

#pragma mark -- audio input mask

typedef void(^PBAudioInputCallback)(BOOL timeout);
//类似与SVProgressHUD的实现方法
@interface PBAudioInputMask : UIView

@property (nonatomic, strong) CADisplayLink *linkTimer;

@property (nonatomic, strong) UILabel *titleLab,*subLab,*retLab;

@property (nonatomic, strong) UIImageView *maskImg;

@property (nonatomic, assign) int mAngle;
@property (nonatomic, assign) CGFloat mRemindInterval;

@property (nonatomic, strong) UIWindow *overlay;

@property (nonatomic, assign) CFTimeInterval beginInterval;

@property (nonatomic, copy) PBAudioInputCallback callback;

+ (void)handleAudioInputCallBack:(PBAudioInputCallback)callback;

+ (void)show;

+ (void)changeStatus:(NSString *)status;

+ (void)dissmissWithStatus:(nullable NSString *)status;

@end

@implementation PBAudioInputMask

- (UIWindow *)overlay {
    if(!_overlay) {
        _overlay = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overlay.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
        _overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _overlay.userInteractionEnabled = false;
        [_overlay makeKeyAndVisible];
    }
    return _overlay;
}

+ (PBAudioInputMask *)sharedView {
    static PBAudioInputMask *sharedView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGRect bounds = [[UIScreen mainScreen] bounds];
        sharedView = [[PBAudioInputMask alloc] initWithFrame:bounds];
        sharedView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    });
    return sharedView;
}

+ (void)show {
    [[PBAudioInputMask sharedView] startShow];
}

+ (void)handleAudioInputCallBack:(PBAudioInputCallback)callback {
    [[PBAudioInputMask sharedView] handleAudioInputCallBack:callback];
}

- (void)handleAudioInputCallBack:(PBAudioInputCallback)callback {
    self.callback = [callback copy];
}

#pragma mark -- getter lazy

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
        [self addSubview:_titleLab];
    }
    return _titleLab;
}

- (UILabel *)subLab {
    if (!_subLab) {
        _subLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 20)];
        [self addSubview:_subLab];
    }
    return _subLab;
}

- (UILabel *)retLab {
    if (!_retLab) {
        _retLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
        [self addSubview:_retLab];
    }
    return _retLab;
}

- (UIImageView *)maskImg {
    if (!_maskImg) {
        _maskImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Chat_record_circle"]];
        [self addSubview:_maskImg];
    }
    return _maskImg;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //设置
        self.titleLab.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2 - 30);
        self.titleLab.textAlignment = NSTextAlignmentCenter;
        self.titleLab.font = [UIFont boldSystemFontOfSize:18];
        self.titleLab.textColor = [UIColor whiteColor];
        
        self.subLab.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2 + 30);
        self.subLab.textAlignment = NSTextAlignmentCenter;
        self.subLab.font = [UIFont boldSystemFontOfSize:14];
        self.subLab.textColor = [UIColor whiteColor];
        
        self.retLab.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2);
        self.retLab.textAlignment = NSTextAlignmentCenter;
        self.retLab.font = [UIFont systemFontOfSize:30];
        self.retLab.textColor = [UIColor yellowColor];
        
        self.maskImg.frame = CGRectMake(0, 0, 154, 154);
        self.maskImg.center = self.retLab.center;
    }
    return self;
}

- (void)startShow {
    [self invalidTimer];
    PBMAIN(^{
        if(!self.superview) {
            //[self.overlay addSubview:self];
            // Default case: iterate over UIApplication windows
            NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
            for (UIWindow *window in frontToBackWindows) {
                BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
                BOOL windowIsVisible = !window.hidden && window.alpha > 0;
                BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
                
                if(windowOnMainScreen && windowIsVisible && windowLevelNormal) {
                    [window addSubview:self];
                    break;
                }
            }
        }
        self.titleLab.text = @"剩余时间:秒";
        self.subLab.text = @"上滑取消";
        self.retLab.text = @"60";
        [self startTimer];
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.alpha = 1;
                         }
                         completion:^(BOOL finished){
                         }];
        [self setNeedsDisplay];
    });
}

- (void)invalidTimer {
    if (_linkTimer != nil) {
        if (!_linkTimer.isPaused) {
            [_linkTimer setPaused:true];
            [_linkTimer invalidate];
        }
        _linkTimer = nil;
    }
}

- (void)startTimer {
    //重置时间
    self.mRemindInterval = 60;
    self.beginInterval = CACurrentMediaTime();
    self.linkTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeFired)];
    self.linkTimer.frameInterval = 6;//每秒调用次数 = 60/frameInterval
    [self.linkTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.linkTimer.paused = false;
}

- (void)timeFired {
    self.mAngle -= 3;
    self.mRemindInterval -= 0.1;
    if (self.mRemindInterval <= 0) {
        //结束了
        if (_callback) {
            _callback(true);
        }
        return;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.09];
    UIView.AnimationRepeatAutoreverses = YES;
    self.maskImg.transform = CGAffineTransformMakeRotation(self.mAngle * (M_PI / 180.0f));
    if (self.mRemindInterval <= 10.0f) {
        self.retLab.textColor = [UIColor redColor];
    }else{
        self.retLab.textColor = [UIColor yellowColor];
    }
    self.retLab.text = PBFormat(@"%0.1f",self.mRemindInterval);
    [UIView commitAnimations];
}

+ (void)changeStatus:(NSString *)status {
    [[PBAudioInputMask sharedView] setState:status];
}

- (void)setState:(NSString *)str {
    self.subLab.text = str;
}

+ (void)dissmissWithStatus:(NSString *)status {
    [[PBAudioInputMask sharedView] dismissWithStatus:status];
}

- (void)dismissWithStatus:(NSString *)state {
    PBMAIN(^{
        NSString *alertInfo = state;
        CFTimeInterval nowInterval = CACurrentMediaTime();
        if (fabs(nowInterval-self.beginInterval) < 1) {
            alertInfo = @"时间太短";
        }
        [self invalidTimer];
        self.titleLab.text = nil;
        self.subLab.text = nil;
        self.retLab.text = alertInfo;
        self.retLab.textColor = [UIColor whiteColor];
        
        CGFloat timeLonger;
        if ([state isEqualToString:@"TooShort"]) {
            timeLonger = 1;
        }else{
            timeLonger = 0.6;
        }
        [UIView animateWithDuration:timeLonger
                              delay:0
                            options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             [self removeFromSuperview];
                             /*
                             NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
                             NSLog(@"wins:%@",windows);
                             [windows removeObject:_overlay];
                             [_overlay resignKeyWindow];
                             [_overlay removeFromSuperview];
                             _overlay = nil;
                             
                             [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
                                 if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                                     [window makeKeyWindow];
                                     *stop = YES;
                                 }
                             }];
                             //*/
                         }];
    });
}


@end

#pragma mark -- audio input button

@class PBAudioInputButton;
typedef void (^PBRecordTouchDown)         (PBAudioInputButton *recordButton);
typedef void (^PBRecordTouchUpOutside)    (PBAudioInputButton *recordButton);
typedef void (^PBRecordTouchUpInside)     (PBAudioInputButton *recordButton);
typedef void (^PBRecordTouchDragEnter)    (PBAudioInputButton *recordButton);
typedef void (^PBRecordTouchDragInside)   (PBAudioInputButton *recordButton);
typedef void (^PBRecordTouchDragOutside)  (PBAudioInputButton *recordButton);
typedef void (^PBRecordTouchDragExit)     (PBAudioInputButton *recordButton);
@interface PBAudioInputButton : UIButton

@property (nonatomic, copy) PBRecordTouchDown         recordTouchDownAction;
@property (nonatomic, copy) PBRecordTouchUpOutside    recordTouchUpOutsideAction;
@property (nonatomic, copy) PBRecordTouchUpInside     recordTouchUpInsideAction;
@property (nonatomic, copy) PBRecordTouchDragEnter    recordTouchDragEnterAction;
@property (nonatomic, copy) PBRecordTouchDragInside   recordTouchDragInsideAction;
@property (nonatomic, copy) PBRecordTouchDragOutside  recordTouchDragOutsideAction;
@property (nonatomic, copy) PBRecordTouchDragExit     recordTouchDragExitAction;

- (void)setButtonStateWithRecording;
- (void)setButtonStateWithNormal;

@end

@implementation PBAudioInputButton

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hidden = YES;
        
        self.backgroundColor = [UIColor pb_colorWithHexString:@"F7F7F7"];;
        
        [self setTitle:@"按住 说话" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        self.layer.cornerRadius = PB_CORNER_RADIUS;
        self.layer.borderWidth = PB_CUSTOM_LINE_HEIGHT;
        self.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1.0].CGColor;
        
        [self addTarget:self action:@selector(recordTouchDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(recordTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(recordTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchCancel];
        [self addTarget:self action:@selector(recordTouchDragInside) forControlEvents:UIControlEventTouchDragInside];
        [self addTarget:self action:@selector(recordTouchDragOutside) forControlEvents:UIControlEventTouchDragOutside];
        [self addTarget:self action:@selector(recordTouchDragExit) forControlEvents:UIControlEventTouchDragExit];
        [self addTarget:self action:@selector(recordTouchDragEnter) forControlEvents:UIControlEventTouchDragEnter];
    }
    return self;
}

- (void)setButtonStateWithRecording {
    self.backgroundColor = [UIColor pb_colorWithHexString:@"D6D7DC"]; //214,215,220
    [self setTitle:@"松开 结束" forState:UIControlStateNormal];
}

- (void)setButtonStateWithNormal {
    self.backgroundColor = [UIColor pb_colorWithHexString:@"F7F7F7"];
    [self setTitle:@"按住 说话" forState:UIControlStateNormal];
}


#pragma mark -- 事件方法回调
- (void)recordTouchDown {
    if (self.recordTouchDownAction) {
        self.recordTouchDownAction(self);
    }
}

- (void)recordTouchUpOutside {
    if (self.recordTouchUpOutsideAction) {
        self.recordTouchUpOutsideAction(self);
    }
}

- (void)recordTouchUpInside {
    if (self.recordTouchUpInsideAction) {
        self.recordTouchUpInsideAction(self);
    }
}

- (void)recordTouchDragEnter {
    if (self.recordTouchDragEnterAction) {
        self.recordTouchDragEnterAction(self);
    }
}

- (void)recordTouchDragInside {
    if (self.recordTouchDragInsideAction) {
        self.recordTouchDragInsideAction(self);
    }
}

- (void)recordTouchDragOutside {
    if (self.recordTouchDragOutsideAction) {
        self.recordTouchDragOutsideAction(self);
    }
}

- (void)recordTouchDragExit {
    if (self.recordTouchDragExitAction) {
        self.recordTouchDragExitAction(self);
    }
}


//解决按钮放在屏幕底部，touchdown事件延迟响应的问题

/**
 iOS7之后提供了做滑手势导致的这个问题
 self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO; 即可
 */
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    BOOL inside = [super pointInside: point withEvent: event];
//
//    if (inside && !self.highlighted)
//    {
//        self.highlighted = YES;
//        [self sendActionsForControlEvents:UIControlEventTouchDown];
//    }
//
//    return inside;
//}

@end

#pragma mark == Chat Input Bar

#import "ECDevice.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface PBChatInputBar ()<HPGrowingTextViewDelegate>
//依赖的根视图
@property (nonatomic, strong) UIViewController *rootCtr;
//输入源
@property (nonatomic, strong) HPGrowingTextView *textView;

@property (nonatomic, strong) UIButton *audioStateBtn, *emojiBtn, *moreBtn;
@property (nonatomic, strong) PBAudioInputButton *audioInputBtn;

//语音输入 表情输入 是否生效开关
@property (nonatomic, assign) BOOL isEmojiActive, isAudioActive;
@property (nonatomic, strong) MASConstraint *emojiStateConstraint, *audioStateConstraint;
//语音输入按钮的高度（当切换到语音输入模式时需要调整自身高度）
@property (nonatomic, copy) NSString *textInputInfo;
//@property (nonatomic, strong) MASConstraint *audioInputHConstraint, *textInputHConstraint;

//表情键盘 更多键盘
@property (nonatomic, strong) PBEmojiPanel *emojiKeyboard;
@property (nonatomic, strong) PBMorePanel *moreKeyboard;

@end

@implementation PBChatInputBar

#pragma mark -- keyboard notifications
- (void)registerKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillDisAppear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_keyboardWillAppear:(NSNotification *)notis {
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notis.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    // Need to translate the bounds to account for rotation.
    //keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatInputBar:willChange2InputState:withKeyboardHeight:)]) {
        [self.delegate chatInputBar:self willChange2InputState:PBChatInputStateText withKeyboardHeight:keyboardBounds.size.height];
    }
}

- (void)_keyboardWillDisAppear:(NSNotification *)notis {
    
}

- (void)dealloc {
    [self unregisterKeyboardNotifications];
}

- (id)initWithDependencyRoot:(UIViewController *)ctr {
    CGRect bounds = CGRectMake(0, 0, PBSCREEN_WIDTH, PB_CHAT_TOOLBAR_HEIGHT);
    self = [super initWithFrame:bounds];
    if (self) {
        [self __initSetup];
    }
    return self;
}

- (void)__initSetup {
    UIColor *bgColor = [UIColor pb_colorWithHexString:@"F4F4F6"];
    self.backgroundColor = bgColor;
    UIColor *lineColor = [UIColor pb_colorWithHexString:@"E0DfE1"];
    CALayer *line = [CALayer layer];
    line.backgroundColor = lineColor.CGColor;
    line.frame = CGRectMake(0, 0, PBSCREEN_WIDTH, PB_CUSTOM_LINE_HEIGHT);
    [self.layer addSublayer:line];
    UILabel *bottomLine = [[UILabel alloc] init];
    bottomLine.backgroundColor = lineColor;
    [self addSubview:bottomLine];
    //audio state btn
    UIImage *audioNormalImg = [UIImage imageNamed:@"chat_voice_record"];
    //UIImage *audioSelectImg = [UIImage pb_iconFont:nil withName:@"\U0000e615" withSize:PB_CHAT_INPUT_BTN_SIZE withColor:iconColor];
    UIImage *audioSelectImg = [UIImage imageNamed:@"chat_ipunt_message"];
    UIButton *audioStateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [audioStateBtn setBackgroundImage:audioNormalImg forState:UIControlStateNormal];
    [audioStateBtn setBackgroundImage:audioSelectImg forState:UIControlStateSelected];
    [audioStateBtn addTarget:self action:@selector(audioTextStateChangeEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:audioStateBtn];
    self.audioStateBtn = audioStateBtn;
    
    UIColor *borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
    HPGrowingTextView *textView = [[HPGrowingTextView alloc] initWithFrame:CGRectZero];
    textView.isScrollable = false;
    textView.animateHeightChange = true;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    textView.minNumberOfLines = PB_CHAT_INPUT_LINE_MIN;
    //textView.maxNumberOfLines = PB_CHAT_INPUT_LINE_MAX;
    // you can also set the maximum height in points with maxHeight
    textView.maxHeight = 100.0f;
    textView.returnKeyType = UIReturnKeySend; //just as an example
    textView.font = PBSysFont(PBFontTitleSize);
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    //textView.internalTextView.backgroundColor = [UIColor purpleColor];
    textView.layer.cornerRadius = PB_CORNER_RADIUS;
    textView.layer.masksToBounds = true;
    textView.layer.borderWidth = PB_CUSTOM_LINE_HEIGHT;
    textView.layer.borderColor = borderColor.CGColor;
    textView.backgroundColor = [UIColor whiteColor];
    textView.placeholder = @"";
    textView.enablesReturnKeyAutomatically = true;
    [self addSubview:textView];
    self.textView = textView;
    //audio input btn
    PBAudioInputButton *audioInputBtn = [[PBAudioInputButton alloc] init];
    [self addSubview:audioInputBtn];
    self.audioInputBtn = audioInputBtn;
    
    //smile emotion
    UIColor *iconColor = [UIColor pb_colorWithHexString:@"7F8388"];
    UIImage *smileNormalImg = [UIImage pb_iconFont:nil withName:@"\U0000e616" withSize:PB_CHAT_INPUT_BTN_SIZE withColor:iconColor];
    UIImage *smileSelectImg = audioSelectImg;
    UIButton *smileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [smileBtn setBackgroundImage:smileNormalImg forState:UIControlStateNormal];
    [smileBtn setBackgroundImage:smileSelectImg forState:UIControlStateSelected];
    [smileBtn addTarget:self action:@selector(smileTextStateChangeEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:smileBtn];
    self.emojiBtn = smileBtn;
    //more action
    UIImage *moreImg = [UIImage pb_iconFont:nil withName:@"\U0000e613" withSize:PB_CHAT_INPUT_BTN_SIZE withColor:iconColor];
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreBtn setBackgroundImage:moreImg forState:UIControlStateNormal];
    [moreBtn setBackgroundImage:moreImg forState:UIControlStateSelected];
    [moreBtn addTarget:self action:@selector(moreActionEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:moreBtn];
    self.moreBtn = moreBtn;
    
    weakify(self)
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
       strongify(self)
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(PB_CUSTOM_LINE_HEIGHT);
    }];
    audioInputBtn.recordTouchDownAction = ^(PBAudioInputButton *btn){
        //NSLog(@"record start!");
        [btn setButtonStateWithRecording];
        strongify(self)
        [self beginRecordVoice];
    };
    audioInputBtn.recordTouchUpInsideAction = ^(PBAudioInputButton *btn){
        //NSLog(@"record done!");
        [btn setButtonStateWithNormal];
        strongify(self)
        [self endRecordVoice];//too short for time
    };
    audioInputBtn.recordTouchUpOutsideAction = ^(PBAudioInputButton *btn){
        //NSLog(@"record canceled!");
        [btn setButtonStateWithNormal];
        strongify(self)
        [self cancelRecordVoice];
    };
    audioInputBtn.recordTouchDragInsideAction = ^(PBAudioInputButton *btn){
        //NSLog(@"拖动重入!");
    };
    audioInputBtn.recordTouchDragOutsideAction = ^(PBAudioInputButton *btn){
        //NSLog(@"拖动出界!");
    };
    audioInputBtn.recordTouchDragExitAction = ^(PBAudioInputButton *btn){
        //中间状态  从 TouchDragInside ---> TouchDragOutside
        //NSLog(@"record will canceled!");
        strongify(self)
        [self RemindDragExit];
    };
    audioInputBtn.recordTouchDragEnterAction = ^(PBAudioInputButton *btn){
        //中间状态  从 TouchDragOutside ---> TouchDragInside
        //NSLog(@"record continue!");
        strongify(self)
        [self RemindDragEnter];
    };
    
    [self layoutIfNeeded];
    
    [self registerKeyboardNotification];
    
    self.isAudioActive = self.isEmojiActive = true;
//    [self enableAudioInputAction:true];
//    [self enableEmojiInputAction:true];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //layout
    int offset = (PB_CHAT_TOOLBAR_HEIGHT-PB_CHAT_INPUT_BTN_SIZE)*0.5;
    weakify(self)
    [self.audioStateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.left.equalTo(self).offset(PB_BOUNDARY_OFFSET*0.5);
        make.bottom.equalTo(self).offset(-offset);
        make.width.height.equalTo(PB_CHAT_INPUT_BTN_SIZE).priority(UILayoutPriorityDefaultHigh);
        if (!self.audioStateConstraint) {
            self.audioStateConstraint = make.width.height.equalTo(@0).priority(UILayoutPriorityRequired);
        }
    }];
    if (self.isAudioActive) {
        [self.audioStateConstraint deactivate];
    }else{
        [self.audioStateConstraint activate];
    }
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.right.equalTo(self).offset(-PB_BOUNDARY_OFFSET*0.5);
        make.bottom.equalTo(self).offset(-offset);
        make.width.height.equalTo(PB_CHAT_INPUT_BTN_SIZE);
    }];
    [self.emojiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.right.equalTo(self.moreBtn.mas_left).offset(-PB_BOUNDARY_OFFSET);
        make.bottom.equalTo(self).offset(-offset);
        make.width.height.equalTo(PB_CHAT_INPUT_BTN_SIZE).priority(UILayoutPriorityDefaultHigh);
        if (!self.emojiStateConstraint) {
            self.emojiStateConstraint = make.width.height.equalTo(@0).priority(UILayoutPriorityRequired);
        }
    }];
    if (self.isEmojiActive) {
        [self.emojiStateConstraint deactivate];
    }else{
        [self.emojiStateConstraint activate];
    }
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.left.equalTo(self.audioStateBtn.mas_right).offset(PB_BOUNDARY_OFFSET);
        make.top.equalTo(self).offset(PB_CHAT_INPUT_PADDING)/*.priority(UILayoutPriorityDefaultHigh)*/;
        make.bottom.equalTo(self).offset(-PB_CHAT_INPUT_PADDING)/*.priority(UILayoutPriorityDefaultHigh)*/;
        make.right.equalTo(self.emojiBtn.mas_left).offset(-PB_BOUNDARY_OFFSET);
    }];
    [self.audioInputBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.left.equalTo(self.audioStateBtn.mas_right).offset(PB_BOUNDARY_OFFSET);
        make.top.equalTo(self).offset(PB_CHAT_INPUT_PADDING)/*.priority(UILayoutPriorityDefaultHigh)*/;
        make.bottom.equalTo(self).offset(-PB_CHAT_INPUT_PADDING)/*.priority(UILayoutPriorityDefaultHigh)*/;
        make.right.equalTo(self.emojiBtn.mas_left).offset(-PB_BOUNDARY_OFFSET);
        //self.audioInputHConstraint = make.height.equalTo(@(PB_CHAT_TOOLBAR_HEIGHT-PB_CHAT_INPUT_PADDING*2)).priority(UILayoutPriorityRequired);
    }];
    //[self.textInputHConstraint deactivate];
    //[self.audioInputHConstraint deactivate];
}

#pragma mark -- TextView Delegate

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView {
    NSLog(@"%s---",__FUNCTION__);
    [self resetInputIndicatorState];
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView {
    NSLog(@"%s---",__FUNCTION__);
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    NSLog(@"%s---",__FUNCTION__);
    NSString *tmpInfo = growingTextView.text;
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatInputBar:didChangeInputInfo:)]) {
        [self.delegate chatInputBar:self didChangeInputInfo:tmpInfo];
    }
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //  控制输入文字的长度和内容   按回车键时回收键盘
    if (range.location >= PB_CHAT_INPUT_CHARS_MAX) {
        //  控制输入文本的长度
        return NO;
    }
    if ([text isEqualToString:@"\n"]) {
        //  禁止输入换行 如果是换行则直接发送
        [self preQueryShouldSendMsgAction];
        return NO;
    }
    return true;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    //NSLog(@"%s---:%f---%f",__FUNCTION__,height,growingTextView.internalTextView.bounds.size.height);
    
    float diff = (growingTextView.frame.size.height - height);
    CGFloat mOriginHeight = self.bounds.size.height;
    mOriginHeight -= diff;
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(mOriginHeight);
    }];
    [UIView animateWithDuration:PBANIMATE_DURATION animations:^{
        //[self.rootCtr.view layoutIfNeeded];
        [self layoutIfNeeded];
    }];
    /*animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:PBANIMATE_DURATION];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    // commit animations
    [UIView commitAnimations];
    //*/
}

#pragma mark -- emoji panel delegate

- (void)emojiPanel:(PBEmojiPanel *)panel didSelectEmoji:(NSString *)emoji {
    if (PBIsEmpty(emoji)) {
        return;
    }
    NSString *tmpInfo = PBFormat(@"%@%@",self.textView.text,emoji);
    self.textView.text = tmpInfo.copy;
}

- (void)emojiPanelDidSelectBackward:(PBEmojiPanel *)panel {
    [self.textView.internalTextView deleteBackward];
}

- (void)emojiPanelDidSelectSendEvent:(PBEmojiPanel *)panel {
    [self preQueryShouldSendMsgAction];
}

#pragma mark -- more panel delegate

- (void)moreActionPanel:(PBMorePanel *)panel didSelectActionType:(PBMorePanelAction)type {
    NSString *urlString = nil;
    if (type == PBMorePanelActionService) {
        urlString = PBFormat(@"%@://YBServiceProfiler/initWithParams:/",PB_SAFE_SCHEME);
    } else if (type == PBMorePanelActionQuickReply) {
        urlString = PBFormat(@"%@://YBQuickReplier/initWithParams:/",PB_SAFE_SCHEME);
    } else if (type == PBMorePanelActionQuery) {
        urlString = PBFormat(@"%@://YBQueryProfiler/initWithParams:/",PB_SAFE_SCHEME);
    } else if (type == PBMorePanelActionFeedback) {
        urlString = PBFormat(@"%@://YBQueryFeedbacker/initWithParams:/",PB_SAFE_SCHEME);
    } else if (type == PBMorePanelActionPhotoAlbum) {
        urlString = PBFormat(@"%@://YBAlbumProfiler/initWithParams:/",PB_SAFE_SCHEME);
    } else if (type == PBMorePanelActionPhotoCamera) {
        //TODO:此处可以自定义相机 也可以使用系统相机
        urlString = PBFormat(@"%@://YBCameraProfiler/initWithParams:/",PB_SAFE_SCHEME);
    }
    //url 编码
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatInputBar:didSelectedMoreFunctionRouter:)]) {
        [self.delegate chatInputBar:self didSelectedMoreFunctionRouter:url];
    }
}

#pragma mark -- input bar function enable/disable

- (void)enableAudioInputAction:(BOOL)enable {
    self.isAudioActive = enable;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)enableEmojiInputAction:(BOOL)enable {
    self.isEmojiActive = enable;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (NSString *)currentInputInfo {
    return self.textView.text;
}

/**
 *  @brief 重置输入按钮（语音、emoji、更多）状态
 */
- (void)resetInputIndicatorState {
    self.audioStateBtn.selected = false;
    self.emojiBtn.selected = false;
    self.moreBtn.selected = false;
}

- (void)outTriggerEndFirstResponder {
    
    [self resetInputIndicatorState];
    [self.textView resignFirstResponder];
    //改变键盘高度
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatInputBar:willChange2InputState:withKeyboardHeight:)]) {
        [self.delegate chatInputBar:self willChange2InputState:PBChatInputStateNone withKeyboardHeight:0];
    }
}

#pragma mark -- input button state change event

- (void)reuseTextInputComponent:(BOOL)hidden {
    if (self.textView.hidden == hidden) {
        return;
    }
    self.textView.hidden = hidden;
    if (hidden) {
        self.textInputInfo = self.textView.text;
        self.textView.text = nil;
    }else{
        self.textView.text = self.textInputInfo;
        _textInputInfo = nil;
    }
}

- (void)audioTextStateChangeEvent:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    
    if (btn.selected) {
        //语音输入状态
        //[self.audioInputHConstraint activate];
        //[self.textInputHConstraint activate];
        [self.textView resignFirstResponder];
        //改变键盘高度
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatInputBar:willChange2InputState:withKeyboardHeight:)]) {
            [self.delegate chatInputBar:self willChange2InputState:PBChatInputStateAudio withKeyboardHeight:0];
        }
    }else{
        //文本输入状态
        //[self.audioInputHConstraint deactivate];
        //[self.textInputHConstraint deactivate];
        [self.textView becomeFirstResponder];
    }
    
    //表情与此状态相反
    self.emojiBtn.selected = false;
    self.moreBtn.selected = false;
    [self reuseTextInputComponent:btn.selected];
    self.audioInputBtn.hidden = !btn.selected;
}

- (void)smileTextStateChangeEvent:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        //表情输入状态
        [self.textView resignFirstResponder];
        //改变键盘高度
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatInputBar:willChange2InputState:withKeyboardHeight:)]) {
            [self.delegate chatInputBar:self willChange2InputState:PBChatInputStateEmoji withKeyboardHeight:PB_CHAT_KEYBOARD_HEIGHT];
        }
    }else{
        //文本输入状态
        [self.textView becomeFirstResponder];
    }
    
    //语音与此状态相反
    self.audioStateBtn.selected = false;
    //self.textView.hidden = false;
    [self reuseTextInputComponent:false];
    self.audioInputBtn.hidden = true;
    self.moreBtn.selected = false;
}

- (void)moreActionEvent:(UIButton *)btn {
    btn.selected = !btn.selected;
    
    if (btn.selected) {
        //更多输入状态
        [self.textView resignFirstResponder];
        //改变键盘高度
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatInputBar:willChange2InputState:withKeyboardHeight:)]) {
            [self.delegate chatInputBar:self willChange2InputState:PBChatInputStateMore withKeyboardHeight:PB_CHAT_KEYBOARD_HEIGHT];
        }
    }else{
        //文本输入状态
        [self.textView becomeFirstResponder];
    }
    
    self.audioStateBtn.selected = false;
    //self.textView.hidden = false;
    [self reuseTextInputComponent:false];
    self.audioInputBtn.hidden = true;
    self.emojiBtn.selected = false;
}

#pragma mark - 录音touch事件
- (void)beginRecordVoice {
    //开始计时
    //NSLog(@"%s",__FUNCTION__);
    weakify(self)
    [PBAudioInputMask handleAudioInputCallBack:^(BOOL timeout) {
        if (timeout) {
            strongify(self)
            [self.audioInputBtn cancelTrackingWithEvent:nil];
            [self endRecordVoice];
        }
    }];
    [PBAudioInputMask show];
    
    /*TODO:0.5"后开始外部第三方开始录音
    ECVoiceMessageBody * messageBody = [[ECVoiceMessageBody alloc] initWithFile:@"语音文件路径.amr" displayName:@"文件名.arm"];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[[ECDevice sharedInstance] messageManager] startVoiceRecording:messageBody error:^(ECError *error, ECVoiceMessageBody *messageBody) {
        
    }];
    //*/
}

- (void)endRecordVoice {
    //NSLog(@"%s",__FUNCTION__);
    [PBAudioInputMask dissmissWithStatus:@""];//too short for time
}

- (void)cancelRecordVoice {
    //NSLog(@"%s",__FUNCTION__);
    [PBAudioInputMask dissmissWithStatus:@"取消"];
}

- (void)RemindDragExit {
    //touch out 提示:松开取消
    //NSLog(@"%s",__FUNCTION__);
    [PBAudioInputMask changeStatus:@"松手取消"];
}

- (void)RemindDragEnter {
    //touch out 提示:上滑取消
    //NSLog(@"%s",__FUNCTION__);
    [PBAudioInputMask changeStatus:@"上滑取消"];
}

#pragma mark --
- (void)preQueryShouldSendMsgAction {
    NSString *tmpInfo = self.textView.text;
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatInputBar:willSendText:)]) {
        [self.delegate chatInputBar:self willSendText:tmpInfo];
    }
    self.textView.text = nil;
}

@end
