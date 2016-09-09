//
//  PBDBEngine.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/18.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBDBEngine.h"
#import <FMDB/FMDB.h>
#import <CommonCrypto/CommonDigest.h>
#import "PBUsr.h"
#import "PBSession.h"
#import "PBAFEngine.h"
#import "ECMessage.h"
#import "ECTextMessageBody.h"
#import "ECFileMessageBody.h"
#import "ECImageMessageBody.h"
#import "ECVoiceMessageBody.h"

static NSString *DBCipherKey                    =       @"com.yibao.guwen.ios";
static NSString *DBNAME                         =       @"securityInfo.db";
static NSString *DBSQLSTRUCT                    =       @"SQLSTUCT";

@interface PBDBEngine ()

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
//全局登录的用户
@property (nonatomic, strong) PBUsr *mUsr;

@end

static PBDBEngine *instance = nil;

@implementation PBDBEngine

+ (id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [super allocWithZone:zone];
        }
    });
    return instance;
}

+ (PBDBEngine *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[PBDBEngine alloc] init];
        }
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self createDBTables];
    }
    return self;
}

#pragma mark -- create db file and tables

- (NSString *)dbFilePath:(NSString *)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *filePath = [[paths firstObject] stringByAppendingPathComponent:file];
    return filePath;
}

// create db file
- (FMDatabaseQueue *)dbQueue {
    if (!_dbQueue) {
        NSString *dbpath = [self dbFilePath:DBNAME];
        ///创建数据库及线程队列
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbpath];
    }
    return _dbQueue;
}

- (BOOL)createDBTables {
    __block BOOL ret = false;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        [db setKey:DBCipherKey];
        NSString *sqlFile = [[NSBundle mainBundle] pathForResource:DBSQLSTRUCT ofType:@"txt"];
        NSString *sqls = [NSString stringWithContentsOfFile:sqlFile encoding:NSUTF8StringEncoding error:nil];
        NSArray *sqlArr = [sqls componentsSeparatedByString:@"|"];
        for (NSString *sql in sqlArr) {
            ret &= [db executeUpdate:sql];
        }
        NSString *filePath = NSHomeDirectory();
        NSLog(@"app sandbox path:%@",filePath);
    }];
    
    return ret;
}

- (NSString*)generateSessionTableNameWithSid:(NSString*)sessionid{
    //username md5
    const char *cStr = [sessionid UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    NSString* SessionMD5 =  [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],result[8], result[9], result[10], result[11],result[12], result[13], result[14], result[15]];
    
    return [NSString stringWithFormat:@"t_chat_%@", SessionMD5];
}

- (BOOL)isTableExist:(NSString *)table {
    __block BOOL ret = false;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [db setKey:DBCipherKey];
        ret = [db tableExists:table];
    }];
    return ret;
}

/**
 *  @brief create table dynamic
 *
 *  @param tableName the table name
 *  @param createSql create sql
 *
 *  @return wether success
 */
- (BOOL)createTable:(NSString*)tableName sql:(NSString *)createSql {
    __block BOOL ret = [self isTableExist:tableName];
    if (!ret) {
        [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [db setKey:DBCipherKey];
            ret = [db executeUpdate:createSql];
        }];
    }
    return ret;
}

- (BOOL )createChatMsgTableWithSessionID:(NSString *)sid {
    if (PBIsEmpty(sid)) {
        return false;
    }
    /*
     ID          自增	主键
     SID         会话ID
     msgid       消息id
     sender      发送者
     receiver	接收者
     createdTime	入库本地时间 毫秒
     userData	用户自定义数据
     msgType		消息类型 0:文本 1:多媒体 2:chunk消息 (0-99聊天的消息类型 100-199系统的推送消息类型)
     text        文本
     localPath	本地路径
     URL         下载路径
     state		发送状态 -1发送失败 0发送成功 1发送中 2接收成功（默认为0 接收的消息）；
     dstate      接收的附件消息下载状态 0未开始下载 1下载中 2下载成功 3下载失败
     serverTime	服务器时间 毫秒
     remark      备注
     duration   语音时长 文件长度
     ownerid    消息所属用户ID
     */
    __block BOOL ret = false;
    NSString *msgTableName = [self generateSessionTableNameWithSid:sid];
    ret = [self createTable:msgTableName sql:PBFormat(@"CREATE table %@(ID INTEGER PRIMARY KEY AUTOINCREMENT, SID varchar(32), msgid varchar(64),sender varchar(32), receiver varchar(32),createdTime INTEGER, userData varchar(256), msgType INTEGER, text TEXT, localPath TEXT, URL TEXT, state INTEGER, serverTime INTEGER,dstate INTEGER,remark TEXT,duration INTEGER,ownerid TEXT)",msgTableName)];
    return ret;
}

