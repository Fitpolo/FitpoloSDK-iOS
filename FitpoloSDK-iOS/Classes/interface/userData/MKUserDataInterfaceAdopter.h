//
//  MKUserDataInterfaceAdopter.h
//  MKFitpoloUserData
//
//  Created by aa on 2019/1/2.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKUserDataInterfaceDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKUserDataInterfaceAdopter : NSObject

+ (BOOL)validTimeProtocol:(id <MKReadDeviceDataTimeProtocol>)protocol;
+ (NSString *)getTimeString:(id <MKReadDeviceDataTimeProtocol>)protocol;
+ (NSArray *)getSleepDataList:(NSArray *)indexList recordList:(NSArray *)recordList;
+ (NSArray <NSDictionary *>*)fetchStepModelList:(NSArray *)resultList;
+ (NSArray <NSDictionary *>*)fetchSleepModelList:(NSArray *)resultList;
+ (NSDictionary *)fetchHeartModelList:(NSArray *)resultList;

@end

NS_ASSUME_NONNULL_END
