//
//  MKDeviceInterface.m
//  MKFitpoloDevice
//
//  Created by aa on 2018/12/14.
//  Copyright © 2018 MK. All rights reserved.
//

#import "MKDeviceInterface.h"
#import "mk_fitpoloDefines.h"
#import "mk_fitpoloCentralManager.h"
#import "MKDeviceInterfaceAdopter.h"
#import "mk_fitpoloAdopter.h"
#import "CBPeripheral+mk_fitpolo701.h"
#import "CBPeripheral+mk_fitpoloCurrent.h"

#define connectedPeripheral (currentCentral.connectedPeripheral)
#define currentCentral ([mk_fitpoloCentralManager sharedInstance])

@implementation MKDeviceInterface

+ (void)readBatteryWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                    failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [self readPeripheralMemoryDataWithSucBlock:^(id returnData) {
            NSString *battery = returnData[@"result"][@"battery"];
            if (!mk_validStr(battery)) {
                battery = @"";
            }
            NSDictionary *dic = @{
                                  @"msg":@"success",
                                  @"code":@"1",
                                  @"result":@{
                                          @"battery":battery,
                                          },
                                  };
            if (sucBlock) {
                sucBlock(dic);
            }
        }
                                         failBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readBatteryOperation
                       resetNum:NO
                  commandString:@"b01900"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

+ (void)readFirmwareVersionWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                            failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    NSString *commandString = (currentCentral.deviceType == mk_fitpolo701 ? @"1606" : @"b01100");
    [self addReadTaskWithTaskID:mk_readFirmwareVersionOperation
                       resetNum:NO
                  commandString:commandString
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

+ (void)readHardwareParametersWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                               failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    NSString *commandString = (currentCentral.deviceType == mk_fitpolo701 ? @"1622" : @"b01000");
    [self addReadTaskWithTaskID:mk_readHardwareParametersOperation
                       resetNum:NO
                  commandString:commandString
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

+ (void)readLastChargingTimeWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                             failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [self readHardwareParametersWithSucBlock:^(id returnData) {
            NSDictionary *dic = @{
                                  @"msg":@"success",
                                  @"code":@"1",
                                  @"result":@{
                                            @"chargingTime":returnData[@"result"][@"hardwareParameters"][@"chargingTime"]
                                          },
                                  };
            if (sucBlock) {
                sucBlock(dic);
            }
        } failedBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readLastChargingTimeOperation
                       resetNum:NO
                  commandString:@"b01800"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

+ (void)readUnitWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                 failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [self readConfigParamsWithSucBlock:^(id returnData) {
            NSString *unit = returnData[@"result"][@"configurationParameters"][@"unit"];
            if (!mk_validStr(unit)) {
                unit = @"";
            }
            NSDictionary *dic = @{
                                  @"msg":@"success",
                                  @"code":@"1",
                                  @"result":@{
                                          @"unit":unit,
                                          },
                                  };
            sucBlock(dic);
        } failedBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readUnitDataOperation
                       resetNum:NO
                  commandString:@"aaa00700"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

+ (void)readTimeFormatWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                       failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [self readConfigParamsWithSucBlock:^(id returnData) {
            NSString *timeFormat = returnData[@"result"][@"configurationParameters"][@"timeFormat"];
            if (!mk_validStr(timeFormat)) {
                timeFormat = @"";
            }
            NSDictionary *dic = @{
                                  @"msg":@"success",
                                  @"code":@"1",
                                  @"result":@{
                                          @"timeFormat":timeFormat,
                                          },
                                  };
            sucBlock(dic);
        } failedBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readTimeFormatDataOperation
                       resetNum:NO
                  commandString:@"b00800"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

+ (void)readPalmingBrightScreenWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                                failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [self readConfigParamsWithSucBlock:^(id returnData) {
            NSDictionary *dic = @{
                                  @"isOn":returnData[@"result"][@"configurationParameters"][@"palmingBrightScreen"],
                                  @"startHour":@"",
                                  @"startMin":@"",
                                  @"endHour":@"",
                                  @"endMin":@"",
                                  };
            NSDictionary *resultDic = @{
                                        @"msg":@"success",
                                        @"code":@"1",
                                        @"result":@{
                                                @"palmingBrightScreen":dic,
                                                },
                                        };
            sucBlock(resultDic);
        } failedBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readPalmingBrightScreenOperation
                       resetNum:NO
                  commandString:@"b00d00"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

+ (void)readHeartRateAcquisitionIntervalWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                                         failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [self readConfigParamsWithSucBlock:^(id returnData) {
            NSString *interval = returnData[@"result"][@"configurationParameters"][@"heartRateAcquisitionInterval"];
            if (!mk_validStr(interval)) {
                interval = @"0";
            }
            NSDictionary *dic = @{
                                  @"msg":@"success",
                                  @"code":@"1",
                                  @"result":@{
                                          @"heartRateAcquisitionInterval":interval,
                                          },
                                  };
            sucBlock(dic);
        } failedBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readHeartRateAcquisitionIntervalOperation
                       resetNum:NO
                  commandString:@"b00b00"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

+ (void)readSedentaryRemindWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                            failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    NSString *commandString = (currentCentral.deviceType == mk_fitpolo701 ? @"b002" : @"b00400");
    [self addReadTaskWithTaskID:mk_readSedentaryRemindOperation
                       resetNum:NO
                  commandString:commandString
                       sucBlock:^(id returnData) {
                           NSDictionary *dic = [MKDeviceInterfaceAdopter conversionTimeDictionary:returnData[@"result"][@"sedentaryRemind"]];
                           NSDictionary *resultDic = @{
                                                       @"msg":@"success",
                                                       @"code":@"1",
                                                       @"result":@{
                                                               @"sedentaryRemind":dic
                                                               },
                                                       };
                           sucBlock(resultDic);
                       } failBlock:failedBlock];
}

+ (void)readAncsConnectStatusWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                              failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [self readHardwareParametersWithSucBlock:^(id returnData) {
            BOOL status = [returnData[@"result"][@"hardwareParameters"][@"ancsConnectStatus"] boolValue];
            NSDictionary *dic = @{
                                  @"msg":@"success",
                                  @"code":@"1",
                                  @"result":@{
                                          @"connectStatus":@(status),
                                          },
                                  };
            sucBlock(dic);
        } failedBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readANCSConnectStatusOperation
                       resetNum:NO
                  commandString:@"b01a00"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

+ (void)readAncsOptionsWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                        failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    NSString *commandString = (currentCentral.deviceType == mk_fitpolo701 ? @"1611" : @"b00300");
    [self addReadTaskWithTaskID:mk_readAncsOptionsOperation
                       resetNum:NO
                  commandString:commandString
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

+ (void)readAlarmClockDatasWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                            failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    __weak typeof(self) weakSelf = self;
    if (currentCentral.deviceType == mk_fitpolo701) {
        //701
        [[mk_fitpoloCentralManager sharedInstance] addNeedResetNumTaskWithTaskID:mk_readAlarmClockOperation
                                                                          number:2
                                                                     commandData:@"b001"
                                                                  characteristic:connectedPeripheral.commandSend
                                                                    successBlock:^(id returnData) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf parseClockDatas:returnData sucBlock:sucBlock];
        }
                                                                    failureBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readAlarmClockOperation
                       resetNum:YES
                  commandString:@"b00100"
                       sucBlock:^(id returnData) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf parseClockDatas:returnData sucBlock:sucBlock];
    }
                      failBlock:failedBlock];
}

+ (void)readRemindLastScreenDisplayWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                                    failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [self readConfigParamsWithSucBlock:^(id returnData) {
            BOOL palmingBrightScreen = [returnData[@"result"][@"configurationParameters"][@"remindLastScreenDisplay"] boolValue];
            
            NSDictionary *dic = @{
                                  @"msg":@"success",
                                  @"code":@"1",
                                  @"result":@{
                                          @"isOn":@(palmingBrightScreen),
                                          },
                                  };
            sucBlock(dic);
        } failedBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readRemindLastScreenDisplayOperation
                       resetNum:NO
                  commandString:@"b00a00"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

+ (void)readCustomScreenDisplayWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                                failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [self readConfigParamsWithSucBlock:^(id returnData) {
            NSDictionary *dic = @{
                                  @"msg":@"success",
                                  @"code":@"1",
                                  @"result":@{
                                          @"customScreenModel":returnData[@"result"][@"configurationParameters"][@"screenDisplayModel"],
                                          },
                                  };
            sucBlock(dic);
        } failedBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readCustomScreenDisplayOperation
                       resetNum:NO
                  commandString:@"b00900"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

#pragma mark - 701特有
+ (void)readPeripheralMemoryDataWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                                   failBlock:(mk_deviceInterfaceFailedBlock)failBlock{
    if (currentCentral.deviceType != mk_fitpolo701 && currentCentral.deviceType == mk_fitpoloUnknow) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readMemoryDataOperation
                       resetNum:NO
                  commandString:@"1600"
                       sucBlock:sucBlock
                      failBlock:failBlock];
}

+ (void)readInternalVersionWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                              failBlock:(mk_deviceInterfaceFailedBlock)failBlock{
    if (currentCentral.deviceType != mk_fitpolo701 && currentCentral.deviceType == mk_fitpoloUnknow) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readInternalVersionOperation
                       resetNum:NO
                  commandString:@"1609"
                       sucBlock:sucBlock
                      failBlock:failBlock];
}

+ (void)readConfigParamsWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                         failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType != mk_fitpolo701 && currentCentral.deviceType == mk_fitpoloUnknow) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readConfigurationParametersOperation
                       resetNum:NO
                  commandString:@"b004"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

#pragma mark - 非701特有
+ (void)readDoNotDisturbWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                         failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readDoNotDisturbTimeOperation
                       resetNum:NO
                  commandString:@"b00c00"
                       sucBlock:^(id returnData) {
                           NSDictionary *dic = [MKDeviceInterfaceAdopter conversionTimeDictionary:returnData[@"result"][@"periodTime"]];
                           NSDictionary *resultDic = @{
                                                       @"msg":@"success",
                                                       @"code":@"1",
                                                       @"result":@{
                                                               @"periodTime":dic
                                                               },
                                                       };
                           sucBlock(resultDic);
                       }
                      failBlock:failedBlock];
}

+ (void)readDialStyleWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                      failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readDialStyleOperation
                       resetNum:NO
                  commandString:@"b00f00"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

#pragma mark - ***********************706、707特有*******************************

+ (void)readDateFormatterWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                          failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock {
    if (currentCentral.deviceType == mk_fitpolo701 || currentCentral.deviceType == mk_fitpolo705) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readDateFormatterOperation
                       resetNum:NO
                  commandString:@"b01d00"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

+ (void)readVibrationIntensityOfDeviceWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                                       failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701 || currentCentral.deviceType == mk_fitpolo705) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readVibrationIntensityOfDeviceOperation
                       resetNum:NO
                  commandString:@"b01e00"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

+ (void)readDeviceScreenListWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                             failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock {
    if (currentCentral.deviceType == mk_fitpolo701 || currentCentral.deviceType == mk_fitpolo705) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readScreenListOperation
                       resetNum:NO
                  commandString:@"b01f00"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

#pragma mark -
+ (void)addReadTaskWithTaskID:(mk_taskOperationID)taskID
                     resetNum:(BOOL)resetNum
                commandString:(NSString *)commandString
                     sucBlock:(mk_communicationSuccessBlock)sucBlock
                    failBlock:(mk_communicationFailedBlock)failBlock{
    CBCharacteristic *character = (currentCentral.deviceType == mk_fitpolo701
                                   ? connectedPeripheral.commandSend
                                   : connectedPeripheral.readData);
    [currentCentral addTaskWithTaskID:taskID
                             resetNum:resetNum
                          commandData:commandString
                       characteristic:character
                         successBlock:sucBlock
                         failureBlock:failBlock];
}

#pragma mark -

+ (void)parseClockDatas:(id)returnData
               sucBlock:(mk_deviceInterfaceSucBlock)sucBlock{
    NSArray *list = [MKDeviceInterfaceAdopter parseAlarmClockList:returnData[@"result"]];
    NSDictionary *resultDic = @{@"msg":@"success",
                                @"code":@"1",
                                @"result":list,
                                };
    
    mk_fitpolo_main_safe(^{
        if (sucBlock) {
            sucBlock(resultDic);
        }
    });
}

@end
