//
//  MKConfigUserDataModel.h
//  FitpoloSDK-iOS_Example
//
//  Created by aa on 2019/6/14.
//  Copyright © 2019 Chengang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKConfigUserDataModel : NSObject<mk_configUserDataProtocol>

@property (nonatomic, assign)NSInteger height;

@property (nonatomic, assign)NSInteger weight;

@property (nonatomic, assign)mk_fitpoloGender gender;

/**
 年龄,1~100
 */
@property (nonatomic, assign)NSInteger userAge;

@end

NS_ASSUME_NONNULL_END
