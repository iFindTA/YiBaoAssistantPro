//
//  PBChatBaseCell.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/27.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBChatBaseCell.h"

@interface PBChatBaseCell ()

@property (nonatomic, strong) UIView *timeStampBgView;
/**
 *  @brief 时间控件 是否激活
 */
@property (nonatomic, strong) MASConstraint *stampConstraint;
/**
 *  @brief 时间
 */
@property (nonatomic, strong) UILabel *timeLab;
//数据源
@property (nonatomic, strong, readwrite) PBChatFrame *dataSource;
//头像
@property (nonatomic, strong, readwrite) UIButton *avatarBtn;
//内容
@property (nonatomic, strong, readwrite) PBChatContenter *contentBtn;

@end

@implementation PBChatBaseCell

- (void)awakeFromNib {
    [self initSetup];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSetup];
    }
    return self;
}

- (BOOL)canBecomeFirstResponder {
    return true;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:)) {
        return true;
    }else if (action == @selector(paste:)){
        return false;
    }
    return false;
}

- (void)initSetup {
    
    //时间背景
    [self.contentView addSubview:self.timeStampBgView];
    //时间
    [self.timeStampBgView addSubview:self.timeLab];
    //用户头像
    [self.contentView addSubview:self.avatarBtn];
    
    //[self.contentView addSubview:self.contentBtn];
    
    self.contentView.backgroundColor = [UIColor pb_randomColor];
    //[self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat mCaps = PB_BOUNDARY_OFFSET*0.5;
    weakify(self)
    [self.timeStampBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.left.right.equalTo(self.contentView);
        self.stampConstraint = make.height.equalTo(0).priority(UILayoutPriorityRequired);
    }];
    [self.stampConstraint deactivate];
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.edges.equalTo(self.timeStampBgView).insets(UIEdgeInsetsMake(mCaps, 0, mCaps, 0)).priority(UILayoutPriorityDefaultHigh);
    }];
    
    //head avatar
    [self.avatarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.equalTo(self.timeStampBgView.mas_bottom);
        if (self.dataSource.isSelfSend) {
            make.right.equalTo(self.contentView).offset(-mCaps);
        } else {
            make.left.equalTo(self.contentView).offset(mCaps);
        }
        make.size.equalTo(CGSizeMake(ChatIconWH, ChatIconWH));
    }];
}

#pragma mark -- getter methods

- (PBChatFrame *)getDataFrame {
    return self.dataSource;
}

- (UIView *)timeStampBgView {
    if (!_timeStampBgView) {
        _timeStampBgView = [[UIView alloc] init];
        _timeStampBgView.clipsToBounds = true;
        _timeStampBgView.backgroundColor = [UIColor pb_colorWithHexString:PB_BASE_BG_HEX];
    }
    return _timeStampBgView;
}

- (UILabel *)timeLab {
    if (!_timeLab) {
        UILabel *tmp = [[UILabel alloc] init];
        tmp.textAlignment = NSTextAlignmentCenter;
        tmp.textColor = [UIColor grayColor];
        tmp.font = PBSysFont(PB_CHAT_TIME_PROMOT_FONT);
        tmp.backgroundColor = [UIColor pb_colorWithHexString:PB_BASE_BG_HEX];
        _timeLab = tmp;
    }
    return _timeLab;
}

- (UIButton *)avatarBtn {
    if (!_avatarBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.exclusiveTouch = true;
        btn.backgroundColor = [UIColor pb_colorWithHexString:PB_BASE_BG_HEX];
        [btn addTarget:self action:@selector(usrAvatarDidTouchEvent) forControlEvents:UIControlEventTouchUpInside];
        _avatarBtn = btn;
    }
    return _avatarBtn;
}

- (PBChatContenter *)contentBtn {
    if (!_contentBtn) {
        PBChatContenter *btn = [PBChatContenter buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = ChatContentFont;
        btn.titleLabel.numberOfLines = 0;
        btn.titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
        btn.titleLabel.preferredMaxLayoutWidth = ChatContentW;
        [btn addTarget:self action:@selector(contentBtnTouchEvent)  forControlEvents:UIControlEventTouchUpInside];
        _contentBtn = btn;
    }
    return _contentBtn;
}

/*
- (CGFloat)pb_chatCellHeight:(ECMessage *)msg {
    
    return 100;
}

+ (NSString *)pb_identifier4Msg:(ECMessage *)msg {
    return @"textCell";
}

+ (Class)pb_class4Msg:(ECMessage *)msg {
    return NSClassFromString(@"PBChatTextCell");
}

- (void)pb_updateCellContent4Source:(ECMessage *)msg {
    
}
//*/

- (void)enableTimeStampComponent:(BOOL)enable {
    if (enable) {
        [self.stampConstraint deactivate];
    } else {
        [self.stampConstraint activate];
    }
}

- (void)updateCellContent4Frame:(PBChatFrame *)frame {
    
    self.dataSource = frame;
    self.timeLab.text = [NSDate pb_chatTimeStamp:frame.timeStamp*0.001];
    [self enableTimeStampComponent:frame.showStamp];
    [self.avatarBtn sd_setImageWithURL:[NSURL URLWithString:frame.usrAvatar] forState:UIControlStateNormal];
    //wether display content button
    
    if (frame.msgType & (PBChatMsgTypeText|PBChatMsgTypeImage|PBChatMsgTypeAudio)) {
        //prepare for reuse
        [self.contentBtn setTitle:@"" forState:UIControlStateNormal];
        //背景气泡图
        UIImage *normal;
        if (frame.isSelfSend) {
            normal = [UIImage imageNamed:@"chatto_bg_normal"];
            normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22)];
            [self.contentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.contentBtn.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentRight, ChatContentBottom, ChatContentLeft);
        } else {
            normal = [UIImage imageNamed:@"chatfrom_bg_normal"];
            normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
            [self.contentBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            self.contentBtn.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentLeft, ChatContentBottom, ChatContentRight);
        }
        [self.contentBtn setBackgroundImage:normal forState:UIControlStateNormal];
        [self.contentBtn setBackgroundImage:normal forState:UIControlStateHighlighted];
    }
}

- (void)usrAvatarDidTouchEvent {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatCell:didSelectActionType:)]) {
        [self.delegate chatCell:self didSelectActionType:PBChatCellActionTypeAvatar];
    }
}

- (void)copy:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatCell:didSelectActionType:)]) {
        [self.delegate chatCell:self didSelectActionType:PBChatCellActionTypeCopy];
    }
}

- (void)contentBtnTouchEvent {
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatCell:didSelectActionType:)]) {
        [self.delegate chatCell:self didSelectActionType:PBChatCellActionTypeContent];
    }
}

@end
