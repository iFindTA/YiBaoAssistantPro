//
//  PBIMEngine.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/22.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBIMEngine.h"
#import "PBAFEngine.h"
#import "PBDBEngine.h"
#import "GCDMulticastDelegate.h"
#import "ECDeviceHeaders.h"
#import <AudioToolbox/AudioToolbox.h>
#import "PBSession.h"

@interface PBIMEngine ()<ECDeviceDelegate>

@property (nonatomic, assign) ECConnectState IMState;

@property (atomic, assign) NSUInteger offlineCount;

@end

static PBIMEngine *instance = nil;
static dispatch_once_t onceToken;

@implementation PBIMEngine

//+ (id)allocWithZone:(struct _NSZone *)zone {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if (instance == nil) {
//            instance = [super allocWithZone:zone];
//        }
//    });
//    return instance;
//}

- (id)copyWithZone:(struct _NSZone *)zone {
    return instance;
}

+ (PBIMEngine *)shared {
    //static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[PBIMEngine alloc] init];
            [ECDevice sharedInstance].delegate = instance;
        }
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        // init multicastDelegate
        self.multicastDelegate = [[GCDMulticastDelegate alloc] init];
        
        //setting delegate
        self.IMState = State_ConnectFailed;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

+ (void)released {
    [[ECDevice sharedInstance] logout:^(ECError *error) {
        NSLog(@"stop im engine...");
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    onceToken = 0;instance = nil;
}

- (void)_applicationDidBecomeActive {
    [self checkConnectState];
}

#pragma mark -- Multicast Delegate
- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
//    [self.multicastDelegate addDelegate:delegate delegateQueue:delegateQueue];
//    return;
    weakify(self)
    dispatch_block_t block = ^{
        strongify(self)
        [self.multicastDelegate addDelegate:delegate delegateQueue:delegateQueue];
    };
    
    block();
    GCDMulticastDelegate *multicast = (GCDMulticastDelegate *)self.multicastDelegate;
    //NSLog(@"multicast delegate count:%zd",multicast.count);
}

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    weakify(self)
    dispatch_block_t block = ^{
        strongify(self)
        [self.multicastDelegate removeDelegate:delegate delegateQueue:delegateQueue];
    };
    
    block();
    GCDMulticastDelegate *multicast = (GCDMulticastDelegate *)self.multicastDelegate;
    //NSLog(@"multicast delegate count:%zd",multicast.count);
}

-(void)acceptMessage:(ECMessage *)msg {
    // send message to delegate
    [self.multicastDelegate newIMMsgDidReceived:msg];
}

#pragma mark -- setup for im
- (void)checkConnectState {
    if ([[PBAFEngine shared] netEnable] && self.IMState == State_ConnectFailed) {
        NSLog(@"im restart!...");
        [self reStart];
    }
}
- (void)start {
    //登录IM
    
    NSDateFormatter *formatter = [[PBDBEngine shared] dateFormatter4Style:@"yyyyMMddHHmmss"];
    NSString *timestamp = [formatter stringFromDate:[NSDate date]];
    timestamp = PBFormat(@"%lld",[[PBDBEngine shared] authorTimeStamp]);
    BBRSACryptor *rsa = [[PBAFEngine shared] getRSA];
    NSString *tmpUsrID = [[PBDBEngine shared] authorID];
    NSData *key = [tmpUsrID dataUsingEncoding:NSUTF8StringEncoding];
    NSData *tokenData = [rsa encryptWithPublicKeyUsingPadding:RSA_PADDING_TYPE_PKCS1 plainData:key];
    NSString *token = [GTMBase64 stringByEncodingData:tokenData];
    NSDictionary *parameter = [[PBAFEngine shared] encryptionDictionary:@{ @"timestamp" : timestamp} withToken:token];
    //NSLog(@"init im params:%@",parameter);
    //__weak typeof([PBAFEngine shared]) weakAF = [PBAFEngine shared];
    weakify(self)
    [[PBAFEngine shared] GET:@"im/initIM" parameters:parameter vcr:nil view:nil hudEnable:false success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObj) {
        NSLog(@"init im engine response:%@",responseObj);
        strongify(self)
        //__strong typeof(PBAFEngine) *strongAF = weakAF;
        NSString *dataString = [responseObj objectForKey:@"data"];
        NSDictionary *data = [[PBAFEngine shared] json2Dict:dataString];
        //[strongAF saveKey:@"fromVoIP" withValue:data[@"fromVoIP"]];
        //[strongAF saveKey:@"sig" withValue:data[@"sig"]];
        NSString *fromVoip = [data objectForKey:@"fromVoIP"];
        [self loginRonglianIMWithVoip:fromVoip];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"init im engine failed:%@",error.localizedDescription);
        
    }];
}

