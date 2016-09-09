//
//  YBMsgRootCtr.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/19.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "YBMsgRootCtr.h"
#import "YBSearchProfiler.h"
#import "PBNetworkLessCtr.h"
#import "PBBaseNavigationController.h"
#import "ECError.h"
#import "ECMessage.h"
#import "PBSession.h"
#import "PBSessionCell.h"
#import "KxMenu.h"

#import "PBMediator+ChatProfiler.h"

static int PBMsgSection                             =       4;
static int PBMsgSection_All                         =       -1;
//static int PBMsgSection_Network                     =       0;
//static int PBMsgSection_Reverse                     =       1;
static int PBMsgSection_Msginfo                     =       2;
//static int PBMsgSection_Empty                       =       3;

#pragma mark -- 消息列表简单cell：无网络｜暂无会话

@interface PBNetworkCell : UITableViewCell

@property (nonatomic, strong) UILabel *icon,*info,*arrow;

@end

@implementation PBNetworkCell

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
    UIFont *font = PBFont(@"iconfont", PBFontTitleSize);
    [self.contentView addSubview:self.icon];
    self.icon.font = font;
    self.icon.textColor = [UIColor pb_colorWithHexString:@"F65E4B"];
    
    [self.contentView addSubview:self.arrow];
    self.arrow.font = font;
    self.arrow.textColor = [UIColor pb_colorWithHexString:@"979797"];
    self.arrow.text = @"\U0000e608";
    
    font = PBSysFont(PBFontSubSize);
    [self.contentView addSubview:self.info];
    self.info.font = font;
    
    self.contentView.backgroundColor = [UIColor pb_colorWithHexString:@"FCEEB9"];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark -- autolayout subviews

- (void)layoutSubviews {
    [super layoutSubviews];
    weakify(self)
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(PB_BOUNDARY_OFFSET);
    }];
    
    [self.info mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.centerY.equalTo(self.icon);
        make.left.equalTo(self.icon.mas_right).offset(PB_BOUNDARY_OFFSET);
    }];
    
    [self.arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-PB_BOUNDARY_OFFSET);
    }];
}

- (UILabel *)icon {
    if (!_icon) {
        UILabel *label = [[UILabel alloc] init];
        _icon = label;
    }
    return _icon;
}

- (UILabel *)info {
    if (!_info) {
        UILabel *label = [[UILabel alloc] init];
        _info = label;
    }
    return _info;
}

- (UILabel *)arrow {
    if (!_arrow) {
        UILabel *label = [[UILabel alloc] init];
        _arrow = label;
    }
    return _arrow;
}

@end

@interface PBEmptyCell : UITableViewCell

@property (nonatomic, strong) UILabel *icon,*info;

@end

@implementation PBEmptyCell

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
    UIFont *font = PBFont(@"iconfont", PBFontTitleSize*6);
    [self.contentView addSubview:self.icon];
    self.icon.font = font;
    self.icon.textColor = [UIColor pb_colorWithHexString:@"ECECEC"];
    
    font = PBSysFont(PBFontTitleSize);
    [self.contentView addSubview:self.info];
    self.info.font = font;
    self.info.textColor = [UIColor pb_colorWithHexString:@"ECECEC"];
    self.info.textAlignment = NSTextAlignmentCenter;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark -- autolayout subviews

- (void)layoutSubviews {
    [super layoutSubviews];
    weakify(self)
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.centerX.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView).offset(-PB_BOUNDARY_MARGIN*4);
    }];
    
    [self.info mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.top.equalTo(self.icon.mas_bottom).offset(PB_BOUNDARY_MARGIN);
        make.left.right.equalTo(self.contentView);
    }];
}

- (UILabel *)icon {
    if (!_icon) {
        UILabel *label = [[UILabel alloc] init];
        _icon = label;
    }
    return _icon;
}

- (UILabel *)info {
    if (!_info) {
        UILabel *label = [[UILabel alloc] init];
        _info = label;
    }
    return _info;
}

@end

#pragma mark --  消息列表实体类

