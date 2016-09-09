//
//  PBMediator+ChatProfiler.m
//  YBAssistantPro
//
//  Created by nanhu on 16/9/5.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBMediator+ChatProfiler.h"
#import "PBConstants.h"

@implementation PBMediator (ChatProfiler)

- (UIViewController *)chat_calledBySessionID:(NSString *)sid forConversationID:(NSString *)cid forUid:(NSString *)usrid forNick:(NSString *)nick forAvatar:(NSString *)avatar forSession:(PBSession *)session {
    
    UIViewController *destCtr = nil;
    
    NSString *aClass = @"PBChatProfiler";
    NSString *aInit = @"initWithSessionID:forConversationID:forUid:forNick:forAvatar:forSession:";
    NSString *urlString = PBFormat(@"%@://%@/%@",PB_SAFE_SCHEME,aClass,aInit);
    NSError *error = nil;
    BOOL wetherCan = [self canOpened:aClass byNativeUrl:[NSURL URLWithString:urlString]];
    if (wetherCan) {
        id aDester = [aClass pb_generateInstanceByInitMethod:aInit withError:&error,sid,cid,usrid,nick,avatar,session];
        if (!error && aDester != nil) {
            if ([aDester isKindOfClass:[UIViewController class]]) {
                destCtr = (UIViewController *)aDester;
            }
        }else{
            NSLog(@"error:%@",error.localizedDescription);
        }
    }
    
    //not found page to display if not found service!
    if (destCtr == nil) {
        PBNotFounder *notfounder = [self generateNotFounder];
        destCtr = notfounder;
    }
    
    return destCtr;
}

@end
