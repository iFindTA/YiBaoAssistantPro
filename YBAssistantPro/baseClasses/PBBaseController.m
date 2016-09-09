//
//  PBBaseController.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/19.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBBaseController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "PBLoginProfiler.h"
#import "PBBaseTabBarController+Hidden.h"

@interface PBBaseController ()

@property (nonatomic, strong) UIView *errorView;
@property (nonatomic, assign) PBViewErrorType errorType;
//记录自己是否是被模态出来的
@property (nonatomic, assign) BOOL isModal;

@end

@implementation PBBaseController

#pragma mark -- dealloc |
- (void)dealloc {
    [[PBAFEngine shared] cancelRequestForClass:self.class];
}

#pragma mark -- init method

- (id)init {
    self = [super init];
    if (self) {
        self.isModal = false;
        self.isInitialized = false;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.isInitialized = false;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isInitialized = false;
    }
    return self;
}
/**
 *  @brief custom init method for url router call
 *
 *  @param aDict the init's params required!
 *
 *  @return the instance
 */
- (id)initWithParams:(NSDictionary * _Nullable)aDict {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark -- custom methods

- (void)loadView {
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isInitialized = false;
    //hidden tabbar when pushed**this property not working performance
    //self.hidesBottomBarWhenPushed = true;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController != nil) {
        self.isModal = self.navigationController.isBeingPresented;
    }else{
        self.isModal = self.isBeingPresented;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:true];
}

#pragma mark -- custom navigationBar item mthods
- (UIBarButtonItem *)barSpacer {
    UIBarButtonItem *barSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    barSpacer.width = -PB_BOUNDARY_OFFSET;
    return barSpacer;
}

- (UIBarButtonItem *)barWithIcon:(NSString *)icon withTarget:(nullable id)target withSelector:(nullable SEL)selector{
    UIColor *color = [UIColor pb_colorWithHexString:@"#FFFFFF"];
    return [self barWithIcon:icon withColor:color withTarget:target withSelector:selector];
}

- (UIBarButtonItem *)barWithIcon:(NSString *)icon withColor:(UIColor *)color withTarget:(nullable id)target withSelector:(nullable SEL)selector{
    return [self barWithIcon:icon withSize:PB_NAVIBAR_ITEM_SIZE withColor:color withTarget:target withSelector:selector];
}

- (UIBarButtonItem *)barWithIcon:(NSString *)icon withSize:(NSInteger)size withColor:(UIColor *)color withTarget:(nullable id)target withSelector:(nullable SEL)selector{
    UIImage *bar_img = [UIImage pb_iconFont:nil withName:icon withSize:size withColor:color];
    return [self assembleBar:bar_img withTarget:target withSelector:selector];
}

- (UIBarButtonItem *)barWithImage:(UIImage *)icon withTarget:(id)target withSelector:(SEL)selector {
    return [self barWithImage:icon withColor:nil withTarget:target withSelector:selector];
}

- (UIBarButtonItem *)barWithImage:(UIImage *)icon withColor:(UIColor *)color withTarget:(id)target withSelector:(SEL)selector {
    if (color != nil) {
        icon = [icon pb_darkColor:color lightLevel:1];
    }
    return [self assembleBar:icon withTarget:target withSelector:selector];
}

- (UIBarButtonItem *)assembleBar:(UIImage *)icon withTarget:(id)target withSelector:(SEL)selector {
    
    CGSize m_bar_size = {PB_NAVIBAR_ITEM_SIZE, PB_NAVIBAR_ITEM_SIZE};
    UIButton *menu = [UIButton buttonWithType:UIButtonTypeCustom];
    //    menu.backgroundColor = [UIColor blueColor];
    menu.frame = (CGRect){.origin = CGPointZero,.size = m_bar_size};
    [menu setImage:icon forState:UIControlStateNormal];
    //    [menu setBackgroundImage:icon forState:UIControlStateNormal];
    [menu addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithCustomView:menu];
    return bar;
}

- (void)popUpLayer {
    NSArray *stacks = self.navigationController.viewControllers;
    if (stacks.count <= 1 && self.isModal) {
        [self dismissViewControllerAnimated:true completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:true];
    }
    
    //TODO:auto check self is pushed or presented!
}

#pragma mark -- error logic's handler

