//
//  PBBaseTabBarController.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/19.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WZLBadgeImport.h>
#import "PBConstants.h"

@interface PBBaseTabBarController : UITabBarController

- (void)updateBadgeStyle:(WBadgeStyle)style value:(NSUInteger)num atIndex:(NSUInteger)index;

- (void)clearBadgeAtIndex:(NSUInteger)index;

@end
