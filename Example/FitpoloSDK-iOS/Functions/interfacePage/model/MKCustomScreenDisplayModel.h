//
//  MKCustomScreenDisplayModel.h
//  FitpoloSDK-iOS_Example
//
//  Created by aa on 2019/6/14.
//  Copyright © 2019 Chengang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKCustomScreenDisplayModel : NSObject<MKCustomScreenDisplayProtocol>

//心率页面
@property (nonatomic, assign)BOOL turnOnHeartRatePage;
//计步页面
@property (nonatomic, assign)BOOL turnOnStepPage;
//卡路里页面
@property (nonatomic, assign)BOOL turnOnCaloriesPage;
//运动距离页面
@property (nonatomic, assign)BOOL turnOnSportsDistancePage;
//运动时间页面
@property (nonatomic, assign)BOOL turnOnSportsTimePage;
//睡眠页面,703、705特有
@property (nonatomic, assign)BOOL turnOnSleepPage;
//跑步2页面,703、705特有
@property (nonatomic, assign)BOOL turnOnSecondRunning;
//跑步3页面,703、705特有
@property (nonatomic, assign)BOOL turnOnThirdRunning;

@end

NS_ASSUME_NONNULL_END
