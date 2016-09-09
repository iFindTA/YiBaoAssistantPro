//
//  PBChatContenter.h
//  YBAssistantPro
//
//  Created by nanhu on 16/9/5.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PBChatContenter : UIButton

/**
 *  @brief 背景bubble
 */
@property (nonatomic, strong) UIImageView *cBubble;

/**
 *  @brief audio 背景
 */
@property (nonatomic, strong) UIView *cAudioBgView;
/**
 *  @brief audio 时长
 */
@property (nonatomic, strong) UILabel *cAudioDuration;
/**
 *  @brief audio 播放动画
 */
@property (nonatomic, strong) UIImageView *cAudioAnimater;
/**
 *  @brief 加载、发送指示器
 */
@property (nonatomic, strong) UIActivityIndicatorView *cIndicator;

/**
 *  @brief 是否是自己发送的消息
 */
@property (nonatomic, assign) BOOL isSelfMsg;

/**
 *  @brief 是否显示图片mask（当消息是图片时）
 *
 *  @param show wether show
 */
- (void)showImageMask:(BOOL)show;

- (void)audioDidBeginLoadState;

- (void)audioDidLoadState;

- (void)audioDidStopPlay;

@end

@interface PBChatMsgState : UIButton

@end
