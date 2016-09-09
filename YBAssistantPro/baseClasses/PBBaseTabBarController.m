//
//  PBBaseTabBarController.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/19.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBBaseTabBarController.h"
#import "YBMsgRootCtr.h"
#import "YBTaskRootCtr.h"
#import "YBReserveRootCtr.h"
#import "YBPatientRootCtr.h"
#import "YBPersonalRootCtr.h"
#import "PBBaseNavigationController.h"

@interface PBBaseTabBarItem : UITabBarItem

@end

@implementation PBBaseTabBarItem

- (instancetype)init {
    self = [super init];
    if (self) {
        [self __initSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self __initSetup];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    self = [super initWithTitle:title image:image selectedImage:selectedImage];
    if (self) {
        [self __initSetup];
    }
    return self;
}

- (void)__initSetup {
    
    self.image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.selectedImage = [self.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIColor *iconTintColor = [UIColor pb_colorWithHexString:PB_TABBAR_TINT_HEX];
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]} forState:UIControlStateNormal];
    [self setTitleTextAttributes:@{NSForegroundColorAttributeName:iconTintColor} forState:UIControlStateSelected];
}

@end

@interface PBBaseTabBarController ()

@end

@implementation PBBaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIColor *iconTintColor = [UIColor pb_colorWithHexString:PB_TABBAR_TINT_HEX];
    //msg module TODO:localizable available
    NSString *title = @"消息";
    UIImage *icon_n = [UIImage imageNamed:@"p_tab_msg_n"];
    UIImage *icon_s = [UIImage imageNamed:@"p_tab_msg_s"];
    icon_s = [icon_s pb_darkColor:iconTintColor lightLevel:1];
    PBBaseTabBarItem *item = [[PBBaseTabBarItem alloc] initWithTitle:title image:icon_n selectedImage:icon_s];
    YBMsgRootCtr *msgCtr = [[YBMsgRootCtr alloc] init];
    PBBaseNavigationController *msgNaviCtr = [[PBBaseNavigationController alloc] initWithRootViewController:msgCtr];
    msgCtr.title = @"壹宝";
    msgNaviCtr.tabBarItem = item;
    
    /*
    //task module
    title = @"任务";
    icon_n = [UIImage imageNamed:@"p_tab_task_n"];
    icon_s = [UIImage imageNamed:@"p_tab_task_s"];
    icon_s = [icon_s pb_darkColor:iconTintColor lightLevel:1];
    item = [[PBBaseTabBarItem alloc] initWithTitle:title image:icon_n selectedImage:icon_s];
    YBTaskRootCtr *taskCtr = [[YBTaskRootCtr alloc] init];
    PBBaseNavigationController *taskNaviCtr = [[PBBaseNavigationController alloc] initWithRootViewController:taskCtr];
    taskCtr.title = title;
    taskNaviCtr.tabBarItem = item;
    
    //reverse module
    title = @"预约";
    icon_n = [UIImage imageNamed:@"p_tab_reverse_n"];
    icon_s = [UIImage imageNamed:@"p_tab_reverse_s"];
    icon_s = [icon_s pb_darkColor:iconTintColor lightLevel:1];
    item = [[PBBaseTabBarItem alloc] initWithTitle:title image:icon_n selectedImage:icon_s];
    YBReserveRootCtr *reverseCtr = [[YBReserveRootCtr alloc] init];
    PBBaseNavigationController *reverseNaviCtr = [[PBBaseNavigationController alloc] initWithRootViewController:reverseCtr];
    reverseCtr.title = title;
    reverseNaviCtr.tabBarItem = item;
    //*/
    
    //patient module
    title = @"联系人";
    icon_n = [UIImage imageNamed:@"p_tab_patient_n"];
    icon_s = [UIImage imageNamed:@"p_tab_patient_s"];
    icon_s = [icon_s pb_darkColor:iconTintColor lightLevel:1];
    item = [[PBBaseTabBarItem alloc] initWithTitle:title image:icon_n selectedImage:icon_s];
    YBPatientRootCtr *patientCtr = [[YBPatientRootCtr alloc] init];
    PBBaseNavigationController *patientNaviCtr = [[PBBaseNavigationController alloc] initWithRootViewController:patientCtr];
    patientCtr.title = title;
    patientNaviCtr.tabBarItem = item;
    
    //personal module
    title = @"我的";
    icon_n = [UIImage imageNamed:@"p_tab_personal_n"];
    icon_s = [UIImage imageNamed:@"p_tab_personal_s"];
    icon_s = [icon_s pb_darkColor:iconTintColor lightLevel:1];
    item = [[PBBaseTabBarItem alloc] initWithTitle:title image:icon_n selectedImage:icon_s];
    YBPersonalRootCtr *personalCtr = [[YBPersonalRootCtr alloc] init];
    PBBaseNavigationController *personalNaviCtr = [[PBBaseNavigationController alloc] initWithRootViewController:personalCtr];
    personalCtr.title = title;
    personalNaviCtr.tabBarItem = item;
    
    //self.viewControllers = @[msgNaviCtr, taskNaviCtr, reverseNaviCtr, patientNaviCtr, personalNaviCtr];
    self.viewControllers = @[msgNaviCtr, patientNaviCtr, personalNaviCtr];
    
    [self setupMaxium];
    
    //add im's multicast delegate
    dispatch_queue_t queue = dispatch_queue_create("com.pullbear.im.ios-listen", DISPATCH_QUEUE_CONCURRENT);
    //should be main queue for update UI
    //dispatch_queue_t queue = dispatch_get_main_queue();
    //weakify(self)
    [[PBIMEngine shared] addDelegate:msgCtr delegateQueue:queue];
    
    //init im's module
    if ([[PBDBEngine shared] wetherUsrDidAuthorization]) {
        [[PBIMEngine shared] reStart];
    }else{
        [[PBIMEngine shared] start];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupMaxium {
    NSArray<UITabBarItem *> *items = [self.tabBar items];
    UIColor *redColor = [UIColor redColor];
    UIColor *textColor = [UIColor whiteColor];
    [items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.badgeBgColor = redColor;
        obj.badgeTextColor = textColor;
        [obj setBadgeMaximumBadgeNumber:99];
    }];
}

- (void)updateBadgeStyle:(WBadgeStyle)style value:(NSUInteger)num atIndex:(NSUInteger)index {
    NSArray<UITabBarItem *> *items = [self.tabBar items];
    NSUInteger mCounts = items.count;
    if (index >= mCounts) {
        return;
    }
    UITabBarItem *barItem = items[index];
    [barItem showBadgeWithStyle:style value:num animationType:WBadgeAnimTypeNone];
}

- (void)clearBadgeAtIndex:(NSUInteger)index {
    NSArray<UITabBarItem *> *items = [self.tabBar items];
    [items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (index == idx) {
            [obj clearBadge];
            *stop = true;
        }
    }];
}

@end
