//
//  YBSearchProfiler.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/22.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBBaseView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^YBSearchEvent)(id);

@interface YBSearchProfiler : PBBaseView

- (void)beginBecomeFirstResponder;
- (void)endFirstResponder;

- (void)searchKeywordDidChange2:(nullable NSString *)key;

- (void)handleSearchMsgEvent:(YBSearchEvent)event;

NS_ASSUME_NONNULL_END

@end
