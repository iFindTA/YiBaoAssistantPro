//
//  PBChatInputBar.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/27.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBBaseView.h"
#import "PBEmojiPanel.h"
#import "PBMorePanel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    PBChatInputStateNone                        =       1   <<  0,
    PBChatInputStateText                        =       1   <<  1,
    PBChatInputStateAudio                       =       1   <<  2,
    PBChatInputStateEmoji                       =       1   <<  3,
    PBChatInputStateMore                        =       1   <<  4
}PBChatInputState;

@class PBEmojiPanelDelegate;
@protocol PBChatInputBarDelegate;
@interface PBChatInputBar : PBBaseView<PBEmojiPanelDelegate, PBMorePanelDelegate>

/**
 *  @brief 委托
 */
@property (nonatomic, weak) id<PBChatInputBarDelegate> delegate;

/**
 *  @brief 初始化方法
 *
 *  @param ctr 输入工具条依附的根视图控制器
 *
 *  @return 输入工具条
 */
- (id)initWithDependencyRoot:(UIViewController *)ctr;

/**
 *  @brief 结束输入状态(外部如 点击/滚动 cell)
 */
- (void)outTriggerEndFirstResponder;

/**
 *  @brief wether enable audio input
 *
 *  @param enable state
 */
- (void)enableAudioInputAction:(BOOL)enable;
- (void)enableEmojiInputAction:(BOOL)enable;

/**
 *  @brief 获取当前输入工具条中输入的文本信息
 *
 *  @return 文本信息
 */
- (NSString *)currentInputInfo;

@end

@protocol PBChatInputBarDelegate <NSObject>
@optional

/**
 *  @brief 切换输入状态（语音、文本、更多）
 *
 *  @param bar       输入工具条
 *  @param state     将要切换到的状态
 *  @param keyHeight 输入键盘（语音、emoji、更多）高度
 */
- (void)chatInputBar:(PBChatInputBar *)bar willChange2InputState:(PBChatInputState)state withKeyboardHeight:(CGFloat)keyHeight;

/**
 *  @brief 输入工具条 输入文本信息变化回调
 *
 *  @param bar  输入工具条
 *  @param info 文本信息
 */
- (void)chatInputBar:(PBChatInputBar *)bar didChangeInputInfo:(NSString *)info;

/**
 *  @brief 更多功能选择了某一项功能
 *
 *  @param bar 输入工具条
 *  @param url 选择的功能点入口
 */
- (void)chatInputBar:(PBChatInputBar *)bar didSelectedMoreFunctionRouter:(nullable NSURL *)url;

/**
 *  @brief 工具条将要发送输入的文本信息
 *
 *  @param bar 输入工具条
 *  @param msg 文本信息
 */
- (void)chatInputBar:(PBChatInputBar *)bar willSendText:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