#pragma mark -- setup

- (NSDateFormatter *)dateDefaultFormatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    });
    return formatter;
}

- (NSDateFormatter *)dateFormatter4Style:(NSString *)style {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    });
    formatter.dateFormat = style;
    return formatter;
}

- (void)setupDB {
    //设置数据库表
    [self setupDBTable];
    //设置全局登录用户
    [self setupInitGlobalAuthor];
}

#pragma mark -- 设置数据库
- (void)setupDBTable {
    /*
     sessionId           会话id：对方的voIp
     dateTime            显示的时间 毫秒
     type                与消息表msgType一样
     text                最后一条消息内容
     unreadCount         未读消息数
     conversationId      服务端会话id
     assistantUserId     助理id
     customerUserId      用户id
     headImg             对方头像
     nickName            对方昵称
     isReplay            是否回复 1：未回复
     lastMsgUserData     最后一条消息的userData
     */
}

#pragma mark -- 登录用户有关

/**
 *  @brief 设置全局授权用户
 */
- (void)setupInitGlobalAuthor {
    if (_mUsr) _mUsr = nil;
    self.mUsr = [self getLatestAuthor];
    NSLog(@"uid:%@---imid:%@---auto:%@",self.mUsr.uid,self.mUsr.imid,self.mUsr.autologin);
}
/**
 *  @brief 获取最近的登录用户
 *
 *  @return usr
 */
- (PBUsr *)getLatestAuthor {
    __block PBUsr *tmpUsr = [[PBUsr alloc] init];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///处理事情
        [db setKey:DBCipherKey];
        FMResultSet *mRets = [db executeQuery:@"SELECT * FROM  t_author_usr ORDER BY authorStamp DESC LIMIT 1"];
        while ([mRets next]) {
            //tmpUsr = [[PBUsr alloc] init];
            tmpUsr.uid = [mRets stringForColumn:@"uid"];
            tmpUsr.imid = [mRets stringForColumn:@"imid"];
            NSLog(@"imid:>>>>>>>%@",tmpUsr.imid);
            tmpUsr.acc = [mRets stringForColumn:@"acc"];
            long long timeStamp = [mRets longLongIntForColumn:@"authorStamp"];
            tmpUsr.authorStamp = timeStamp;
            tmpUsr.pwd= [mRets stringForColumn:@"pwd"];
            tmpUsr.autologin = [mRets stringForColumn:@"autologin"];
        }
        [mRets close];
    }];
    return tmpUsr;
}

- (BOOL)wetherUsrDidAuthorization {
    BOOL autoAuthor = [self.mUsr autologin].boolValue;
    return self.mUsr && self.mUsr.uid.length>0 && self.mUsr.imid.length>0 && autoAuthor;
}

- (BOOL)saveAuthor:(PBUsr *)usr {
    if (!usr) {
        return false;
    }
    if (self.mUsr != nil) {
        if (![self.mUsr.uid isEqualToString:usr.uid]) {
            _mUsr = nil;
        }
    }
    self.mUsr = usr;
    
    __block BOOL ret = false;
    NSTimeInterval interval = [NSDate date].timeIntervalSince1970 * 1000;//毫秒
    //NSString *authoStamp = PBFormat(@"%lld",(long long)interval);
    self.mUsr.authorStamp = interval;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *mSQL = @"INSERT OR REPLACE INTO t_author_usr (uid, imid, acc, pwd, autologin, authorStamp) VALUES(?, ?, ?, ?, ?, ?)";
        NSMutableArray *params = [NSMutableArray array];
        [params addObject:usr.uid];
        [params addObject:PBAvailableString(usr.imid)];
        [params addObject:usr.acc];
        [params addObject:usr.pwd];
        [params addObject:usr.autologin];
        [params addObject:@(interval)];
        ///执行SQL语句
        [db setKey:DBCipherKey];
        ret = [db executeUpdate:mSQL withArgumentsInArray:params];
        NSLog(@"ret:%zd---保存登录用户",ret);
    }];
    return ret;
}

- (NSString *)authorID {
    return self.mUsr.uid;
}

- (NSString *)authorIMID {
    return self.mUsr.imid;
}

- (NSString *)authorAvatar {
    return self.mUsr.avatar;
}