- (UIView *)generateErrorViewByType:(PBViewErrorType)type {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    bounds = CGRectZero;
    UIView *tmp = [[UIView alloc] initWithFrame:CGRectZero];
    tmp.backgroundColor = [UIColor whiteColor];
    NSString *alertInfo;
    if (type == PBViewErrorType404) {
        alertInfo = @"未找到相关资源";
    }else if (type == PBViewErrorTypeNetwork){
        alertInfo = @"网络不佳，点击重试！";
    }else if (type == PBViewErrorTypeEmpty){
        alertInfo = @"暂无任何数据！";
    }
    UIFont *font = PBSysBoldFont(PBFontTitleSize*1.5);
    UILabel *label = [[UILabel alloc] init];
    label.userInteractionEnabled = true;
    label.font = font;
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = alertInfo;
    [tmp addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(tmp);
    }];
    
    //[tmp layoutIfNeeded];
    return tmp;
}

- (void)showErrorType:(PBViewErrorType)type inView:(UIView *)superview layoutMargin:(UIView *)layout withTarget:(nullable id)target withSelector:(SEL)selector {
    [self removeErrorAlertView];
    if (superview && layout && PBViewErrorTypeNone != type) {
        self.errorType = type;
        UIView *tmp = [self generateErrorViewByType:type];
        [superview addSubview:tmp];
        self.errorView = tmp;
        [tmp mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(layout).insets(UIEdgeInsetsMake(50, 0, 0, 0));
        }];
        if (target && selector) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            [tmp addGestureRecognizer:tap];
        }
    }
}

- (void)removeErrorAlertView {
    if (self.errorView) {
        [self.errorView removeFromSuperview];
        _errorView = nil;
    }
    self.errorType = PBViewErrorTypeNone;
}

#pragma mark -- UITabBar

- (AppDelegate *)appDelegate {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate;
}

- (PBBaseTabBarController *)rootTabBar {
    AppDelegate *delegate = [self appDelegate];
    if (delegate) {
        PBBaseTabBarController *tabBarCtr = [delegate rootTabBar];
        return tabBarCtr;
    }
    return nil;
}

- (void)hideTabBar:(BOOL)hidden animated:(BOOL)animated {
    PBBaseTabBarController *tabBarCtr = [self rootTabBar];
    [tabBarCtr setTabBarHidden:hidden animated:animated delaysContentResizing:true completion:^{
        
    }];
}

- (void)switchRoot2MainComponent:(BOOL)ismain {
    AppDelegate *delegate = [self appDelegate];
    [delegate switchRoot2MainComponent:ismain isInitMode:false];
}

- (void)setBadgeValue:(NSInteger)value atIndex:(NSUInteger)idx {
    PBBaseTabBarController *tabBarCtr = [self rootTabBar];
    if (value < 0) {
        [tabBarCtr clearBadgeAtIndex:idx];
        return;
    }
    WBadgeStyle style = WBadgeStyleNew;
    if (value == 0) {
        style = WBadgeStyleRedDot;
    }else if (value > 0 && value < 1000){
        style = WBadgeStyleNumber;
    }
    [tabBarCtr updateBadgeStyle:style value:value atIndex:idx];
}

- (void)clearBadgeAtIndex:(NSUInteger)idx {
    PBBaseTabBarController *tabBarCtr = [self rootTabBar];
    [tabBarCtr clearBadgeAtIndex:idx];
}

#pragma mark -- handle the response error

- (void)handleRequestError:(NSError *)error withCompleteion:(nullable void (^)(BOOL, id _Nullable))success{
    if (!error) {
        return;
    }
    NSUInteger code = [error code];
    if (code == 0) {
        //成功 无需理会
    }else if (code == 99 || code == 1000){
        //需要登录授权
        if ([NSStringFromClass(self.class) rangeOfString:@"login"].location != NSNotFound) {
            //发起请求本身就是登录页面 无需弹出
            PBMAINDelay(PBANIMATE_DURATION, ^{
                [SVProgressHUD showErrorWithStatus:error.domain];
            });
        }else{
            //TODO:切换到登录页面
            UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"当前登录状态已失效，请重新登录！" message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            weakify(self)
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                strongify(self)
                [PBIMEngine released];
                [self switchRoot2MainComponent:false];
            }];
            [alertCtr addAction:action];
            PBMAINDelay(PBANIMATE_DURATION, ^{
                strongify(self)
                [self presentViewController:alertCtr animated:true completion:nil];
            });
            
        }
    }else{
        //其他提示性HUD错误
        PBMAINDelay(PBANIMATE_DURATION, ^{
            [SVProgressHUD showErrorWithStatus:error.domain];
        });
    }
}

@end
