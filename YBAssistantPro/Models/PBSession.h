//
//  PBSession.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/27.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

@interface PBSession : NSObject
/**
 *  @brief 当前会话ID 即对方的voip
 */
@property (nonatomic, copy) NSString *sessionID;
/**
 *  @brief 创建时间 显示的时间 毫秒
 */
@property (nonatomic, assign) long long dateTime;
/**
 *  @brief lastMsgType 与消息表msgType一样
 */
@property (nonatomic, assign) int type;
/**
 *  @brief 显示的内容
 */
@property (nonatomic, copy) NSString *text;
/**
 *  @brief 未读消息数
 */
@property (nonatomic, assign) int unreadCount;
/**
 *  @brief 总消息数
 */
@property (nonatomic, assign) int sumCount;
/**
 *  @brief SDK之外第三方服务器（这里指自己搭建的服务器）生成的会话ID 唯一代表当前会话
 */
@property (nonatomic, copy) NSString *conversationId;
/**
 *  @brief 助理ID 其实就是自己的用户ID
 */
@property (nonatomic, copy) NSString *assistantUserId;
/**
 *  @brief 会话对方ID 其实就是对方的用户ID
 */
@property (nonatomic, copy) NSString *customerUserId;
/**
 *  @brief 对方的头像
 */
@property (nonatomic, copy) NSString *headImg;
/**
 *  @brief 对方的昵称
 */
@property (nonatomic, copy) NSString *nickName;
/**
 *  @brief 回复对方状态
 */
@property (nonatomic, assign) int replyStatus;
/**
 *  @brief 最后一条数据的表单类型:问诊、咨询 etc
 */
@property (nonatomic, copy) NSString *lastMsgUserData;
/**
 *  @brief 消息发送状态 仅对Session中最后一条消息是自己发送的起效
 *  -1发送失败 0发送成功 1发送中 2接收成功 (默认0)
 */
@property (nonatomic, assign) int sendState;
/**
 *  @brief 是否置顶 0否 1是 (默认0)
 */
@property (nonatomic, assign) int sticky;

@end