- (NSString *)authorAccount {
    return self.mUsr.acc;
}

- (long long)authorTimeStamp {
    return self.mUsr.authorStamp;
}

- (BOOL)updateIMID:(NSString *)imid authorID:(NSString *)uid {
    if ([uid isEqualToString:self.mUsr.uid]) {
        self.mUsr.imid = imid;
    }
    __block BOOL ret = false;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///执行SQL语句
        [db setKey:DBCipherKey];
        ret = [db executeUpdate:@"UPDATE t_author_usr SET imid = ? WHERE uid = ?", imid, uid, nil];
        NSLog(@"ret:%zd---更新登录用户imid",ret);
    }];
    
    return ret;
}

#pragma mark -- session table method

- (BOOL)clearAllSessions {
    __block BOOL ret = false;
    if (PBIsEmpty(self.mUsr.uid)) {
        return ret;
    }
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///执行SQL语句
        [db setKey:DBCipherKey];
        ret = [db executeUpdate:@"DELETE FROM t_msg_session WHERE ownerid = ?",self.mUsr.uid];
        NSLog(@"ret:%zd---清除所有会话session",ret);
    }];
    
    return ret;
}
/**
 *  @brief 检查当前会话的服务端ID
 *
 *  @attention:造成服务端ID缺失的情况是因为发送与接受都是走第三方 并不通知自己后端服务器（这个是第三方不好的架构，正常情况下发送或接收成功第三方服务器应该回调自己的API服务器）
 *
 *  @param session
 *
 *  @return
 */
- (BOOL)checkConversationInfo4Session:(PBSession *)session {
    __block BOOL ret = true;
    if (!PBIsEmpty(session.conversationId)) {
        return ret;
    }
    NSLog(@"该条session需要去服务端同步数据!");
    //去服务端获取会话服务ID
    NSDictionary *dic = @{@"voip" : session.sessionID};
    NSDictionary *params = [[PBAFEngine shared] encryptionDictionary:dic];
    __weak typeof(PBDBEngine) *weakDBEngine = instance;
    [[PBAFEngine shared] GET:@"/im/getConversationByCustomerVoip" parameters:params vcr:nil view:nil hudEnable:false success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObj) {
        NSDictionary *mDataDict = [responseObj objectForKey:@"data"];
        __strong typeof(PBDBEngine) *strongDBEngine = weakDBEngine;
        PBSession *oldSession = [strongDBEngine getSession4ID:session.sessionID];
        if (!PBIsEmpty(oldSession.sessionID)) {
            oldSession.conversationId = mDataDict[@"id"];
            oldSession.assistantUserId = mDataDict[@"assistantUserId"];
            oldSession.customerUserId = mDataDict[@"customerUserId"];
            oldSession.headImg = mDataDict[@"customerHeadImg"];
            oldSession.nickName = mDataDict[@"customerNickName"];
            [strongDBEngine updateSession:oldSession];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"get session's convesation id failed:%@",error.localizedDescription);
    }];
    return ret;
}

- (BOOL)updateSession:(PBSession *)session {
    __block BOOL ret = false;
    if (PBIsEmpty(session.sessionID)) {
        return ret;
    }
    NSString *ownerID = self.mUsr.uid;
    NSString *mSQL = @"INSERT OR REPLACE INTO t_msg_session (sessionId, dateTime, type, text, unreadCount, conversationId, assistantUserId, customerUserId, replyStatus, lastMsgUserData, sendState, ownerid) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    //NSUInteger mCount = sessions.count;
    NSMutableArray *params = [NSMutableArray array];
    [params addObject:session.sessionID];
    [params addObject:@(session.dateTime)];
    [params addObject:@(session.type)];
    [params addObject:session.text];
    [params addObject:@(session.unreadCount)];
    [params addObject:PBAvailableString(session.conversationId)];
    [params addObject:PBAvailableString(session.assistantUserId)];
    [params addObject:PBAvailableString(session.customerUserId)];
    [params addObject:@(session.replyStatus)];
    [params addObject:PBAvailableString(session.lastMsgUserData)];
    [params addObject:@(session.sendState)];
    [params addObject:ownerID];
    //保存usr
    NSDictionary *usrDict = @{@"uid":session.customerUserId,@"nick":PBAvailableString(session.nickName),@"avatar":PBAvailableString(session.headImg)};
    [self saveSessionUsrs:@[usrDict]];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///执行SQL语句
        [db setKey:DBCipherKey];
        ret = [db executeUpdate:mSQL withArgumentsInArray:params];
        
        NSLog(@"ret:%zd---更新会话sessions",ret);
    }];
    //检测会话服务ID完整性
    [self checkConversationInfo4Session:session];
    return true;
}

