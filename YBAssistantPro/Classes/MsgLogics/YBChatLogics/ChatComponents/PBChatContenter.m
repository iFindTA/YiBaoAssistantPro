//
//  PBChatContenter.m
//  YBAssistantPro
//
//  Created by nanhu on 16/9/5.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBChatContenter.h"

@implementation PBChatContenter

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //bubble bg
        _cBubble = [[UIImageView alloc]init];
        _cBubble.hidden = true;
        _cBubble.userInteractionEnabled = YES;
        _cBubble.layer.cornerRadius = 5;
        _cBubble.layer.masksToBounds  = YES;
        _cBubble.contentMode = UIViewContentModeScaleAspectFill;
        _cBubble.backgroundColor = [UIColor yellowColor];
        [self addSubview:_cBubble];
        
        //语音
        self.cAudioBgView = [[UIView alloc]init];
        self.cAudioBgView.hidden = true;
        [self addSubview:self.cAudioBgView];
        self.cAudioDuration = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 30)];
        self.cAudioDuration.textAlignment = NSTextAlignmentCenter;
        self.cAudioDuration.font = [UIFont systemFontOfSize:14];
        self.cAudioAnimater = [[UIImageView alloc]initWithFrame:CGRectMake(80, 5, 20, 20)];
        self.cAudioAnimater.image = [UIImage imageNamed:@"chat_animation_white3"];
        self.cAudioAnimater.animationImages = [NSArray arrayWithObjects:
                                      [UIImage imageNamed:@"chat_animation_white1"],
                                      [UIImage imageNamed:@"chat_animation_white2"],
                                      [UIImage imageNamed:@"chat_animation_white3"],nil];
        self.cAudioAnimater.animationDuration = 1;
        self.cAudioAnimater.animationRepeatCount = 0;
        self.cIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.cIndicator.center=CGPointMake(80, 15);
        [self.cAudioBgView addSubview:self.cIndicator];
        [self.cAudioBgView addSubview:self.cAudioAnimater];
        [self.cAudioBgView addSubview:self.cAudioDuration];
        
        self.cAudioBgView.userInteractionEnabled = NO;
        self.cAudioBgView.userInteractionEnabled = NO;
        self.cAudioDuration.userInteractionEnabled = NO;
        self.cAudioAnimater.userInteractionEnabled = NO;
        
        self.cAudioDuration.backgroundColor = [UIColor clearColor];
        self.cAudioAnimater.backgroundColor = [UIColor clearColor];
        self.cAudioBgView.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)audioDidBeginLoadState {
    self.cAudioAnimater.hidden = YES;
    [self.cIndicator startAnimating];
}
- (void)audioDidLoadState {
    self.cAudioAnimater.hidden = NO;
    [self.cIndicator stopAnimating];
    [self.cAudioAnimater startAnimating];
}
-(void)audioDidStopPlay {
    [self.cAudioAnimater stopAnimating];
}

- (void)setIsSelfMsg:(BOOL)isSelfMsg {
    _isSelfMsg = isSelfMsg;
    if (isSelfMsg) {
        self.cBubble.frame = CGRectMake(5, 5, 220, 220);
        self.cAudioBgView.frame = CGRectMake(15, 10, 130, 35);
        self.cAudioDuration.textColor = [UIColor whiteColor];
    }else{
        self.cBubble.frame = CGRectMake(15, 5, 220, 220);
        self.cAudioBgView.frame = CGRectMake(25, 10, 130, 35);
        self.cAudioDuration.textColor = [UIColor grayColor];
        
        self.cAudioAnimater.image = [UIImage imageNamed:@"chat_animation_3"];
        self.cAudioAnimater.animationImages = [NSArray arrayWithObjects:
                                               [UIImage imageNamed:@"chat_animation_1"],
                                               [UIImage imageNamed:@"chat_animation_2"],
                                               [UIImage imageNamed:@"chat_animation_3"],nil];
    }
}

- (void)showImageMask:(BOOL)show {
    if (!show) {
        self.cBubble.layer.mask = nil;
    } else {
        UIImage *image = self.currentBackgroundImage;
        UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
        imageViewMask.frame = self.cBubble.bounds;
        self.cBubble.layer.mask = imageViewMask.layer;
    }
}

@end
