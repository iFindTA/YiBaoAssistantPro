//
//  PBChatFrame.m
//  YBAssistantPro
//
//  Created by nanhu on 16/9/4.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBChatFrame.h"
#import "PBChatConstants.h"
#import "PBDBEngine.h"
#import "PBSession.h"
#import "ECMessage.h"
#import "ECFileMessageBody.h"
#import "ECTextMessageBody.h"
#import "ECImageMessageBody.h"
#import "ECVoiceMessageBody.h"
#import "ECLocationMessageBody.h"

static const int PB_DISPLAY_TIME_INTERVAL                       =       60*3;//三分钟

@implementation PBChatMessage

/**
 userData 中type字段的使用规则:
 
 1\. 如果userData字段对应JSON格式数据中无type字段或者字段对应内容为空字符串  则将该条消息作为正常文本消息处理;
 2\. 如果userData中有type字段
 ① 如果当前版本app或者html5识别该type类型值则用相应规则正常解析显示该条消息;
 
 msgType值如下:
 1  患者咨询单            userData  formType  字段含义
 formType字段不存在或者为1时为咨询单
 formType为2时为申请单
 然后content字段中
 subType值为1时为专家预约申请单,
 subType值为2时为手术申请单,
 subType值为3时为患者报到.
 2  咨询反馈单
 3  各种壹宝服务推送       content字段中 type值含义
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
 4  就诊安排单
 5  健康档案
 6  顾问发起的咨询单
 ② 如果当前版本不识别该msgType类型则将该条消息当成一条文本消息处理,当前文本默认显示为 "当前版本暂不支持查看此消息，请下载最新版本。"(具体文案若有异议可与产品经理协商);
 
 userData中其他字段的使用规则:
 
 1.由于userData是自定义字段,有些时候为了产品能够快速迭代,可能需要在userData中添加新字段来快速添加新服务
 ① 如果是系统发送的模拟用户或者顾问的角色,而且信息比较单一的话,可以当成普通的文本消息显示,然后通过在userData中添加 systemMsgType类型来控制, systemMsgType字端值可按需求依次递增
 曾经用户端产品模拟以系统的角色模拟用户向顾问发送消息
 {
 systemMsgType : 1   //1.指定顾问时的消息类型   2.医生主页系统模拟用户发送给顾问的消息类型   3.解雇顾问时的消息类型
 }
 
 content 字段具体含义解析(主要针对userData type不为空的情况)
 1.userData type为1时;
 (1)userData 中formType为1或者不存在时为咨询单
 (2)userData中formType为2时为申请单
 
 ① content字段中 subType为1 为专家预约申请单
 ② content字段中 subType为2 为手术申请单
 ③ content字段中 subType为3 为患者报到
 
 2.userData type为2时; 为咨询反馈单
 
 3.userData type为3时; 为推送服务
 ① content字段中 type为1 为专家门诊服务
 ② content字段中 type为2 为检查服务
 ③ content字段中 type为3 为代问诊服务
 ④ content字段中 type为4 为住院申请服务
 ⑤ content字段中 type为5 为手术申请服务
 ⑥ content字段中 type为6 为产检卡服务
 
 4.userData type为4时; 为就诊安排单
 
 5.userData type为5时; 为健康档案
 6.userData type为6时; 为唤起用户端填写咨询单标签
 
 7. userData type为7时; 为门诊预约成功推送信息

 8. userData type为8时; 为专家门诊咨询单
 
 9. userData type为9时; 为手术直通车咨询单
 10.userData type为10时;为咨询反馈单评价情况
 11.userData type为11时;为对顾问打赏信息
 12.userData type为12时;为对顾问建议/投诉信息
 13.userData type为13时;为专家团知识库推送信息 defaultType : 2000
 14.userData type为14时;为专家团推送患者报到信息 defaultType : 1001
 **/

@end

@interface PBChatFrame ()

@property (nonatomic, strong, readwrite) PBChatMessage *msg;

@property (nonatomic, assign, readwrite) CGFloat cellHeight;

@property (nonatomic, assign, readwrite) BOOL showStamp;
@property (nonatomic, assign, readwrite) long long timeStamp;

@property (nonatomic, copy, readwrite) NSString *cellIdentifier;
@property (nonatomic, strong, readwrite) Class cellClass;
@property (nonatomic, assign, readwrite) BOOL isCellClassExist;

@property (nonatomic, assign, readwrite) BOOL isSelfSend;
@property (nonatomic, copy, readwrite) NSString *usrAvatar;

@property (nonatomic, assign) PBChatMsgType msgType;

@end

@implementation PBChatFrame

#pragma mark -- init methods

