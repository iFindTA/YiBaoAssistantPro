//
//  PBUsr.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/23.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension.h>

@interface PBUsr : NSObject

//user's unique global id for system
@property (nonatomic, copy) NSString *uid;

//user's im's id for other system eg.ronglianyun
@property (nonatomic, copy) NSString *imid;

//user's account eg.mobile phone num
@property (nonatomic, copy) NSString *acc;

@property (nonatomic, copy) NSString *pwd;

@property (nonatomic, copy) NSString *soundable;

@property (nonatomic, copy) NSString *shakeable;

@property (nonatomic, copy) NSString *soundfile;
//wether usr can auto login NO means should show login controller
@property (nonatomic, copy) NSString *autologin;
//上次登录时间戳
@property (nonatomic, assign) long long authorStamp;

//usr's authorition to comunicate with server, generated after usr logined
@property (nonatomic, copy) NSString *authorToken;
//usr age
@property (nonatomic, copy) NSString *age;
//usr gender 0:none 1:male 2:female default by 0
@property (nonatomic, copy) NSString *gender;
//usr account'e level default by 0
@property (nonatomic, copy) NSString *level;
//usr nick name
@property (nonatomic, copy) NSString *nick;
//usr avatar's url
@property (nonatomic, copy) NSString *avatar;
//usr signature
@property (nonatomic, copy) NSString *signature;
//usr's real name by law
@property (nonatomic, copy) NSString *authorName;
//usr's identity's number by law
@property (nonatomic, copy) NSString *authorID;
//usr's authorition type, default by 0 that mean idcard
@property (nonatomic, copy) NSString *authorType;

@end
