//
//  PBBaseController.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/19.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBConstants.h"
#import "PBAFEngine.h"
#import "PBDBEngine.h"
#import "PBIMEngine.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    PBViewErrorTypeNone                 =       0,
    PBViewErrorType404                  =       1 << 0,
    PBViewErrorTypeNetwork              =       1 << 1,
    PBViewErrorTypeEmpty                =       1 << 2
}PBViewErrorType;

@interface PBBaseController : UIViewController

/**
 *  @brief wether initialized
 */
@property (nonatomic, assign) BOOL isInitialized;

/**
 *  @brief wether should refresh data when called:viewWillApppear method
 */
@property (nonatomic, assign) BOOL shouldRefreshWhenWillShow;

/**
 *  @brief generate fixed space baritem
 *
 *  @return the bar item
 */
- (UIBarButtonItem *)barSpacer;

/**
 *  @brief generate custom barItem: default::color:FFFFFF/size:31
 *
 *  @param icon     iconfont's name
 *  @param target   iconfont's target
 *  @param selector iconfont's selector
 *
 *  @return the bar item
 */
- (UIBarButtonItem *)barWithIcon:(NSString *)icon withTarget:(nullable id)target withSelector:(nullable SEL)selector;

/**
 *  @brief generate custom barItem: default::size:31
 *
 *  @param icon  iconfont's name
 *  @param color bar's front color
 *  @param target   iconfont's target
 *  @param selector iconfont's selector
 *
 *  @return the bar item
 */
- (UIBarButtonItem *)barWithIcon:(NSString *)icon withColor:(UIColor *)color withTarget:(nullable id)target withSelector:(nullable SEL)selector;

/**
 *  @brief generate custom barItem: default::size:31
 *
 *  @param icon     the icon image
 *  @param target   bar's target
 *  @param selector bar's selector
 *
 *  @return the bar item
 */
- (UIBarButtonItem *)barWithImage:(UIImage *)icon withTarget:(nullable id)target withSelector:(nullable SEL)selector;

/**
 *  @brief generate custom barItem: default::size:31
 *
 *  @param icon     the icon image
 *  @param color    the icon image's tintColor, default is whiteColor
 *  @param target   bar's target
 *  @param selector bar's selector
 *
 *  @return the bar item
 */
- (UIBarButtonItem *)barWithImage:(UIImage *)icon withColor:(nullable UIColor *)color withTarget:(nullable id)target withSelector:(nullable SEL)selector;

/**
 *  @brief call pop
 */
- (void)popUpLayer;

/**
 *  @brief 统一处理错误页面
 *
 *  @attention:***此方法需要配合 子类方法使用
 *  @param type 页面类型
 *  @param view 被添加上的view
 */
- (void)showErrorType:(PBViewErrorType)type inView:(UIView *)superview layoutMargin:(UIView *)layout withTarget:(nullable id)target withSelector:(nullable SEL)selector;
- (void)removeErrorAlertView;

/**
 *  @brief hidden/show root tabbar
 *
 *  @param hidden   wether hidden
 *  @param animated wether animated
 */
- (void)hideTabBar:(BOOL)hidden animated:(BOOL)animated;

/**
 *  @brief switch root controller
 *
 *  @param ismain wether main
 */
- (void)switchRoot2MainComponent:(BOOL)ismain;

/**
 *  @brief update tabBar's item badge value
 *
 *  @param value the value
 *  @param idx   the item's index
 */
- (void)setBadgeValue:(NSInteger)value atIndex:(NSUInteger)idx;
- (void)clearBadgeAtIndex:(NSUInteger)idx;

/**
 *  @brief handle the request's response error
 *
 *  @param error 
 */
- (void)handleRequestError:(NSError *)error withCompleteion:(nullable void(^)(BOOL  success, id _Nullable usr))success;

NS_ASSUME_NONNULL_END

@end
