//
//  CBPeripheral+mk_fitpoloCurrent.h
//  mk_fitpoloCentralManager
//
//  Created by aa on 2018/12/10.
//  Copyright © 2018 mk_fitpolo. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (mk_fitpoloCurrent)

@property (nonatomic, strong, readonly)CBCharacteristic *readData;

@property (nonatomic, strong, readonly)CBCharacteristic *writeData;

@property (nonatomic, strong, readonly)CBCharacteristic *stepData;

@property (nonatomic, strong, readonly)CBCharacteristic *heartRate;

@property (nonatomic, strong, readonly)CBCharacteristic *updateWrite;

@property (nonatomic, strong, readonly)CBCharacteristic *updateNotify;

- (void)updateCurrentCharacteristicsForService:(CBService *)service;
- (void)updateCurrentNotifySuccess:(CBCharacteristic *)characteristic;
- (BOOL)fitpoloCurrentConnectSuccess;
- (void)setFitpoloCurrentCharacteNil;

@end

NS_ASSUME_NONNULL_END
