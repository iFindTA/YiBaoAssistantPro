//
//  PBChatRefresh.h
//  YBAssistantPro
//
//  Created by nanhu on 16/9/7.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBBaseView.h"
/**
 // 普通闲置状态 /
MJRefreshStateIdle = 1,
/ 松开就可以进行刷新的状态 /
MJRefreshStatePulling,
/ 正在刷新中的状态 /
MJRefreshStateRefreshing,
/ 即将刷新的状态 /
MJRefreshStateWillRefresh,
/ 所有数据加载完毕，没有更多的数据了 /
MJRefreshStateNoMoreData
 **/
typedef enum {
    // 普通闲置状态 /
    PBChatRefreshStateIdle                              =   1   <<  0,
    //松开就可以进行刷新的状态
    PBChatRefreshStatePulling                           =   1   <<  1,
    //正在刷新中的状态
    PBChatRefreshStateRefreshing                        =   1   <<  2,
    //即将刷新的状态
    PBChatRefreshStateWillRefresh                       =   1   <<  3,
    //所有数据加载完毕，没有更多的数据了
    PBChatRefreshStateNoMore                            =   1   <<  4
}PBChatRefreshState;

typedef void(^PBChatRefreshEvent)(void);

@interface PBChatRefresh : PBBaseView

/**
 *  @brief 刷新状态
 */
@property (nonatomic, assign, readonly) PBChatRefreshState state;

/**
 *  @brief 初始化方法
 *
 *  @param scroller 委托
 *
 *  @return 实例
 */
- (id)initWithScrollView:(UIScrollView *)scroller withEvent:(PBChatRefreshEvent)event;
- (void)handleCharRefreshEvent:(PBChatRefreshEvent)event;

- (void)beginRefreshing;
- (void)endRefreshing;
- (void)endRefreshingWithNoMoreData;

@end

FOUNDATION_EXPORT int const PB_CHAT_REFRESH_HEIGHT;
