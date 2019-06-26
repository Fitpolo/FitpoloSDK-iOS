//
//  MKUserDataInterface.m
//  MKFitpoloUserData
//
//  Created by aa on 2019/1/2.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKUserDataInterface.h"
#import "mk_fitpoloDefines.h"
#import "mk_fitpoloCentralManager.h"
#import "MKUserDataInterfaceAdopter.h"
#import "mk_fitpoloAdopter.h"
#import "CBPeripheral+mk_fitpolo701.h"
#import "CBPeripheral+mk_fitpoloCurrent.h"

#define connectedPeripheral (currentCentral.connectedPeripheral)
#define currentCentral ([mk_fitpoloCentralManager sharedInstance])

typedef NS_ENUM(NSInteger, readDataWithTimeStamp) {
    readStepDataWithTimeStamp,         //时间戳请求计步数据
    readSleepIndexDataWithTimeStamp,   //时间戳请求睡眠index数据
    readSleepRecordDataWithTimeStamp,  //时间戳请求睡眠record数据
    readHeartRateDataWithTimeStamp,    //时间戳请求心率数据
};

@implementation MKUserDataInterface

+ (void)readStepDataWithTimeStamp:(id <MKReadDeviceDataTimeProtocol>)protocol
                         sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                      failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock{
    if (![MKUserDataInterfaceAdopter validTimeProtocol:protocol]) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *hexTime = [MKUserDataInterfaceAdopter getTimeString:protocol];
    if (!mk_validStr(hexTime)) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (currentCentral.deviceType == mk_fitpolo701) {
        [self read701PeripheralData:hexTime dataType:readStepDataWithTimeStamp sucBlock:^(id returnData) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                NSArray *dataList = [MKUserDataInterfaceAdopter fetchStepModelList:returnData[@"result"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (sucBlock) {
                        sucBlock(dataList);
                    }
                });
            });
        } failBlock:failedBlock];
        return;
    }
    [self readCurrentPeripheralStepData:hexTime sucBlock:^(id returnData) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSArray *dataList = [MKUserDataInterfaceAdopter fetchStepModelList:returnData[@"result"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (sucBlock) {
                    sucBlock(dataList);
                }
            });
        });
    } failBlock:failedBlock];
}

+ (void)readSleepDataWithTimeStamp:(id <MKReadDeviceDataTimeProtocol>)protocol
                          sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                       failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock{
    if (![MKUserDataInterfaceAdopter validTimeProtocol:protocol]) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *hexTime = [MKUserDataInterfaceAdopter getTimeString:protocol];
    if (!mk_validStr(hexTime)) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    dispatch_async(dispatch_queue_create("readSleepDataQueue", DISPATCH_QUEUE_SERIAL), ^{
        NSArray *indexList = [self fetchSleepIndexData:hexTime];
        if (!indexList) {
            [mk_fitpoloAdopter operationRequestDataErrorBlock:failedBlock];
            return ;
        }
        if (indexList.count == 0) {
            mk_fitpolo_main_safe(^{
                if (sucBlock) {
                    sucBlock(@[]);
                }
            });
            return;
        }
        NSArray *recordList = [self fetchSleepRecordData:hexTime];
        if (!mk_validArray(recordList)) {
            [mk_fitpoloAdopter operationRequestDataErrorBlock:failedBlock];
            return;
        }
        NSArray *sleepList = [MKUserDataInterfaceAdopter getSleepDataList:indexList recordList:recordList];
        NSArray *dataList = [MKUserDataInterfaceAdopter fetchSleepModelList:sleepList];
        mk_fitpolo_main_safe(^{
            if (sucBlock) {
                sucBlock(dataList);
            }
        });
    });
}

+ (void)readHeartDataWithTimeStamp:(id <MKReadDeviceDataTimeProtocol>)protocol
                          sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                       failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock{
    if (![MKUserDataInterfaceAdopter validTimeProtocol:protocol]) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *hexTime = [MKUserDataInterfaceAdopter getTimeString:protocol];
    if (!mk_validStr(hexTime)) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    dispatch_async(dispatch_queue_create("readHeartRateDataQueue", 0), ^{
        NSArray *list = [self fetchHeartRate:hexTime];
        NSDictionary *dataDic = [MKUserDataInterfaceAdopter fetchHeartModelList:list];
        mk_fitpolo_main_safe(^{
            if (sucBlock) {
                sucBlock(dataDic);
            }
        });
    });
}

#pragma mark - 705、706、707

+ (void)readUserDataWithSucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                     failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readUserInfoOperation
                       resetNum:NO
                  commandString:@"b00e00"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

+ (void)readMovingTargetWithSucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                         failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    [self addReadTaskWithTaskID:mk_readMovingTargetOperation
                       resetNum:NO
                  commandString:@"b00600"
                       sucBlock:sucBlock
                      failBlock:failedBlock];
}

