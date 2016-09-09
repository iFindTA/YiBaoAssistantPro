//
//  PBChatProfiler.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/27.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBChatProfiler.h"
#import "PBChatInputBar.h"
#import "PBMorePanel.h"
#import "PBEmojiPanel.h"
#import "PBChatRefresh.h"

#import "PBChatFrame.h"
#import "PBChatBaseCell.h"

#import "ECError.h"
#import "ECMessage.h"
#import "ECTextMessageBody.h"
#import "ECFileMessageBody.h"
#import "ECImageMessageBody.h"
#import "ECVoiceMessageBody.h"

#import "MJRefresh.h"

@interface PBChatProfiler ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, PBChatInputBarDelegate, PBChatBaseCellDelegate>
//sessionid 即对方的voip ID
@property (nonatomic, copy) NSString *chatSID;
//conversionid 会话服务ID
@property (nonatomic, copy) NSString *chatCID;
//用户（对方）的用户userID
@property (nonatomic, copy) NSString *uid;
//用户昵称/群聊名称
@property (nonatomic, copy) NSString *chatTheme;
//用户昵称/群聊头像
@property (nonatomic, copy) NSString *chatAvatar;
//是否激活语音/表情输入 默认 否
@property (nonatomic, assign) BOOL isActiveAudio, isActiveEmoji;
//session 自带的最后一条消息（从其他页面进入聊天则此属性为空）
@property (nonatomic, strong, nullable) ECMessage *sessionMsg;
@property (nonatomic, strong, nullable) PBSession *lastSession;

//聊天界面相关
@property (nonatomic, strong) NSMutableArray *chatQueue;
@property (nonatomic, strong) UITableView *chatTable;
@property (nonatomic, strong) PBChatRefresh *headerRefresh;

//输入工具栏
@property (nonatomic, strong) PBChatInputBar *inputBar;
@property (nonatomic, strong) PBEmojiPanel *emojiKeyboard;
@property (nonatomic, strong) PBMorePanel *moreKeyboard;
@property (nonatomic, assign) PBChatInputState inputState;
@property (nonatomic, assign) CGFloat currentKeyboardHeight;

@end

@implementation PBChatProfiler

- (BOOL)canOpenedByNativeUrl:(NSURL *)url {
    return true;
}

- (void)dealloc {
    [[PBIMEngine shared] setChatSessionID:nil];
    [[PBIMEngine shared] removeDelegate:self delegateQueue:NULL];
    [[PBAFEngine shared] cancelRequestForClass:self.class];
    //[self unregisterKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[PBIMEngine shared] setChatSessionID:nil];
    [[PBIMEngine shared] removeDelegate:self delegateQueue:NULL];
}

#pragma mark -- 第一种初始化方法

/**
 *  @brief 初始化方法
 *
 *  @param aDict 参数集
 *  sessionID:      当前会话ID即对方的voip账号
 *  conversationID: 当前会话服务端ID（自身服务端API生成的ID）
 *
 *  @return 实例
 */
- (id)initWithParams:(NSDictionary *)aDict {
    self = [super init];
    if (self) {
        self.chatSID = [aDict objectForKey:@"sessionID"];
        self.chatCID = [aDict objectForKey:@"conversationID"];
        self.chatTheme = [aDict objectForKey:@"usrNick"];
        self.chatAvatar = [aDict objectForKey:@"usrAvatar"];
        self.isActiveAudio = [[aDict objectForKey:@"activeAudio"] boolValue];
        self.isActiveEmoji = [[aDict objectForKey:@"activeEmoji"] boolValue];
        //上个页面是否传来最后一条消息
        NSString *msg = [aDict objectForKey:@"msg"];
        if (!PBIsEmpty(msg)) {
            NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *msgDict = [NSJSONSerialization JSONObjectWithData:msgData options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:nil];
            [self convertSessionMsg:msgDict];
        }
        //设置当前会话session ID 即对方voip ID
        //add im's multicast delegate
        dispatch_queue_t queue = dispatch_queue_create("com.publicBasic.im.ios-listen", DISPATCH_QUEUE_CONCURRENT);
        [[PBIMEngine shared] addDelegate:self delegateQueue:queue];
        [[PBIMEngine shared] setChatSessionID:self.chatSID];
    }
    return self;
}

