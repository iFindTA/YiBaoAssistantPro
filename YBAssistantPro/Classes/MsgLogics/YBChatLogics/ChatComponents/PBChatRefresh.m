//
//  PBChatRefresh.m
//  YBAssistantPro
//
//  Created by nanhu on 16/9/7.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBChatRefresh.h"

NSString *const PBRefreshKeyPathContentOffset = @"contentOffset";
NSString *const PBRefreshKeyPathContentInset = @"contentInset";
NSString *const PBRefreshKeyPathContentSize = @"contentSize";
NSString *const PBRefreshKeyPathPanState = @"state";

int const PB_CHAT_REFRESH_HEIGHT                        =       30;
static float const PB_CHAT_REFRESH_DURATION             =       0.25;

@interface PBChatRefresh ()

/** 记录scrollView刚开始的inset */
@property (assign, nonatomic) UIEdgeInsets scrollViewOriginalInset;
@property (assign, nonatomic) CGFloat insetTDelta;
/** 父控件 */
@property (strong, nonatomic) UIScrollView *scrollView;

@property (nonatomic, assign) float pullingPercent;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, copy) PBChatRefreshEvent event;

@property (nonatomic, assign) PBChatRefreshState state;

@end

@implementation PBChatRefresh

- (void)dealloc {
    [self removeObservers];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //indicator
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.hidesWhenStopped = true;
        //[indicator startAnimating];
        [self addSubview:indicator];
        self.indicator = indicator;
        //state
        UILabel *label = [[UILabel alloc] init];
        //label.backgroundColor = [UIColor redColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:13];
        [self addSubview:label];
        self.stateLabel = label;
        
        self.state = PBChatRefreshStateIdle;
    }
    return self;
}

- (void)handleCharRefreshEvent:(PBChatRefreshEvent)event {
    self.event = [event copy];
}

- (id)initWithScrollView:(UIScrollView *)scroller withEvent:(PBChatRefreshEvent)event {
    self = [super init];
    if (self) {
        self.scrollView = scroller;self.event = [event copy];
        //indicator
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.hidesWhenStopped = true;
        //[indicator startAnimating];
        [self addSubview:indicator];
        self.indicator = indicator;
        //state
        UILabel *label = [[UILabel alloc] init];
        //label.backgroundColor = [UIColor redColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:13];
        [self addSubview:label];
        self.stateLabel = label;
        
        // 设置永远支持垂直弹簧效果
        _scrollView.alwaysBounceVertical = YES;
        // 记录UIScrollView最开始的contentInset
        _scrollViewOriginalInset = _scrollView.contentInset;
        
        // 添加监听
        [self addObservers];
        
        self.state = PBChatRefreshStateIdle;
    }
    return self;
}

#pragma mark -- layout subviews

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    self.indicator.center = CGPointMake(bounds.size.width*0.5, bounds.size.height*0.5);
    self.stateLabel.frame = bounds;
}
/*
- (UIScrollView *)getSuperScrollView:(UIView *)tmp {
    UIScrollView *scroll = nil;
    UIView *superView = tmp.superview;
    while (superView != nil) {
        if ([superView isKindOfClass:[UIScrollView class]]) {
            scroll = (UIScrollView *)superView;
            break;
        }
        superView = superView.superview;
    }
    return scroll;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
//    // 旧的父控件移除监听
//    if (!newSuperview) {
//        [self removeObservers];
//    }
//    return;
    // 如果不是UIScrollView，不做任何事情
//    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) return;
//    // 旧的父控件移除监听
//    [self removeObservers];
//    if (newSuperview) { // 新的父控件
//        // 设置宽度
//        //self.mj_w = newSuperview.mj_w;
//        // 设置位置
//        //self.mj_x = 0;
//        
//        // 记录UIScrollView
//        _scrollView = (UIScrollView *)newSuperview;
//        // 设置永远支持垂直弹簧效果
//        _scrollView.alwaysBounceVertical = YES;
//        // 记录UIScrollView最开始的contentInset
//        _scrollViewOriginalInset = _scrollView.contentInset;
//        
//        // 添加监听
//        [self addObservers];
//    }
}
//*/
- (void)setState:(PBChatRefreshState)state {
    //NSLog(@"setting state:%zd",state);
    if (state == self.state) {
        return;
    }
    _state = state;
    if (state != PBChatRefreshStateRefreshing) {
        // 恢复inset和offset
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top += self.insetTDelta;
        [UIView animateWithDuration:PB_CHAT_REFRESH_DURATION animations:^{
            self.scrollView.contentInset = inset;
        } completion:^(BOOL finished) {
            self.pullingPercent = 0.0;
            
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            //开始风火轮
            [self.indicator startAnimating];
            self.stateLabel.text = nil;
            
            [UIView animateWithDuration:PB_CHAT_REFRESH_DURATION animations:^{
                CGFloat top =  _scrollViewOriginalInset.top+PB_CHAT_REFRESH_HEIGHT;
                // 增加滚动区域top
                UIEdgeInsets inset = self.scrollView.contentInset;
                inset.top = top;
                self.scrollView.contentInset = inset;
                // 设置滚动位置
                [self.scrollView setContentOffset:CGPointMake(0, -PB_CHAT_REFRESH_HEIGHT) animated:NO];
            } completion:^(BOOL finished) {
                
            }];
        });
    }
    // 根据状态做事情
    if (state == PBChatRefreshStateIdle) {
        //if (_state != PBChatRefreshStateRefreshing) return;
        //停止风火轮
        [self.indicator stopAnimating];
        self.stateLabel.text = nil;
    } else if (state == PBChatRefreshStateRefreshing) {
        [self.indicator startAnimating];
        self.stateLabel.text = nil;
    } else if (state == PBChatRefreshStateNoMore) {
        [self.indicator stopAnimating];
        self.stateLabel.text = @"没有更多历史消息";
    } else if (state == PBChatRefreshStatePulling) {
        [self.indicator startAnimating];
        self.stateLabel.text = nil;
    }
    //self.stateLabel.text = [NSString stringWithFormat:@"state:%zd",state];
    
}

