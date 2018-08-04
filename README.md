# JJLoginAndShare

由于iOS上架因为友盟分享中涉及到支付宝的支付信息，以及微信的支付信息，导致app无法上架。

所以自己集成，实现了qq的登录和分享，以及微信的登录与分享


导入
#import "KXWXLoginShareManager.h"
#import "KXQQLoginShareManager.h"
两个登录管理类
AppDelegate 中需要处理的
```

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
```

微信登录和分享
//    [KXWXLoginShareManager shareInstance].delegate = self;
可以注册成为代理，也可以不注册，直接通过block的回到获取到成功与失败的值

微信登录

```
[[KXWXLoginShareManager shareInstance] wechatLoginSuccess:^(NSDictionary *dict) {
NSLog(@"dict = %@",dict);

} fail:^(NSDictionary *dict) {
NSLog(@"dict = %@",dict);

}];

```

微信分享给好友
```
[[KXWXLoginShareManager shareInstance]wechatSendWebToWX:WXSceneSession title:@"就是牛逼" iconImage:@"" desc:@"666" url:@"https://www.baidu.com"];

```

微信分享到朋友圈
```
[[KXWXLoginShareManager shareInstance] wechatSendWebToWX:WXSceneTimeline title:@"就是牛逼" iconImage:@"" desc:@"666" url:@"https://www.baidu.com"];

```


qq的登录和分享
需要成为代理
[KXQQLoginShareManager shareInstance].delegate = self;


qq登录

```
[[KXQQLoginShareManager shareInstance] qqLogin];

```

qq分享给好友
```
[[KXQQLoginShareManager shareInstance] qqSendWebMessageToFriendWithTitle:@"qq分享" iconImage:@"" desc:@"haodd" url:@"https://www.qq.com"];

```
qq分享到qq空间
```
[[KXQQLoginShareManager shareInstance] qqSendWebMessageToQQZoneWithTitle:@"qq分享" iconImage:@"" desc:@"haodd" url:@"https://www.qq.com"];
```

qq两个代理方法，一个成功登录拿到数据，一个失败拿到失败原因
```
#pragma KXQQLoginShareManagerDelegate
- (void)qqLoginSuccess:(NSDictionary *)dict
{
NSLog(@"qqLoginSuccess== %@",dict);
}

- (void)qqLoginFailure:(NSInteger)errorCode
{
NSLog(@"登录失败=====================");
}

```

