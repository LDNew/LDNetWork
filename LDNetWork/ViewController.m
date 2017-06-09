//
//  ViewController.m
//  LDNetWork
//
//  Created by liude on 17/6/9.
//  Copyright © 2017年 liude. All rights reserved.
//

#import "ViewController.h"
#import "BaseRequestManager.h"
@interface ViewController ()<ManagerCallBackDelegate,ManagerParamSourceDelegate>

@property (nonatomic, strong) NSArray *actorList;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.actorList = @[@"刘德华",@"张学友",@"王心凌",@"张杰",@"光良",@"陈奕迅",@"王力宏",@"汪峰",@"莫文蔚",@"王菲"];

    //请求列表中歌手的歌曲,循环请求,为了更好地演示网络请求自动取消的情况
    for (NSInteger i = 0; i < 5; i++) {
        BaseRequestManager *duoMiManager = [BaseRequestManager sharedManager];
        duoMiManager.requestType = ManagerRequestTypeGet;
        duoMiManager.requestUrl = @"http://v5.pc.duomi.com/search-ajaxsearch-searchall";
        duoMiManager.delegate = self;
        duoMiManager.paramSource = self;
        [duoMiManager loadData];
    }
}

#pragma mark -- MSAPIManagerParamSourceDelegate
- (NSDictionary *)paramsForApi:(BaseRequestManager *)manager {
    NSMutableDictionary * params = [[NSMutableDictionary alloc]init];
    [params setObject:@"刘德华" forKey:@"kw"];
    [params setObject:@"0" forKey:@"pi"];
    [params setObject:@"1000" forKey:@"pz"];
    return params;
}

#pragma mark -- MSAPIManagerApiCallBackDelegate
- (void)managerCallDidSuccess:(BaseRequestManager *)manager {

    NSArray *tracks = [manager.responseObject objectForKey:@"tracks"];
    for (NSDictionary *tempDic in tracks) {
        NSLog(@"\n%@",[tempDic objectForKey:@"title"]);
    }
}

- (void)managerCallDidFailed:(BaseRequestManager *)manager {
    NSLog(@"失败原因：%@",manager.errorMessage);
}


@end
