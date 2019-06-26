//
//  mk_fitpoloCurrentAdopter.h
//  mk_fitpoloCentralManager
//
//  Created by aa on 2018/12/10.
//  Copyright © 2018 mk_fitpolo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface mk_fitpoloCurrentAdopter : NSObject

+ (NSArray <NSDictionary *>*)getAlarmClockDataList:(NSString *)content;
+ (NSDictionary *)fetchAncsOptionsModel:(NSString *)content;
+ (NSDictionary *)getSedentaryRemindData:(NSString *)content;
+ (NSDictionary *)fetchCustomScreenModel:(NSString *)content;
+ (NSDictionary *)getUserInfo:(NSString *)content;
+ (NSDictionary *)getHardwareParameters:(NSString *)content;
+ (NSString *)getFirmwareVersion:(NSString *)content;
+ (NSArray *)getSleepDetailList:(NSString *)detail;
//解析睡眠index，记录到本地日志
+ (NSDictionary *)getSleepIndexData:(NSString *)content;
//解析睡眠record，记录到本地日志
+ (NSDictionary *)getSleepRecordData:(NSString *)content;
+ (NSDictionary *)getSportData:(NSString *)content;
+ (NSString *)getLastChargingTime:(NSString *)content;
+ (NSString *)getTimeSpaceWithStatus:(BOOL)isOn
                           startHour:(NSInteger)startHour
                        startMinutes:(NSInteger)startMinutes
                             endHour:(NSInteger)endHour
                          endMinutes:(NSInteger)endMinutes;
//解析读取回来的计步数据，并记录到本地
+ (NSDictionary *)getStepDetailData:(NSString *)content;
//解析心率数据，并记录到本地
+ (NSDictionary *)getHeartRateList:(NSString *)content;

/**
 获取计步间隔数据

 @param content content
 @return dic
 */
+ (NSDictionary *)fetchStepIntervalData:(NSString *)content;

+ (NSArray *)fetch706CurrentScreenList:(NSString *)conten;

@end

NS_ASSUME_NONNULL_END
