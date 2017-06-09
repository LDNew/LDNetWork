//
//  NetWorkingManager.h
//  LDNetWork
//
//  Created by liude on 17/6/9.
//  Copyright © 2017年 liude. All rights reserved.
//

#import <Foundation/Foundation.h>
//网络请求类型
typedef NS_ENUM(NSUInteger, ManagerRequestType) {
    ManagerRequestTypeGet = 0,                  //Get 请求
    ManagerRequestTypePost,                     //Post 请求
};

//网络请求返回类型
typedef NS_ENUM (NSUInteger, ManagerReturnType){
    ManagerReturnDefault = 0,       //没有产生过API请求，这个是manager的默认状态。
    ManagerReturnSuccess,           //API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    ManagerReturnParamsError,       //参数错误，
    ManagerReturnTimeout,           //请求超时。
    ManagerReturnNoNetWork,         //网络不通。
    ManagerReturnInvalidURL,        //请求失败， 无效的URL
    ManagerReturnNoHost,            //服务器异常 （找不到服务器，服务器不支持等）
    ManagerReturnCancelled,         //取消网络请求
    ManagerReturnUnknown            //未知错误
    
};


typedef void(^callBack)(id responseObject, ManagerReturnType errorType);
@interface NetWorkingManager : NSObject
+ (instancetype)sharedManager;

- (NSURLSessionDataTask *)callApiWithUrl:(NSString *)url params:(NSDictionary *)params requestType:(ManagerRequestType)requestType success:(callBack)success fail:(callBack)fail;
- (void)cancelAllRequest;
@end