#pragma mark - KVO监听
- (void)addObservers {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [_scrollView addObserver:self forKeyPath:PBRefreshKeyPathContentOffset options:options context:nil];
    [_scrollView addObserver:self forKeyPath:PBRefreshKeyPathContentSize options:options context:nil];
    //self.pan = self.scroller.panGestureRecognizer;
    //[self.pan addObserver:self forKeyPath:PBRefreshKeyPathPanState options:options context:nil];
}

- (void)removeObservers {
    [_scrollView removeObserver:self forKeyPath:PBRefreshKeyPathContentOffset];
    [_scrollView removeObserver:self forKeyPath:PBRefreshKeyPathContentSize];;
    //[self.pan removeObserver:self forKeyPath:PBRefreshKeyPathPanState];
    //self.pan = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // 遇到这些情况就直接返回
    if (!self.userInteractionEnabled) return;
    
    // 这个就算看不见也需要处理
    if ([keyPath isEqualToString:PBRefreshKeyPathContentSize]) {
        [self scrollViewContentSizeDidChange:change];
    }
    
    // 看不见
    if (self.hidden) return;
    if ([keyPath isEqualToString:PBRefreshKeyPathContentOffset]) {
        [self scrollViewContentOffsetDidChange:change];
    } else if ([keyPath isEqualToString:PBRefreshKeyPathPanState]) {
        [self scrollViewPanStateDidChange:change];
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    // 在刷新的refreshing状态
    if (self.state == PBChatRefreshStateRefreshing) {
        if (self.window == nil) return;
        
        // sectionheader停留解决
        CGFloat insetT = - self.scrollView.contentOffset.y > _scrollViewOriginalInset.top ? - self.scrollView.contentOffset.y : _scrollViewOriginalInset.top;
        insetT = insetT > self.frame.size.height + _scrollViewOriginalInset.top ? self.self.frame.size.height + _scrollViewOriginalInset.top : insetT;
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top = insetT;
        self.scrollView.contentInset = inset;
        
        self.insetTDelta = _scrollViewOriginalInset.top - insetT;
        return;
    } else if (self.state == PBChatRefreshStateNoMore) {
        
        return;
    }
    
    // 跳转到下一个控制器时，contentInset可能会变
    _scrollViewOriginalInset = self.scrollView.contentInset;
    
    // 当前的contentOffset
    CGFloat offsetY = self.scrollView.contentOffset.y;
    // 头部控件刚好出现的offsetY
    CGFloat happenOffsetY = - self.scrollViewOriginalInset.top;
    
    // 如果是向上滚动到看不见头部控件，直接返回
    // >= -> >
    if (offsetY > happenOffsetY) return;
    
    // 普通 和 即将刷新 的临界点
    CGFloat normal2pullingOffsetY = happenOffsetY - PB_CHAT_REFRESH_HEIGHT;
    CGFloat pullingPercent = (happenOffsetY - offsetY) / PB_CHAT_REFRESH_HEIGHT;
    //NSLog(@"prestate:%zd---offset:%f---point:%f",_state,offsetY,normal2pullingOffsetY);
    if (self.scrollView.isDragging) { // 如果正在拖拽
        self.pullingPercent = pullingPercent;
        if (_state == PBChatRefreshStateIdle && (offsetY < normal2pullingOffsetY)) {
            // 转为即将刷新状态
            self.state = PBChatRefreshStatePulling;
        } else if (self.state == PBChatRefreshStatePulling && offsetY >= normal2pullingOffsetY) {
            // 转为普通状态
            self.state = PBChatRefreshStateIdle;
        }
    } else if (self.state == PBChatRefreshStatePulling) {// 即将刷新 && 手松开
        // 开始刷新
        [self beginRefreshing];
    } else if (pullingPercent < 1) {
        self.pullingPercent = pullingPercent;
    }
}
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{}
- (void)scrollViewPanStateDidChange:(NSDictionary *)change{}

- (void)beginRefreshing {
    self.state = PBChatRefreshStateRefreshing;
    if (self.event) {
        self.event();
    }
}

- (void)endRefreshing {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.state = PBChatRefreshStateIdle;
    });
}

- (void)endRefreshingWithNoMoreData {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.state = PBChatRefreshStateNoMore;
    });
}

@end