+ (void)readSportDataWithTimeStamp:(id <MKReadDeviceDataTimeProtocol>)protocol
                          sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                       failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock {
    if (currentCentral.deviceType == mk_fitpolo701) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    if (![MKUserDataInterfaceAdopter validTimeProtocol:protocol]) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *hexTime = [MKUserDataInterfaceAdopter getTimeString:protocol];
    if (!mk_validStr(hexTime)) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = [@"b01605" stringByAppendingString:hexTime];
    [currentCentral addNeedPartOfDataTaskWithTaskID:mk_readSportsDataOperation commandData:commandString characteristic:connectedPeripheral.readData successBlock:^(id returnData) {
        mk_fitpolo_main_safe(^{
            if (sucBlock) {
                sucBlock(returnData);
            }
        });
    } failureBlock:failedBlock];
}

+ (void)readSportHeartRateDataWithTimeStamp:(id <MKReadDeviceDataTimeProtocol>)protocol
                                   sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                                failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock {
    if (currentCentral.deviceType == mk_fitpolo701) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    if (![MKUserDataInterfaceAdopter validTimeProtocol:protocol]) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *hexTime = [MKUserDataInterfaceAdopter getTimeString:protocol];
    if (!mk_validStr(hexTime)) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = [@"b60405" stringByAppendingString:hexTime];
    [currentCentral addNeedPartOfDataTaskWithTaskID:mk_readSportHeartDataOperation commandData:commandString characteristic:connectedPeripheral.heartRate successBlock:^(id returnData) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *dataList = returnData[@"result"];
            NSMutableArray *tempList = [NSMutableArray array];
            for (NSDictionary *dic in dataList) {
                NSArray *heartList = dic[@"heartList"];
                if (mk_validArray(heartList)) {
                    [tempList addObjectsFromArray:heartList];
                }
            }
            NSDictionary *dataDic = [MKUserDataInterfaceAdopter fetchHeartModelList:tempList];
            mk_fitpolo_main_safe(^{
                if (sucBlock) {
                    sucBlock(dataDic);
                }
            });
        });
    } failureBlock:failedBlock];
}

#pragma mark - 706、707
+ (void)readStepIntervalDataWithTimeStamp:(id <MKReadDeviceDataTimeProtocol>)protocol
                                 sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                              failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock {
    if (currentCentral.deviceType == mk_fitpolo701
        || currentCentral.deviceType == mk_fitpolo705) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    if (![MKUserDataInterfaceAdopter validTimeProtocol:protocol]) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *hexTime = [MKUserDataInterfaceAdopter getTimeString:protocol];
    if (!mk_validStr(hexTime)) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@",@"b40505",hexTime];
    [currentCentral addNeedPartOfDataTaskWithTaskID:mk_readStepIntervalDataOperation
                                        commandData:commandString
                                     characteristic:connectedPeripheral.stepData
                                       successBlock:^(id returnData) {
                                           dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                               NSArray *dataList = returnData[@"result"];
                                               NSMutableArray *tempList = [NSMutableArray array];
                                               for (NSDictionary *dic in dataList) {
                                                   NSArray *stepList = dic[@"stepList"];
                                                   if (mk_validArray(stepList)) {
                                                       [tempList addObjectsFromArray:stepList];
                                                   }
                                               }
                                               mk_fitpolo_main_safe(^{
                                                   if (sucBlock) {
                                                       sucBlock(tempList);
                                                   }
                                               });
                                           });
                                       }
                                       failureBlock:failedBlock];
}

#pragma mark - private method

/**
 请求数据
 
 @param hexTime 要请求的时间点，返回的是该时间点之后的所有计步数据，
 @param dataType 请求数据类型，目前支持计步、睡眠index、睡眠record、心率
 @param successBlock success callback
 @param failedBlock fail callback
 */
+ (void)read701PeripheralData:(NSString *)hexTime
                     dataType:(readDataWithTimeStamp)dataType
                     sucBlock:(mk_userDataInterfaceSucBlock)successBlock
                    failBlock:(mk_userDataInterfaceFailedBlock)failedBlock{
    //默认是计步
    NSString *function = @"92";
    mk_taskOperationID operationID = mk_readStepDataOperation;
    if (dataType == readSleepIndexDataWithTimeStamp) {
        //睡眠index
        function = @"93";
        operationID = mk_readSleepIndexOperation;
    }else if (dataType == readSleepRecordDataWithTimeStamp){
        //睡眠record
        function = @"94";
        operationID = mk_readSleepRecordOperation;
    }else if (dataType == readHeartRateDataWithTimeStamp){
        //心率
        function = @"a8";
        operationID = mk_readHeartDataOperation;
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"2c",hexTime,function];
    [currentCentral addNeedPartOfDataTaskWithTaskID:operationID
                                        commandData:commandString
                                     characteristic:connectedPeripheral.commandSend
                                       successBlock:successBlock
                                       failureBlock:failedBlock];
}

