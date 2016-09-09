//
//  PBAFEngine.h
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/18.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
//TODO:https for delete this en/decrypt 3 files
#import "MD5.h"
#import "GTMBase64.h"
#import "BBRSACryptor.h"
#import "RNCryptor iOS.h"

@interface PBAFEngine : AFHTTPSessionManager

NS_ASSUME_NONNULL_BEGIN

/**
 *  @brief network's engine
 *
 *  @return singleton instance
 */
+ (PBAFEngine *)shared;

/**
 *  @brief judge the network's work state
 *
 *  @return wether enabled
 */
- (BOOL)netEnable;

/**
 *  @brief cancel all requests
 */
- (void)cancelAllRequest;
- (void)cancelRequestForClass:(nullable Class)aClass;

#pragma mark -- Request Methods

- (void)GET:(NSString *)path parameters:(nullable id)params vcr:(nullable UIViewController *)vcr view:(nullable UIView *)view success:(void(^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObj))success failure:(void(^)(NSURLSessionDataTask *_Nullable task, NSError *error))failure;

- (void)GET:(NSString *)path parameters:(nullable id)params vcr:(nullable UIViewController *)vcr view:(nullable UIView *)view hudEnable:(BOOL)hud success:(void (^)(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObj))success failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error))failure;

- (void)POST:(NSString *)path parameters:(nullable id)parameters vcr:(UIViewController * _Nullable)vcr view:(UIView * _Nullable)view success:(void (^)(NSURLSessionDataTask *task, id _Nullable responseObj))success failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

- (void)PUT:(NSString *)path parameters:(nullable id)params vcr:(UIViewController * _Nullable)vcr view:(UIView * _Nullable)view success:(void (^)(NSURLSessionDataTask * task,id _Nullable responseObj))success failure:(void (^)(NSURLSessionDataTask * _Nullable task, NSError * error))failure;

#pragma mark -- 加密 引入HTTPS可删除
- (BBRSACryptor *)getRSA;
- (NSString*)dict2Json:(NSDictionary *)dic;
- (NSDictionary *)json2Dict:(NSString *)json;
- (void)saveKey:(NSString *)key withValue:(NSString *)value;
- (NSString *) readKey:(NSString *)key;
- (NSDictionary *)encryptionDictionary:(NSDictionary *)parameters;
- (NSDictionary *)encryptionDictionary:(NSDictionary *)parameters withToken:(NSString *)token;

NS_ASSUME_NONNULL_END

@end