@interface YBMsgRootCtr ()<UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating,UISearchControllerDelegate>

/**
 *  @brief 消息队列 网络状态队列 预约队列 空内容队列
 */
@property (nonatomic, strong) NSMutableArray *msgQueue, *netStateQueue, *reverseQueue, *emptyQueue;
@property (nonatomic, strong) UITableView *msgTable;

//search logic
@property (nonatomic, strong) UISearchController *msgSearcher;
@property (nonatomic, strong) YBSearchProfiler *searchMaskLayer;

@end

@implementation YBMsgRootCtr

- (void)dealloc {
    [_msgSearcher.view removeFromSuperview];
    [_msgSearcher removeFromParentViewController];
}

- (id)init {
    self = [super init];
    if (self) {
        self.isInitialized = false;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //hidden tabbar when pushed
    self.hidesBottomBarWhenPushed = false;
    self.definesPresentationContext = true;
    self.extendedLayoutIncludesOpaqueBars = true;
    
    //navigation bar item
    UIBarButtonItem *spacer = [self barSpacer];
    UIBarButtonItem *menuBar = [self barWithIcon:@"\U0000e601" withTarget:self withSelector:@selector(navigationBarAddAction)];
    self.navigationItem.rightBarButtonItems = @[spacer, menuBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.isInitialized) {
        self.isInitialized = true;
        [self renderMsgQueueBody];
    }
    NSLog(@"will appear|");
    [self hideTabBar:self.msgSearcher.active animated:!self.msgSearcher.active];
    
    [self refreshAllSourceQueue];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self __checkIMEngine];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //menu dismiss
    [KxMenu dismissMenu];
}

#pragma mark -- Check IM Engine

- (void)__checkIMEngine {
    [[PBIMEngine shared] checkConnectState];
}

- (void)newIMMsgPullState:(PBMSGPullState)state {
    NSString *title = @"壹宝";
    if (state == PBMSGPullStatePulling) {
        title = @"收取中...";
    }else if (state == PBMSGPullStateError){
        title = @"壹宝(未连接)";
    }else if (state == PBMSGPullStateConnecting){
        title = @"连接中...";
    }
    PBMAINDelay(PBANIMATE_DURATION, ^{self.navigationItem.title = title;});
}

