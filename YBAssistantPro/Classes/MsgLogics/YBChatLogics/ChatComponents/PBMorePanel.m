//
//  PBMorePanel.m
//  YBAssistantPro
//
//  Created by nanhu on 16/9/2.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBMorePanel.h"

@implementation PBMorePanel

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self __initSetup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self __initSetup];
    }
    return self;
}

- (void)__initSetup {
    self.backgroundColor = [UIColor pb_colorWithHexString:@"F4F4F6"];
    //壹宝服务 快捷回复 发起咨询 咨询反馈 照片 拍照 语音电话
    int mItemSize = 60;
    int mItemCols = 4;//4cols
    int mItemRows = 2;//2rows
    UIColor *titleColor = [UIColor pb_colorWithHexString:@"8E8E8E"];
    UIFont *titleFont = PBSysFont(PBFontSubSize-2);
    CGFloat mHCaps = (PBSCREEN_WIDTH-mItemSize*mItemCols)/(mItemCols+1);
    UIImage *bgNormal = [UIImage imageNamed:@"sharemore_other"];
    UIImage *bgHighlight = [UIImage imageNamed:@"sharemore_other_HL"];
    //服务
    UIImage *iconImg = [UIImage imageNamed:@"sharemore_service"];
    CGRect bounds = CGRectMake(mHCaps, PB_BOUNDARY_MARGIN, mItemSize, mItemSize);
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = bounds;
    btn.exclusiveTouch = true;
    [btn setBackgroundImage:bgNormal forState:UIControlStateNormal];
    [btn setBackgroundImage:bgHighlight forState:UIControlStateHighlighted];
    [btn setImage:iconImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(morePanelFunction4Service) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    CGRect mLabBounds = (CGRect){.origin=CGPointMake(bounds.origin.x, bounds.origin.y+mItemSize+PB_BOUNDARY_OFFSET*0.5), .size = CGSizeMake(mItemSize, PB_CUSTOM_LAB_HEIGHT)};
    UILabel *label = [[UILabel alloc] initWithFrame:mLabBounds];
    //label.backgroundColor = [UIColor pb_randomColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = titleFont;
    label.textColor = titleColor;
    label.text = @"壹宝服务";
    [self addSubview:label];
    //快捷回复
    iconImg = [UIImage imageNamed:@"sharemore_service"];
    bounds.origin.x += mItemSize + mHCaps;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = bounds;
    btn.exclusiveTouch = true;
    [btn setBackgroundImage:bgNormal forState:UIControlStateNormal];
    [btn setBackgroundImage:bgHighlight forState:UIControlStateHighlighted];
    [btn setImage:iconImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(morePanelFunction4QuickReply) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    mLabBounds.origin.x += mItemSize + mHCaps;
    label = [[UILabel alloc] initWithFrame:mLabBounds];
    //label.backgroundColor = [UIColor pb_randomColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = titleFont;
    label.textColor = titleColor;
    label.text = @"快捷回复";
    [self addSubview:label];
    //发起咨询
    iconImg = [UIImage imageNamed:@"sharemore_sight"];
    bounds.origin.x += mItemSize + mHCaps;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = bounds;
    btn.exclusiveTouch = true;
    [btn setBackgroundImage:bgNormal forState:UIControlStateNormal];
    [btn setBackgroundImage:bgHighlight forState:UIControlStateHighlighted];
    [btn setImage:iconImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(morePanelFunction4Query) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    mLabBounds.origin.x += mItemSize + mHCaps;
    label = [[UILabel alloc] initWithFrame:mLabBounds];
    //label.backgroundColor = [UIColor pb_randomColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = titleFont;
    label.textColor = titleColor;
    label.text = @"咨询";
    [self addSubview:label];
    //反馈
    iconImg = [UIImage imageNamed:@"sharemorePay"];
    bounds.origin.x += mItemSize + mHCaps;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = bounds;
    btn.exclusiveTouch = true;
    [btn setBackgroundImage:bgNormal forState:UIControlStateNormal];
    [btn setBackgroundImage:bgHighlight forState:UIControlStateHighlighted];
    [btn setImage:iconImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(morePanelFunction4Feedback) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    mLabBounds.origin.x += mItemSize + mHCaps;
    label = [[UILabel alloc] initWithFrame:mLabBounds];
    //label.backgroundColor = [UIColor pb_randomColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = titleFont;
    label.textColor = titleColor;
    label.text = @"反馈";
    [self addSubview:label];
    //照片
    CGFloat start_y = PB_BOUNDARY_MARGIN+mItemSize+PB_BOUNDARY_OFFSET*0.5+PB_CUSTOM_LAB_HEIGHT+PB_BOUNDARY_MARGIN;
    bounds = CGRectMake(mHCaps, start_y, mItemSize, mItemSize);
    iconImg = [UIImage imageNamed:@"sharemore_pic"];
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = bounds;
    btn.exclusiveTouch = true;
    [btn setBackgroundImage:bgNormal forState:UIControlStateNormal];
    [btn setBackgroundImage:bgHighlight forState:UIControlStateHighlighted];
    [btn setImage:iconImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(morePanelFunction4PhotoAlbum) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    mLabBounds = (CGRect){.origin=CGPointMake(bounds.origin.x, bounds.origin.y+mItemSize+PB_BOUNDARY_OFFSET*0.5), .size = CGSizeMake(mItemSize, PB_CUSTOM_LAB_HEIGHT)};
    label = [[UILabel alloc] initWithFrame:mLabBounds];
    //label.backgroundColor = [UIColor pb_randomColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = titleFont;
    label.textColor = titleColor;
    label.text = @"照片";
    [self addSubview:label];
    //拍摄
    iconImg = [UIImage imageNamed:@"sharemore_video"];
    bounds.origin.x += mItemSize + mHCaps;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = bounds;
    btn.exclusiveTouch = true;
    [btn setBackgroundImage:bgNormal forState:UIControlStateNormal];
    [btn setBackgroundImage:bgHighlight forState:UIControlStateHighlighted];
    [btn setImage:iconImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(morePanelFunction4PhotoCamera) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    mLabBounds.origin.x += mItemSize + mHCaps;
    label = [[UILabel alloc] initWithFrame:mLabBounds];
    //label.backgroundColor = [UIColor pb_randomColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = titleFont;
    label.textColor = titleColor;
    label.text = @"拍摄";
    [self addSubview:label];
    //位置
    iconImg = [UIImage imageNamed:@"sharemore_location"];
    bounds.origin.x += mItemSize + mHCaps;
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = bounds;
    btn.exclusiveTouch = true;
    [btn setBackgroundImage:bgNormal forState:UIControlStateNormal];
    [btn setBackgroundImage:bgHighlight forState:UIControlStateHighlighted];
    [btn setImage:iconImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(morePanelFunction4Location) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    mLabBounds.origin.x += mItemSize + mHCaps;
    label = [[UILabel alloc] initWithFrame:mLabBounds];
    //label.backgroundColor = [UIColor pb_randomColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = titleFont;
    label.textColor = titleColor;
    label.text = @"位置";
    [self addSubview:label];
}

#pragma mark -- touch actions

- (void)morePanelFunction4Service {
    if (self.delegate && [self.delegate respondsToSelector:@selector(moreActionPanel:didSelectActionType:)]) {
        [self.delegate moreActionPanel:self didSelectActionType:PBMorePanelActionService];
    }
}

- (void)morePanelFunction4QuickReply {
    if (self.delegate && [self.delegate respondsToSelector:@selector(moreActionPanel:didSelectActionType:)]) {
        [self.delegate moreActionPanel:self didSelectActionType:PBMorePanelActionQuickReply];
    }
}

- (void)morePanelFunction4Query {
    if (self.delegate && [self.delegate respondsToSelector:@selector(moreActionPanel:didSelectActionType:)]) {
        [self.delegate moreActionPanel:self didSelectActionType:PBMorePanelActionQuery];
    }
}

- (void)morePanelFunction4Feedback {
    if (self.delegate && [self.delegate respondsToSelector:@selector(moreActionPanel:didSelectActionType:)]) {
        [self.delegate moreActionPanel:self didSelectActionType:PBMorePanelActionFeedback];
    }
}

- (void)morePanelFunction4PhotoAlbum {
    if (self.delegate && [self.delegate respondsToSelector:@selector(moreActionPanel:didSelectActionType:)]) {
        [self.delegate moreActionPanel:self didSelectActionType:PBMorePanelActionPhotoAlbum];
    }
}

- (void)morePanelFunction4PhotoCamera {
    if (self.delegate && [self.delegate respondsToSelector:@selector(moreActionPanel:didSelectActionType:)]) {
        [self.delegate moreActionPanel:self didSelectActionType:PBMorePanelActionPhotoCamera];
    }
}

- (void)morePanelFunction4Location {
    if (self.delegate && [self.delegate respondsToSelector:@selector(moreActionPanel:didSelectActionType:)]) {
        [self.delegate moreActionPanel:self didSelectActionType:PBMorePanelActionLocation];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
