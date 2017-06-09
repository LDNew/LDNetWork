//
//  NetWorkingManager.m
//  LDNetWork
//
//  Created by liude on 17/6/9.
//  Copyright © 2017年 liude. All rights reserved.
//

#import "NetWorkingManager.h"
#import <AFNetworking.h>
@interface NetWorkingManager()
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;   //通用会话管理器
@end
@implementation NetWorkingManager

+ (instancetype)sharedManager
{
    static NetWorkingManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NetWorkingManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self initSessionManager];
    }
    return self;
}

- (void)initSessionManager
{
    // 设置全局会话管理实例
    _sessionManager = [[AFHTTPSessionManager alloc] init];
    
    // 设置请求序列化器
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy; // 默认缓存策略
    requestSerializer.timeoutInterval = 10;//超时时间
    _sessionManager.requestSerializer = requestSerializer;
    
    // 设置响应序列化器，解析Json对象
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    responseSerializer.removesKeysWithNullValues = YES; // 清除返回数据的 NSNull
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:  @"application/x-javascript", @"application/json", @"text/json", @"text/javascript", @"text/html", nil]; // 设置接受数据的格式
    _sessionManager.responseSerializer = responseSerializer;
    // 设置安全策略
    _sessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
}

- (NSURLSessionDataTask *)callApiWithUrl:(NSString *)url params:(NSDictionary *)params requestType:(ManagerRequestType)requestType success:(callBack)success fail:(callBack)fail {
    //  url 长度为0是， 返回错误
    if ( !url || url.length == 0)
    {
        if (fail) {
            fail(nil,ManagerReturnInvalidURL);
        }
        return nil;
    }
    // 会话管理对象为空时
    if (!_sessionManager)
    {
        [self initSessionManager];
    }
    
    // 请求成功时的回调
    void (^successWrap)(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) = ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
        if (success) {
            success(responseObject,ManagerReturnSuccess);
        }
    };
    
    // 请求失败时的回调
    void (^failureWrap)(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) = ^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
        if (fail) {
            fail(error,[self errorTypeWithCode:error.code]);
        }
    };
    
    // 设置请求头
    [self formatRequestHeader];
    
    //  分离URL中的参数信息, 重建参数列表
    params = [self formatParametersForURL:url withParams:params];
    url = [url componentsSeparatedByString:@"?"][0];
    __block NSURLSessionDataTask * urlSessionDataTask;
    
    if (requestType == ManagerRequestTypePost)  // Post 请求
    {
        // 检查url
        if (![NSURL URLWithString:url]) {
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        }
        
        urlSessionDataTask = [_sessionManager POST:url
                                        parameters:params
                                          progress:nil
                                           success:successWrap
                                           failure:failureWrap];
    }
    else if (requestType == ManagerRequestTypeGet) // Get 请求
    {
        // 检查url
        if (![NSURL URLWithString:url]) {
            url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        }
        
        urlSessionDataTask = [_sessionManager GET:url
                                       parameters:params
                                         progress:nil
                                          success:successWrap
                                          failure:failureWrap];
    }
    return urlSessionDataTask;
}

//  分离URL中的参数信息, 重建参数列表
- (NSDictionary *)formatParametersForURL:(NSString *)url withParams:(NSDictionary *)params
{
    NSMutableDictionary *fixedParams = [params mutableCopy];
    //    分离URL中的参数信息
    NSArray *urlComponents = [[url stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@"?"];
    NSArray *paramsComponets = urlComponents.count >= 2 && [urlComponents[1] length] > 0 ? [urlComponents[1] componentsSeparatedByString:@"&"] : nil;
    [paramsComponets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *paramComponets = [obj componentsSeparatedByString:@"="];
        if (!fixedParams[paramsComponets[0]])
        {
            [fixedParams setObject:(paramComponets.count>=2 ? paramComponets[1] : @"") forKey:paramComponets[0]];
        }
    }];
    
    //    检查param的个数，为0时，置为nil
    fixedParams = fixedParams.allKeys.count ? fixedParams : nil;
    return [fixedParams copy];
}

#pragma mark --取消当前所有网络请求
- (void)cancelAllRequest {
    [self.sessionManager.operationQueue cancelAllOperations];
}


#pragma mark --根据需要设置安全策略
- (AFSecurityPolicy *)creatCustomPolicy
{
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    policy.allowInvalidCertificates = YES;
    return policy;
}

#pragma mark --根据需要设置请求头信息
- (void)formatRequestHeader
{
    [_sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
}

#pragma makr --解析错误码
- (ManagerReturnType)errorTypeWithCode:(NSInteger)code {
    ManagerReturnType returnType = ManagerReturnDefault;
    if (code == -1) {
        returnType = ManagerReturnUnknown;
    }else if (code == -999 || code == -1012) {
        returnType = ManagerReturnCancelled;
    }else if (code == -1000) {
        returnType = ManagerReturnInvalidURL;
    }else if (code == -1001) {
        returnType = ManagerReturnTimeout;
    }else if (code == -1005 || code == -1009) {
        returnType = ManagerReturnNoNetWork;
    }else {
        returnType = ManagerReturnNoHost;
    }
    return returnType;
}

@end
