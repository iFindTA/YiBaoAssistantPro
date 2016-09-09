//
//  PBLoginProfiler.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/22.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBBaseController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^PBLoginEvent)(BOOL success, NSDictionary * _Nullable info);

@interface PBLoginProfiler : PBBaseController

/**
 *  @brief the class that should pop to when user logined!
 */
@property (nonatomic, strong, nullable) Class aBackClass;

/**
 *  @brief the class that should replace login vcr when user logined!
 */
@property (nonatomic, strong, nullable) Class aReplaceClass;

/**
 *  @brief the block to be excute after login success
 *
 *  @param event block 
 */
- (void)handleLoginModuleEvent:(PBLoginEvent)event;

/**
 *  @brief hidden the left back button item
 *
 *  @param hidden wether hidden
 */
- (void)hiddenNavigationBarBackItem:(BOOL)hidden;

NS_ASSUME_NONNULL_END

@end
