//
//  PBSessionCell.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/25.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBSessionCell.h"
#import "PBConstants.h"
#import "PBSession.h"
#import "JSBadgeView.h"
#import "PBAFEngine.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PBSessionCell ()

/**
 *  @brief 对方/群组 头像
 */
@property (nonatomic, strong) UIImageView *mAvatar;

@property (nonatomic, strong) UILabel *mTitleLab;
@property (nonatomic, strong) UILabel *mTimeLab;

@property (nonatomic, strong) UILabel *mInfoLab;
//@property (nonatomic, strong) UILabel *mReplay;

@property (nonatomic, strong) UILabel *mLine;

/**
 *  @brief 数据源
 */
@property (nonatomic, strong) PBSession *dataSource;

@property (nonatomic, strong) MGSwipeButton *replyBtn,*deleteBtn;

/**
 *  @brief session未读消息badge
 */
@property (nonatomic, strong) JSBadgeView *badgeView;

@property (nonatomic, copy) PBSessionActionEvent event;

@end

@implementation PBSessionCell

- (void)awakeFromNib {
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
    
    self.allowsButtonsWithDifferentWidth = true;
    
    [self.contentView addSubview:self.mAvatar];
//    self.mAvatar.layer.cornerRadius = PB_CORNER_RADIUS;
//    self.mAvatar.layer.masksToBounds = true;
    
    UIFont *font = PBSysFont(PBFontTitleSize);
    UIColor *color = [UIColor pb_colorWithHexString:@"070707"];
    [self.contentView addSubview:self.mTitleLab];
    self.mTitleLab.font = font;
    self.mTitleLab.textColor = color;
    
    font = PBSysFont(PBFontSubSize-4);
    color = [UIColor pb_colorWithHexString:@"B1B1B1"];
    [self.contentView addSubview:self.mTimeLab];
    self.mTimeLab.font = font;
    self.mTimeLab.textColor = color;
    self.mTimeLab.textAlignment = NSTextAlignmentRight;
    
    font = PBSysFont(PBFontSubSize-2);
    color = [UIColor pb_colorWithHexString:@"959595"];
    [self.contentView addSubview:self.mInfoLab];
    self.mInfoLab.font = font;
    self.mInfoLab.textColor = color;
    
//    color = [UIColor pb_colorWithHexString:@"EA332F"];
//    [self.contentView addSubview:self.mReplay];
//    self.mReplay.font = font;
//    self.mReplay.textColor = color;
//    self.mReplay.textAlignment = NSTextAlignmentRight;
    
    //消息未读
    font = PBSysFont(PBFontSubSize-4);
    self.badgeView.badgeTextFont = font;
    
    color = [UIColor pb_colorWithHexString:@"E0E0E0"];
    [self.contentView addSubview:self.mLine];
    self.mLine.backgroundColor = color;
    
    color = [UIColor pb_colorWithHexString:@"C7C7CC"];
    self.replyBtn.backgroundColor = color;
    color = [UIColor pb_colorWithHexString:@"EA332F"];
    self.deleteBtn.backgroundColor = color;
    self.rightButtons = @[self.deleteBtn, self.replyBtn];
    
    [self layoutIfNeeded];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    //self.dataSource = nil;
    self.mTitleLab.text = nil;
    [self.replyBtn setTitle:@"标为未读" forState:UIControlStateNormal];
    //self.mReplay.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    weakify(self)
    [self.mAvatar mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(PB_BOUNDARY_OFFSET);
        make.height.width.equalTo(PB_CUSTOM_CELL_HEIGHT-PB_BOUNDARY_OFFSET*2);
    }];
    
    [self.mTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.equalTo(self.mAvatar);
        make.left.equalTo(self.mAvatar.mas_right).offset(PB_BOUNDARY_OFFSET);
        make.right.equalTo(self.mTimeLab.mas_left);
        make.height.equalTo(PB_CUSTOM_LAB_HEIGHT);
    }];
    
    [self.mTimeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.equalTo(self.mAvatar);
        make.right.equalTo(self.contentView).offset(-PB_BOUNDARY_OFFSET);
        make.height.equalTo(PB_CUSTOM_LAB_HEIGHT);
    }];
    
    [self.mInfoLab mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.bottom.equalTo(self.mAvatar);
        make.left.equalTo(self.mAvatar.mas_right).offset(PB_BOUNDARY_OFFSET);
        make.height.equalTo(PBFontSubSize);
        make.right.mas_equalTo(self.contentView).offset(-PB_CONTENT_MARGIN);
    }];
    
//    [self.mReplay mas_makeConstraints:^(MASConstraintMaker *make) {
//        strongify(self)
//        make.bottom.equalTo(self.mAvatar);
//        make.right.equalTo(self.contentView).offset(-PB_BOUNDARY_OFFSET);
//        make.height.equalTo(PBFontSubSize);
//    }];
    
    [self.mLine mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.left.equalTo(self.mAvatar);
        make.bottom.right.equalTo(self.contentView);
        make.height.equalTo(PB_CUSTOM_LINE_HEIGHT);
    }];
    
