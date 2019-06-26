//
//  mk_fitpolo701Adopter.h
//  mk_fitpoloCentralManager
//
//  Created by aa on 2018/12/10.
//  Copyright © 2018 mk_fitpolo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface mk_fitpolo701Adopter : NSObject

+ (NSDictionary *)getHardwareParameters:(NSString *)content;
+ (NSDictionary *)getAncsOptions:(NSString *)content;
+ (NSDictionary *)getMemoryData:(NSString *)content;
+ (NSDictionary *)getStepData:(NSString *)content;
+ (NSDictionary *)getSleepIndexData:(NSString *)content;
+ (NSDictionary *)getSleepRecordData:(NSString *)content;
+ (NSArray *)getHeartRateData:(NSString *)content;
+ (NSDictionary *)getFirmwareVersion:(NSString *)content;
+ (NSArray <NSDictionary *>*)getAlarmClockList:(NSString *)content;
+ (NSDictionary *)getSedentaryRemindData:(NSString *)content;
+ (NSDictionary *)getConfigurationParameters:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
