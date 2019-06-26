//
//  mk_fitpoloCurrentParser.m
//  mk_fitpoloCentralManager
//
//  Created by aa on 2018/12/10.
//  Copyright © 2018 mk_fitpolo. All rights reserved.
//

#import "mk_fitpoloCurrentParser.h"
#import "mk_fitpoloCurrentAdopter.h"
#import "mk_fitpoloDefines.h"
#import "mk_fitpoloAdopter.h"
#import "mk_fitpoloLogManager.h"
#import "mk_fitpoloTaskIDDefines.h"

@implementation mk_fitpoloCurrentParser

+ (NSDictionary *)parseReadDataFromCharacteristic:(CBCharacteristic *)characteristic{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB0"]]) {
        //读取参数
        return [self parseReadConfigData:characteristic];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB1"]]){
        //设置数据
        return [self parseSetConfigData:characteristic];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB2"]]){
        //计步数据
        return [self parseStepData:characteristic];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB3"]]){
        //心率数据
        return [self parseHeartRateData:characteristic];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFC2"]]){
        //升级监听
        return [self parseUpdateData:characteristic];
    }
    return nil;
}

#pragma mark - data process method
+ (NSDictionary *)parseReadConfigData:(CBCharacteristic *)characteristic{
    NSData *readData = characteristic.value;
    NSString *content = [mk_fitpoloAdopter hexStringFromData:readData];
    if (!mk_validData(readData) || !mk_validStr(content) || content.length < 6) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:%@",content];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[origData] sourceInfo:mk_logDataSourceDevice];
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"b1"]) {
        //应答帧头b1
        return nil;
    }
    //数据域长度
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    NSDictionary *returnData = nil;
    mk_taskOperationID operationID = mk_defaultTaskOperationID;
    if ([function isEqualToString:@"01"] && content.length == 8) {
        //闹钟条数
        returnData = @{
                       mk_communicationDataNum:[mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)]
                       };
        operationID = mk_readAlarmClockOperation;
    }else if ([function isEqualToString:@"02"]){
        //闹钟详情数据
        NSInteger len = [mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(4, 2)];
        NSArray *clockList = [mk_fitpoloCurrentAdopter getAlarmClockDataList:[content substringWithRange:NSMakeRange(6, 2 * len)]];
        returnData = @{
                       @"clockList":clockList,
                       };
        operationID = mk_readAlarmClockOperation;
    }else if ([function isEqualToString:@"03"] && content.length == 14){
        //ancs选项
        returnData = @{
                       @"ancsOptionsModel":[mk_fitpoloCurrentAdopter fetchAncsOptionsModel:[content substringWithRange:NSMakeRange(10, 4)]],
                       };
        operationID = mk_readAncsOptionsOperation;
    }else if ([function isEqualToString:@"04"] && content.length == 16){
        //久坐提醒数据
        returnData = @{
                       @"sedentaryRemind":[mk_fitpoloCurrentAdopter getSedentaryRemindData:[content substringWithRange:NSMakeRange(6, 10)]],
                       };
        operationID = mk_readSedentaryRemindOperation;
    }else if ([function isEqualToString:@"06"] && content.length == 10){
        //运动目标
        returnData = @{
                       @"movingTarget":[mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 4)],
                       };
        operationID = mk_readMovingTargetOperation;
    }else if ([function isEqualToString:@"07"] && content.length == 8){
        //单位信息
        returnData = @{
                       @"unit":[content substringWithRange:NSMakeRange(6, 2)],
                       };
        operationID = mk_readUnitDataOperation;
    }else if ([function isEqualToString:@"08"] && content.length == 8){
        //时间进制信息
        returnData = @{
                       @"timeFormat":[content substringWithRange:NSMakeRange(6, 2)],
                       };
        operationID = mk_readTimeFormatDataOperation;
    }else if ([function isEqualToString:@"09"] && content.length == 14){
        //当前屏幕显示
        returnData = @{
                       @"customScreenModel":[mk_fitpoloCurrentAdopter fetchCustomScreenModel:[content substringWithRange:NSMakeRange(10, 4)]],
                       };
        operationID = mk_readCustomScreenDisplayOperation;
    }else if ([function isEqualToString:@"0a"] && content.length == 8){
        //显示上一次屏幕
        BOOL isOn = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
        returnData = @{
                       @"isOn":@(isOn),
                       };
        operationID = mk_readRemindLastScreenDisplayOperation;
    }else if ([function isEqualToString:@"0b"] && content.length == 8){
        //心率采集间隔
        returnData = @{
                       @"heartRateAcquisitionInterval":[mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)],
                       };
        operationID = mk_readHeartRateAcquisitionIntervalOperation;
    }else if ([function isEqualToString:@"0c"] && content.length == 16){
        //勿扰时间段
        returnData = @{
                       @"periodTime":[mk_fitpoloCurrentAdopter getSedentaryRemindData:[content substringWithRange:NSMakeRange(6, 10)]],
                       };
        operationID = mk_readDoNotDisturbTimeOperation;
    }else if ([function isEqualToString:@"0d"] && content.length == 16){
        //翻腕亮屏信息
        returnData = @{
                       @"palmingBrightScreen":[mk_fitpoloCurrentAdopter getSedentaryRemindData:[content substringWithRange:NSMakeRange(6, 10)]],
                       };
        operationID = mk_readPalmingBrightScreenOperation;
    }else if ([function isEqualToString:@"0e"] && content.length == 20){
        //个人信息
        returnData = @{
                       @"userInfo":[mk_fitpoloCurrentAdopter getUserInfo:[content substringWithRange:NSMakeRange(6, 14)]],
                       };
        operationID = mk_readUserInfoOperation;
    }else if ([function isEqualToString:@"0f"] && content.length == 8){
        //表盘样式
        returnData = @{
                       @"dialStyle":[content substringWithRange:NSMakeRange(6, 2)],
                       };
        operationID = mk_readDialStyleOperation;
    }else if ([function isEqualToString:@"10"] && content.length == 22){
        //硬件参数
        returnData = @{
                       @"hardwareParameters":[mk_fitpoloCurrentAdopter getHardwareParameters:[content substringWithRange:NSMakeRange(6, 16)]],
                       };
        operationID = mk_readHardwareParametersOperation;
    }else if ([function isEqualToString:@"11"] && content.length == 18){
        //固件版本号
        returnData = @{
                       @"firmwareVersion":[mk_fitpoloCurrentAdopter getFirmwareVersion:[content substringWithRange:NSMakeRange(6, 12)]],
                       };
        operationID = mk_readFirmwareVersionOperation;
    }else if ([function isEqualToString:@"12"] && content.length == 10){
        //睡眠概况条数
        returnData = @{
                       mk_communicationDataNum:[mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 4)]
                       };
        operationID = mk_readSleepIndexOperation;
    }else if ([function isEqualToString:@"13"] && content.length == 40){
        //睡眠概况数据
        returnData = [mk_fitpoloCurrentAdopter getSleepIndexData:[content substringWithRange:NSMakeRange(6, 34)]];
        operationID = mk_readSleepIndexOperation;
    }else if ([function isEqualToString:@"14"] && content.length == 10){
        //睡眠详情条数
        returnData = @{
                       mk_communicationDataNum:[mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 4)]
                       };
        operationID = mk_readSleepRecordOperation;
    }else if ([function isEqualToString:@"15"] && content.length >= 8){
        //睡眠详情数据
        returnData = [mk_fitpoloCurrentAdopter getSleepRecordData:[content substringWithRange:NSMakeRange(6, content.length - 6)]];
        operationID = mk_readSleepRecordOperation;
    }else if ([function isEqualToString:@"16"] && content.length == 10){
        //运动数据条数
        returnData = @{
                       mk_communicationDataNum:[mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 4)],
                       };
        operationID = mk_readSportsDataOperation;
    }else if ([function isEqualToString:@"17"] && content.length == 40){
        //运动数据
        returnData = [mk_fitpoloCurrentAdopter getSportData:[content substringWithRange:NSMakeRange(4, 36)]];
        operationID = mk_readSportsDataOperation;
    }else if ([function isEqualToString:@"18"] &&  content.length == 16){
        //上一次充电时间
        returnData = @{
                       @"chargingTime":[mk_fitpoloCurrentAdopter getLastChargingTime:[content substringWithRange:NSMakeRange(6, 10)]],
                       };
        operationID = mk_readLastChargingTimeOperation;
    }else if ([function isEqualToString:@"19"] && content.length == 8){
        //电池电量
        returnData = @{
                       @"battery":[mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)],
                       };
        operationID = mk_readBatteryOperation;
    }else if ([function isEqualToString:@"1a"] && content.length == 8){
        //手环当前ancs连接状态
        BOOL status = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
        returnData = @{
                       @"connectStatus":@(status),
                       };
        operationID = mk_readANCSConnectStatusOperation;
    }else if ([function isEqualToString:@"1d"] && content.length == 8) {
        //706手环当前日期制式
        NSString *dateFormatter = [content substringWithRange:NSMakeRange(6, 2)];
        returnData = @{
                       @"dateFormatter" : dateFormatter
                       };
        operationID = mk_readDateFormatterOperation;
    }else if ([function isEqualToString:@"1e"] && content.length == 8) {
        //706手环当前震动强度
        NSInteger value = [mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(6, 2)];
        NSString *vibrationIntensityOfDevice = [NSString stringWithFormat:@"%ld",(long)value];
        returnData = @{
                       @"vibrationIntensityOfDevice" : vibrationIntensityOfDevice,
                       };
        operationID = mk_readVibrationIntensityOfDeviceOperation;
    }else if ([function isEqualToString:@"1f"] && content.length == 40) {
        //706当前屏幕显示列表
        returnData = @{
                       @"screenList" : [mk_fitpoloCurrentAdopter fetch706CurrentScreenList:[content substringWithRange:NSMakeRange(6, 34)]],
                       };
        operationID = mk_readScreenListOperation;
    }
    return [self dataParserGetDataSuccess:returnData operationID:operationID];
}