//    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        strongify(self)
//        make.width.equalTo(PBSCREEN_WIDTH);
//        make.bottom.equalTo(self.mLine);
//    }];
}

- (void)updateContent4Source:(PBSession *)session {
    
    self.dataSource = session;
    
    [self.mAvatar sd_setImageWithURL:[NSURL URLWithString:session.headImg]];
    
    NSUInteger badge = session.unreadCount;
    //NSUInteger badge = arc4random()%100;
    self.badgeView.badgeText = PBFormat(@"%zd",badge);
    self.badgeView.hidden = (badge==0);
    
    self.mTitleLab.text = session.nickName;
    
    long long timeStamp = session.dateTime * 0.001;//毫秒2秒
    NSString *timeString = [NSDate pb_chatTimeStamp:timeStamp];
    self.mTimeLab.text = timeString;
    
    //self.mInfoLab.text = [self sessionDisplayInfo:session];
    self.mInfoLab.text = session.text;
    
    NSString *replyInfo = (session.unreadCount > 0?@"标为已读":@"标为未读");
    [self.replyBtn setTitle:replyInfo forState:UIControlStateNormal];
}

- (NSString *)sessionDisplayInfo:(PBSession *)session {
    NSString *lastMsgData = session.lastMsgUserData;
    NSString *display = session.text;//
    if (PBIsEmpty(lastMsgData)||[lastMsgData rangeOfString:@"type"].location == NSNotFound) {
        if (session.type == 1) {
            //图片 1.文本消息 4.图片
            display = session.text;
        }else if (session.type == 4){
            //图片 1.文本消息 4.图片
            display = @"[图片]";
        }
    }else{
        
        NSDictionary *aDict = [[PBAFEngine shared] json2Dict:session.lastMsgUserData];
        NSUInteger type = [[aDict objectForKey:@"type"] integerValue];
        if (type == 1) {
            display = @"[患者咨询单]";
        } else if (type == 2) {
            display = @"[咨询反馈单]";
        } else if (type == 3) {
            display = @"[壹宝服务]";
            /**
             *content字段中 type值含义
             type:1 //门诊服务
             type:2 //检查服务
             type:3 //代问诊服务
             type:4 //手术直通车服务
             type:5 //住院直通车服务
             type:6 //产检卡服务
             type : 6
             subTypeId : 1 //孕产一体卡
             subTypeId : 2 //壹宝产检卡
             type:7 //预约成功的门诊推送信息
             */
        }else if (type == 4) {
            display = @"[就诊安排单]";
        }else if (type == 5) {
            display = @"[健康档案]";
        }else if (type == 6) {
            display = @"[咨询单]";
        }else{
            display = session.text;
        }
    }
    return display;
}

#pragma mark -- lazy method

- (UIImageView *)mAvatar {
    if (!_mAvatar) {
        _mAvatar = [[UIImageView alloc] init];
    }
    return _mAvatar;
}

- (UILabel *)mTitleLab {
    if (!_mTitleLab) {
        _mTitleLab = [[UILabel alloc] init];
    }
    return _mTitleLab;
}

- (UILabel *)mTimeLab {
    if (!_mTimeLab) {
        _mTimeLab = [[UILabel alloc] init];
    }
    return _mTimeLab;
}

- (UILabel *)mInfoLab {
    if (!_mInfoLab) {
        _mInfoLab = [[UILabel alloc] init];
    }
    return _mInfoLab;
}

//- (UILabel *)mReplay {
//    if (!_mReplay) {
//        _mReplay = [[UILabel alloc] init];
//    }
//    return _mReplay;
//}

- (UILabel *)mLine {
    if (!_mLine) {
        _mLine = [[UILabel alloc] init];
    }
    return _mLine;
}

- (JSBadgeView *)badgeView {
    if (!_badgeView) {
        _badgeView= [[JSBadgeView alloc] initWithParentView:self.mAvatar alignment:JSBadgeViewAlignmentTopRight];
        //_badgeView.badgePositionAdjustment = CGPointMake(-PB_BOUNDARY_OFFSET*2, -PB_BOUNDARY_MARGIN);
    }
    return _badgeView;
}

- (MGSwipeButton *)replyBtn {
    if (!_replyBtn) {
        _replyBtn = [MGSwipeButton buttonWithTitle:@"标为未读" backgroundColor:[UIColor lightGrayColor] callback:^BOOL(MGSwipeTableCell *sender) {
            //NSLog(@"action for reply");
            if (self.event) {
                self.event(true, sender);
            }
            return true;
        }];
    }
    return _replyBtn;
}

- (MGSwipeButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor lightGrayColor] callback:^BOOL(MGSwipeTableCell *sender) {
            if (self.event) {
                self.event(false, sender);
            }
            return true;
        }];
    }
    return _deleteBtn;
}

#pragma mark -- block event

- (void)handleSessionMoreAction:(PBSessionActionEvent)event {
    self.event = [event copy];
}

@end
