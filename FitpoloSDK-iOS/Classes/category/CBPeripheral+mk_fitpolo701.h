//
//  CBPeripheral+mk_fitpolo701.h
//  mk_fitpoloCentralManager
//
//  Created by aa on 2018/12/10.
//  Copyright © 2018 mk_fitpolo. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (mk_fitpolo701)

@property (nonatomic, strong, readonly)CBCharacteristic *commandSend;

@property (nonatomic, strong, readonly)CBCharacteristic *commandNotify;

- (void)update701CharacteristicsForService:(CBService *)service;

- (void)update701NotifySuccess:(CBCharacteristic *)characteristic;

- (BOOL)fitpolo701ConnectSuccess;

- (void)setFitpolo701CharacterNil;

@end

NS_ASSUME_NONNULL_END
