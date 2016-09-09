//
//  PBChatTextCell.m
//  YBAssistantPro
//
//  Created by nanhu on 16/9/3.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBChatTextCell.h"

@interface PBChatTextCell ()

@end

@implementation PBChatTextCell

- (void)awakeFromNib {
    [self initSetupSubClass];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSetupSubClass];
    }
    return self;
}

- (void)initSetupSubClass {
    
    [self.contentView addSubview:self.contentBtn];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    weakify(self)
//    [self.contentBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//        strongify(self)
//        make.top.equalTo(self.avatarBtn);
//        if (self.dataSource.isSelfSend) {
//            make.right.equalTo(self.avatarBtn.mas_left).offset(-PB_BOUNDARY_OFFSET);
//        } else {
//            make.left.equalTo(self.avatarBtn.mas_right).offset(PB_BOUNDARY_OFFSET);
//        }
//        make.size.equalTo(self.dataSource.contentSize);
//    }];
}

#pragma mark -- getter methods

//- (void)updateCellContent4Frame:(PBChatFrame *)frame {
//    [super updateCellContent4Frame:frame];
//
//    self.contentBtn.isSelfMsg = frame.isSelfSend;
//    //隐藏语音、图片背景
//    self.contentBtn.cBubble.hidden = true;
//    self.contentBtn.cAudioBgView.hidden = true;
//    [self.contentBtn setTitle:frame.displayText forState:UIControlStateNormal];
//    
//    [self layoutIfNeeded];
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