+ (NSDictionary *)parseSetConfigData:(CBCharacteristic *)characteristic{
    NSData *readData = characteristic.value;
    NSString *content = [mk_fitpoloAdopter hexStringFromData:readData];
    NSLog(@"%@",content);
    if (!mk_validData(readData) || !mk_validStr(content) || content.length != 8) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:%@",content];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[origData] sourceInfo:mk_logDataSourceDevice];
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"b3"]) {
        //应答帧头b3
        return nil;
    }
    NSDictionary *returnData = nil;
    mk_taskOperationID operationID = mk_defaultTaskOperationID;
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    if ([function isEqualToString:@"01"]) {
        //设置闹钟组数
        operationID = mk_configAlarmClockNumbersOperation;
    }else if ([function isEqualToString:@"02"]){
        //设置闹钟数据
        operationID = mk_configAlarmClockOperation;
    }else if ([function isEqualToString:@"03"]){
        //ancs提醒
        operationID = mk_configANCSOptionsOperation;
    }else if ([function isEqualToString:@"04"]){
        //久坐提醒
        operationID = mk_configSedentaryRemindOperation;
    }else if ([function isEqualToString:@"06"]){
        //运动目标
        operationID = mk_configMovingTargetOperation;
    }else if ([function isEqualToString:@"07"]){
        //单位选择
        operationID = mk_configUnitOperation;
    }else if ([function isEqualToString:@"08"]){
        //时间进制
        operationID = mk_configTimeFormatOperation;
    }else if ([function isEqualToString:@"09"]){
        //屏幕显示
        operationID = mk_configScreenDisplayOperation;
    }else if ([function isEqualToString:@"0a"]){
        //上一次屏幕显示
        operationID = mk_remindLastScreenDisplayOperation;
    }else if ([function isEqualToString:@"0b"]){
        //心率采集间隔
        operationID = mk_configHeartRateAcquisitionIntervalOperation;
    }else if ([function isEqualToString:@"0c"]){
        //设置勿扰时段
        operationID = mk_configDoNotDisturbTimeOperation;
    }else if ([function isEqualToString:@"0d"]){
        //设置翻腕亮屏
        operationID = mk_openPalmingBrightScreenOperation;
    }else if ([function isEqualToString:@"0e"]){
        //个人信息
        operationID = mk_configUserInfoOperation;
    }else if ([function isEqualToString:@"0f"]){
        //设置时间
        operationID = mk_configDateOperation;
    }else if ([function isEqualToString:@"10"]){
        //设置表盘样式
        operationID = mk_configDialStyleOperation;
    }else if ([function isEqualToString:@"12"]){
        //关机
        operationID = mk_powerOffDeviceOperation;
    }else if ([function isEqualToString:@"13"]){
        //震动
        operationID = mk_vibrationOperation;
    }else if ([function isEqualToString:@"16"]) {
        //设置搜索手环功能
        operationID = mk_configSearchPhoneOperation;
    }else if ([function isEqualToString:@"1b"]) {
        //设置706显示语言
        operationID = mk_configLanguageOperation;
    }else if ([function isEqualToString:@"1c"]) {
        //设置706日期制式
        operationID = mk_configDateFormatterOperation;
    }else if ([function isEqualToString:@"1d"]) {
        //设置706震动强度
        operationID = mk_configVibrationIntensityOfDeviceOperation;
    }else if ([function isEqualToString:@"1e"]) {
        //设置706屏幕显示列表
        operationID = mk_configScreenListOperation;
    }else if ([function isEqualToString:@"21"]) {
        //设置706计步间隔
        operationID = mk_configStepIntervalOperation;
    }
    BOOL result = ([[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"00"]);
    returnData = @{
                   @"result":@(result),
                   };
    return [self dataParserGetDataSuccess:returnData operationID:operationID];
}

