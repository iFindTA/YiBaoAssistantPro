//
//  PBMorePanel.h
//  YBAssistantPro
//
//  Created by nanhu on 16/9/2.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBBaseView.h"

//壹宝服务 快捷回复 发起咨询 咨询反馈 照片 拍照 语音电话
typedef enum {
    PBMorePanelActionNone                       =   1   <<  0,
    PBMorePanelActionService                    =   1   <<  1,
    PBMorePanelActionQuickReply                 =   1   <<  2,
    PBMorePanelActionQuery                      =   1   <<  3,
    PBMorePanelActionFeedback                   =   1   <<  4,
    PBMorePanelActionPhotoAlbum                 =   1   <<  5,
    PBMorePanelActionPhotoCamera                =   1   <<  6,
    PBMorePanelActionLocation                   =   1   <<  7
}PBMorePanelAction;

@protocol PBMorePanelDelegate;
@interface PBMorePanel : PBBaseView

/**
 *  @brief 更多键盘委托
 */
@property (nonatomic, weak) id<PBMorePanelDelegate> delegate;

@end

@protocol PBMorePanelDelegate <NSObject>

/**
 *  @brief 更多键盘选择功能
 *
 *  @param panel 更多键盘
 *  @param type  类型
 */
- (void)moreActionPanel:(PBMorePanel *)panel didSelectActionType:(PBMorePanelAction)type;

@end