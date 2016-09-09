//
//  PBTransitionMasker.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/23.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBTransitionMasker.h"

@interface PBTransitionMasker ()

@property (nonatomic, copy) PBTransitionEvent event;
// 一开始的状态栏状态
@property (nonatomic, assign)BOOL statusBarHiddenInited;
@property (nonatomic, strong)UIWindow *actionWindow;

@property (nonatomic, strong) UIImageView *mIconView;

@end

@implementation PBTransitionMasker

#pragma mark - Lifecycle
- (void)loadView {
    _statusBarHiddenInited = [UIApplication sharedApplication].isStatusBarHidden;
    // 隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //initsubviews
    weakify(self)
    UIImageView *tmp = [[UIImageView alloc] init];
    tmp.contentMode = UIViewContentModeScaleAspectFill;
    tmp.image = [UIImage imageNamed:@"p_logo"];
    [self.view addSubview:tmp];
    self.mIconView = tmp;
    //布局
    [self.mIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTransitionEvent:(PBTransitionEvent)event {
    self.event = [event copy];
}

- (void)maskWillAppear {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    window.opaque = true;
//    UIWindowLevel level = UIWindowLevelStatusBar+10.0f;
//    if (_statusBarHiddenInited) {
//        level = UIWindowLevelNormal+10.0f;
//    }
    window.windowLevel = UIWindowLevelNormal;
    window.backgroundColor = [UIColor whiteColor];
    window.rootViewController = self;
    [window makeKeyAndVisible];
    self.actionWindow = window;
    //动画淡入
    weakify(self)
    self.actionWindow.layer.opacity = 0.01f;
    [UIView animateWithDuration:PBANIMATE_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        strongify(self)
        self.actionWindow.layer.opacity = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            strongify(self)
            PBMAINDelay(2, ^{
                [self dismiss];
            });
        }
    }];
}

- (void)dismiss {
    
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHiddenInited withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:PBANIMATE_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.actionWindow.layer.opacity = 0.01f;
    } completion:^(BOOL finished) {
        [self.actionWindow removeFromSuperview];
        [self.actionWindow resignKeyWindow];
        self.actionWindow = nil;
        if (_event) {
            _event();
        }
    }];
}

@end