- (BOOL)saveNewestSessions:(NSArray<PBSession *> *)sessions {
    __block BOOL ret = false;
    if (PBIsEmpty(sessions)) {
        return ret;
    }
    NSString *ownerID = self.mUsr.uid;
    NSString *mSQL = @"INSERT OR REPLACE INTO t_msg_session (sessionId, dateTime, type, text, unreadCount, conversationId, assistantUserId, customerUserId, replyStatus, lastMsgUserData, ownerid) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    //NSUInteger mCount = sessions.count;
    __block NSMutableArray *tmpUsrs = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSMutableArray *params = [NSMutableArray array];
        for (PBSession *mSession in sessions) {
            [params addObject:mSession.sessionID];
            [params addObject:@(mSession.dateTime)];
            [params addObject:@(mSession.type)];
            [params addObject:mSession.text];
            [params addObject:@(mSession.unreadCount)];
            [params addObject:PBAvailableString(mSession.conversationId)];
            [params addObject:PBAvailableString(mSession.assistantUserId)];
            [params addObject:PBAvailableString(mSession.customerUserId)];
            [params addObject:@(mSession.replyStatus)];
            [params addObject:PBAvailableString(mSession.lastMsgUserData)];
            [params addObject:ownerID];
            //保存usr
            NSDictionary *usrDict = @{@"uid":mSession.customerUserId,@"nick":PBAvailableString(mSession.nickName),@"avatar":PBAvailableString(mSession.headImg)};
            [tmpUsrs addObject:usrDict];
            ///执行SQL语句
            [db setKey:DBCipherKey];
            ret = [db executeUpdate:mSQL withArgumentsInArray:params];
            [params removeAllObjects];
        }
        
        NSLog(@"ret:%zd---保存最新会话sessions",ret);
    }];
    [self saveSessionUsrs:tmpUsrs.copy];
    return ret;
}

- (BOOL)saveSessionUsrs:(NSArray <NSDictionary *>*)usrs{
    __block BOOL ret = false;
    if (PBIsEmpty(usrs)) {
        return ret;
    }
    NSString *mSQL = @"INSERT OR REPLACE INTO t_usrs (uid, nick, avatar) VALUES(?, ?, ?)";
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSMutableArray *params = [NSMutableArray array];
        for (NSDictionary *mUsr in usrs) {
            [params addObject:PBAvailableString(mUsr[@"uid"])];
            [params addObject:mUsr[@"nick"]];
            [params addObject:mUsr[@"avatar"]];
            ///执行SQL语句
            [db setKey:DBCipherKey];
            ret = [db executeUpdate:mSQL withArgumentsInArray:params];
            [params removeAllObjects];
        }
        
        NSLog(@"ret:%zd---保存会话sessions中用户数据",ret);
    }];
    return ret;
}

- (NSArray <PBSession *>*)getLatestSessions {
    NSString *ownerID = self.mUsr.uid;
    __block NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithCapacity:0];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///处理事情
        [db setKey:DBCipherKey];
        //sessionId, dateTime, type, text, unreadCount, conversationId, assistantUserId, customerUserId, replyStatus, lastMsgUserData
        FMResultSet *mRets = [db executeQuery:@"SELECT * FROM  t_msg_session INNER JOIN t_usrs ON t_msg_session.customerUserId = t_usrs.uid WHERE t_msg_session.ownerid = ? ORDER BY dateTime DESC",ownerID];
        while ([mRets next]) {
            PBSession *mSession = [[PBSession alloc] init];
            mSession.sessionID = [mRets stringForColumn:@"sessionId"];
            mSession.dateTime = [mRets longLongIntForColumn:@"dateTime"];
            mSession.type = [mRets intForColumn:@"type"];
            mSession.text = [mRets stringForColumn:@"text"];
            mSession.unreadCount = [mRets intForColumn:@"unreadCount"];
            mSession.conversationId = [mRets stringForColumn:@"conversationId"];
            mSession.customerUserId = [mRets stringForColumn:@"customerUserId"];
            mSession.replyStatus = [mRets intForColumn:@"replyStatus"];
            mSession.lastMsgUserData = [mRets stringForColumn:@"lastMsgUserData"];
            mSession.sendState = [mRets intForColumn:@"sendState"];
            mSession.sticky = [mRets intForColumn:@"sticky"];
            mSession.nickName = [mRets stringForColumn:@"nick"];
            mSession.headImg = [mRets stringForColumn:@"avatar"];
            //NSLog(@"avatar:>>>>>>>%@",mSession.headImg);
            [tmpArr addObject:mSession];
        }
        [mRets close];
    }];
    return [tmpArr copy];
}

