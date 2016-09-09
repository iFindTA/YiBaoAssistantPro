//
//  PBAFEngine.m
//  YBAssistantPro
//
//  Created by hu jiaju on 16/8/18.
//  Copyright © 2016年 Nanhu. All rights reserved.
//

#import "PBAFEngine.h"
#import "PBDBEngine.h"
#import "SVProgressHUD.h"
#import <mach/mach_time.h>

static int      kRequestOut                 =       30;
#if DEBUG
static NSString *kHost                      =       @"http://assistant.120yibao.com/yb";
#else
static NSString *kHost                      =       @"http://assistant.120yibao.com/yb";
#endif
static NSString *pingDomain                 =       @"www.baidu.com";
static NSString *kNetworkDisable            =       @"当前网络不可用！";
static NSString *kNetworkWorking            =       @"请稍后...";

#define kRSAPublicKey  \
@"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCrJhZS8r0M6R3T4xDe5aJEtHk+\rWPE5fo1KhHLmnPPgF+8QoLK50GAGXmYVkKqF52ZUgV+FVSBEL++JCiGace+uGCl/\rucSKDLjoVal408Tm2x68W+R/ZTMAcaczvr4yTNe78DM5tueWbGmAFUtpgNu4zZu4\rvx7BseWlvQn0VrwN8wIDAQAB"

@interface PBAFEngine ()

@property (nonatomic, strong) BBRSACryptor *rsa;

@end

static PBAFEngine *instance = nil;

@implementation PBAFEngine

//+ (id)allocWithZone:(struct _NSZone *)zone {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if (instance == nil) {
//            instance = [super allocWithZone:zone];
//        }
//    });
//    return instance;
//}

+ (PBAFEngine *)shared {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            NSURL *baseURL = [NSURL URLWithString:kHost];
            instance = [[PBAFEngine alloc] initWithBaseURL:baseURL];
        }
    });
    
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        //reachability
        [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSLog(@"net state :%zd",status);
        }];
        [self.reachabilityManager startMonitoring];
        
        //TODO:直接引入HTTPS 可以删除繁杂的加密
        self.rsa = [[BBRSACryptor alloc] init];
        BOOL importSuccess = [self.rsa importRSAPublicKeyBase64:kRSAPublicKey];
        if (NO == importSuccess) {
            
        }
        
        //request serializer, can be set with HTTP's header
        AFHTTPRequestSerializer *req_serial = [AFHTTPRequestSerializer serializer];
        req_serial.timeoutInterval = kRequestOut;
        //[req_serial setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.requestSerializer = req_serial;
        //*
        //response serializer, can be set with HTTP's accept type
        AFJSONResponseSerializer *res_serial = [AFJSONResponseSerializer serializer];
        //res_serial.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        //res_serial.acceptableStatusCodes = [NSIndexSet indexSetWithIndex:400];
        self.responseSerializer = res_serial;
        //*/
        
        //双向认证 安全设置
        AFSecurityPolicy *sec_policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        sec_policy.allowInvalidCertificates = true;//
        sec_policy.validatesDomainName = false;//验证域名
        self.securityPolicy = sec_policy;
    }
    return self;
}

#pragma mark == Network State

- (BOOL)netEnable {
    BOOL state = [self.reachabilityManager isReachable];
    state |= ([PBAFEngine shared].reachabilityManager.networkReachabilityStatus==AFNetworkReachabilityStatusUnknown);
    return state;
    //return self.reachManager.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable;
}

- (BOOL)wifiEnable {
    return [self.reachabilityManager isReachableViaWiFi];
}

#pragma mark == cancel Methods

- (void)cancelAllRequest {
    
    NSArray *dataTasks = self.dataTasks;
    for (NSURLSessionDataTask *task in dataTasks) {
        [task cancel];
    }
    //    //老版取消方法
    //    NSArray *operations = [[self operationQueue] operations];
    //    NSUInteger count = [operations count];
    //    if (operations && count) {
    //        for (id operator in operations) {
    //            NSLog(@"operation class :%@",NSStringFromClass([operator class]));
    //            AFHTTPRequestOperation *requestOperation = (AFHTTPRequestOperation *)operator;
    //            [requestOperation cancel];
    //        }
    //    }
}

- (void)cancelRequestForClass:(Class)aClass {
    NSArray *dataTasks = self.dataTasks;
    if (aClass == nil) {
        return;
    }
    NSString *classString = NSStringFromClass(aClass);
    for (NSURLSessionDataTask *task in dataTasks) {
        NSString *taskDesc = task.taskDescription;
        if (!PBIsEmpty(taskDesc) && [taskDesc rangeOfString:classString].location != NSNotFound) {
            [task cancel];
        }
    }
}

