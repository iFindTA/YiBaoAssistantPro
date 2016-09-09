//
//  PBBaseTextField.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/22.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBBaseTextField.h"

@implementation PBBaseTextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:)) {
        return false;
    }else if (action == @selector(paste:)){
        return false;
    }
    return true;
}

@end
