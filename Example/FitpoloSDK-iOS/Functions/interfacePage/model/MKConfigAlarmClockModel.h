//
//  MKConfigAlarmClockModel.h
//  FitpoloSDK-iOS_Example
//
//  Created by aa on 2019/6/14.
//  Copyright © 2019 Chengang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKClockStatusModel : NSObject<MKAlarmClockStatusProtocol>

//周一是否打开
@property (nonatomic, assign)BOOL mondayIsOn;
//周二是否打开
@property (nonatomic, assign)BOOL tuesdayIsOn;
//周三是否打开
@property (nonatomic, assign)BOOL wednesdayIsOn;
//周四是否打开
@property (nonatomic, assign)BOOL thursdayIsOn;
//周五是否打开
@property (nonatomic, assign)BOOL fridayIsOn;
//周六是否打开
@property (nonatomic, assign)BOOL saturdayIsOn;
//周日是否打开
@property (nonatomic, assign)BOOL sundayIsOn;

@end

@interface MKConfigAlarmClockModel : NSObject<MKSetAlarmClockProtocol>

//闹钟index
@property (nonatomic, assign)NSInteger index;
//闹钟时间，必须是HH:mm
@property (nonatomic, copy)NSString *time;
//闹钟状态，周一至周日
@property (nonatomic, strong)id <MKAlarmClockStatusProtocol>clockStatusProtocol;
//闹钟类型，一共6种，吃药0、喝水1、普通2、睡眠3、锻炼4、运动5
@property (nonatomic, assign)MKAlarmClockType clockType;
//当前闹钟状态，YES打开，NO关闭
@property (nonatomic, assign)BOOL isOn;

@end

NS_ASSUME_NONNULL_END