- (void)newIMMsgDidReceived:(ECMessage *)msg {
    NSLog(@"%@:didReceivedMsg:%@",NSStringFromClass([self class]),msg.description);
    
    self.view.userInteractionEnabled = false;
    __block BOOL isExist = false;__block PBSession *oldSession = nil;__block NSUInteger __row = 0;
    @synchronized (self.msgQueue) {
        [self.msgQueue enumerateObjectsUsingBlock:^(PBSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.sessionID isEqualToString:msg.sessionId]) {
                isExist = true;
                oldSession = obj;
                __row = idx;
                *stop = true;
            }
        }];
    }
    if (oldSession == nil) {
        oldSession = [[PBSession alloc] init];
        oldSession.sessionID = msg.sessionId;
        oldSession.unreadCount = 0;
        //oldSession.conversationId = nil;这个时候会话服务ID可能为空 需要从服务器拉取
        oldSession.assistantUserId = msg.to;
        oldSession.customerUserId = msg.from;
        oldSession.replyStatus = 1;
        oldSession.sendState = 0;
        oldSession.sticky = 0;
    }
    oldSession.text = [[PBDBEngine shared] getFileAttribute4Msg:msg];
    oldSession.type = msg.messageBody.messageBodyType;
    oldSession.dateTime = msg.timestamp.longLongValue;
    oldSession.lastMsgUserData = PBAvailableString(msg.userData);
    oldSession.unreadCount += (msg.isRead?0:1);
    //更新当前行cell
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:isExist?__row:0 inSection:PBMsgSection_Msginfo];
    if (!isExist) {
        [self.msgQueue insertObject:oldSession atIndex:0];
        PBMAIN(^{
            [self.msgTable insertRowsAtIndexPaths:[NSArray arrayWithObject:cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
    }else{
        PBMAIN(^{
            [self.msgTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
    }
    
    //更新tabbar未读/已读个数
    [self reloadTabBadgeValue];
    
    self.view.userInteractionEnabled = true;
}

- (void)accountKnickedOff:(ECError *)error {
    [PBIMEngine released];
    //帐号异地登录 切换到登录页面
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:error.errorDescription preferredStyle:UIAlertControllerStyleAlert];
    weakify(self)
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        strongify(self)
        PBMAINDelay(PBANIMATE_DURATION, ^{[self switchRoot2MainComponent:false];});
    }];
    [alertCtr addAction:action];
    PBMAINDelay(PBANIMATE_DURATION, ^{
        [self presentViewController:alertCtr animated:true completion:nil];
    });
}

- (void)initEngineError:(NSError *)error {
    [self handleRequestError:error withCompleteion:nil];
}

- (void)refreshSessions:(NSArray *)sessions {
    if (PBIsEmpty(sessions)) {
        return;
    }
    //return;
    self.view.userInteractionEnabled = false;
    [self.msgQueue removeAllObjects];
    //TODO:刷新session数据
    NSArray *sorted = [self sortedSessions:sessions];
    [self.msgQueue addObjectsFromArray:sorted];
    
    //空的提示条件==预约 && session队列全为空则显示
    if (self.reverseQueue.count==0 && self.msgQueue.count==0) {
        [self.emptyQueue removeAllObjects];
        NSString *info = @"暂无会话！";
        [self.emptyQueue addObject:info];
    }
    //刷新页面
    [self reloadTableSection:PBMsgSection_Msginfo];
    self.view.userInteractionEnabled = true;
}

#pragma mark -- refresh DataSource Queue

- (void)refreshAllSourceQueue {
    //self.view.userInteractionEnabled = false;
    NSLog(@"refresh session pre count:%zd",self.msgQueue.count);
    //[self reloadTableSection:PBMsgSection_All];
    
    [self.netStateQueue removeAllObjects];
    [self.emptyQueue removeAllObjects];
    [self.msgQueue removeAllObjects];
    //接口获取预约数据
    [self.reverseQueue removeAllObjects];
    if (![[PBAFEngine shared] netEnable]) {
        NSString *info = @"请检查当前网络连接！";
        [self.netStateQueue addObject:info];
    }
    
    //TODO:刷新session数据
    NSArray *sessions = [[PBDBEngine shared] getLatestSessions];
    NSArray *sorted = [self sortedSessions:sessions];
    [self.msgQueue addObjectsFromArray:sorted];
    
    //空的提示条件==预约 && session队列全为空则显示
    if (self.reverseQueue.count==0 && self.msgQueue.count==0) {
        NSString *info = @"暂无会话！";
        [self.emptyQueue addObject:info];
    }
    //刷新页面
    [self reloadTableSection:PBMsgSection_All];
    //[self.msgTable reloadData];
    //self.view.userInteractionEnabled = true;
}

- (void)reloadTableSection:(NSInteger)sec {
    NSLog(@"excute once!---%zd",self.msgQueue.count);
//    @try {
//        //[self.msgTable beginUpdates];
//        [self.msgTable reloadData];
//        //[self.msgTable endUpdates];
//    }
//    @catch (NSException *exception) {
//        NSLog(@"%@", exception);
//    }
//    @finally {
//        
//    }
//    PBMAIN(^{
//        [self.msgTable beginUpdates];
//        [self.msgTable reloadData];
//        [self.msgTable endUpdates];
//    });
//    PBMAINDelay(PBANIMATE_DURATION, ^{[self.msgTable reloadData];});
    if (sec < 0) {
        PBMAIN(^{
            [self.msgTable reloadData];
        });
    }else if (sec < PBMsgSection){
        PBMAIN(^{
            [self.msgTable reloadSections:[NSIndexSet indexSetWithIndex:sec] withRowAnimation:UITableViewRowAnimationAutomatic];
        });
    }
    //未读消息
    [self reloadTabBadgeValue];
}
//刷新tabBar未读消息个数
- (void)reloadTabBadgeValue {
    NSUInteger mCounts = [[PBDBEngine shared] getLatestSessionUnReadCounts];
    mCounts = (mCounts>0?mCounts:-1);
    //NSLog(@"消息tab未读消息个数:%zd",mCounts);
    PBMAINDelay(PBANIMATE_DURATION, ^{[self setBadgeValue:mCounts atIndex:0];});
}

//对当前session排序
- (NSArray *)sortedSessions:(NSArray <PBSession *> *)sessions {
    if (PBIsEmpty(sessions)) {
        return nil;
    }
    //__block NSMutableArray *pre_unReply = [NSMutableArray arrayWithCapacity:0];
    //__block NSMutableArray *pre_didReply = [NSMutableArray arrayWithCapacity:0];
    //1.先按照时间降序排列
    NSArray *sortedByDate = [sessions sortedArrayUsingComparator:^NSComparisonResult(PBSession * _Nonnull obj1, PBSession * _Nonnull obj2) {
        return [@(obj1.dateTime) compare:@(obj2.dateTime)] == NSOrderedAscending;
    }];
    /*2.再按照未回复>已回复排列 其实没有必要 真正要考虑的是是否置顶
    [sortedByDate enumerateObjectsUsingBlock:^(PBSession * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.replyStatus == 1) {
            //未回复
            [pre_unReply addObject:obj];
        }else{
            //已回复
            [pre_didReply addObject:obj];
        }
    }];
    NSMutableArray *sorted = [NSMutableArray arrayWithCapacity:0];
    if (!PBIsEmpty(pre_unReply)) {
        [sorted addObjectsFromArray:pre_unReply.copy];
    }
    if (!PBIsEmpty(pre_unReply)) {
        [sorted addObjectsFromArray:pre_didReply.copy];
    }
    return sorted.copy;
    //*/
    
    return sortedByDate;
}

#pragma mark -- getter

- (NSMutableArray *)msgQueue {
    if (_msgQueue == nil) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
        _msgQueue = arr;
    }
    return _msgQueue;
}

- (NSMutableArray *)netStateQueue {
    if (_netStateQueue == nil) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
        _netStateQueue = arr;
    }
    return _netStateQueue;
}

- (NSMutableArray *)reverseQueue {
    if (_reverseQueue == nil) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
        _reverseQueue = arr;
    }
    return _reverseQueue;
}

