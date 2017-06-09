//
//  BaseRequestManager.h
//  LDNetWork
//
//  Created by liude on 17/6/9.
//  Copyright © 2017年 liude. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetWorkingManager.h"
@class BaseRequestManager;

@protocol ManagerParamSourceDelegate <NSObject>
@required
- (NSDictionary *)paramsForApi:(BaseRequestManager *)manager;
@end

@protocol ManagerCallBackDelegate <NSObject>
@required
- (void)managerCallDidSuccess:(BaseRequestManager *)manager;
- (void)managerCallDidFailed:(BaseRequestManager *)manager;
@end


@interface BaseRequestManager : NSObject

@property (nonatomic, strong) NSString *requestUrl;

/** 网络请求类型*/
@property (nonatomic, assign) ManagerRequestType requestType;

/** 请求回调delegate*/
@property (nonatomic, weak) id<ManagerCallBackDelegate> delegate;

/** 请求参数delegate*/
@property (nonatomic, weak) id<ManagerParamSourceDelegate> paramSource;

@property (nonatomic, copy, readonly) NSString *errorMessage;
@property (nonatomic, readonly) ManagerReturnType errorType;
@property (nonatomic, strong) id responseObject;

//使用loadData这个方法来请求数据,这个方法会通过param source来获得参数
- (void)loadData;
+ (instancetype)sharedManager;
@end
