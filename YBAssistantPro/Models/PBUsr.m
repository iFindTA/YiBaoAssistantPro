//
//  PBUsr.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/23.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBUsr.h"

@implementation PBUsr

//属性不一致的处理
+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"new":@"old"};
}
//NSString -> NSDate, nil -> @""
- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property {
    if ([property.name isEqualToString:@"publisher"]) {
        if (oldValue == nil) return @"";
    } else if (property.type.typeClass == [NSDate class]) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"yyyy-MM-dd";
        return [fmt dateFromString:oldValue];
    }
    
    return oldValue;
}

@end
