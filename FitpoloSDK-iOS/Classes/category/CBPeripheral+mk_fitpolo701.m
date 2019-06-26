//
//  CBPeripheral+mk_fitpolo701.m
//  mk_fitpoloCentralManager
//
//  Created by aa on 2018/12/10.
//  Copyright © 2018 mk_fitpolo. All rights reserved.
//

#import "CBPeripheral+mk_fitpolo701.h"
#import <objc/runtime.h>

static const char *writeCharacteristic = "writeCharacteristic";
static const char *notifyCharacteristic = "notifyCharacteristic";
static const char *notifySuccess = "notifySuccess";

@implementation CBPeripheral (mk_fitpolo701)

- (void)update701CharacteristicsForService:(CBService *)service{
    if (![service.UUID isEqual:[CBUUID UUIDWithString:@"FFC0"]]) {
        return;
    }
    NSArray *charactList = [service.characteristics mutableCopy];
    for (CBCharacteristic *characteristic in charactList) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFC1"]]) {
            objc_setAssociatedObject(self, &writeCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFC2"]]){
            objc_setAssociatedObject(self, &notifyCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [self setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

- (void)update701NotifySuccess:(CBCharacteristic *)characteristic{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFC2"]]){
        objc_setAssociatedObject(self, &notifySuccess, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)setFitpolo701CharacterNil{
    objc_setAssociatedObject(self, &writeCharacteristic, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &notifyCharacteristic, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &notifySuccess, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CBCharacteristic *)commandSend{
    return objc_getAssociatedObject(self, &writeCharacteristic);
}

- (CBCharacteristic *)commandNotify{
    return objc_getAssociatedObject(self, &notifyCharacteristic);
}

- (BOOL)fitpolo701ConnectSuccess{
    if (!self.commandSend) {
        return NO;
    }
    if (!self.commandNotify) {
        return NO;
    }
    NSNumber *notifySuccessNumber = objc_getAssociatedObject(self, &notifySuccess);
    if (!notifySuccessNumber || ![notifySuccessNumber boolValue]) {
        return NO;
    }
    return YES;
}

@end