#pragma mark -- encrypt method
- (BBRSACryptor *)getRSA {
    return self.rsa;
}
- (void)saveKey:(NSString *)key withValue:(NSString *)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}

- (NSString *)readKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}
- (NSString*)dict2Json:(NSDictionary *)dic {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
- (NSDictionary *)json2Dict:(NSString *)json {
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *parseError = nil;
    NSDictionary *aDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&parseError];
    return aDict;
}
- (NSDictionary *)encryptionDictionary:(NSDictionary *)parameters {
    //NSString *token = [self readKey:@"token"];
    NSString *tmpUsrID = [[PBDBEngine shared] authorID];
    NSData *key = [tmpUsrID dataUsingEncoding:NSUTF8StringEncoding];
    NSData *tokenData = [self.rsa encryptWithPublicKeyUsingPadding:RSA_PADDING_TYPE_PKCS1 plainData:key];
    NSString *token = [GTMBase64 stringByEncodingData:tokenData];
    return [self encryptionDictionary:parameters withToken:token];
}

- (NSDictionary *)encryptionDictionary:(NSDictionary *)parameters withToken:(NSString *)token {
    
    if (token == nil)
        return @{};
    
    NSString* appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    if (parameters.count == 0) {
        NSDictionary *paraDdic = @{@"token" : token, @"Yb_Assistant_Client" : @"3", @"app_version": appVersion};
        return paraDdic;
    }
    uint64_t start = mach_absolute_time();
    NSComparator cmptr = ^(NSString* obj1, NSString* obj2){
        return [obj1 compare: obj2];
    };
    NSArray *sortedArray = [[parameters allKeys] sortedArrayUsingComparator:cmptr];
    
    NSString *sign;
    for (int i = 0; i < sortedArray.count; ++ i) {
        NSString* key = sortedArray[i];
        if (i == 0)
        {
            sign = [NSString stringWithFormat:@"%@=%@", key, parameters[key]];
        }
        else {
            sign = [NSString stringWithFormat:@"%@&%@=%@", sign, key, parameters[key]];
        }
    }
    NSString *aesKeyText = [self readKey:@"aesKey"];
    
    sign = [NSString stringWithFormat:@"%@%@%@", aesKeyText, sign, aesKeyText];
    sign = [MD5 md5:sign];
    
    NSString *paraData = [self dict2Json:parameters];
    NSData *dataAes = [paraData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSData *encryptedData = [RNEncryptor encryptData:dataAes
                                        withSettings:kRNCryptorAES256Settings
                                            password:aesKeyText
                                               error:&error];
    paraData = [encryptedData base64EncodedStringWithOptions:0];
    
    NSDictionary *paraDdic = @{@"token" : token, @"sign" : PBAvailableString(sign), @"data" : PBAvailableString(paraData), @"Yb_Assistant_Client" : @"3", @"app_version": appVersion};
    
    uint64_t end = mach_absolute_time();
    uint64_t elapsed = end - start;mach_timebase_info_data_t info;
    if (mach_timebase_info (&info) != KERN_SUCCESS){
        printf ("mach_timebase_info failed\n");
    }
    uint64_t nanosecs = elapsed * info.numer / info.denom;
    uint64_t millisecs = nanosecs / 1000000;
    NSLog(@">>>>>>>>>>encrypt time = %lld ms", millisecs);
    
    return paraDdic;
}

#pragma mark == Request Methods

#pragma mark -- Public Methods --

- (void)GET:(NSString *)path parameters:(id)params vcr:(UIViewController *)vcr view:(UIView *)view success:(void(^)(NSURLSessionDataTask * _Nonnull, id ))success failure:(void(^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    [self GET:path parameters:params vcr:vcr view:view hudEnable:false success:success failure:failure];
}

- (void)GET:(NSString *)path parameters:(id)params vcr:(UIViewController *)vcr view:(UIView *)view hudEnable:(BOOL)hud success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    ///judge the current network state
    if (![self netEnable]) {
        if (hud) {
            PBMAIN(^{[SVProgressHUD showErrorWithStatus:kNetworkDisable];});
        }
        NSError *error = [NSError errorWithDomain:@"neterror" code:100 userInfo:nil];
        if (failure) {
            failure(nil, error);
        }
        return;
    }
    
    if (view != nil) {
        view.userInteractionEnabled = false;
    }
    __weak typeof(&*view) weakView = view;
    if (hud) {
        PBMAIN(^{[SVProgressHUD showWithStatus:kNetworkWorking];});
    }
    NSURLSessionDataTask *dataTask = [super GET:path parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (weakView) {
            weakView.userInteractionEnabled = true;
        }
        PBMAINDelay(PBANIMATE_DURATION, ^{[SVProgressHUD dismiss];});
        //[MBProgressHUD hideAllHUDsForView:vcr.view animated:true];
        int code = [[responseObject objectForKey:@"status"] intValue];
        if (code == 0) {
            if (success) {
                success(task,responseObject);
            }
        }else{
            NSString *domain = [responseObject objectForKey:@"info"];
            NSError *error = [NSError errorWithDomain:domain code:code userInfo:nil];
            if (failure) {
                failure(nil, error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (weakView) {
            weakView.userInteractionEnabled = true;
        }
        PBMAINDelay(PBANIMATE_DURATION,^{[SVProgressHUD dismiss];});
        if (failure) {
            failure(task,error);
        }
    }];
    
    if (vcr != nil) {
        dataTask.taskDescription = PBFormat(@"class_%@_request",NSStringFromClass([vcr class]));
    }
}

- (void)POST:(NSString *)path parameters:(id)parameters vcr:(UIViewController *)vcr view:(UIView *)view success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure{
    
    ///judge the current network state
    if (![self netEnable]) {
        PBMAIN(^{[SVProgressHUD showErrorWithStatus:kNetworkDisable];});
        NSError *error = [NSError errorWithDomain:@"neterror" code:100 userInfo:nil];
        if (failure) {
            failure(nil, error);
        }
        return;
    }
    
    if (view != nil) {
        view.userInteractionEnabled = false;
    }
    __weak typeof(&*view) weakView = view;
    PBMAIN(^{[SVProgressHUD showWithStatus:kNetworkWorking];});
    
    NSURLSessionDataTask *dataTask = [super POST:path parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (weakView) {
            weakView.userInteractionEnabled = true;
        }
        PBMAINDelay(PBANIMATE_DURATION,^{[SVProgressHUD dismiss];});
        //[MBProgressHUD hideAllHUDsForView:vcr.view animated:true];
        int code = [[responseObject objectForKey:@"status"] intValue];
        if (code == 0) {
            if (success) {
                success(task,responseObject);
            }
        }else{
            NSString *domain = [responseObject objectForKey:@"info"];
            NSError *error = [NSError errorWithDomain:domain code:code userInfo:nil];
            if (failure) {
                failure(nil, error);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (weakView) {
            weakView.userInteractionEnabled = true;
        }
        PBMAINDelay(PBANIMATE_DURATION,^{[SVProgressHUD dismiss];});
        if (failure) {
            failure(task,error);
        }
    }];
    
    if (vcr != nil) {
        dataTask.taskDescription = PBFormat(@"class_%@_request",NSStringFromClass([vcr class]));
    }
}

- (void)PUT:(NSString *)path parameters:(id)params vcr:(UIViewController *)vcr view:(UIView *)view success:(void (^)(NSURLSessionDataTask * _Nonnull,id _Nullable))success failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure {
    ///judge the current network state
    if (![self netEnable]) {
        PBMAIN(^{[SVProgressHUD showErrorWithStatus:kNetworkDisable];});
        NSError *error = [NSError errorWithDomain:@"neterror" code:100 userInfo:nil];
        if (failure) {
            failure(nil, error);
        }
        return;
    }
    
    if (view != nil) {
        view.userInteractionEnabled = false;
    }
    __weak typeof(&*view) weakView = view;
    PBMAIN(^{[SVProgressHUD showWithStatus:kNetworkWorking];});
    
    NSURLSessionDataTask *dataTask = [super PUT:path parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (weakView) {
            weakView.userInteractionEnabled = true;
        }
        PBMAINDelay(PBANIMATE_DURATION,^{[SVProgressHUD dismiss];});
        //[MBProgressHUD hideAllHUDsForView:vcr.view animated:true];
        int code = [[responseObject objectForKey:@"status"] intValue];
        if (code == 0) {
            if (success) {
                success(task,responseObject);
            }
        }else{
            NSString *domain = [responseObject objectForKey:@"info"];
            NSError *error = [NSError errorWithDomain:domain code:code userInfo:nil];
            if (failure) {
                failure(nil, error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (weakView) {
            weakView.userInteractionEnabled = true;
        }
        PBMAINDelay(PBANIMATE_DURATION,^{[SVProgressHUD dismiss];});
        if (failure) {
            failure(task,error);
        }
    }];
    
    if (vcr != nil) {
        dataTask.taskDescription = PBFormat(@"class_%@_request",NSStringFromClass([vcr class]));
    }
}

@end