- (void)reStart {
    if (self.IMState != State_ConnectFailed) {
        return;
    }
    NSString *tmpIMID = [[PBDBEngine shared] authorIMID];
    [self loginRonglianIMWithVoip:tmpIMID];
}

- (void)setConfigData:(NSString*)CIP :(NSString*)CPORT :(NSString*)LIP :(NSString*)LPORT :(NSString*)FIP :(NSString*)FPORT  {
    
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><ServerAddr version=\"2\"><Connector><server><host>%@</host><port>%@</port></server></Connector><LVS><server><host>%@</host><port>%@</port></server></LVS><FileServer><server><host>%@</host><port>%@</port></server></FileServer></ServerAddr>",CIP,CPORT,LIP,LPORT,FIP,FPORT];
    //Caches文件路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //服务器配置文件夹
    NSString * config = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"config.data"];
    
    [[string dataUsingEncoding:NSUTF8StringEncoding] writeToFile:config atomically:YES];
    [[ECDevice sharedInstance] SwitchServerEvn:NO];
}

- (void)loginRonglianIMWithVoip:(NSString *)voip {
    if (PBIsEmpty(voip)) {
        return;
    }
    NSString *tmpUsrID = [[PBDBEngine shared] authorID];
    [[PBDBEngine shared] updateIMID:[voip copy] authorID:tmpUsrID];
    //初始化登录信息类ECLoginInfo实例（ECLoginInfo已经包含在SDK包里，不要用户创建）
    //默认模式：对AppKey、AppToken和userName鉴权
    ECLoginInfo * loginInfo = [[ECLoginInfo alloc] init];
    loginInfo.username = [voip copy];//用户登录app的用户id即可。
#if DEBUG && 0
    loginInfo.appKey = @"8a22e7ba5626b36f015626bd05100000";
    loginInfo.appToken = @"a8ccfa322d31afd8ee1e6fa547b358a8";
#else
    loginInfo.appKey = @"aaf98f894fa5766f014fa60919d000c5";
    loginInfo.appToken = @"62dbcaab3ad556605a2be9f50fe85b69";
#endif
    loginInfo.authType = LoginAuthType_NormalAuth;//默认方式登录
    loginInfo.mode = LoginMode_InputPassword;
    //服务器配置
    [self setConfigData:@"ybkj.cloopen.com" :@"8085" :@"ybkj.cloopen.com" :@"8888" :@"ybkj.cloopen.com" :@"8090"];
    weakify(self)
    [[ECDevice sharedInstance] login:loginInfo completion:^(ECError *error){
        strongify(self)
        if (error.errorCode == ECErrorType_NoError) {
            //登录成功
            NSLog(@"登录容联云成功");
            self.IMState = State_ConnectSuccess;
            [self.multicastDelegate newIMMsgPullState:(PBMSGPullState)self.IMState];
            // 获取会话列表，缓存
            NSDictionary *sessionListParamDic = @{
                                                  @"start" : @"0",
                                                  @"size" : @"1000"
                                                  };
            NSDictionary *sessionListParam = [[PBAFEngine shared] encryptionDictionary:sessionListParamDic];
            //NSLog(@"get session params:%@",sessionListParam);
            weakify(self)
            [[PBAFEngine shared] GET:@"im/getConversationList" parameters:sessionListParam vcr:nil view:nil hudEnable:false success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObj) {
                //NSLog(@"get conversation :%@",responseObj);
                NSString *dataString = [responseObj objectForKey:@"data"];
                NSDictionary *data = [[PBAFEngine shared] json2Dict:dataString];
                NSArray *conversations = [data objectForKey:@"conversation"];
                //保存新的session会话
                strongify(self)
                [self saveNewestSessions:conversations];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"get sessions error:%@",error.localizedDescription);
                strongify(self)
                [self.multicastDelegate initEngineError:error];
            }];
            
        }else{
            //登录失败
            NSLog(@"登录容联云失败:%zd---%@",error.errorCode,error.errorDescription);
            if (error.errorCode == 99 || error.errorCode==1000) {
                NSError *mError = [NSError errorWithDomain:PBAvailableString(error.errorDescription) code:error.errorCode userInfo:nil];
                strongify(self)
                [self.multicastDelegate initEngineError:mError];
            }
            if (!PBIsEmpty(error.errorDescription)) {
                self.IMState = State_ConnectFailed;
                [self.multicastDelegate newIMMsgPullState:(PBMSGPullState)self.IMState];
            }
        }
    }];
}

