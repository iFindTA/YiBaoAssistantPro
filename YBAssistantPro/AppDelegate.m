//
//  AppDelegate.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/18.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "PBBaseTabBarController.h"
#import "PBBaseNavigationController.h"
#import "PBLoginProfiler.h"
#import "PBTransitionMasker.h"
#import "PBIMEngine.h"
#import "PBDBEngine.h"
#import "JPEngine.h"
#import "PBChatProfiler.h"

@interface AppDelegate ()<UITabBarControllerDelegate>

@property (nonatomic, strong) PBBaseTabBarController *rootTabBarCtr;
//@property (nonatomic, strong) PBBaseNavigationController *rootNaviCtr;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [PBDBEngine shared];[PBAFEngine shared];
    usleep(0.2);
    [[PBDBEngine shared] setupDB];
    [PBMediator setupForTrustSchemes:@[PB_SAFE_SCHEME]];
    [JPEngine startEngine];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"dynamicPatch" ofType:@"js"];
    [JPEngine evaluateScriptWithPath:filePath];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    /*TODO:测试
    PBChatProfiler *chatProfiler = [[PBChatProfiler alloc] init];
    UINavigationController *naviRoot = [[UINavigationController alloc] initWithRootViewController:chatProfiler];
    naviRoot.navigationBar.translucent = false;
    [self setupDefaultUITheme];
    self.window.rootViewController = naviRoot;
    [self.window makeKeyAndVisible];
    //*/
    
    //*
    BOOL usrDidLogin = [self doseAnyUsrLoginedBefore];
    [self switchRoot2MainComponent:usrDidLogin isInitMode:true];
    //*/
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    //YiBao://PBChatProfiler/initWithParams:/?sessionid=8763
    if ([[PBMediator shared] shouldDisplayURL:url]) {
        UIViewController *ctr = [[PBMediator shared] remoteCallWithURL:url];
        ctr.hidesBottomBarWhenPushed = true;
        [self.rootNavigationController pushViewController:ctr animated:true];
    }
    return true;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -- getter

- (PBBaseTabBarController *)rootTabBar {
    return self.rootTabBarCtr;
}

#pragma mark -- query pre login usr

/**
 *  @brief (启动页覆盖下)查询是否有用户登录过 && token不过期 && 用户未主动退出 ｜如无网络则视为不过期
 *
 *  @return 如有合法用户则显示主界面 否则为登录界面
 */
- (BOOL)doseAnyUsrLoginedBefore {
    BOOL ret = false;
    
    
    return ret;
}

#pragma mark -- main or login UI swtich

- (void)setupDefaultUITheme {
    //color text setting
    if (self.rootTabBarCtr) {
        self.rootTabBarCtr.tabBar.translucent = false;
        self.rootTabBarCtr.tabBar.barTintColor = [UIColor whiteColor];
    }
    UIColor *iconTintColor = [UIColor pb_colorWithHexString:PB_TABBAR_TINT_HEX];
    [[UINavigationBar appearance] setTranslucent:false];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:iconTintColor];
    NSDictionary *attributs = @{
                                NSForegroundColorAttributeName:[UIColor whiteColor],
                                NSFontAttributeName:PBSysFont(21)
                                };
    [[UINavigationBar appearance] setTitleTextAttributes:attributs];
}

