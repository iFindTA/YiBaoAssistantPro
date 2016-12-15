//
//  PBChatUnknowCell.m
//  YBAssistantPro
//
//  Created by nanhu on 16/9/5.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBChatUnknowCell.h"

@interface PBChatUnknowCell ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation PBChatUnknowCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self __initSetup];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self __initSetup];
    }
    return self;
}

- (void)__initSetup {
    [self.contentView addSubview:self.label];
    self.label.text = @"该版本壹宝不支持查看此消息，请升级版本!";
    
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    weakify(self)
    [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.equalTo(self.avatarBtn);
        if (self.dataSource.isSelfSend) {
            make.right.equalTo(self.avatarBtn.mas_left).offset(-PB_BOUNDARY_OFFSET);
        } else {
            make.left.equalTo(self.avatarBtn.mas_right).offset(PB_BOUNDARY_OFFSET);
        }
        
    }];
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
    }
    
    return _label;
}

@end
