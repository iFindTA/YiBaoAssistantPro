//
//  PBBaseView.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/19.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBBaseView.h"

@implementation PBBaseView

- (id)init {
    self = [super init];
    if (self) {
        [self ___initSetup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self ___initSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self ___initSetup];
    }
    return self;
}

- (void)___initSetup {
    self.backgroundColor = [UIColor pb_colorWithHexString:PB_BASE_BG_HEX];
}

@end