- (void)switchRoot2MainComponent:(BOOL)ismain isInitMode:(BOOL)isInit {
    if (!isInit) {
        weakify(self)
        PBTransitionMasker *masker = [[PBTransitionMasker alloc] init];
        [masker handleTransitionEvent:^{
            strongify(self)
            if (ismain) {
                PBBaseTabBarController *rootTabBarCtr = [[PBBaseTabBarController alloc] init];
                rootTabBarCtr.delegate = self;
//                PBBaseNavigationController *rootNaviCtr = [[PBBaseNavigationController alloc] initWithRootViewController:rootTabBarCtr];
//                rootNaviCtr.navigationBarHidden = true;//this way can't swip back
//                rootNaviCtr.navigationBar.hidden = true;
                self.window.rootViewController = rootTabBarCtr;
//                self.rootNaviCtr = rootNaviCtr;
                self.rootTabBarCtr = rootTabBarCtr;
                [self.window makeKeyAndVisible];
            }else{
                //stop the im engine
                [PBIMEngine released];
                self.window.rootViewController = nil;
                PBLoginProfiler *logger = [[PBLoginProfiler alloc] init];
                logger.hidesBottomBarWhenPushed = true;
                weakify(self)
                [logger handleLoginModuleEvent:^(BOOL success, NSDictionary * _Nullable info) {
                    strongify(self)
                    self.window.rootViewController = nil;
                    weakify(self)
                    PBTransitionMasker *masker = [[PBTransitionMasker alloc] init];
                    [masker handleTransitionEvent:^{
                        strongify(self)
                        self.rootTabBarCtr = [[PBBaseTabBarController alloc] init];
                        self.rootTabBarCtr.delegate = self;
                        //self.rootNaviCtr = [[PBBaseNavigationController alloc] initWithRootViewController:self.rootTabBarCtr];
                        //self.rootNaviCtr.navigationBar.hidden = true;
                        self.window.rootViewController = self.rootTabBarCtr;
                        //[self setupDefaultUITheme];
                        [self.window makeKeyAndVisible];
                    }];
                    [masker maskWillAppear];
                    
                }];
                PBBaseNavigationController *rootNaviCtr = [[PBBaseNavigationController alloc] initWithRootViewController:logger];
                self.window.rootViewController = rootNaviCtr;
                if (_rootTabBarCtr) _rootTabBarCtr = nil;
                [self.window makeKeyAndVisible];
            }
        }];
        [masker maskWillAppear];
        self.window.rootViewController = nil;
    }else{
        
        ismain = [[PBDBEngine shared] wetherUsrDidAuthorization];
        
        if (ismain) {
            PBBaseTabBarController *rootTabBarCtr = [[PBBaseTabBarController alloc] init];
            rootTabBarCtr.delegate = self;
            //PBBaseNavigationController *rootNaviCtr = [[PBBaseNavigationController alloc] initWithRootViewController:rootTabBarCtr];
            //rootNaviCtr.navigationBar.hidden = true;
            self.window.rootViewController = rootTabBarCtr;
            //self.rootNaviCtr = rootNaviCtr;
            self.rootTabBarCtr = rootTabBarCtr;
            [self.window makeKeyAndVisible];
        }else{
            //stop the im engine
            [PBIMEngine released];
            PBLoginProfiler *logger = [[PBLoginProfiler alloc] init];
            logger.hidesBottomBarWhenPushed = true;
            weakify(self)
            [logger handleLoginModuleEvent:^(BOOL success, NSDictionary * _Nullable info) {
                strongify(self)
                self.window.rootViewController = nil;
                weakify(self)
                PBTransitionMasker *masker = [[PBTransitionMasker alloc] init];
                [masker handleTransitionEvent:^{
                    strongify(self)
                    self.rootTabBarCtr = [[PBBaseTabBarController alloc] init];
                    self.window.rootViewController = self.rootTabBarCtr;
                    //[self setupDefaultUITheme];
                    [self.window makeKeyAndVisible];
                }];
                [masker maskWillAppear];
                
            }];
            PBBaseNavigationController *rootNaviCtr = [[PBBaseNavigationController alloc] initWithRootViewController:logger];
            self.window.rootViewController = rootNaviCtr;
            if (_rootTabBarCtr) _rootTabBarCtr = nil;
            [self.window makeKeyAndVisible];
        }
    }
    
    [self setupDefaultUITheme];
}
//获取当前正在显示的导航根视图
- (PBBaseNavigationController *)rootNavigationController {
    if (!self.rootTabBarCtr) {
        return nil;
    }
    PBBaseNavigationController *destRootNavigationCtr = nil;
    UIViewController *tmpCtr = self.rootTabBarCtr.selectedViewController;
    if ([tmpCtr isKindOfClass:[PBBaseNavigationController class]]) {
        destRootNavigationCtr = (PBBaseNavigationController *)tmpCtr;
    }
    return destRootNavigationCtr;
}

@end
