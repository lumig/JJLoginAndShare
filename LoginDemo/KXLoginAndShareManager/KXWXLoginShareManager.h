//
//  KXWXLoginShareManager.h
//  LoginDemo
//
//  Created by jessie on 2018/8/4.
//  Copyright © 2018年 luming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@protocol KXWXLoginShareManagerDelegate <NSObject>

@optional
/**
 *  登录成功
 *
 *  @param dict 微信后台返回的数据
 */

- (void)wechatLoginShareLoginSuccess:(NSDictionary *)dict;
/**
 *  登录失败
 *
 *  @param dict 微信后台返回的数据
 */
- (void)wechatLoginShareLoginFailure:(NSDictionary *)dict;

@end

/**
 *  成功
 */
typedef void(^loginSuccess)(NSDictionary *dict);

/**
 *  失败
 */
typedef void(^loginFailure)(NSDictionary *dict);

@interface KXWXLoginShareManager : NSObject

@property (nonatomic, weak) id<KXWXLoginShareManagerDelegate> delegate;

/**
 *  成功的block
 */
@property (nonatomic, copy) loginSuccess loginSuccessBlock;
/**
 *  失败的block
 */
@property (nonatomic, copy) loginFailure loginFailureBlock;

+ (instancetype)shareInstance;

/**
 *  注册ID
 */
- (void)wechatLoginShareRegisterApp;

/**
 *  微信登录
 */
- (void)wechatLogin;
/**
 *  微信登录 block版本
 *
 *  @param successBlock 成功回调
 *  @param failureBlock    失败回调
 */
- (void)wechatLoginSuccess:(loginSuccess)successBlock fail:(loginFailure)failureBlock;

/**
 *  微信文字分享
 *
 *  @param scene WXSceneSession:微信聊天  WXSceneTimeline:朋友圈  WXSceneFavorite:收藏
 */
- (void)wechatSendMessageToWX:(int)scene message:(NSString *)message;

/**
 *  微信网页分享
 *
 *  @param scene WXSceneSession:微信聊天  WXSceneTimeline:朋友圈  WXSceneFavorite:收藏
 */
- (void)wechatSendWebToWX:(int)scene title:(NSString *)title iconImage:(NSString *)image desc:(NSString *)desc url:(NSString *)url;



@end