- (NSMutableArray *)emptyQueue {
    if (_emptyQueue == nil) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:0];
        _emptyQueue = arr;
    }
    return _emptyQueue;
}

- (YBSearchProfiler *)searchMaskLayer {
    if (!_searchMaskLayer) {
        //weakify(self)
        YBSearchProfiler * view = [[YBSearchProfiler alloc] initWithFrame:CGRectZero];
        [view handleSearchMsgEvent:^(id _Nonnull dd) {
            //strongify(self)
            //TODO:搜索结果
        }];
        _searchMaskLayer = view;
    }
    return _searchMaskLayer;
}

#pragma mark -- render msg body

- (void)renderMsgQueueBody {
    
    if (self.msgTable != nil) {
        return;
    }
    //table
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.delegate = self;
    table.dataSource = self;
    table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:table];
    self.msgTable = table;
    weakify(self)
    [table mas_makeConstraints:^(MASConstraintMaker *make) {
        strongify(self)
        make.edges.equalTo(self.view);
    }];
    
    //search controller ios8+
    UISearchController *searchCtr = [[UISearchController alloc] initWithSearchResultsController:nil];
    searchCtr.searchBar.placeholder = @"搜索";
    searchCtr.searchResultsUpdater = self;
    searchCtr.delegate = self;
    searchCtr.hidesNavigationBarDuringPresentation = true;
    searchCtr.dimsBackgroundDuringPresentation = false;
    table.tableHeaderView = searchCtr.searchBar;
    self.msgSearcher = searchCtr;
    //searchCtr.definesPresentationContext = YES;
    //searchRooter.definesPresentationContext = YES;
    [searchCtr.searchBar sizeToFit];
    
    //设置TableView的偏移
    table.contentOffset = CGPointMake(0, CGRectGetHeight(searchCtr.searchBar.bounds));
    [table reloadData];
    //TODO:test for data
