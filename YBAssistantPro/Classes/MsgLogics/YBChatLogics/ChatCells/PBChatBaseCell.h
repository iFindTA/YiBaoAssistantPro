//
//  PBChatBaseCell.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/27.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBConstants.h"
#import "PBChatFrame.h"
#import "PBChatConstants.h"
#import "PBChatContenter.h"
#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ECMessage.h"
#import "ECFileMessageBody.h"
#import "ECTextMessageBody.h"
#import "ECImageMessageBody.h"
#import "ECVoiceMessageBody.h"
#import "ECLocationMessageBody.h"

typedef enum {
    PBChatCellActionTypeNone                        =       1   <<  0,
    PBChatCellActionTypeAvatar                      =       1   <<  1,
    PBChatCellActionTypeCopy                        =       1   <<  2,
    PBChatCellActionTypeDelete                      =       1   <<  3,
    PBChatCellActionTypeResend                      =       1   <<  4,
    PBChatCellActionTypeContent                     =       1   <<  5
}PBChatCellActionType;

@protocol PBChatBaseCellDelegate;
@interface PBChatBaseCell : UITableViewCell

/**
 *  @brief weak 委托者
 */
@property (nonatomic, weak) id<PBChatBaseCellDelegate> delegate;

/**
 *  @brief 数据源
 */
@property (nonatomic, strong, readonly) PBChatFrame *dataSource;
- (PBChatFrame *)getDataFrame;

/**
 *  @brief 用户头像
 */
@property (nonatomic, strong, readonly) UIButton *avatarBtn;

/**
 *  @brief 语音、文字、图片载体
 */
@property (nonatomic, strong, readonly) PBChatContenter *contentBtn;
//正在放送/发送失败 按钮
@property (nonatomic, strong) PBChatMsgState *stateBtn;

///**
// *  @brief 计算cell高度
// *
// *  @param msg 具体的消息
// *
// *  @return 高度
// */
//- (CGFloat)pb_chatCellHeight:(ECMessage *)msg NS_REQUIRES_SUPER;
//
///**
// *  @brief 获取cell重用标示
// *
// *  @param msg 具体的消息
// *
// *  @return 标示
// */
//+ (NSString *)pb_identifier4Msg:(ECMessage *)msg;
//
///**
// *  @brief 获取cell实体类名
// *
// *  @param msg 具体的消息
// *
// *  @return cell类名
// */
//+ (Class)pb_class4Msg:(ECMessage *)msg;
//
///**
// *  @brief 更新cell内容
// *
// *  @param msg 具体的消息
// */
//- (void)pb_updateCellContent4Source:(ECMessage *)msg NS_REQUIRES_SUPER;

/**
 *  @brief 更新cell 内容
 *
 *  @param frame 包含msg的结构体
 */
- (void)updateCellContent4Frame:(PBChatFrame *)frame NS_REQUIRES_SUPER;

/**
 *  @brief 是否激活时间组件
 *
 *  @param enable
 */
- (void)enableTimeStampComponent:(BOOL)enable;

@end

@protocol PBChatBaseCellDelegate <NSObject>
@optional

/**
 *  @brief 聊天cell操作action
 *
 *  @param cell
 *  @param type 操作类型
 */
- (void)chatCell:(PBChatBaseCell *)cell didSelectActionType:(PBChatCellActionType)type;

@end
