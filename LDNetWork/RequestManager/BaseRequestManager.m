//
//  BaseRequestManager.m
//  LDNetWork
//
//  Created by liude on 17/6/9.
//  Copyright © 2017年 liude. All rights reserved.
//

#import "BaseRequestManager.h"

@interface BaseRequestManager()
@property (nonatomic, copy, readwrite) NSString *errorMessage;
@property (nonatomic, readwrite) ManagerReturnType errorType;

@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) NSURLSessionTask *task;
@end

@implementation BaseRequestManager

+ (instancetype)sharedManager
{
    static BaseRequestManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BaseRequestManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegate = nil;
        self.paramSource = nil;
        self.task = nil;
        self.params = nil;
        self.errorType = ManagerReturnDefault;
        self.responseObject = nil;
    }
    return self;
}

- (void)loadData {
    if (self.paramSource) {
        if ([self.paramSource respondsToSelector:@selector(paramsForApi:)]) {
            self.params = [self.paramSource paramsForApi:self];
        }
    }
    
    [self cancelRequest];
    __weak typeof(self)weakSelf = self;
    self.task = [[NetWorkingManager sharedManager] callApiWithUrl:self.requestUrl params:self.params?:@{} requestType:self.requestType success:^(id responseObject, ManagerReturnType errorType) {
            if (errorType == ManagerReturnSuccess) {
                weakSelf.errorType = ManagerReturnSuccess;
                if ([weakSelf.delegate respondsToSelector:@selector(managerCallDidSuccess:)] ) {
                    weakSelf.responseObject = responseObject;
                    [weakSelf.delegate managerCallDidSuccess:weakSelf];
                    weakSelf.task = nil;
                }
            }
    } fail:^(id responseObject, ManagerReturnType errorType) {
        NSString * errorMessage = @"";
        switch (errorType) {
            case ManagerReturnNoNetWork:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeNoNetwork", nil);
                break;
                
            case ManagerReturnDefault:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeDefault", nil);
                break;
                
            case ManagerReturnTimeout:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeTimeout", nil);
                break;
                
            case ManagerReturnParamsError:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeParamsError", nil);
                break;
                
            case ManagerReturnInvalidURL:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeInvalidURL", nil);
                break;
                
            case ManagerReturnNoHost:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeNoHost", nil);
                break;
                
            case ManagerReturnCancelled:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeCancelled", nil);
                break;
                
            case ManagerReturnUnknown:
                errorMessage = NSLocalizedString(@"APIManagerErrorTypeUnknown", nil);
                break;
                
            default:
                errorMessage = @"";
                break;
        }
        
        weakSelf.errorType = errorType;
        weakSelf.errorMessage = errorMessage;
        
        if (weakSelf.delegate) {
            if ([weakSelf.delegate respondsToSelector:@selector(managerCallDidFailed:)]) {
                [weakSelf.delegate managerCallDidFailed:weakSelf];
                weakSelf.task = nil;
            }
        }
    }];
}

- (void)cancelRequest {
    if (self.task) {
        [self.task cancel];
        self.task = nil;
    }
}

@end