- (nullable PBSession *)getSession4ID:(NSString *)sessionid {
    __block PBSession *mSession = nil;
    if (PBIsEmpty(sessionid)) {
        return mSession;
    }
    NSString *ownerID = self.mUsr.uid;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///处理事情
        [db setKey:DBCipherKey];
        //sessionId, dateTime, type, text, unreadCount, conversationId, assistantUserId, customerUserId, replyStatus, lastMsgUserData
        FMResultSet *mRets = [db executeQuery:@"SELECT * FROM  t_msg_session INNER JOIN t_usrs ON t_msg_session.customerUserId = t_usrs.uid WHERE sessionId = ? AND ownerid = ?", sessionid, ownerID];
        while ([mRets next]) {
            mSession = [[PBSession alloc] init];
            mSession.sessionID = [mRets stringForColumn:@"sessionId"];
            mSession.dateTime = [mRets longLongIntForColumn:@"dateTime"];
            mSession.type = [mRets intForColumn:@"type"];
            mSession.text = [mRets stringForColumn:@"text"];
            mSession.unreadCount = [mRets intForColumn:@"unreadCount"];
            mSession.conversationId = [mRets stringForColumn:@"conversationId"];
            mSession.customerUserId = [mRets stringForColumn:@"customerUserId"];
            mSession.replyStatus = [mRets intForColumn:@"replyStatus"];
            mSession.lastMsgUserData = [mRets stringForColumn:@"lastMsgUserData"];
            mSession.sendState = [mRets intForColumn:@"sendState"];
            mSession.sticky = [mRets intForColumn:@"sticky"];
            mSession.nickName = [mRets stringForColumn:@"nick"];
            mSession.headImg = [mRets stringForColumn:@"avatar"];
        }
        [mRets close];
    }];
    return mSession;
}

- (NSUInteger)getLatestSessionUnReadCounts {
    NSString *ownerID = self.mUsr.uid;
    __block NSUInteger mCounts = 0;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///执行SQL语句
        [db setKey:DBCipherKey];
        FMResultSet *mRets = [db executeQuery:@"SELECT SUM(unreadCount) FROM t_msg_session WHERE ownerid = ?",ownerID];
        while ([mRets next]) {
            mCounts = [mRets intForColumnIndex:0];
        }
        [mRets close];
    }];
    NSLog(@"未读消息个数:%zd---",mCounts);
    return mCounts;
}

//标记为已读 or 未读
- (BOOL)wetherReadMsg:(BOOL)readable forSession:(NSString *)sessionid {
    __block BOOL ret = false;
    if (PBIsEmpty(sessionid)) {
        return ret;
    }
    NSString *ownerID = self.mUsr.uid;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///执行SQL语句
        [db setKey:DBCipherKey];
        ret = [db executeUpdate:@"UPDATE t_msg_session SET unreadCount = ? WHERE sessionId = ? AND ownerid = ?", @(!readable), sessionid, ownerID, nil];
        NSLog(@"ret:%zd---更新消息未读、已读状态",ret);
    }];
    
    return ret;
}

- (BOOL)deleteSession:(NSString *)sessionid {
    __block BOOL ret = false;
    if (PBIsEmpty(sessionid)) {
        return ret;
    }
    NSString *ownerID = self.mUsr.uid;
    NSString *chatTable = [self generateSessionTableNameWithSid:sessionid];
    BOOL isExist = [self isTableExist:chatTable];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///执行SQL语句
        [db setKey:DBCipherKey];
        ret = [db executeUpdate:@"DELETE FROM t_msg_session WHERE sessionId = ? AND ownerid = ?", sessionid, ownerID, nil];
        if (isExist) {
            ret &= [db executeUpdateWithFormat:PBFormat(@"DELETE FROM %@ WHERE ownerid = %@",chatTable, ownerID)];
        }
        NSLog(@"ret:%zd---删除会话&聊天表数据",ret);
    }];
    
    return ret;
}