- (void)saveNewestSessions:(NSArray *)sessions {
    if (PBIsEmpty(sessions)) {
        return;
    }
    //清除该用户 旧的session会话
    [[PBDBEngine shared] clearAllSessions];
    NSLog(@"conversations count:%zd",sessions.count);
    __block NSMutableArray *sess = [NSMutableArray arrayWithCapacity:0];
    [sessions enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PBSession *mSession = [PBSession mj_objectWithKeyValues:obj];
        //做个异常处理 如果消息是未回复 则未读个数加1
        if (mSession.replyStatus!=2 && mSession.unreadCount==0) {
            mSession.unreadCount += 1;
        }
        [sess addObject:mSession];
    }];
    [[PBDBEngine shared] saveNewestSessions:sess.copy];
    [self.multicastDelegate refreshSessions:sess.copy];
}

#pragma mark -- ECDeviceDelegate --

- (void)onReachbilityChanged:(ECNetworkType)status {
    if (status != ECNetworkType_NONE && self.IMState == State_ConnectFailed) {
        NSLog(@"im restart!...");
        [self reStart];
    }
}
/**
 @brief 连接状态接口
 @discussion 监听与服务器的连接状态 V5.0版本接口
 @param state 连接的状态
 @param error 错误原因值
 */
-(void)onConnectState:(ECConnectState)state failed:(ECError*)error {
    switch (state) {
        case State_ConnectSuccess:
            NSLog(@"IM Engine State:conneted---%@",error.errorDescription);
            break;
        case State_Connecting:
            NSLog(@"IM Engine State:conneting---%@",error.errorDescription);
            break;
        case State_ConnectFailed:
            NSLog(@"IM Engine State:Failed---%@---code:%zd",error.errorDescription,error.errorCode);
            break;
        default:
            break;
    }
    self.IMState = state;
    [self.multicastDelegate newIMMsgPullState:(PBMSGPullState)self.IMState];
    if (error.errorCode == ECErrorType_KickedOff) {
        [self.multicastDelegate accountKnickedOff:error];
    }
}

/**
 @brief 离线消息数
 @param count 消息数
 */
-(void)onOfflineMessageCount:(NSUInteger)count{
    NSLog(@"onOfflineMessageCount=%lu",(unsigned long)count);
    self.offlineCount = count;
}

/**
 @brief 需要获取的消息数
 @return 消息数 -1:全部获取 0:不获取
 */
-(NSInteger)onGetOfflineMessage{
    NSInteger retCount = -1;
    if (self.offlineCount!=0) {
        
    }
    return retCount;
}

/**
 @brief 接收离线消息代理函数
 @param message 接收的消息
 */
-(void)onReceiveOfflineMessage:(ECMessage*)message{
    NSLog(@"onReceiveOfflineMessage=%@",message);
    self.IMState = State_ConnectSuccess;
    [self.multicastDelegate newIMMsgPullState:PBMSGPullStatePulling];
    [self imEngineDidReceivedMsg:message];
}

/**
 @brief 离线消息接收是否完成
 @param isCompletion YES:拉取完成 NO:拉取未完成(拉取消息失败)
 */
-(void)onReceiveOfflineCompletion:(BOOL)isCompletion {
    [self.multicastDelegate newIMMsgPullState:isCompletion?PBMSGPullStateNone:PBMSGPullStateError];
}

/**
 @brief 接收即时消息代理函数
 @param message 接收的消息
 */
-(void)onReceiveMessage:(ECMessage*)message {
    NSLog(@"received msg:%@",message);
    [self imEngineDidReceivedMsg:message];
}

- (void)vibrateDevice {
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}
//统一收到消息入口
- (void)imEngineDidReceivedMsg:(ECMessage *)msg {
    //vibrate device
    [self vibrateDevice];
    
    //时间转换成本地时间
    if (msg.timestamp) {
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp = [date timeIntervalSince1970] * 1000;
        msg.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    }
    //是否已读
    if (!PBIsEmpty(self.chatSessionID)
        && !PBIsEmpty(msg.sessionId)
        && [msg.sessionId isEqualToString:self.chatSessionID]) {
        msg.isRead = true;
    }
    //保存到数据库
    [[PBDBEngine shared] saveLatestNewMsg:msg];
    //通知 回调
    [self.multicastDelegate newIMMsgDidReceived:msg];
}

//统一发送消息入口

- (void)imEngineDidSendMsg:(ECMessage *)msg {
    
}

/**
 @brief 消息操作通知:已读、撤回、删除
 @param message 通知消息
 */
- (void)onReceiveMessageNotify:(ECMessageNotifyMsg *)message {
    NSLog(@"onReceiveMessageNotify:--%@",message);
}

@end