+ (NSDictionary *)parseStepData:(CBCharacteristic *)characteristic{
    NSData *readData = characteristic.value;
    NSString *content = [mk_fitpoloAdopter hexStringFromData:readData];
    if (!mk_validData(readData) || !mk_validStr(content) || content.length < 6) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:%@",content];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[origData] sourceInfo:mk_logDataSourceDevice];
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"b5"]) {
        //应答帧头b5
        return nil;
    }
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    NSDictionary *returnData = nil;
    mk_taskOperationID operationID = mk_defaultTaskOperationID;
    if ([function isEqualToString:@"01"] && content.length == 10) {
        //计步数据的条数
        returnData = @{
                       mk_communicationDataNum:[mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 4)]
                       };
        operationID = mk_readStepDataOperation;
    }else if ([function isEqualToString:@"02"] && content.length == 34){
        //计步详情
        returnData = [mk_fitpoloCurrentAdopter getStepDetailData:[content substringWithRange:NSMakeRange(6, 28)]];
        operationID = mk_readStepDataOperation;
    }else if ([function isEqualToString:@"03"] && content.length == 8){
        //计步监听状态设置
        BOOL result = ([[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"00"]);
        returnData = @{
                       @"result":@(result),
                       };
        operationID = mk_stepChangeMeterMonitoringStatusOperation;
    }else if ([function isEqualToString:@"05"] && content.length == 10) {
        //706间隔计步数据条数
        returnData = @{
                       mk_communicationDataNum:[mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 4)]
                       };
        operationID = mk_readStepIntervalDataOperation;
    }else if ([function isEqualToString:@"06"] && content.length == 36) {
        //706间隔计步数据详情
        returnData = [mk_fitpoloCurrentAdopter fetchStepIntervalData:[content substringWithRange:NSMakeRange(8, 28)]];
        operationID = mk_readStepIntervalDataOperation;
    }
    return [self dataParserGetDataSuccess:returnData operationID:operationID];
}

