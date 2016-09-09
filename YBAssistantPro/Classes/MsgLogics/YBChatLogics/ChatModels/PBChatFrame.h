//
//  PBChatFrame.h
//  YBAssistantPro
//
//  Created by nanhu on 16/9/4.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 拆包消息类型（其实没有必要 因为cellClass已经指明了类型）
 */
typedef enum {
    PBChatMsgTypeNone                       =       1   <<  0,
    PBChatMsgTypeText                       =       1   <<  1,
    PBChatMsgTypeImage                      =       1   <<  2,
    PBChatMsgTypeAudio                      =       1   <<  3,
    PBChatMsgTypeAudioCall                  =       1   <<  4,
    PBChatMsgTypeVideoCall                  =       1   <<  5,
    PBChatMsgTypeForm                       =       1   <<  6
} PBChatMsgType;

@class ECMessage;
@class PBSession;
@class PBChatMessage;
@interface PBChatFrame : NSObject

NS_ASSUME_NONNULL_BEGIN

/**
 *  @brief 具体的消息实例
 */
@property (nonatomic, strong, readonly) PBChatMessage *msg;

/**
 *  @brief cell高度 如果小于等于0 则计算大小
 */
@property (nonatomic, assign, readonly, getter=getCellHeight) CGFloat cellHeight;

/**
 *  @brief 是否显示时间
 */
@property (nonatomic, assign, readonly, getter=shouldShowStamp) BOOL showStamp;
/**
 *  @brief 时间戳
 */
@property (nonatomic, assign, readonly, getter=getTimeStamp) long long timeStamp;

/**
 *  @brief 消息显示的cell identifier
 */
@property (nonatomic, copy, readonly, getter=getCellIdentifier) NSString *cellIdentifier;

/**
 *  @brief 消息显示的cell class
 */
@property (nonatomic, strong, readonly, getter=getCellClass) Class cellClass;

/**
 *  @brief 标记该消息对应的cell class 是否存在 否的话则"该版本不支持查看该消息"
 */
@property (nonatomic, assign, readonly) BOOL isCellClassExist;

/**
 *  @brief 消息发送状态
 */
@property (nonatomic, assign) BOOL sendState;

/**
 *  @brief 是否是自己发送的消息
 */
@property (nonatomic, assign, readonly) BOOL isSelfSend;

/**
 *  @brief 该消息的所属用户头像
 */
@property (nonatomic, copy, readonly) NSString *usrAvatar;

/**
 *  @brief 消息拆包类型 (此属性已经废弃 因拆包时已经指明cell类型)
 */
@property (nonatomic, assign, readonly) PBChatMsgType msgType /*NS_DEPRECATED_IOS(2_0, 8_0)*/;

#pragma mark -- Text Cell Properties

/**
 *  @brief 文本cell 显示内容
 */
@property (nonatomic, copy) NSString *displayText;
/**
 *  @brief 文本cell 显示内容的区域（包括间隔 其实就是整个背景的区域）
 */
@property (nonatomic, assign) CGSize contentSize;

#pragma mark -- init 初始化方法

/**
 *  @brief 初始化方法
 *
 *  @param msg 具体的消息
 *  @param preTime 上次显示时间戳:毫秒
 *
 *  @return 实例
 */
- (id)initWithMsg:(ECMessage *)msg withPreStamp:(long long)preTime;

/**
 *  @brief 初始化方法
 *
 *  @param session 具体的session
 *  @param preTime 上次显示时间戳:毫秒
 *
 *  @return 实例
 */
- (id)initWithSession:(PBSession *)session withPreStamp:(long long)preTime;

/**
 *  @brief 初始化方法
 *
 *  @param msg     主要是指聊天历史消息类型
 *  @param preTime 上次显示时间戳:毫秒
 *
 *  @return 实例
 */
- (id)initWithChatMsg:(PBChatMessage *)msg withPreStamp:(long long)preTime;

@end

#pragma mark -- 历史消息model

@interface PBChatMessage : NSObject
/**
 *  @brief 消息ID（唯一）
 */
@property (nonatomic, copy) NSString *msgId;
/**
 *  @brief  1.文本消息, 4.图片消息   (此类型跟着第三方一致)
 */
@property (nonatomic, assign) PBChatMsgType msgType;
/**
 *  @brief 该条消息的目标者voip
 */
@property (nonatomic, copy) NSString *toVoIp;
/**
 *  @brief 该条消息的发送者voip
 */
@property (nonatomic, copy) NSString *fromVoIp;
/**
 *  @brief 消息体
 */
@property (nonatomic, copy) NSString *content;
/**
 *  @brief 创建时间(毫秒)
 */
@property (nonatomic, copy) NSString *createTimeStamp;
/**
 *  @brief 附加字段 默认为空字符串或者 JSON格式字符串 "{}"
 */
@property (nonatomic, copy) NSString *userData;

@end

NS_ASSUME_NONNULL_END