/**
 请求数据
 
 @param hexTime 要请求的时间点，返回的是该时间点之后的所有计步数据，
 @param successBlock success callback
 @param failedBlock fail callback
 */
+ (void)readCurrentPeripheralStepData:(NSString *)hexTime
                             sucBlock:(mk_userDataInterfaceSucBlock)successBlock
                            failBlock:(mk_userDataInterfaceFailedBlock)failedBlock{
    NSString *commandString = [NSString stringWithFormat:@"%@%@",@"b40105",hexTime];
    [currentCentral addNeedPartOfDataTaskWithTaskID:mk_readStepDataOperation
                                        commandData:commandString
                                     characteristic:connectedPeripheral.stepData
                                       successBlock:successBlock
                                       failureBlock:failedBlock];
}

+ (NSArray *)fetchSleepIndexData:(NSString *)hexTime{
    __block NSArray *resultList = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    if (currentCentral.deviceType == mk_fitpolo701) {
        [self read701PeripheralData:hexTime dataType:readSleepIndexDataWithTimeStamp sucBlock:^(id returnData) {
            resultList = returnData[@"result"];
            dispatch_semaphore_signal(semaphore);
        } failBlock:^(NSError *error) {
            dispatch_semaphore_signal(semaphore);
        }];
    }else{
        NSString *commandString = [NSString stringWithFormat:@"%@%@",@"b01205",hexTime];
        [currentCentral addNeedPartOfDataTaskWithTaskID:mk_readSleepIndexOperation
                                            commandData:commandString
                                         characteristic:connectedPeripheral.readData
                                           successBlock:^(id returnData) {
                                               resultList = returnData[@"result"];
                                               dispatch_semaphore_signal(semaphore);
                                           } failureBlock:^(NSError *error) {
                                               dispatch_semaphore_signal(semaphore);
                                           }];
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return resultList;
}

+ (NSArray *)fetchSleepRecordData:(NSString *)hexTime{
    __block NSArray *resultList = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    if (currentCentral.deviceType == mk_fitpolo701) {
        [self read701PeripheralData:hexTime dataType:readSleepRecordDataWithTimeStamp sucBlock:^(id returnData) {
            resultList = returnData[@"result"];
            dispatch_semaphore_signal(semaphore);
        } failBlock:^(NSError *error) {
            dispatch_semaphore_signal(semaphore);
        }];
    }else{
        NSString *commandString = [NSString stringWithFormat:@"%@%@",@"b01405",hexTime];
        [currentCentral addNeedPartOfDataTaskWithTaskID:mk_readSleepRecordOperation
                                            commandData:commandString
                                         characteristic:connectedPeripheral.readData
                                           successBlock:^(id returnData) {
                                               resultList = returnData[@"result"];
                                               dispatch_semaphore_signal(semaphore);
                                           } failureBlock:^(NSError *error) {
                                               dispatch_semaphore_signal(semaphore);
                                           }];
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return resultList;
}

+ (NSArray *)fetchHeartRate:(NSString *)hexTime{
    __block NSArray *resultList = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    if (currentCentral.deviceType == mk_fitpolo701) {
        [self read701PeripheralData:hexTime dataType:readHeartRateDataWithTimeStamp sucBlock:^(id returnData) {
            NSArray *dataList = returnData[@"result"];
            NSMutableArray *tempList = [NSMutableArray array];
            for (NSDictionary *dic in dataList) {
                NSArray *heartList = dic[@"heartList"];
                if (mk_validArray(heartList)) {
                    [tempList addObjectsFromArray:heartList];
                }
            }
            resultList = [tempList copy];
            dispatch_semaphore_signal(semaphore);
        } failBlock:^(NSError *error) {
            dispatch_semaphore_signal(semaphore);
        }];
    }else{
        NSString *commandString = [NSString stringWithFormat:@"%@%@",@"b60105",hexTime];
        [currentCentral addNeedPartOfDataTaskWithTaskID:mk_readHeartDataOperation
                                            commandData:commandString
                                         characteristic:connectedPeripheral.heartRate
                                           successBlock:^(id returnData) {
                                               NSArray *dataList = returnData[@"result"];
                                               NSMutableArray *tempList = [NSMutableArray array];
                                               for (NSDictionary *dic in dataList) {
                                                   NSArray *heartList = dic[@"heartList"];
                                                   if (mk_validArray(heartList)) {
                                                       [tempList addObjectsFromArray:heartList];
                                                   }
                                               }
                                               resultList = [tempList copy];
                                               dispatch_semaphore_signal(semaphore);
                                           } failureBlock:^(NSError *error) {
                                               dispatch_semaphore_signal(semaphore);
                                           }];
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return resultList;
}

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

@end