//    int mCount = 30;
//    for (int i = 0; i < mCount; i++) {
//        NSString *name = PBFormat(@"name:%zd",i);
//        [self.msgQueue addObject:name];
//    }
    
}

#pragma mark -- Msg header search delegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    //NSLog(@"%s",__func__);
    [self hideTabBar:true animated:true];
    
    [self.view addSubview:self.searchMaskLayer];
    [self.searchMaskLayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    //NSLog(@"%s",__func__);
    [self hideTabBar:false animated:true];
    [self.searchMaskLayer removeFromSuperview];
    _searchMaskLayer = nil;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // 设置显示搜索结果的tableView
    //NSLog(@"%s",__func__);
    NSString * searchtext = searchController.searchBar.text;
    if (self.searchMaskLayer) {
        [self.searchMaskLayer searchKeywordDidChange2:searchtext];
    }
}

#pragma mark -- UITableView Datasource && Delegate

- (NSMutableArray *)dataSource4Section:(NSUInteger)sec {
   // NSArray *arr = nil;
    if (sec == 0) {
        return self.netStateQueue;
    }else if (sec == 1){
        return self.reverseQueue;
    }else if (sec == 2){
        return self.msgQueue;
    }else if (sec == 3){
        return self.emptyQueue;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return PBMsgSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSArray *tmpSource = [self dataSource4Section:section];
    NSUInteger mCount = 0;
    //NSArray *arr = nil;
    if (section == 0) {
        mCount = self.netStateQueue.count;
    }else if (section == 1){
        mCount = self.reverseQueue.count;
    }else if (section == 2){
        mCount = self.msgQueue.count;
        NSLog(@"消息表个数:%zd",mCount);
    }else if (section == 3){
        mCount = self.emptyQueue.count;
    }
    //NSLog(@"count:%zd",mCount);
    return mCount;
}

//height
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat mHeight = PB_CUSTOM_CELL_HEIGHT;
    NSUInteger __sec_idx = [indexPath section];
    if (__sec_idx == 0) {
        mHeight -= PB_BOUNDARY_MARGIN;
    } else if (__sec_idx == 3) {
        mHeight = PBSCREEN_HEIGHT-PB_NAVIBAR_HEIGHT-PB_NAVIBAR_HEIGHT;
    }
    return mHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UILabel *label = [[UILabel alloc] init];
//    label.backgroundColor = [UIColor pb_randomColor];
//    return label;
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    UILabel *label = [[UILabel alloc] init];
//    label.backgroundColor = [UIColor pb_randomColor];
//    return label;
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger __sec_idx = [indexPath section];
    NSUInteger __row_idx = [indexPath row];
    NSMutableArray *dataSource = [self dataSource4Section:__sec_idx];
    if (__sec_idx == 0) {
        static NSString *idendifier = @"netCell";
        PBNetworkCell *cell = (PBNetworkCell *)[tableView dequeueReusableCellWithIdentifier:idendifier];
        if (cell == nil) {
            cell = [[PBNetworkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idendifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell layoutIfNeeded];
        
        NSString *tmp = dataSource[__row_idx];
        cell.icon.text = @"\U0000e60d";
        cell.info.text = tmp;
        return cell;
    }else if (__sec_idx == 1){
        //预约
    }else if (__sec_idx == 2){
        //消息
        static NSString *idendifier = @"msgCell";
        PBSessionCell *cell = (PBSessionCell *)[tableView dequeueReusableCellWithIdentifier:idendifier];
        if (cell == nil) {
            cell = [[PBSessionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idendifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell layoutIfNeeded];
        
        PBSession *tmp = dataSource[__row_idx];
        [cell updateContent4Source:tmp];
        weakify(self)
        [cell handleSessionMoreAction:^(BOOL replyAction, MGSwipeTableCell *swipeCell) {
            strongify(self)
            NSIndexPath *dstPath = [self.msgTable indexPathForCell:swipeCell];
            //NSLog(@"reply:%zd---index row:%zd-%zd---destIndex:%zd-%zd",replyAction, indexPath.section,indexPath.row,dstPath.section,dstPath.row);
            if (replyAction) {
                [self readableMsg4Index:dstPath.row];
            }else{
                [self deleteMsg4Index:dstPath.row];
            }
        }];
        
        return cell;
    }else if (__sec_idx == 3){
        //空消息
        static NSString *idendifier = @"emptyCell";
        PBEmptyCell *cell = (PBEmptyCell *)[tableView dequeueReusableCellWithIdentifier:idendifier];
        if (cell == nil) {
            cell = [[PBEmptyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idendifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell layoutIfNeeded];
        
        NSString *tmp = dataSource[__row_idx];
        cell.icon.text = @"\U0000e60e";
        cell.info.text = tmp;
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger __sec_idx = [indexPath section];
    NSUInteger __row_idx = [indexPath row];
    if (__sec_idx == 0) {
        //无网络
        PBNetworkLessCtr *networkCtr = [[PBNetworkLessCtr alloc] init];
        networkCtr.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:networkCtr animated:true];
    }else if (__sec_idx == 3){
        //无会话
    }else if (__sec_idx == 1){
        //预约
    }else if (__sec_idx == 2){
        //消息
        //step1 获取当前session
        NSUInteger mCounts = self.msgQueue.count;
        if (__row_idx >= mCounts) {
            return;
        }
        PBSession *session = self.msgQueue[__row_idx];
        BOOL shouldUpdate = (session.unreadCount > 0);
        if (shouldUpdate) {
            session.unreadCount = 0;
            [[PBDBEngine shared] updateSession:session];
            //更新当前行cell(其实不用更新 因为在viewWillApear里会刷新)
//            PBMAIN(^{
//                [self.msgTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//            });
//            [self reloadTabBadgeValue];
        }
        /*第一种方法初始化
        //转为一条聊天消息 如果不是文本就为空 下个页面可以从网上获取
        NSString *msgString = nil;
        NSDictionary *msgDict = [[PBDBEngine shared] session2Dictinary:session];
        if (msgDict != nil) {
            NSData *msgData = [NSJSONSerialization dataWithJSONObject:msgDict options:NSJSONWritingPrettyPrinted error:nil];
            msgString = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
            msgString = PBAvailableString(msgString);
        }
        NSString *usrAvatar = PBAvailableString(session.headImg);
        NSString *usrNick = PBAvailableString(session.nickName);
        NSString *sessionID = session.sessionID;
        NSString *conversationID = session.conversationId;
        NSString *chatURLString = PBFormat(@"%@://%@/%@/?sessionID=%@&conversationID=%@&usrAvatar=%@&usrNick=%@&msg=%@",PB_SAFE_SCHEME,@"PBChatProfiler",@"initWithParams:",sessionID, conversationID, usrAvatar, usrNick, msgString);
        chatURLString = [chatURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *chatURL = [NSURL URLWithString:chatURLString];
        UIViewController *chatProfiler = [[PBMediator shared] nativeCallWithURL:chatURL];
        chatProfiler.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:chatProfiler animated:true];
        //*/
        //第二种方法初始化
        NSString *sid = session.sessionID;
        NSString *cid = session.conversationId;
        NSString *uid = session.customerUserId;
        NSString *nick = session.nickName;
        NSString *avatar = session.headImg;
        UIViewController *dstChatPtofiler = [[PBMediator shared] chat_calledBySessionID:sid forConversationID:cid forUid:uid forNick:nick forAvatar:avatar forSession:session];
        dstChatPtofiler.hidesBottomBarWhenPushed = true;
        [self.navigationController pushViewController:dstChatPtofiler animated:true];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

#pragma mark -- remark msg 2 unRead or read

- (void)readableMsg4Index:(NSUInteger)row {
    NSUInteger mCount = [self.msgQueue count];
    if (row >= mCount) {
        return;
    }
    self.view.userInteractionEnabled = false;
    PBSession *mSession = self.msgQueue[row];
    //之前已读/未读状态
    BOOL wetherDidRead = (mSession.unreadCount==0);
    //更新数据库数据
    [[PBDBEngine shared] wetherReadMsg:!wetherDidRead forSession:mSession.sessionID];
    //更新model数据
    mSession.unreadCount = wetherDidRead;
    //更新当前行cell
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:row inSection:PBMsgSection_Msginfo];
    PBMAIN(^{
        [self.msgTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
    //更新tabbar未读/已读个数
    [self reloadTabBadgeValue];
    self.view.userInteractionEnabled = true;
}

- (void)deleteMsg4Index:(NSUInteger)row {
    NSUInteger mCount = [self.msgQueue count];
    if (row >= mCount) {
        return;
    }
    NSLog(@"需要删除的行号:%zd",row);
    self.view.userInteractionEnabled = false;
    PBSession *mSession = self.msgQueue[row];
    //之前已读/未读状态
    BOOL wetherDidRead = (mSession.unreadCount==0);
    //删除数据库数据
    [[PBDBEngine shared] deleteSession:mSession.sessionID];
    //删除内存中数据
    [self.msgQueue removeObjectAtIndex:row];
    //删除表格对应行
    
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:row inSection:PBMsgSection_Msginfo];
    PBMAIN(^{
        [self.msgTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        //[self.msgTable reloadSections:[NSIndexSet indexSetWithIndex:PBMsgSection_Msginfo] withRowAnimation:UITableViewRowAnimationNone];
    });
    
    if (!wetherDidRead) {
        //更新tabbar未读/已读个数
        [self reloadTabBadgeValue];
    }
    self.view.userInteractionEnabled = true;
}


#pragma mark -- navigationBar actions

- (void)navigationBarAddAction {
    //TODO:导航条增加 actions：扫一扫 etc.
    NSUInteger iconSize = PBFontSubSize;UIColor *color = [UIColor whiteColor];
    UIImage *chatIcon = [UIImage pb_iconFont:nil withName:@"\U0000e611" withSize:iconSize withColor:color];
    chatIcon = [chatIcon pb_scaleToSize:CGSizeMake(PB_CUSTOM_LAB_HEIGHT, PB_CUSTOM_LAB_HEIGHT) keepAspect:true];
    UIImage *swipeIcon = [UIImage pb_iconFont:nil withName:@"\U0000e612" withSize:iconSize withColor:color];
    swipeIcon = [swipeIcon pb_scaleToSize:CGSizeMake(PB_CUSTOM_LAB_HEIGHT, PB_CUSTOM_LAB_HEIGHT) keepAspect:true];
    KxMenuItem *chatItem = [KxMenuItem menuItem:@"发起会话" image:chatIcon target:self action:@selector(launchNewChatSessionAction)];
    chatItem.alignment = NSTextAlignmentLeft;
    chatItem.foreColor = [UIColor lightGrayColor];
    KxMenuItem *swipeItem = [KxMenuItem menuItem:@"扫一扫" image:swipeIcon target:self action:@selector(launchQRCodeAction)];
    swipeItem.alignment = NSTextAlignmentLeft;
    [KxMenu setTitleFont:PBSysFont(iconSize)];
    //[KxMenu setTintColor:];
    [KxMenu showMenuInView:self.navigationController.view fromRect:CGRectMake(PBSCREEN_WIDTH-PB_NAVIBAR_ITEM_SIZE-PB_BOUNDARY_OFFSET, PB_NAVIBAR_ITEM_SIZE+PB_CUSTOM_LINE_HEIGHT, PB_NAVIBAR_ITEM_SIZE, PB_NAVIBAR_ITEM_SIZE) menuItems:@[chatItem,swipeItem]];
}

- (void)launchNewChatSessionAction {
    
}

- (void)launchQRCodeAction {
    
}

@end
