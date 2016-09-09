//
//  AppDelegate.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/18.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PBBaseTabBarController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

// key window
@property (strong, nonatomic) UIWindow *window;

/**
 *  @brief get root tabbar controller
 *
 *  @return the bar
 */
- (PBBaseTabBarController *)rootTabBar;

/**
 *  @brief switch the display root view
 *
 *  @param ismain wether show the main view
 *  @param isInit wether is init project
 */
- (void)switchRoot2MainComponent:(BOOL)ismain isInitMode:(BOOL)isInit;

NS_ASSUME_NONNULL_END

@end

