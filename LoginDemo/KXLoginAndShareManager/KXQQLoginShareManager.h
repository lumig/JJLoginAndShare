//
//  KXQQLoginShareManager.h
//  LoginDemo
//
//  Created by jessie on 2018/8/4.
//  Copyright © 2018年 luming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>

/**
 *  成功
 */
typedef void(^loginSuccess)(NSDictionary *dict);

/**
 *  失败
 */
typedef void(^loginFailure)(NSDictionary *dict);

@protocol KXQQLoginShareManagerDelegate<NSObject>
@optional
//qq登录成功回调
- (void)qqLoginSuccess:(NSDictionary *)dict;

//qq登录失败回调
- (void)qqLoginFailure:(NSInteger)errorCode;
@end

@interface KXQQLoginShareManager : NSObject<TencentSessionDelegate>
/**
 *  成功的block
 */
@property (nonatomic, copy) loginSuccess loginSuccessBlock;

/**
 *  失败的block
 */
@property (nonatomic, copy) loginFailure loginFailureBlock;

@property (nonatomic, weak) id<KXQQLoginShareManagerDelegate> delegate;

+ (instancetype)shareInstance;

/**
 注册qq
 */
- (void)qqLoginShareRegisterApp;

//qq登录
- (void)qqLogin;

/**
qq分享纯文本给好友
 */
- (void)qqSendMessageToFriend:(NSString *)message;

/**
qq 分享纯文本到qq空间
 */
- (void)qqSendMessageToQQZone:(NSString *)message;

/**
qq分享网页信息给好友
 */
- (void)qqSendWebMessageToFriendWithTitle:(NSString *)title iconImage:(NSString *)image desc:(NSString *)desc url:(NSString *)url;

/**
 qq分享网页信息到qq空间
 */
- (void)qqSendWebMessageToQQZoneWithTitle:(NSString *)title iconImage:(NSString *)image desc:(NSString *)desc url:(NSString *)url;
@end
