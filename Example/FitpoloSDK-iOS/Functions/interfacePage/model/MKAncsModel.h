//
//  MKAncsModel.h
//  FitpoloSDK-iOS_Example
//
//  Created by aa on 2019/6/14.
//  Copyright © 2019 Chengang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKAncsModel : NSObject<MKANCSProtocol>

//打开短信提醒
@property (nonatomic, assign)BOOL openSMS;
//打开电话提醒
@property (nonatomic, assign)BOOL openPhone;
//打开微信提醒
@property (nonatomic, assign)BOOL openWeChat;
//打开qq提醒
@property (nonatomic, assign)BOOL openQQ;
//打开whatsapp提醒
@property (nonatomic, assign)BOOL openWhatsapp;
//打开facebook提醒
@property (nonatomic, assign)BOOL openFacebook;
//打开twitter提醒
@property (nonatomic, assign)BOOL openTwitter;
//打开skype提醒
@property (nonatomic, assign)BOOL openSkype;
//打开snapchat提醒
@property (nonatomic, assign)BOOL openSnapchat;
//打开Line
@property (nonatomic, assign)BOOL openLine;

@end

NS_ASSUME_NONNULL_END