- (NSDictionary *)session2Dictinary:(PBSession *)session {
    NSMutableDictionary *ret = nil;
    if (PBIsEmpty(session.sessionID)) {
        return ret;
    }
    ret = [NSMutableDictionary dictionaryWithCapacity:0];
    // setting text
    NSString *text = session.text;
    text = PBAvailableString(text);
    [ret setObject:text forKey:@"text"];
    // setting remark
    long long dateTime = session.dateTime;
    [ret setObject:@(dateTime) forKey:@"timeStamp"];
    //setting type
    NSUInteger type = session.type;
    [ret setObject:@(type) forKey:@"msgtype"];
    
    return ret.copy;
}

- (NSString *)getFileAttribute:(NSString *)file {
    if ([file hasSuffix:@".amr"]) {
        return @"[语音]";
    } else if ([file hasSuffix:@".jpg"] || [file hasSuffix:@".png"]) {
        return @"[图片]";
    } else if ([file hasSuffix:@".mp4"]) {
        return @"[视频]";
    } else {
        return @"[文件]";
    }
}

- (NSString *)getFileProperty4Type:(MessageBodyType)type {
    NSString *property = @"[文件]";
    if (type == MessageBodyType_Voice) {
        property = @"[语音]";
    }else if (type == MessageBodyType_Video){
        property = @"[视频]";
    }else if (type == MessageBodyType_Image){
        property = @"[图片]";
    }else if (type == MessageBodyType_Location){
        property = @"[位置]";
    }else if (type == MessageBodyType_Call){
        property = @"[通话]";
    }
    return property;
}

- (NSString *)getFileAttribute4Msg:(ECMessage *)msg {
    MessageBodyType type = msg.messageBody.messageBodyType;
    ECMessageBody *msgBody = msg.messageBody;
    NSString *property = nil;
    if (type == MessageBodyType_Text) {
        ECTextMessageBody *textMsg = (ECTextMessageBody *)msgBody;
        property = textMsg.text;
    }else{
        property = [self getFileProperty4Type:type];
    }
    //自定义表单判断
    NSString *userData = msg.userData;
    if (userData && ![userData isEqualToString:@""] && ![userData isEqualToString:@"{}"] && type != 0) {
        property = @"[表单]";
    }
    return property;
}

#pragma mark -- chat table methods --

