//
//  PBTransitionMasker.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/23.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PBTransitionEvent)(void);

@interface PBTransitionMasker : UIViewController

- (void)handleTransitionEvent:(PBTransitionEvent)event;

- (void)maskWillAppear;

@end
