//
//  CBPeripheral+mk_fitpoloCurrent.m
//  mk_fitpoloCentralManager
//
//  Created by aa on 2018/12/10.
//  Copyright © 2018 mk_fitpolo. All rights reserved.
//

#import "CBPeripheral+mk_fitpoloCurrent.h"
#import <objc/runtime.h>

#pragma mark -
static const char *readDataCharacteristic = "readDataCharacteristic";
static const char *writeDataCharacteristic = "writeDataCharacteristic";
static const char *stepDataCharacteristic = "stepDataCharacteristic";
static const char *heartRateCharacteristic = "heartRateCharacteristic";
static const char *updateWriteCharacteristic = "updateWriteCharacteristic";
static const char *updateNotifyCharacteristic = "updateNotifyCharacteristic";

static const char *notifyReadConfigDataSuccess = "notifyReadConfigDataSuccess";
static const char *notifySetConfigDataSuccess = "notifySetConfigDataSuccess";
static const char *notifyStepMeterDataSuccess = "notifyStepMeterDataSuccess";
static const char *notifyHeartRateDataSuccess = "notifyHeartRateDataSuccess";
static const char *notifyUpdateSuccess = "notifyUpdateSuccess";

@implementation CBPeripheral (mk_fitpoloCurrent)

- (void)updateCurrentCharacteristicsForService:(CBService *)service{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFB0"]]) {
        NSArray *charactList = [service.characteristics mutableCopy];
        for (CBCharacteristic *characteristic in charactList) {
            [self setNotifyValue:YES forCharacteristic:characteristic];
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB0"]]) {
                objc_setAssociatedObject(self, &readDataCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB1"]]){
                objc_setAssociatedObject(self, &writeDataCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB2"]]){
                objc_setAssociatedObject(self, &stepDataCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB3"]]){
                objc_setAssociatedObject(self, &heartRateCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
        return;
    }
    if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFC0"]]){
        NSArray *charactList = [service.characteristics mutableCopy];
        for (CBCharacteristic *characteristic in charactList) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFC1"]]) {
                objc_setAssociatedObject(self, &updateWriteCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFC2"]]){
                [self setNotifyValue:YES forCharacteristic:characteristic];
                objc_setAssociatedObject(self, &updateNotifyCharacteristic, characteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
        return;
    }
}

- (void)updateCurrentNotifySuccess:(CBCharacteristic *)characteristic{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB0"]]) {
        objc_setAssociatedObject(self, &notifyReadConfigDataSuccess, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB1"]]){
        objc_setAssociatedObject(self, &notifySetConfigDataSuccess, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB2"]]){
        objc_setAssociatedObject(self, &notifyStepMeterDataSuccess, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB3"]]){
        objc_setAssociatedObject(self, &notifyHeartRateDataSuccess, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFC2"]]){
        objc_setAssociatedObject(self, &notifyUpdateSuccess, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (BOOL)fitpoloCurrentConnectSuccess{
    if (!self.readData) {
        return NO;
    }
    if (!self.writeData) {
        return NO;
    }
    if (!self.stepData) {
        return NO;
    }
    if (!self.heartRate) {
        return NO;
    }
    if (!self.updateWrite) {
        return NO;
    }
    if (!self.updateNotify) {
        return NO;
    }
    NSNumber *notifyReadData = objc_getAssociatedObject(self, &notifyReadConfigDataSuccess);
    if (!notifyReadData || ![notifyReadData boolValue]) {
        return NO;
    }
    NSNumber *notifySetData = objc_getAssociatedObject(self, &notifySetConfigDataSuccess);
    if (!notifySetData || ![notifySetData boolValue]) {
        return NO;
    }
    NSNumber *notifyStepData = objc_getAssociatedObject(self, &notifyStepMeterDataSuccess);
    if (!notifyStepData || ![notifyStepData boolValue]) {
        return NO;
    }
    NSNumber *notifyHeartData = objc_getAssociatedObject(self, &notifyHeartRateDataSuccess);
    if (!notifyHeartData || ![notifyHeartData boolValue]) {
        return NO;
    }
    NSNumber *notifyUpdate = objc_getAssociatedObject(self, &notifyUpdateSuccess);
    if (!notifyUpdate || ![notifyUpdate boolValue]) {
        return NO;
    }
    return YES;
}

- (void)setFitpoloCurrentCharacteNil{
    objc_setAssociatedObject(self, &readDataCharacteristic, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &writeDataCharacteristic, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &stepDataCharacteristic, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &heartRateCharacteristic, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &updateWriteCharacteristic, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &updateNotifyCharacteristic, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    objc_setAssociatedObject(self, &notifyReadConfigDataSuccess, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &notifySetConfigDataSuccess, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &notifyStepMeterDataSuccess, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &notifyHeartRateDataSuccess, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, &notifyUpdateSuccess, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CBCharacteristic *)readData{
    return objc_getAssociatedObject(self, &readDataCharacteristic);
}

- (CBCharacteristic *)writeData{
    return objc_getAssociatedObject(self, &writeDataCharacteristic);
}

- (CBCharacteristic *)stepData{
    return objc_getAssociatedObject(self, &stepDataCharacteristic);
}

- (CBCharacteristic *)heartRate{
    return objc_getAssociatedObject(self, &heartRateCharacteristic);
}

- (CBCharacteristic *)updateWrite{
    return objc_getAssociatedObject(self, &updateWriteCharacteristic);
}

- (CBCharacteristic *)updateNotify{
    return objc_getAssociatedObject(self, &updateNotifyCharacteristic);
}

@end
