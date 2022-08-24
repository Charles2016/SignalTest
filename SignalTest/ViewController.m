//
//  ViewController.m
//  SignalTest
//
//  Created by 1084-Wangcl-Mac on 2022/8/24.
//  Copyright © 2022 Charles2021. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@", [self getDataA]);
}

- (NSString *)getDataA {
    __block NSString *dataTest = @"getDataA____信号量同步数据GG了！！！";
    //创建信号量
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    //记得信号量同步时给manager.completionQueue设置个队列，否则AFN默认block在主线程执行，此时设置信号量导致卡死
    manager.completionQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSURL *URL = [NSURL URLWithString:@"http://rap2api.taobao.org/app/mock/256798/api/chat/list"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
        NSLog(@"DISPATCH_QUEUE_CONCURRENT___故障现象数据请求下来了哦，可以进行下一步了");
        dataTest = @"getDataA____信号量同步数据已经请求下来了！！！";
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];
    //信号量等待
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"DISPATCH_QUEUE_CONCURRENT___进一步操作数据");
    return dataTest;
}

@end
