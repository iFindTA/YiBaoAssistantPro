//
//  PBIMEngine.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/22.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ECError;
@class ECMessage;
@protocol PBIMMsgHandlerDelegate;
@interface PBIMEngine : NSObject

NS_ASSUME_NONNULL_BEGIN

#pragma mark -- Multicast Delegate

@property (nonatomic, strong) id multicastDelegate;
- (void)addDelegate:(id)delegate delegateQueue:(nullable dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate delegateQueue:(nullable dispatch_queue_t)delegateQueue;

/**
 *  @brief im' engine
 *
 *  @return singleton instance
 */
+ (PBIMEngine *)shared;

+ (void)released;

- (void)start;

- (void)reStart;

/**
 *  @brief 检查当前IM管道状态
 */
- (void)checkConnectState;

/**
 *  @brief 当前会话sessionID 只在进入chat页面设置
 */
@property (nonatomic, copy, nullable) NSString *chatSessionID;

@end

typedef enum : NSUInteger {
    PBMSGPullStateNone,
    PBMSGPullStateConnecting,
    PBMSGPullStateError,
    PBMSGPullStatePulling
} PBMSGPullState;

@protocol PBIMMsgHandlerDelegate <NSObject>

@optional
/**
 *  @brief 新消息到达回调
 *
 *  @param msg 新消息
 */
- (void)newIMMsgDidReceived:(ECMessage *)msg;

/**
 *  @brief 当前消息pull状态 对应消息列表的title
 *
 *  @param state 状态
 */
- (void)newIMMsgPullState:(PBMSGPullState)state;

/**
 *  @brief 帐号异地登录 被退出
 *
 *  @param error 错误提示
 */
- (void)accountKnickedOff:(ECError *)error;

/**
 *  @brief 启动引擎失败回调
 *
 *  @param error 错误
 */
- (void)initEngineError:(NSError *)error;

- (void)refreshSessions:(nullable NSArray *)sessions;

NS_ASSUME_NONNULL_END

@end
