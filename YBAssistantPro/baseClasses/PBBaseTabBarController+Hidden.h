//
//  PBBaseTabBarController+Hidden.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/19.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBBaseTabBarController.h"

@interface PBBaseTabBarController (Hidden)

@property(nonatomic, getter=isTabBarHidden) BOOL tabBarHidden;
@property(nonatomic, readonly, getter=isTabBarAnimating) BOOL tabBarAnimating;

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated completion:(void (^)(void))completion;

//
// NOTE:
// For above methods, default delaysContentResizing = NO.
// Set delaysContentResizing=YES when stretching UITableView, which often clips bottom content on bounds-change.
//
- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated delaysContentResizing:(BOOL)delaysContentResizing completion:(void (^)(void))completion;

@end
