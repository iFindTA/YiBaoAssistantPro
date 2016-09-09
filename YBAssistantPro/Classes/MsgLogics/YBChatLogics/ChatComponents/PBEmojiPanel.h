//
//  PBEmojiPanel.h
//  YBAssistantPro
//
//  Created by nanhu on 16/9/2.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBBaseView.h"

@protocol PBEmojiPanelDelegate;
@interface PBEmojiPanel : PBBaseView

/**
 *  @brief 表情键盘委托
 */
@property (nonatomic, weak) id<PBEmojiPanelDelegate> delegate;

/**
 *  @brief 是否激活emoji键盘的发送按钮
 *
 *  @param enable 是否激活
 */
- (void)enableEmojiKeyboardSendState:(BOOL)enable;

@end


@protocol PBEmojiPanelDelegate <NSObject>
@optional
/**
 *  @brief 表情选择事件回调
 *
 *  @param panel 键盘
 *  @param emoji 表情
 */
- (void)emojiPanel:(PBEmojiPanel *)panel didSelectEmoji:(NSString *)emoji;

/**
 *  @brief 表情键盘选择退格键
 *
 *  @param panel 键盘
 */
- (void)emojiPanelDidSelectBackward:(PBEmojiPanel *)panel;

/**
 *  @brief 表情键盘选择发送键
 *
 *  @param panel 键盘
 */
- (void)emojiPanelDidSelectSendEvent:(PBEmojiPanel *)panel;

@end