+ (NSDictionary *)parseHeartRateData:(CBCharacteristic *)characteristic{
    NSData *readData = characteristic.value;
    NSString *content = [mk_fitpoloAdopter hexStringFromData:readData];
    if (!mk_validData(readData) || !mk_validStr(content) || content.length < 4) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:%@",content];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[origData] sourceInfo:mk_logDataSourceDevice];
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if (![header isEqualToString:@"b7"]) {
        //应答帧头b7
        return nil;
    }
    NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
    NSDictionary *returnData = nil;
    mk_taskOperationID operationID = mk_defaultTaskOperationID;
    if ([function isEqualToString:@"01"] && content.length == 8) {
        //心率数据的条数
        returnData = @{
                       mk_communicationDataNum:[mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(4, 4)]
                       };
        operationID = mk_readHeartDataOperation;
    }else if ([function isEqualToString:@"02"] && content.length >= 16){
        //心率详情
        returnData = [mk_fitpoloCurrentAdopter getHeartRateList:[content substringWithRange:NSMakeRange(4, content.length - 4)]];
        operationID = mk_readHeartDataOperation;
    }else if ([function isEqualToString:@"04"] && content.length == 8){
        //运动心率的条数
        returnData = @{
                       mk_communicationDataNum:[mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(4, 4)]
                       };
        operationID = mk_readSportHeartDataOperation;
    }else if ([function isEqualToString:@"05"] && content.length >= 16){
        //运动心率详情
        returnData = [mk_fitpoloCurrentAdopter getHeartRateList:[content substringWithRange:NSMakeRange(4, content.length - 4)]];
        operationID = mk_readSportHeartDataOperation;
    }
    return [self dataParserGetDataSuccess:returnData operationID:operationID];
}

+ (NSDictionary *)parseUpdateData:(CBCharacteristic *)characteristic{
    NSData *readData = characteristic.value;
    NSString *content = [mk_fitpoloAdopter hexStringFromData:readData];
    if (!mk_validStr(content) || content.length != 4) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环升级数据:%@",content];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[origData] sourceInfo:mk_logDataSourceDevice];
    NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
    if ([header isEqualToString:@"96"]) {
        NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
        if ([function isEqualToString:@"28"]) {
            return [self dataParserGetDataSuccess:@{@"result":@(1)} operationID:mk_startUpdateOperation];
        }else if ([function isEqualToString:@"0a"]) {
            //恢复出厂设置
            return [self dataParserGetDataSuccess:@{@"result":@(1)} operationID:mk_clearDeviceDataOperation];
        }
    }
    return nil;
}

#pragma mark - Private method
+ (NSDictionary *)dataParserGetDataSuccess:(NSDictionary *)returnData operationID:(mk_taskOperationID)operationID{
    if (!returnData) {
        return nil;
    }
    return @{@"returnData":returnData,@"operationID":@(operationID)};
}

@end
