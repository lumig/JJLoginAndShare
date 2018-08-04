//
//  ViewController.m
//  LoginDemo
//
//  Created by jessie on 2018/8/4.
//  Copyright © 2018年 luming. All rights reserved.
//

#import "ViewController.h"

#import "KXWXLoginShareManager.h"
#import "KXQQLoginShareManager.h"
@interface ViewController ()<KXQQLoginShareManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [KXWXLoginShareManager shareInstance].delegate = self;
    [KXQQLoginShareManager shareInstance].delegate = self;
}

- (IBAction)wechatDidLogin:(id)sender
{
    [[KXWXLoginShareManager shareInstance] wechatLoginSuccess:^(NSDictionary *dict) {
        NSLog(@"dict = %@",dict);

    } fail:^(NSDictionary *dict) {
        NSLog(@"dict = %@",dict);

    }];
   
}

- (IBAction)sharePerson:(id)sender
{
    [[KXWXLoginShareManager shareInstance]wechatSendWebToWX:WXSceneSession title:@"就是牛逼" iconImage:@"" desc:@"666" url:@"https://www.baidu.com"];
}

- (IBAction)sharePengyouquan:(id)sender
{
    [[KXWXLoginShareManager shareInstance] wechatSendWebToWX:WXSceneTimeline title:@"就是牛逼" iconImage:@"" desc:@"666" url:@"https://www.baidu.com"];
}


- (IBAction)qqLogin:(id)sender {
    [[KXQQLoginShareManager shareInstance] qqLogin];
}

#pragma KXQQLoginShareManagerDelegate
- (void)qqLoginSuccess:(NSDictionary *)dict
{
    NSLog(@"qqLoginSuccess== %@",dict);
}

- (void)qqLoginFailure:(NSInteger)errorCode
{
    NSLog(@"登录失败=====================");
}

- (IBAction)qqSharePerson:(id)sender {
    [[KXQQLoginShareManager shareInstance] qqSendWebMessageToFriendWithTitle:@"qq分享" iconImage:@"" desc:@"haodd" url:@"https://www.qq.com"];
}

- (IBAction)qqShareKongjian:(id)sender {
    
    [[KXQQLoginShareManager shareInstance] qqSendWebMessageToQQZoneWithTitle:@"qq分享" iconImage:@"" desc:@"haodd" url:@"https://www.qq.com"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
