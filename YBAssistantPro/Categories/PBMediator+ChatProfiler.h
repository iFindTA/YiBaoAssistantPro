//
//  PBMediator+ChatProfiler.h
//  YBAssistantPro
//
//  Created by nanhu on 16/9/5.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import <PBMediator/PBMediator.h>

@class PBSession;
@interface PBMediator (ChatProfiler)

NS_ASSUME_NONNULL_BEGIN

- (UIViewController *)chat_calledBySessionID:(NSString *)sid
                           forConversationID:(NSString *)cid
                                      forUid:(NSString *)usrid
                                     forNick:(nullable NSString *)nick
                                   forAvatar:(nullable NSString *)avatar
                                  forSession:(nullable PBSession *)session;

NS_ASSUME_NONNULL_END

@end
