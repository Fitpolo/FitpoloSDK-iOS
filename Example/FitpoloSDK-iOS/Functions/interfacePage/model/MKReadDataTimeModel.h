//
//  MKReadDataTimeModel.h
//  FitpoloSDK-iOS_Example
//
//  Created by aa on 2019/6/13.
//  Copyright © 2019 Chengang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKReadDataTimeModel : NSObject<MKReadDeviceDataTimeProtocol>

@property (nonatomic, assign)NSInteger year;

@property (nonatomic, assign)NSInteger month;

@property (nonatomic, assign)NSInteger day;

@property (nonatomic, assign)NSInteger hour;

@property (nonatomic, assign)NSInteger minutes;

@end

@interface MKConfigDateModel : MKReadDataTimeModel<MKConfigDateProtocol>

@property (nonatomic, assign)NSInteger seconds;

@end

NS_ASSUME_NONNULL_END