- (void)convertSessionMsg:(NSDictionary *)aDict {
    if (PBIsEmpty(aDict)) {
        return;
    }
    ECMessage *msg = [[ECMessage alloc] init];
    msg.sessionId = self.chatSID;
    msg.from = self.chatSID;
    msg.to = [[PBDBEngine shared] authorIMID];
    long long timeStamp = [[aDict objectForKey:@"timeStamp"] longLongValue];
    msg.timestamp = PBFormat(@"%lld",timeStamp);
    msg.messageBody = [self assembleMessageBodyWithDict:aDict];
    self.sessionMsg = msg;
}

- (ECMessageBody *)assembleMessageBodyWithDict:(NSDictionary *)aDict {
    ECMessageBody *mBody = nil;
    NSString *text = [aDict objectForKey:@"text"];
    NSString *remark = [aDict objectForKey:@"remark"];
    NSString *localPath = [aDict objectForKey:@"localPath"];
    NSString *url = [aDict objectForKey:@"url"];
    NSUInteger duration = [[aDict objectForKey:@"duration"] integerValue];
    long long serverTime = [[aDict objectForKey:@"serverTime"] longLongValue];
    NSUInteger type = [[aDict objectForKey:@"msgtype"] integerValue];
    if (type == MessageBodyType_Text) {
        ECTextMessageBody *body = [[ECTextMessageBody alloc] initWithText:text];
        body.serverTime = PBFormat(@"%lld",serverTime);
        mBody = body;
    }else if (type == MessageBodyType_Image){
        ECImageMessageBody *body = [[ECImageMessageBody alloc] initWithFile:localPath displayName:@""];
        body.remotePath = url;
        body.serverTime = PBFormat(@"%lld",serverTime);
        body.thumbnailRemotePath = remark;
        mBody = body;
    }else if (type == MessageBodyType_Voice){
        ECVoiceMessageBody * body = [[ECVoiceMessageBody alloc] initWithFile:localPath displayName:@""];
        body.remotePath = url;
        body.serverTime = PBFormat(@"%lld",serverTime);
        //body.mediaDownloadStatus = [rs intForColumnIndex:12];
        body.displayName = remark;
        body.duration = duration;
        mBody = body;
    }else if (type == MessageBodyType_File){
        ECFileMessageBody *body = [[ECFileMessageBody alloc] initWithFile:localPath displayName:@""];
        body.remotePath = url;
        body.serverTime = PBFormat(@"%lld",serverTime);
        //body.mediaDownloadStatus = [rs intForColumnIndex:12];
        body.displayName = remark;
        mBody = body;
    }else if (type == MessageBodyType_Video){
        
    }else if (type == MessageBodyType_Location){
        
    }else if (type == MessageBodyType_Call){
        
    }
    return mBody;
}

#pragma mark -- 第二种初始化方法

- (instancetype)initWithSessionID:(NSString *)sid
                           forConversationID:(NSString *)cid
                                      forUid:(NSString *)usrid
                                     forNick:(nullable NSString *)nick
                                   forAvatar:(nullable NSString *)avatar
                                  forSession:(nullable PBSession *)session {
    self = [super init];
    if (self) {
        self.chatSID = [sid copy];
        self.chatCID = [cid copy];
        self.uid = [usrid copy];
        self.chatTheme = [nick copy];
        self.chatAvatar = [avatar copy];
        self.lastSession = session;
        //默认不开启语音、表情输入
        self.isActiveAudio = true;
        self.isActiveEmoji = true;
        //设置当前会话session ID 即对方voip ID
        //add im's multicast delegate
        dispatch_queue_t queue = dispatch_queue_create("com.publicBasic.im.ios-listen", DISPATCH_QUEUE_CONCURRENT);
        [[PBIMEngine shared] addDelegate:self delegateQueue:queue];
        [[PBIMEngine shared] setChatSessionID:self.chatSID];
    }
    return self;
}

#pragma mark -- getter

- (NSMutableArray *)chatQueue {
    if (!_chatQueue) {
        _chatQueue = [NSMutableArray arrayWithCapacity:0];
    }
    return _chatQueue;
}