- (BOOL)saveLatestNewMsg:(ECMessage *)msg {
    __block BOOL ret = false;
    if (PBIsEmpty(msg.from)||PBIsEmpty(msg.to)||PBIsEmpty(msg.messageId)||PBIsEmpty(msg.sessionId)) {
        return ret;
    }
    NSLog(@"msg from:%@--to:%@--session:%@",msg.from,msg.to,msg.sessionId);
    NSString *ownerID = self.mUsr.uid;
    if (![self.mUsr.imid isEqualToString:msg.to]) {
        NSLog(@"收到了一条不是发给自己的消息!");
        return ret;
    }
    NSString *chatTable = [self generateSessionTableNameWithSid:msg.sessionId];
    //1查看是否存在chat表 不存在则创建
    ret = [self isTableExist:chatTable];
    if (!ret) {
        [self createChatMsgTableWithSessionID:msg.sessionId];
    }
    //2存入chat表
    //消息类型预处理
    MessageBodyType type = msg.messageBody.messageBodyType;
    ECMessageBody *msgBody = msg.messageBody;
    NSString *userData = PBAvailableString(msg.userData);
    long long timeStamp = [msg.timestamp longLongValue];
    NSString *text = [self getFileAttribute4Msg:msg];
    NSString *localPath = nil;NSString *url = nil;long long serverTime = 0;NSUInteger dstate = 0; NSString *remark = nil;long long duration = 0;
    if (type == MessageBodyType_Text) {
        ECTextMessageBody *textMsg = (ECTextMessageBody *)msgBody;
        serverTime = textMsg.serverTime.longLongValue;
    }else{
        if (type == MessageBodyType_File){
            ECFileMessageBody *fileMsg = (ECFileMessageBody *)msgBody;
            serverTime = fileMsg.serverTime.longLongValue;
            url = fileMsg.remotePath;
            duration = fileMsg.fileLength;
        }else if (type == MessageBodyType_Image){
            ECImageMessageBody *imageMsg = (ECImageMessageBody *)msgBody;
            serverTime = imageMsg.serverTime.longLongValue;
            url = imageMsg.remotePath;
            remark = imageMsg.thumbnailRemotePath;
        }else if (type == MessageBodyType_Voice){
            ECVoiceMessageBody *voiceMsg = (ECVoiceMessageBody *)msgBody;
            serverTime = voiceMsg.serverTime.longLongValue;
            url = voiceMsg.remotePath;
            duration = voiceMsg.duration;
        }
    }
    // assemble datas
    NSMutableArray *params = [NSMutableArray array];
    [params addObject:chatTable];
    [params addObject:msg.sessionId];
    [params addObject:msg.messageId];
    [params addObject:msg.from];
    [params addObject:msg.to];
    [params addObject:@(timeStamp)];
    [params addObject:userData];
    [params addObject:@(type)];
    [params addObject:text];
    [params addObject:PBAvailableString(localPath)];
    [params addObject:PBAvailableString(url)];
    [params addObject:@0];//发送状态
    [params addObject:@(serverTime)];
    [params addObject:@(dstate)];//下载状态
    [params addObject:PBAvailableString(remark)];
    [params addObject:@(duration)];
    [params addObject:ownerID];
    //3更新session表
    PBSession *oldSession = [self getSession4ID:msg.sessionId];
    if (oldSession == nil) {
        oldSession = [[PBSession alloc] init];
        oldSession.sessionID = msg.sessionId;
        oldSession.unreadCount = 0;
        //oldSession.conversationId = nil;这个时候会话服务ID可能为空 需要从服务器拉取
        oldSession.assistantUserId = ownerID;
        oldSession.customerUserId = msg.from;
        oldSession.replyStatus = 1;
        oldSession.sendState = 0;
        oldSession.sticky = 0;
    }
    oldSession.text = text;
    oldSession.type = type;
    oldSession.dateTime = timeStamp;
    //oldSession.lastMsgUserData = userData;
    oldSession.lastMsgUserData = url;
    oldSession.unreadCount += (msg.isRead?0:1);
    [self updateSession:oldSession];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///执行SQL语句
        [db setKey:DBCipherKey];
        ////CREATE table %@(ID INTEGER PRIMARY KEY AUTOINCREMENT, SID varchar(32), msgid varchar(64),sender varchar(32), receiver varchar(32),createdTime INTEGER, userData varchar(256), msgType INTEGER, text TEXT, localPath TEXT, URL TEXT, state INTEGER, serverTime INTEGER,dstate INTEGER,remark TEXT,duration,ownerid TEXT)
        //[db executeUpdateWithFormat:PBFormat(@"INSERT OR REPLACE INTO %@ (SID, msgid, sender, receiver, createdTime, userData, msgType, text, localPath, URL, state, serverTime, dstate, remark, duration, ownerid) VALUES (:, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)")];
       
        ret = [db executeUpdate:PBFormat(@"INSERT OR REPLACE INTO %@ (SID, msgid, sender, receiver, createdTime, userData, msgType, text, localPath, URL, state, serverTime, dstate, remark, duration, ownerid) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", chatTable) withArgumentsInArray:params];
        
        NSLog(@"ret:%zd---保存新消息chat数据",ret);
    }];
    
    return ret;
}

- (BOOL)deleteChatMsg:(NSString *)msgid withSession:(NSString *)sessionid {
    __block BOOL ret = false;
    if (PBIsEmpty(sessionid)||PBIsEmpty(msgid)) {
        return ret;
    }
    NSString *ownerID = self.mUsr.uid;
    NSString *chatTable = [self generateSessionTableNameWithSid:sessionid];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///执行SQL语句
        [db setKey:DBCipherKey];
        ret = [db executeUpdateWithFormat:PBFormat(@"DELETE FROM %@ WHERE msgid = %@ AND ownerid = %@", chatTable, msgid, ownerID)];
        NSLog(@"ret:%zd---删除会话&聊天表数据",ret);
    }];
    return ret;
}

- (NSUInteger)getMsgCounts4Session:(NSString *)sessionid {
    __block NSUInteger mCounts = 0;
    if (PBIsEmpty(sessionid)) {
        return mCounts;
    }
    NSString *ownerID = self.mUsr.uid;
    NSString *chatTable = [self generateSessionTableNameWithSid:sessionid];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///执行SQL语句
        [db setKey:DBCipherKey];
        FMResultSet *mRets = [db executeQueryWithFormat:PBFormat(@"SELECT COUNT(msgid) AS count FROM %@ WHERE ownerid = %@", chatTable, ownerID)];
        while ([mRets next]) {
            mCounts = [mRets intForColumn:@"count"];
        }
        [mRets close];
    }];
    return mCounts;
}