- (id)initWithSession:(PBSession *)session withPreStamp:(long long)preTime {
    self = [super init];
    if (self) {
        [self convertSession:session];
        //组装其他属性
        self.showStamp = (llabs(session.dateTime - preTime) >= PB_DISPLAY_TIME_INTERVAL);
    }
    return self;
}

- (id)initWithChatMsg:(PBChatMessage *)msg withPreStamp:(long long)preTime {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithMsg:(ECMessage *)msg withPreStamp:(long long)preTime {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark -- getter methods

- (long long)getTimeStamp {
    return _timeStamp;
}

static const int PB_TIME_HEIGHT                     =       24;

- (CGFloat)getCellHeight {
    CGFloat mHeight = _cellHeight;
    if (mHeight > 0) {
        return mHeight;
    }
    if (!self.isCellClassExist) {
        mHeight = 50;
    } else {
        //时间
        mHeight = self.showStamp?PB_TIME_HEIGHT:0;
        //内容
        if (self.msgType == PBChatMsgTypeText) {
            CGSize mContentSize = [self getContentSize];
            CGFloat mCeilWidth = ceil(mContentSize.width);
            CGFloat mCeilHeight = ceil(mContentSize.height);
            //NSLog(@"ceil w:%f---h:%f",mCeilWidth,mCeilHeight);
            mHeight += mCeilHeight;
            self.contentSize = CGSizeMake(mCeilWidth+ChatContentLeft+ChatContentRight, mCeilHeight+ChatContentTop+ChatContentBottom);
        } else if (self.msgType == PBChatMsgTypeImage) {
            mHeight += ChatPicWH;
            self.contentSize = CGSizeMake(ChatPicWH+ChatContentLeft+ChatContentRight, ChatPicWH+ChatContentTop+ChatContentBottom);
        } else if (self.msgType == PBChatMsgTypeAudio) {
            mHeight += 20;
            self.contentSize = CGSizeMake(120+ChatContentLeft+ChatContentRight, 20+ChatContentTop+ChatContentBottom);
        }
        mHeight += ChatContentTop+ChatContentBottom;
        
    }
    _cellHeight = MAX(mHeight, ChatIconWH) + ChatMargin;
    return mHeight;
}

- (Class)getCellClass {
    return _cellClass;
}

- (NSString *)getCellIdentifier {
    return NSStringFromClass(self.cellClass);
}

#pragma mark -- 拆包session
- (void)convertSession:(PBSession *)session {
    if (!session) {
        //TODO:session缺少了标示最后一条消息是谁发送的
        //待确认点：能否根据session判断出最后消息是谁发出
        return;
    }
    BOOL isSelfMsg = (session.replyStatus==2);
    self.isSelfSend = isSelfMsg;
    if (isSelfMsg) {
        self.usrAvatar = [[PBDBEngine shared] authorAvatar];
    } else {
        self.usrAvatar = session.headImg;
    }
    NSString *selfImvoip = [[PBDBEngine shared] authorIMID];
    ECMessage *msg = [[ECMessage alloc] init];
    msg.sessionId = session.sessionID;
    msg.from = isSelfMsg?selfImvoip:session.sessionID;
    msg.to = isSelfMsg?session.sessionID:selfImvoip;
    
    long long timeStamp = session.dateTime;
    [self setTimeStamp:timeStamp];
    msg.timestamp = PBFormat(@"%lld",session.dateTime);
    //组装body
    ECMessageBody *mBody = nil;
    NSString *text = session.text;
    NSUInteger type = session.type;
    Class aUnknowCellClass = NSClassFromString(@"PBChatUnknowCell");
    if (type == MessageBodyType_Text) {
        ECTextMessageBody *body = [[ECTextMessageBody alloc] initWithText:text];
        body.serverTime = PBFormat(@"%lld",timeStamp);
        mBody = body;
        //组装cell class(class信息可由后台服务组装)
        NSString *cellClassString = @"PBChatTextCell";
        Class aClass = NSClassFromString(cellClassString);
        self.isCellClassExist = (aClass != nil);
        self.cellClass = (aClass == nil?aUnknowCellClass:aClass);
        self.displayText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];;
        self.msgType = PBChatMsgTypeText;
    }else if (type == MessageBodyType_Image){
        ECImageMessageBody *body = [[ECImageMessageBody alloc] initWithFile:nil displayName:@""];
        body.remotePath = text;
        body.serverTime = PBFormat(@"%lld",timeStamp);
        body.thumbnailRemotePath = text;
        mBody = body;
        NSString *cellClassString = @"PBChatImageCell";
        Class aClass = NSClassFromString(cellClassString);
        self.isCellClassExist = (aClass != nil);
        self.cellClass = (aClass == nil?aUnknowCellClass:aClass);
        self.displayText = [session.lastMsgUserData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];;
        self.msgType = PBChatMsgTypeImage;
    }else if (type == MessageBodyType_Voice){
        ECVoiceMessageBody * body = [[ECVoiceMessageBody alloc] initWithFile:nil displayName:@""];
        body.remotePath = text;
        body.serverTime = PBFormat(@"%lld",timeStamp);
        //body.mediaDownloadStatus = [rs intForColumnIndex:12];
        body.displayName = text;
        body.duration = 2;
        mBody = body;
        self.msgType = PBChatMsgTypeAudio;
    }else if (type == MessageBodyType_File){
        
    }else if (type == MessageBodyType_Video){
        
    }else if (type == MessageBodyType_Location){
        
    }else if (type == MessageBodyType_Call){
        
    }
    msg.messageBody = mBody;
    self.msg = msg;
}

#pragma mark --拆包ECMessage

- (void)unBoxECMessage:(ECMessage *)msg {
    if (!msg || PBIsEmpty(msg.from) || PBIsEmpty(msg.messageId)) {
        return;
    }
    NSString *selfIMID = [[PBDBEngine shared] authorIMID];
    self.isSelfSend = ([selfIMID isEqualToString:msg.from]);
    if (self.isSelfSend) {
        self.usrAvatar = [[PBDBEngine shared] authorAvatar];
    } else {
        self.usrAvatar = nil;//这里暂时置空
    }
    NSString *selfImvoip = [[PBDBEngine shared] authorIMID];
    PBChatMessage *chatMsg = [[PBChatMessage alloc] init];
    chatMsg.msgId = msg.messageId;
    chatMsg.fromVoIp = msg.from;
    chatMsg.toVoIp = msg.to;
    long long timeStamp = [msg.timestamp longLongValue];
    [self setTimeStamp:timeStamp];
    chatMsg.createTimeStamp = msg.timestamp;
    chatMsg.userData = msg.userData;
    //content <=> body
    NSString *content = nil;
    //msgType <=> type
    PBChatMsgType msgType = PBChatMsgTypeNone;
    
    //组装body
    ECMessageBody *mBody = nil;
    NSString *text = session.text;
    NSUInteger type = session.type;
    Class aUnknowCellClass = NSClassFromString(@"PBChatUnknowCell");
    if (type == MessageBodyType_Text) {
        ECTextMessageBody *body = [[ECTextMessageBody alloc] initWithText:text];
        body.serverTime = PBFormat(@"%lld",timeStamp);
        mBody = body;
        //组装cell class(class信息可由后台服务组装)
        NSString *cellClassString = @"PBChatTextCell";
        Class aClass = NSClassFromString(cellClassString);
        self.isCellClassExist = (aClass != nil);
        self.cellClass = (aClass == nil?aUnknowCellClass:aClass);
        self.displayText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];;
        self.msgType = PBChatMsgTypeText;
    }else if (type == MessageBodyType_Image){
        ECImageMessageBody *body = [[ECImageMessageBody alloc] initWithFile:nil displayName:@""];
        body.remotePath = text;
        body.serverTime = PBFormat(@"%lld",timeStamp);
        body.thumbnailRemotePath = text;
        mBody = body;
        NSString *cellClassString = @"PBChatImageCell";
        Class aClass = NSClassFromString(cellClassString);
        self.isCellClassExist = (aClass != nil);
        self.cellClass = (aClass == nil?aUnknowCellClass:aClass);
        self.displayText = [session.lastMsgUserData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];;
        self.msgType = PBChatMsgTypeImage;
    }else if (type == MessageBodyType_Voice){
        ECVoiceMessageBody * body = [[ECVoiceMessageBody alloc] initWithFile:nil displayName:@""];
        body.remotePath = text;
        body.serverTime = PBFormat(@"%lld",timeStamp);
        //body.mediaDownloadStatus = [rs intForColumnIndex:12];
        body.displayName = text;
        body.duration = 2;
        mBody = body;
        self.msgType = PBChatMsgTypeAudio;
    }else if (type == MessageBodyType_File){
        
    }else if (type == MessageBodyType_Video){
        
    }else if (type == MessageBodyType_Location){
        
    }else if (type == MessageBodyType_Call){
        
    }
    msg.messageBody = mBody;
    self.msg = msg;
}

#pragma mark -- Text Cell 类型相关方法

- (CGSize)getContentSize {
    NSString *displayInfo = [self.displayText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    NSDictionary *attributes = @{NSFontAttributeName:ChatContentFont,NSParagraphStyleAttributeName:style};
    CGFloat displayWidth = ceil(pb_autoResize(ChatContentW, @"6"));
    CGSize realSize = [displayInfo boundingRectWithSize:CGSizeMake(displayWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    
    return realSize;
}

@end
