//
//  MKDeviceInterfaceAdopter.h
//  MKFitpoloDevice
//
//  Created by aa on 2018/12/19.
//  Copyright © 2018 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKDeviceInterfaceHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKDeviceInterfaceAdopter : NSObject

+ (NSString *)fetchAncsOptionsCommand:(id <MKANCSProtocol>)protocol;
+ (NSDictionary *)conversionTimeDictionary:(NSDictionary *)timeDic;
+ (NSArray <NSDictionary *>*)parseAlarmClockList:(NSArray <NSDictionary *>*)list;
/**
 把originalArray数组按照range进行截取，生成一个新的数组并返回该数组
 
 @param originalArray 原数组
 @param range 截取范围
 @return 截取后生成的数组
 */
+ (NSArray *)interceptionOfArray:(NSArray *)originalArray subRange:(NSRange)range;
+ (NSString *)getAlarmClockType:(MKAlarmClockType)clockType;
+ (NSString *)fetchAlarlClockSetInfo:(BOOL)isOn statusModel:(id <MKAlarmClockStatusProtocol>)statusModel;
+ (NSString *)fetch705ClockCommand:(id <MKSetAlarmClockProtocol>)model;
+ (NSString *)fetch701SedentaryRemindCommand:(id <MKPeriodTimeSetProtocol>)protocol;
+ (NSString *)fetch705SedentaryRemindCommand:(id <MKPeriodTimeSetProtocol>)protocol;
+ (NSString *)fetchTimeString:(id <MKPeriodTimeSetProtocol>)protocol;
+ (NSString *)fetch701ScreenDisplay:(id <MKCustomScreenDisplayProtocol>)displayModel;
+ (NSString *)fetch705ScreenDisplay:(id <MKCustomScreenDisplayProtocol>)screenModel;
+ (NSString *)fetchDialStyle:(mk_fitpoloDialStyle)style;

@end

NS_ASSUME_NONNULL_END