- (NSArray *)getMsgsFromTimeStamp:(long long)timeStamp withSession:(NSString *)sessionid {
    __block NSMutableArray *tmpArr = nil;
    if (PBIsEmpty(sessionid)||timeStamp < 0) {
        return tmpArr;
    }
    if (timeStamp == 0) {
        //如果时间戳为0 则从现在开始获取
        timeStamp = [[NSDate date] timeIntervalSince1970] * 1000;//毫秒
    }
    NSUInteger mDefaultPageSize = 10;//每页获取10条数据
    NSString *ownerID = self.mUsr.uid;
    NSString *chatTable = [self generateSessionTableNameWithSid:sessionid];
    if (![self isTableExist:chatTable]) {
        return tmpArr;
    }
    tmpArr = [NSMutableArray arrayWithCapacity:0];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ///处理事情
        [db setKey:DBCipherKey];
        //ID INTEGER PRIMARY KEY AUTOINCREMENT, SID varchar(32), msgid varchar(64),sender varchar(32), receiver varchar(32),createdTime INTEGER, userData varchar(256), msgType INTEGER, text TEXT, localPath TEXT, URL TEXT, state INTEGER, serverTime INTEGER,dstate INTEGER,remark TEXT,duration INTEGER,ownerid TEXT
        
        FMResultSet *mRets = [db executeQueryWithFormat:PBFormat(@"SELECT SID, msgid, sender, receiver, createdTime, userData, state, msgType, text, localPath, URL, serverTime, remark, duration FROM (SELECT * FROM %@ WHERE ownerid = %@ AND (createdTime < %@) ORDER BY createdTime LIMIT %@) ORDER BY createdTime ASC", chatTable, ownerID, @(timeStamp), @(mDefaultPageSize))];
        while ([mRets next]) {
            ECMessage *msg = [[ECMessage alloc] init];
            msg.sessionId = sessionid;
            msg.messageId = [mRets stringForColumn:@"msgid"];
            msg.from = [mRets stringForColumn:@"sender"];
            msg.to = [mRets stringForColumn:@"receiver"];
            long long timeStamp = [mRets longLongIntForColumn:@"createdTime"];
            msg.timestamp = PBFormat(@"%lld",timeStamp);
            NSLog(@"msg stamp:>>>>>>>%lld",timeStamp);
            msg.userData = [mRets stringForColumn:@"userData"];
            msg.messageState = [mRets intForColumn:@"state"];
            MessageBodyType type = [mRets intForColumn:@"msgType"];
            NSString *text = [mRets stringForColumn:@"text"];//8
            NSString *localPath = [mRets stringForColumn:@"localPath"];//9
            NSString *url = [mRets stringForColumn:@"URL"];//10
            long long serverTime = [mRets longLongIntForColumn:@"serverTime"];
            NSString *remark = [mRets stringForColumn:@"remark"];//12
            int duration = [mRets intForColumn:@"duration"];
            if (type == MessageBodyType_Text) {
                ECTextMessageBody *body = [[ECTextMessageBody alloc] initWithText:text];
                body.serverTime = PBFormat(@"%lld",serverTime);
                msg.messageBody = body;
            }else if (type == MessageBodyType_Image){
                ECImageMessageBody *body = [[ECImageMessageBody alloc] initWithFile:localPath displayName:@""];
                body.remotePath = url;
                body.serverTime = PBFormat(@"%lld",serverTime);
                body.thumbnailRemotePath = remark;
                msg.messageBody = body;
            }else if (type == MessageBodyType_Voice){
                ECVoiceMessageBody * body = [[ECVoiceMessageBody alloc] initWithFile:localPath displayName:@""];
                body.remotePath = url;
                body.serverTime = PBFormat(@"%lld",serverTime);
                //body.mediaDownloadStatus = [rs intForColumnIndex:12];
                body.displayName = remark;
                body.duration = duration;
                msg.messageBody = body;
            }else if (type == MessageBodyType_File){
                ECFileMessageBody *body = [[ECFileMessageBody alloc] initWithFile:localPath displayName:@""];
                body.remotePath = url;
                body.serverTime = PBFormat(@"%lld",serverTime);
                //body.mediaDownloadStatus = [rs intForColumnIndex:12];
                body.displayName = remark;
                msg.messageBody = body;
            }else if (type == MessageBodyType_Video){
                
            }else if (type == MessageBodyType_Location){
                
            }else if (type == MessageBodyType_Call){
                
            }
            [tmpArr addObject:msg];
        }
        [mRets close];
    }];
    return [tmpArr copy];
}

@end
