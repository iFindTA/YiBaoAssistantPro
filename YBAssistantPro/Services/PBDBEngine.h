//
//  PBDBEngine.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/18.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PBUsr.h"

@class PBSession;
@class ECMessage;
@interface PBDBEngine : NSObject

NS_ASSUME_NONNULL_BEGIN

/**
 *  @brief db' engine
 *
 *  @return singleton instance
 */
+ (PBDBEngine *)shared;

/**
 *  @brief something to be done after init method
 */
- (void)setupDB;

/**
 *  @brief dateformatter
 *
 *  @return the singleton
 */
- (NSDateFormatter *)dateDefaultFormatter;
- (NSDateFormatter *)dateFormatter4Style:(NSString *)style;

/**
 *  @brief wether usr login api server
 *
 *  @return result
 */
- (BOOL)wetherUsrDidAuthorization;

#pragma mark -- 登录用户有关
/**
 *  @brief 保存当前登录用户
 *
 *  @param usr 用户
 *
 *  @return 结果
 */
- (BOOL)saveAuthor:(PBUsr *)usr;

/**
 *  @brief 获取当前用户id
 *
 *  @return id
 */
- (NSString *)authorID;
- (NSString *)authorIMID;
- (NSString *)authorAvatar;
- (NSString *)authorAccount;
- (long long)authorTimeStamp;

/**
 *  @brief 更新当前用户imid（fromVoip）
 *
 *  @param imid id
 *  @param uid  usr id
 *
 *  @return 结果
 */
- (BOOL)updateIMID:(NSString *)imid authorID:(NSString *)uid;

#pragma mark -- session table method

/**
 *  @brief 获取缓存的session列表数据
 *
 *  @return 缓存sessions
 */
- (NSArray <PBSession *>*)getLatestSessions;

/**
 *  @brief 获取session未读数据个数
 *
 *  @return 个数
 */
- (NSUInteger)getLatestSessionUnReadCounts;

/**
 *  @brief 清除所有session
 *
 *  @return 结果
 */
- (BOOL)clearAllSessions;

/**
 *  @brief 保存最新的sessions
 *
 *  @param sessions
 *
 *  @return 结果
 */
- (BOOL)saveNewestSessions:(nullable NSArray<PBSession *>*)sessions;

/**
 *  @brief 更新session未读、已读状态
 *
 *  @param readable  是否已读
 *  @param sessionid id
 *
 *  @return 结果
 */
- (BOOL)wetherReadMsg:(BOOL)readable forSession:(NSString *)sessionid;

/**
 *  @brief 删除一条session
 *
 *  @param sessionid ID
 *
 *  @return 结果
 */
- (BOOL)deleteSession:(NSString *)sessionid;

/**
 *  @brief 更新一条session数据
 *
 *  @param session
 *
 *  @return 结果
 */
- (BOOL)updateSession:(PBSession *)session;

/**
 *  @brief session转字典（聊天页面初始化数据）
 *
 *  @param session
 *
 *  @return 字典
 */
- (NSDictionary *)session2Dictinary:(PBSession *)session;

#pragma mark -- chat table methods --

/**
 *  @brief 保存一条聊天消息
 *
 *  @param msg 消息
 *
 *  @return 结果
 */
- (BOOL)saveLatestNewMsg:(ECMessage *)msg;

/**
 *  @brief 删除一条聊天消息
 *
 *  @param msgid     消息ID
 *  @param sessionid ID
 *
 *  @return 结果
 */
- (BOOL)deleteChatMsg:(NSString *)msgid withSession:(NSString *)sessionid;

/**
 *  @brief 获取与某人(群)的本地聊天数据总数
 *
 *  @param sessionid id
 *
 *  @return 结果
 */
- (NSUInteger)getMsgCounts4Session:(NSString *)sessionid;

/**
 *  @brief 获取与某人(群)的聊天本地历史数据 默认10条
 *
 *  @param timeStamp 开始获取的时间戳 如果为0则默认从现在开始
 *  @param sessionid id
 *
 *  @return 聊天历史信息
 */
- (NSArray *)getMsgsFromTimeStamp:(long long)timeStamp withSession:(NSString *)sessionid;

/**
 *  @brief 判断消息应该在session列表显示的内容
 *
 *  @param msg 消息
 *
 *  @return 结果
 */
- (NSString *)getFileAttribute4Msg:(ECMessage *)msg;

NS_ASSUME_NONNULL_END

@end
