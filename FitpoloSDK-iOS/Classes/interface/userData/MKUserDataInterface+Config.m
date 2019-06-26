
//
//  MKUserDataInterface+Config.m
//  MKFitpolo
//
//  Created by aa on 2019/1/14.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKUserDataInterface+Config.h"
#import "mk_fitpoloDefines.h"
#import "mk_fitpoloCentralManager.h"
#import "MKUserDataInterfaceAdopter.h"
#import "mk_fitpoloAdopter.h"
#import "CBPeripheral+mk_fitpolo701.h"
#import "CBPeripheral+mk_fitpoloCurrent.h"

#define connectedPeripheral (currentCentral.connectedPeripheral)
#define currentCentral ([mk_fitpoloCentralManager sharedInstance])

@implementation MKUserDataInterface (Config)

+ (void)configDate:(id <MKConfigDateProtocol>)protocol
          sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
       failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock{
    if (![MKUserDataInterfaceAdopter validTimeProtocol:protocol]) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (protocol.seconds < 0 || protocol.seconds > 59) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *hexTime = [MKUserDataInterfaceAdopter getTimeString:protocol];
    if (!mk_validStr(hexTime)) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *secString = [NSString stringWithFormat:@"%1lx",(long)protocol.seconds];
    if (secString.length == 1) {
        secString = [@"0" stringByAppendingString:secString];
    }
    NSString *commandString = [hexTime stringByAppendingString:secString];
    if (currentCentral.deviceType == mk_fitpolo701) {
        //701
        commandString = [@"11" stringByAppendingString:commandString];
    }else{
        //新手环
        commandString = [@"b20f06" stringByAppendingString:commandString];
    }
    [self addConfigTaskWithTaskID:mk_configDateOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)configUserData:(id <mk_configUserDataProtocol>)protocol
              sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
           failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock{
    if (!protocol
        || protocol.weight < 30
        || protocol.weight > 150
        || protocol.height < 100
        || protocol.height > 200
        || protocol.userAge < 1
        || protocol.userAge > 100) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    
    NSString *ageString = [NSString stringWithFormat:@"%1lx",(unsigned long)protocol.userAge];
    if (ageString.length == 1) {
        ageString = [@"0" stringByAppendingString:ageString];
    }
    NSString *heightString = [NSString stringWithFormat:@"%1lx",(unsigned long)protocol.height];
    if (heightString.length == 1) {
        heightString = [@"0" stringByAppendingString:heightString];
    }
    NSString *weightString = [NSString stringWithFormat:@"%1lx",(unsigned long)protocol.weight];
    if (weightString.length == 1) {
        weightString = [@"0" stringByAppendingString:weightString];
    }
    //步距的计算方法:步长=身高*0.45 ,并且向下取整，程昂修改于2017年6月10号
    NSInteger stepAway = floor(protocol.height * 0.45);
    NSString *stepAwayString = [NSString stringWithFormat:@"%1lx",(unsigned long)stepAway];
    if (stepAwayString.length == 1) {
        stepAwayString = [@"0" stringByAppendingString:stepAwayString];
    }
    NSString *genderString = (protocol.gender == mk_fitpoloGenderMale ? @"00" : @"01");
    NSString *commandString = @"";
    if (currentCentral.deviceType == mk_fitpolo701) {
        commandString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                         @"12",
                         weightString,
                         heightString,
                         ageString,
                         genderString,
                         stepAwayString];
    }else{
        commandString = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",
                         @"b20e07",
                         weightString,
                         heightString,
                         ageString,
                         @"01",
                         @"01",
                         genderString,
                         stepAwayString];
    }
    [self addConfigTaskWithTaskID:mk_configUserInfoOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

#pragma mark - 705、706、707

+ (void)configStepChangeMeterMonitoringState:(BOOL)open
                                    sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                                 failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [mk_fitpoloAdopter operationDeviceTypeErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = (open ? @"b4030101" : @"b4030100");
    [currentCentral addTaskWithTaskID:mk_stepChangeMeterMonitoringStatusOperation
                             resetNum:NO
                          commandData:commandString
                       characteristic:connectedPeripheral.stepData
                         successBlock:sucBlock
                         failureBlock:failedBlock];
}

+ (void)configMovingTarget:(NSInteger)target
                  sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
               failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [mk_fitpoloAdopter operationDeviceTypeErrorBlock:failedBlock];
        return;
    }
    if (target < 1 || target > 60000) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *targetHex = [NSString stringWithFormat:@"%1lx",(unsigned long)target];
    if (targetHex.length == 1) {
        targetHex = [@"000" stringByAppendingString:targetHex];
    }else if (targetHex.length == 2){
        targetHex = [@"00" stringByAppendingString:targetHex];
    }else if (targetHex.length == 3){
        targetHex = [@"0" stringByAppendingString:targetHex];
    }
    NSString *commandString = [@"b20602" stringByAppendingString:targetHex];
    [self addConfigTaskWithTaskID:mk_configMovingTargetOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

#pragma mark - 706、707

+ (void)configMeterStepInterval:(NSInteger)interval
                       sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                    failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock {
    if (currentCentral.deviceType == mk_fitpolo701
        || currentCentral.deviceType == mk_fitpolo705) {
        [mk_fitpoloAdopter operationDeviceTypeErrorBlock:failedBlock];
        return;
    }
    if (interval < 0 || interval > 60) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *stepInterval = [NSString stringWithFormat:@"%1lx",(unsigned long)interval];
    if (stepInterval.length == 1) {
        stepInterval = [@"0" stringByAppendingString:stepInterval];
    }
    NSString *commandString = [@"b22101" stringByAppendingString:stepInterval];
    [self addConfigTaskWithTaskID:mk_configStepIntervalOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)configSearchPhone:(BOOL)open
                 sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
              failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock {
    if (currentCentral.deviceType == mk_fitpolo701
        || currentCentral.deviceType == mk_fitpolo705) {
        [mk_fitpoloAdopter operationDeviceTypeErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = (open ? @"b2160101" : @"b2160100");
    [self addConfigTaskWithTaskID:mk_configSearchPhoneOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

#pragma mark - private method

+ (void)addConfigTaskWithTaskID:(mk_taskOperationID)taskID
                       resetNum:(BOOL)resetNum
                  commandString:(NSString *)commandString
                       sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                    failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock{
    CBCharacteristic *character = (currentCentral.deviceType == mk_fitpolo701
                                   ? connectedPeripheral.commandSend
                                   : connectedPeripheral.writeData);
    [currentCentral addTaskWithTaskID:taskID
                             resetNum:resetNum
                          commandData:commandString
                       characteristic:character
                         successBlock:^(id returnData) {
                             [mk_fitpoloAdopter operationSetParamsResult:returnData sucBlock:sucBlock failedBlock:failedBlock];
                         } failureBlock:failedBlock];
}

@end
