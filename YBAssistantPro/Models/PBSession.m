//
//  PBSession.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/27.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBSession.h"

@implementation PBSession

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"sessionID":@"customerVoipAccount",
             @"dateTime":@"lastMsgTimeStamp",
             @"type":@"lastMsgType",
             @"text":@"lastMsgContent",
             @"conversationId":@"id",
             @"headImg":@"customerHeadImg",
             @"nickName":@"customerNickName"
             };
}

@end