- (PBEmojiPanel *)emojiKeyboard {
    if (!_emojiKeyboard) {
        PBEmojiPanel *emojiPanel = [[PBEmojiPanel alloc] initWithFrame:CGRectZero];
        [self.view addSubview:emojiPanel];
        _emojiKeyboard = emojiPanel;
        //_emojiKeyboard.delegate = self.inputBar;
        weakify(self)
        [_emojiKeyboard mas_makeConstraints:^(MASConstraintMaker *make) {
            strongify(self)
            make.top.equalTo(self.inputBar.mas_bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(PB_CHAT_KEYBOARD_HEIGHT);
        }];
    }
    return _emojiKeyboard;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.chatTheme;
    //left
    UIBarButtonItem *spacer = [self barSpacer];
    UIBarButtonItem *menuBar = [self barWithIcon:PB_NAVI_ICON_BACK withTarget:self withSelector:@selector(popUpLayer)];
    self.navigationItem.leftBarButtonItems = @[spacer, menuBar];
    //right
    UIBarButtonItem *moreBar = [self barWithIcon:@"\U0000e60b" withTarget:self withSelector:@selector(navigationBarMoreAction)];
    self.navigationItem.rightBarButtonItems = @[spacer, moreBar];
    
    [self renderChatBody];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.isInitialized) {
        self.isInitialized = true;
        //[self renderChatBody];
        //TODO:查询用户当前在线状态
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- navigationBar item action

- (void)navigationBarMoreAction {
    
}

#pragma mark -- IMEngine delegate for New Msg

- (void)newIMMsgDidReceived:(ECMessage *)msg {
    NSLog(@"%@:didReceivedMsg:%@",NSStringFromClass([self class]),msg.description);
}

#pragma mark -- 聊天界面
- (void)renderChatBody {
    
    if (self.chatTable != nil) {
        return;
    }
    
    //chat table
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor pb_colorWithHexString:PB_BASE_BG_HEX];
    table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:table];
    self.chatTable = table;
    UIView *tableBgView = [[UIView alloc] init];
    //tableBgView.backgroundColor = [UIColor pb_randomColor];
    table.backgroundView = tableBgView;
    //加载历史更多数据
//    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, -40, PBSCREEN_WIDTH, 40)];
//    refreshControl.backgroundColor = [UIColor pb_randomColor];
//    [refreshControl addTarget:self action:@selector(loadHistory) forControlEvents:UIControlEventValueChanged];
//    table.backgroundView = refreshControl;;
    //PBChatRefresh *refreshControl = [[PBChatRefresh alloc] initWithFrame:CGRectZero];
    weakify(self)
    PBChatRefresh *refreshControl = [[PBChatRefresh alloc] initWithScrollView:table withEvent:^{
        NSLog(@"开始加载历史数据！");
        strongify(self);
        PBMAINDelay(2, ^{
            [self.headerRefresh endRefreshingWithNoMoreData];
        });
    }];
    [table.backgroundView addSubview:refreshControl];
    self.headerRefresh = refreshControl;
    [refreshControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(tableBgView);
        make.bottom.equalTo(self.chatTable.mas_top);
        make.height.equalTo(PB_CHAT_REFRESH_HEIGHT);
    }];
    
    //input bar
    PBChatInputBar *inputBar = [[PBChatInputBar alloc] initWithDependencyRoot:self];
    inputBar.delegate = self;
    [self.view addSubview:inputBar];
    self.inputBar = inputBar;
    
    //weakify(self)
    [self.chatTable mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.inputBar.mas_top);
    }];
    [self.inputBar mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.equalTo(self.chatTable.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(PB_CHAT_TOOLBAR_HEIGHT);
    }];
    //input bar's more keyboard
    [self.inputBar enableAudioInputAction:self.isActiveAudio];
    //input bar's emoji keyboard
    [self.inputBar enableEmojiInputAction:self.isActiveEmoji];
    if (self.isActiveEmoji) {
        self.emojiKeyboard.delegate = self.inputBar;
    }
    //more function
    PBMorePanel *morePanel = [[PBMorePanel alloc] initWithFrame:CGRectZero];
    [self.view addSubview:morePanel];
    self.moreKeyboard = morePanel;
    self.moreKeyboard.delegate = self.inputBar;
    [self.moreKeyboard mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.equalTo(self.inputBar.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.equalTo(PB_CHAT_KEYBOARD_HEIGHT);
    }];
    
    //[self registerKeyboardNotification];
    self.currentKeyboardHeight = 0;
    self.inputState = PBChatInputStateNone;
    
    //准备初始化本地数据
    [self _initLocalPathChatData];
    //刷新表格
    [self.chatTable reloadData];
    [self scroll2Bottom];
    
    //获取历史消息
    [self loadMoreHistoryChatMsgs];
}

