//
//  MKConfigPeriodTimeModel.h
//  FitpoloSDK-iOS_Example
//
//  Created by aa on 2019/6/14.
//  Copyright © 2019 Chengang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKConfigPeriodTimeModel : NSObject<MKPeriodTimeSetProtocol>

/**
 开始时,0~23
 */
@property (nonatomic, assign)NSInteger startHour;

/**
 开始分,0~59
 */
@property (nonatomic, assign)NSInteger startMin;

/**
 结束时,0~23
 */
@property (nonatomic, assign)NSInteger endHour;

/**
 结束分,0~59
 */
@property (nonatomic, assign)NSInteger endMin;

/**
 YES:打开，NO:关闭,这种状态下，开始时间和结束时间就没有任何意义了
 */
@property (nonatomic, assign)BOOL isOn;

@end

NS_ASSUME_NONNULL_END
