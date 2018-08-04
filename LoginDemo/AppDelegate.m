//
//  AppDelegate.m
//  LoginDemo
//
//  Created by jessie on 2018/8/4.
//  Copyright © 2018年 luming. All rights reserved.
//

#import "AppDelegate.h"
#import "KXWXLoginShareManager.h"
#import "KXQQLoginShareManager.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[KXWXLoginShareManager shareInstance] wechatLoginShareRegisterApp];
    [[KXQQLoginShareManager shareInstance] qqLoginShareRegisterApp];
    
    return YES;
}

///从微信端打开第三方APP会调用此方法,此方法再调用代理的onResp方法
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    if (YES == [TencentOAuth CanHandleOpenURL:url]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    id idwXLoginShare = [KXWXLoginShareManager shareInstance];
    return [WXApi handleOpenURL:url delegate:idwXLoginShare];
}

//qq处理回调
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (YES == [TencentOAuth CanHandleOpenURL:url])
    {
        return [TencentOAuth HandleOpenURL:url];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
