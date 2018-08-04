//
//  KXQQLoginShareManager.m
//  LoginDemo
//
//  Created by jessie on 2018/8/4.
//  Copyright © 2018年 luming. All rights reserved.
//

#import "KXQQLoginShareManager.h"

#define QQAppKey @"1106168227"
#define QQAppSecret @""

@interface KXQQLoginShareManager()
@property (nonatomic, strong) TencentOAuth *tencentOAuth;
@property (nonatomic, copy) NSArray *permissions;
@end
@implementation KXQQLoginShareManager

+ (instancetype)shareInstance
{
    static KXQQLoginShareManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/**
 注册qqid
 */
- (void)qqLoginShareRegisterApp
{
    self.tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQAppKey andDelegate:self];
}

/**
 调用用户登录
 */
- (void)qqLogin
{
    _permissions =  [NSArray arrayWithObjects:@"get_user_info", @"get_simple_userinfo", @"add_t", nil];
    [_tencentOAuth authorize:_permissions];
}

#pragma mark -- TencentSessionDelegate
/**
 用户登录后回调方法
 */
- (void)tencentDidLogin
{
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length])
    {
        // 获取用户信息
        [_tencentOAuth getUserInfo];

    }
    else
    {
        NSLog(@"登录失败！");
    }
}

/**
用户没有登录
 */
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled) {
        NSLog(@"用户取消登录！");
    } else {
        NSLog(@"用户登录失败！");
    }
}

/**
 没有网络
 */
- (void)tencentDidNotNetWork
{
    NSLog(@"无网络连接，请设置网络!");
}

// 获取用户信息
- (void)getUserInfoResponse:(APIResponse *)response
{
    if (response && response.retCode == URLREQUEST_SUCCEED) {
        NSDictionary *userInfo = [response jsonResponse];
        if ([self.delegate respondsToSelector:@selector(qqLoginSuccess:)]) {
            [self.delegate qqLoginSuccess:userInfo];
        }
        
    } else {
        NSLog(@"登录失败 %d", response.detailRetCode);
        if ([self.delegate respondsToSelector:@selector(qqLoginFailure:)]) {
            [self.delegate qqLoginFailure:response.detailRetCode];
        }
    }
}


/**
 增量授权
 */
- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth
                   withPermissions:(NSArray *)permissions
{
    // incrAuthWithPermissions是增量授权时需要调用的登录接口
    // permissions是需要增量授权的权限列表
    [tencentOAuth incrAuthWithPermissions:permissions];
    return NO; // 返回NO表明不需要再回传未授权API接口的原始请求结果；
    // 否则可以返回YES
}

- (void)qqSendMessage:(NSString *)message
{
    QQApiTextObject *txtObj = [QQApiTextObject objectWithText:message];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
    //将内容分享到qq
    dispatch_async(dispatch_get_main_queue(), ^{
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    });
    
}

- (void)qqSendMessageToQQZone:(NSString *)message
{
    QQApiTextObject *txtObj = [QQApiTextObject objectWithText:message];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
    //将内容分享到qq
    dispatch_async(dispatch_get_main_queue(), ^{
        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    });
}

- (void)qqSendWebMessageToFriendWithTitle:(NSString *)title iconImage:(NSString *)image desc:(NSString *)desc url:(NSString *)url
{
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:url]
                                title:title
                                description:desc
                                previewImageURL:[NSURL URLWithString:image]];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    //将内容分享到qq
    dispatch_async(dispatch_get_main_queue(), ^{
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    });
    
}

- (void)qqSendWebMessageToQQZoneWithTitle:(NSString *)title iconImage:(NSString *)image desc:(NSString *)desc url:(NSString *)url
{
    
    QQApiNewsObject *newsObj = nil;
    //网络图片
    if ([image isEqualToString:@"http://"]
        || [image isEqualToString:@"https://"]) {
        newsObj  = [QQApiNewsObject
           objectWithURL:[NSURL URLWithString:url]
           title:title
           description:desc
           previewImageURL:[NSURL URLWithString:image]];
    } else {
//        将UIImage 转为 NSData
        UIImage *img = [UIImage imageNamed:image];
        NSData *data = nil;
        if (UIImagePNGRepresentation(img) == nil) {
            
            data = UIImageJPEGRepresentation(img, 1);
            
        } else {
            
            data = UIImagePNGRepresentation(img);
        }
        newsObj = [QQApiNewsObject
                   objectWithURL:[NSURL URLWithString:url]
                   title:title
                   description:desc previewImageData:data];
    }
 
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    dispatch_async(dispatch_get_main_queue(), ^{
        //将内容分享到qzone
        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    });

}


@end