#pragma mark -- get chat data
//初始化UI完毕之后 初始化本地聊天数据
- (void)_initLocalPathChatData {
    [self.chatQueue removeAllObjects];
    //获取本地保存的数据 默认10条
    NSArray *tmpChats = [[PBDBEngine shared] getMsgsFromTimeStamp:0 withSession:self.chatSID];
    if (PBIsEmpty(tmpChats)) {
        if (self.sessionMsg) {
            PBChatFrame *msgFrame = [[PBChatFrame alloc] initWithMsg:self.sessionMsg withPreStamp:0];
            [self.chatQueue addObject:msgFrame];
            _sessionMsg = nil;
        } else if (self.lastSession) {
            PBChatFrame *msgFrame = [[PBChatFrame alloc] initWithSession:self.lastSession withPreStamp:0];
            [self.chatQueue addObject:msgFrame];
            _lastSession = nil;
        }
    }else{
        //TODO:转换为ChatFrame
        [self.chatQueue addObjectsFromArray:tmpChats];
    }
}
//每页获取条数
static const int PB_CHAT_PAGE_SIZE                      =       10;
/**
 *  @brief 加载更多历史消息 每页10条数据
 */
- (void)loadMoreHistoryChatMsgs {
    NSString *lastMsgID = nil;
    if (self.chatQueue.count) {
        
    }
    lastMsgID = PBAvailableString(lastMsgID);
    NSUInteger msgPageSize = PB_CHAT_PAGE_SIZE;
    NSDictionary *dic = @{
                          @"conversationId" : self.chatCID,
                          @"num" : @(msgPageSize),
                          @"msgId" : lastMsgID
                          };
    NSDictionary *params = [[PBAFEngine shared] encryptionDictionary:dic];
    weakify(self)
    [[PBAFEngine shared] GET:@"im/getHistoryMsg" parameters:params vcr:nil view:nil hudEnable:false success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObj) {
        NSString *dataString = [responseObj objectForKey:@"data"];
        NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *parseError = nil;
        NSArray *hMsgs = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&parseError];
        strongify(self)
        [self dealWithLoadedHistoryMsgs:hMsgs];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        strongify(self)
        [self handleRequestError:error withCompleteion:nil];
    }];
}

- (void)dealWithLoadedHistoryMsgs:(nullable NSArray <NSDictionary *>*)msgs {
    if (PBIsEmpty(msgs)) {
        return;
    }
    
    __block NSMutableArray <PBChatMessage *>*tmpDatas = [NSMutableArray arrayWithCapacity:0];
    [msgs enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PBChatMessage *msg = [PBChatMessage mj_objectWithKeyValues:obj];
        [tmpDatas addObject:msg];
    }];
    NSLog(@"loaded history msg:%@",tmpDatas);
}

#pragma mark -- scrollview scroll actions

- (void)scroll2Top {
    
}

- (void)scroll2Bottom {
    if (PBIsEmpty(self.chatQueue)) {
        return;
    }
    NSUInteger mCounts = self.chatQueue.count;
    if (mCounts == 0) {
        return;
    }
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:mCounts-1 inSection:0];
//    [self.chatTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:true];
}

- (void)scroll2IndexPath4Row:(NSUInteger)row {
    
}

#pragma mark -- TableView & ScrollView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatQueue.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat mHeight = 0;
    //NSArray *dataSource = self.chatQueue.copy;
    NSUInteger __row = indexPath.row;NSUInteger mCounts = self.chatQueue.count;
    if (__row >= mCounts) {
        return mHeight;
    }
    
    /*
    static PBChatBaseCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [[PBChatBaseCell alloc] init];
    });
    
    ECMessage *msg = self.chatQueue[__row];
    mHeight = [cell pb_chatCellHeight:msg];
    //*/
    
    PBChatFrame *msgFrame = self.chatQueue[__row];
    mHeight = [msgFrame getCellHeight];
    return mHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSArray *dataSource = self.chatQueue.copy;
    NSUInteger __row = indexPath.row;NSUInteger mCounts = self.chatQueue.count;
    if (__row >= mCounts) {
        return nil;
    }
    PBChatFrame *msgFrame = self.chatQueue[__row];
    NSString *identifier = [msgFrame getCellIdentifier];
    PBChatBaseCell *cell = (PBChatBaseCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        Class aClass = [msgFrame getCellClass];
        cell = [[aClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //bad method call in this area!!!
    //[cell layoutIfNeeded];
    
    [cell updateCellContent4Frame:msgFrame];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self endEditingState];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self endEditingState];
}

