//
//  KXWXLoginShareManager.m
//  LoginDemo
//
//  Created by jessie on 2018/8/4.
//  Copyright © 2018年 luming. All rights reserved.
//

#import "KXWXLoginShareManager.h"
#import <UIKit/UIKit.h>

//微信
#define wechatAppKey @"wx5c390d18ad9ff371"
#define wechatAppSecret @"e51f10d96039ce8fa32f2035d15f2ff9"


@interface KXWXLoginShareManager ()

@property (nonatomic, copy)NSString *kWeiXinRefreshToken;

@end

@implementation KXWXLoginShareManager

+ (instancetype)shareInstance
{
    static KXWXLoginShareManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/**
 *  注册ID
 */
- (void)wechatLoginShareRegisterApp
{
    [WXApi registerApp:wechatAppKey];
}

/**
 *  微信登录
 */
- (void)wechatLogin
{
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"kx_userinfo";
    req.state = @"kxWechatLoginShare";
    [WXApi sendReq:req];
}

/**
 *  微信登录 block版本
 *
 *  @param successBlock 成功回调
 *  @param failureBlock    失败回调
 */
- (void)wechatLoginSuccess:(loginSuccess)successBlock fail:(loginFailure)failureBlock
{
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"kx_userinfo";
    req.state = @"kxWechatLoginShare";
    [WXApi sendReq:req];
    

    self.loginSuccessBlock = ^(NSDictionary *dict){
        successBlock(dict);
    };
    self.loginFailureBlock = ^(NSDictionary *dict){
        failureBlock(dict);
    };
}


/**
 *  微信文字分享
 *
 *  @param scene WXSceneSession:微信聊天  WXSceneTimeline:朋友圈  WXSceneFavorite:收藏
 */
- (void)wechatSendMessageToWX:(int)scene message:(NSString *)message
{
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.text = message;
    req.bText = YES;
    req.scene = scene;
    [WXApi sendReq:req];
}

/**
 *  微信网页分享
 *
 *  @param scene WXSceneSession:微信聊天  WXSceneTimeline:朋友圈  WXSceneFavorite:收藏
 */
- (void)wechatSendWebToWX:(int)scene title:(NSString *)title iconImage:(NSString *)image desc:(NSString *)desc url:(NSString *)url
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = desc;
    [message setThumbImage:[UIImage imageNamed:image]];
    
    WXWebpageObject *videoobject = [WXWebpageObject object];
    videoobject.webpageUrl = url;
    message.mediaObject = videoobject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    [WXApi sendReq:req];
}


#pragma mark - WXApiDelegate
-(void) onReq:(BaseReq*)req
{
    if ([req isKindOfClass:[SendMessageToWXResp class]]) {
        NSLog(@"========== ");
    }
}

-(void) onResp:(BaseResp*)resp
{
    // 微信登录
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (resp.errCode == 0) {
            SendAuthResp *aresp = (SendAuthResp *)resp;
            [self getAccessTokenWithCode:aresp.code];
            return;
        }
    }
    // 微信分享/收藏
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp *aresp = (SendMessageToWXResp *)resp;
        NSLog(@"county = %@",aresp.country);
        NSLog(@"lang = %@",aresp.lang);
    }
}
/**
 *  获取access_token
 *
 *  @param code code description
 */
- (void)getAccessTokenWithCode:(NSString *)code
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",wechatAppKey,wechatAppSecret,code];
    NSLog(@"urlString = %@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data)
            {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"dict = %@",dict);
                if ([dict objectForKey:@"errcode"])
                {
                    if (self.loginFailureBlock) {
                        self.loginFailureBlock(dict);
                    }
                    // 授权失败(用户取消/拒绝)
                    if ([self.delegate respondsToSelector:@selector(wechatLoginShareLoginFailure:)]) {
                        [self.delegate wechatLoginShareLoginFailure:dict];
                    }
                }else{
                    self.kWeiXinRefreshToken = [dict objectForKey:@"access_token"];
                    [self getUserInfoWithAccessToken:[dict objectForKey:@"access_token"] andOpenId:[dict objectForKey:@"openid"]];
                }
            }
        });
    });
}

/**
 *  获取用户信息
 *
 *  @param accessToken access_token
 *  @param openId      openId description
 */
- (void)getUserInfoWithAccessToken:(NSString *)accessToken andOpenId:(NSString *)openId
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openId];
    NSLog(@"urlString = %@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"dict = %@",dict);
                if ([dict objectForKey:@"errcode"]) {
                    //AccessToken失效
                    [self getAccessTokenWithRefreshToken:[[NSUserDefaults standardUserDefaults]objectForKey:self.kWeiXinRefreshToken]];
                } else {
                    if (self.loginSuccessBlock) {
                        self.loginSuccessBlock(dict);
                    }
                    if ([self.delegate respondsToSelector:@selector(wechatLoginShareLoginSuccess:)]) {
                        [self.delegate wechatLoginShareLoginSuccess:dict];                    }
                }
            }
        });
    });
}
/**
 *  刷新access_token
 *
 *  @param refreshToken refreshToken description
 */
- (void)getAccessTokenWithRefreshToken:(NSString *)refreshToken
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@",@"wx29c1153063de230b",refreshToken];
    NSLog(@"urlString = %@",urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                if ([dict objectForKey:@"errcode"]) {
                    //授权过期
                } else {
                    //重新使用AccessToken获取信息
                }
            }
        });
    });
    
}


@end