- (void)endEditingState {
    [self.inputBar outTriggerEndFirstResponder];
}

#pragma mark -- keyboard notifications
/*
- (void)registerKeyboardNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_keyboardWillDisAppear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_keyboardWillAppear:(NSNotification *)notis {
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[notis.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [notis.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notis.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    self.inputState = PBChatInputStateText;
    //文本输入状态下重置各个功能按钮状态
    [self.inputBar resetOtherInputState];
    // Need to translate the bounds to account for rotation.
    //keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    // set views with new info
    [self.inputBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-keyboardBounds.size.height-PB_BOUNDARY_OFFSET);
    }];
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    [self.view layoutIfNeeded];
    
    // commit animations
    [UIView commitAnimations];
}

- (void)_keyboardWillDisAppear:(NSNotification *)notis {
    CGFloat offset = 0;
    if (self.inputState == PBChatInputStateMore) {
        offset = PB_CHAT_KEYBOARD_HEIGHT;
    }
    // set views with new info
    [self.inputBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-offset);
    }];
    [self.inputBar resetOtherInputState];
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:PBANIMATE_DURATION];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [self.view layoutIfNeeded];
    
    // commit animations
    [UIView commitAnimations];
}
//*/

#pragma mark -- Input Bar Delegate

- (void)chatInputBar:(PBChatInputBar *)bar willChange2InputState:(PBChatInputState)state withKeyboardHeight:(CGFloat)keyHeight {
    if (self.inputState == state && self.currentKeyboardHeight==keyHeight) {
        return;
    }
    if (state == PBChatInputStateNone) {
        keyHeight = 0;
    }
    if (state == PBChatInputStateEmoji) {
        [self.view bringSubviewToFront:self.emojiKeyboard];
        //切换到输入emoji键盘时要根据当前输入的文本框信息 激活/重置 发送按钮状态
        NSString *tmpInfo = [self.inputBar currentInputInfo];
        BOOL enable = !PBIsEmpty(tmpInfo);
        [self.emojiKeyboard enableEmojiKeyboardSendState:enable];
    }else if (state == PBChatInputStateMore){
        [self.view bringSubviewToFront:self.moreKeyboard];
    }
    self.inputState = state;
    self.currentKeyboardHeight = keyHeight;
    // set views with new info
    [self.inputBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-keyHeight);
    }];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:PBANIMATE_DURATION];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [self.view layoutIfNeeded];
    
    // commit animations
    [UIView commitAnimations];
}

- (void)chatInputBar:(PBChatInputBar *)bar didChangeInputInfo:(NSString *)info {
    BOOL enable = !PBIsEmpty(info);
    [self.emojiKeyboard enableEmojiKeyboardSendState:enable];
}

- (void)chatInputBar:(PBChatInputBar *)bar didSelectedMoreFunctionRouter:(NSURL *)url {
    BOOL shouldResponse = [[PBMediator shared] shouldDisplayURL:url];
    if (!shouldResponse) {
        return;
    }
    UIViewController *dstLogicModule = [[PBMediator shared] nativeCallWithURL:url];
    UINavigationController *dstModuleNaviBar = [[UINavigationController alloc] initWithRootViewController:dstLogicModule];
    [self presentViewController:dstModuleNaviBar animated:true completion:nil];
}

- (void)chatInputBar:(PBChatInputBar *)bar willSendText:(NSString *)msg {
    //调整发送按钮状态
    if (self.emojiKeyboard) {
        [self.emojiKeyboard enableEmojiKeyboardSendState:false];
    }
    //去除两端的空白字符
    msg = [msg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (PBIsEmpty(msg)) {
        [SVProgressHUD showErrorWithStatus:@"不能发送空白信息！"];
        return;
    }
    //TODO:调用发送消息接口
}

#pragma mark -- load more history

- (void)loadHistory {
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
