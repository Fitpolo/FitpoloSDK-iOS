//
//  mk_fitpolo701Parser.m
//  mk_fitpoloCentralManager
//
//  Created by aa on 2018/12/10.
//  Copyright © 2018 mk_fitpolo. All rights reserved.
//

#import "mk_fitpolo701Parser.h"
#import "mk_fitpolo701Adopter.h"
#import "mk_fitpoloDefines.h"
#import "mk_fitpoloAdopter.h"
#import "mk_fitpoloLogManager.h"
#import "mk_fitpoloTaskIDDefines.h"

@implementation mk_fitpolo701Parser

#pragma mark - data process method
+ (NSDictionary *)parse96HeaderData:(NSString *)content{
    if (!mk_validStr(content) || (content.length != 2 && content.length != 8)) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:96%@",content];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[origData] sourceInfo:mk_logDataSourceDevice];
    NSString *function = [content substringWithRange:NSMakeRange(0, 2)];
    mk_taskOperationID operationID = mk_defaultTaskOperationID;
    NSDictionary *result = @{@"result":@(YES)};
    if ([function isEqualToString:@"17"] && content.length == 2) {
        //震动
        operationID = mk_vibrationOperation;
    }else if ([function isEqualToString:@"23"] && content.length == 2){
        //单位进制切换
        operationID = mk_configUnitOperation;
    }else if ([function isEqualToString:@"0f"] && content.length == 2){
        //开启ancs
        operationID = mk_openANCSOperation;
    }else if ([function isEqualToString:@"10"] && content.length == 2){
        //设置ancs提醒选项
        operationID = mk_configANCSOptionsOperation;
    }else if ([function isEqualToString:@"11"] && content.length == 2){
        //设置日期
        operationID = mk_configDateOperation;
    }else if ([function isEqualToString:@"12"] && content.length == 2){
        //设置个人信息
        operationID = mk_configUserInfoOperation;
    }else if ([function isEqualToString:@"24"] && content.length == 2){
        //设置时间进制
        operationID = mk_configTimeFormatOperation;
    }else if ([function isEqualToString:@"25"] && content.length == 2){
        //设置翻腕亮屏
        operationID = mk_openPalmingBrightScreenOperation;
    }else if ([function isEqualToString:@"26"] && content.length == 2){
        //设置闹钟
        operationID = mk_configAlarmClockOperation;
    }else if ([function isEqualToString:@"27"] && content.length == 2){
        //设置记住上一次屏幕显示
        operationID = mk_remindLastScreenDisplayOperation;
    }else if ([function isEqualToString:@"28"] && content.length == 2){
        //开启升级
        operationID = mk_startUpdateOperation;
    }else if ([function isEqualToString:@"2a"] && content.length == 2){
        //设置久坐提醒
        operationID = mk_configSedentaryRemindOperation;
    }else if ([function isEqualToString:@"0c"] && content.length == 2){
        //关机
        operationID = mk_powerOffDeviceOperation;
    }else if ([function isEqualToString:@"0c"] && content.length == 2){
        //恢复出厂设置
        operationID = mk_clearDeviceDataOperation;
    }else if ([function isEqualToString:@"09"] && content.length == 8){
        //内部版本号
        operationID = mk_readInternalVersionOperation;
        result = @{
                   @"internalVersion":[content substringWithRange:NSMakeRange(2, 6)],
                   };
    }
    return [self dataParserGetDataSuccess:result operationID:operationID];
}

+ (NSDictionary *)parseA5HeaderData:(NSString *)content{
    if (!mk_validStr(content) || (content.length != 2 && content.length != 38 && content.length != 10)) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:a5%@",content];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[origData] sourceInfo:mk_logDataSourceDevice];
    NSString *function = [content substringWithRange:NSMakeRange(0, 2)];
    mk_taskOperationID operationID = mk_defaultTaskOperationID;
    NSDictionary *result = @{@"result":@(YES)};
    if ([function isEqualToString:@"17"] && content.length == 2) {
        //设置心率采集间隔
        operationID = mk_configHeartRateAcquisitionIntervalOperation;
    }else if ([function isEqualToString:@"19"] && content.length == 2){
        //设置屏幕显示
        operationID = mk_configScreenDisplayOperation;
    }else if ([function isEqualToString:@"16"] && content.length == 2){
        //关闭ancs
    }else if ([function isEqualToString:@"22"] && content.length == 38){
        //硬件参数
        operationID = mk_readHardwareParametersOperation;
        result = @{
                   @"hardwareParameters":[mk_fitpolo701Adopter getHardwareParameters:content],
                   };
    }else if ([function isEqualToString:@"11"] && content.length == 10){
        //ancs选项
        operationID = mk_readAncsOptionsOperation;
        result = @{
                   @"ancsOptionsModel":[mk_fitpolo701Adopter getAncsOptions:content],
                   };
    }
    return [self dataParserGetDataSuccess:result operationID:operationID];
}

+ (NSDictionary *)parse91HeaderData:(NSString *)content{
    if (!mk_validStr(content) || content.length != 6) {
        return nil;
    }
    return [self dataParserGetDataSuccess:[mk_fitpolo701Adopter getMemoryData:content] operationID:mk_readMemoryDataOperation];
}

+ (NSDictionary *)parse92HeaderData:(NSString *)content{
    if (!mk_validStr(content) || content.length != 28) {
        return nil;
    }
    return [self dataParserGetDataSuccess:[mk_fitpolo701Adopter getStepData:content] operationID:mk_readStepDataOperation];
}

+ (NSDictionary *)parse93HeaderData:(NSString *)content{
    if (!mk_validStr(content) || content.length != 34) {
        return nil;
    }
    return [self dataParserGetDataSuccess:[mk_fitpolo701Adopter getSleepIndexData:content] operationID:mk_readSleepIndexOperation];
}

+ (NSDictionary *)parse94HeaderData:(NSString *)content{
    if (!mk_validStr(content) || content.length < 8) {
        return nil;
    }
    return [self dataParserGetDataSuccess:[mk_fitpolo701Adopter getSleepRecordData:content] operationID:mk_readSleepRecordOperation];
}

+ (NSDictionary *)parseA8HeaderData:(NSString *)content{
    if (!mk_validStr(content) || content.length != 38) {
        return nil;
    }
    NSDictionary *dic = @{
                          @"heartList":[mk_fitpolo701Adopter getHeartRateData:[content substringWithRange:NSMakeRange(2, 36)]]
                          };
    return [self dataParserGetDataSuccess:dic operationID:mk_readHeartDataOperation];
}

+ (NSDictionary *)parse90HeaderData:(NSString *)content{
    if (!mk_validStr(content) || content.length != 6) {
        return nil;
    }
    return [self dataParserGetDataSuccess:[mk_fitpolo701Adopter getFirmwareVersion:content] operationID:mk_readFirmwareVersionOperation];
}

+ (NSDictionary *)parseAAHeaderData:(NSString *)content{
    if (!mk_validStr(content) || content.length != 4) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环最新数据数据:aa%@",content];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[origData] sourceInfo:mk_logDataSourceDevice];
    NSString *function = [content substringWithRange:NSMakeRange(0, 2)];
    NSDictionary *dic = @{
                          mk_communicationDataNum:[mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(2, 2)]
                          };
    mk_taskOperationID operationID = mk_defaultTaskOperationID;
    NSString *msgInfo = @"";
    if ([function isEqualToString:@"92"]) {
        operationID = mk_readStepDataOperation;
        msgInfo = @"最新计步数据";
    }else if ([function isEqualToString:@"93"]){
        operationID = mk_readSleepIndexOperation;
        msgInfo = @"最新睡眠index数据";
    }else if ([function isEqualToString:@"94"]){
        operationID = mk_readSleepRecordOperation;
        msgInfo = @"最新睡眠record数据";
    }else if ([function isEqualToString:@"a8"]){
        operationID = mk_readHeartDataOperation;
        msgInfo = @"最新心率数据";
    }
    NSString *tempString = [NSString stringWithFormat:@"%@%@条",msgInfo,[mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(2, 2)]];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[tempString] sourceInfo:mk_logDataSourceDevice];
    return [self dataParserGetDataSuccess:dic operationID:operationID];
}

+ (NSDictionary *)parseB1HeaderData:(NSString *)content{
    if (!mk_validStr(content) || content.length < 4) {
        return nil;
    }
    NSString *origData = [NSString stringWithFormat:@"手环返回数据:b1%@",content];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[origData] sourceInfo:mk_logDataSourceDevice];
    NSString *funtion = [content substringWithRange:NSMakeRange(0, 2)];
    mk_taskOperationID operationID = mk_defaultTaskOperationID;
    NSDictionary *dic = nil;
    if ([funtion isEqualToString:@"01"] && content.length == 36) {
        //闹钟数据
        operationID = mk_readAlarmClockOperation;
        dic = @{
                @"clockList":[mk_fitpolo701Adopter getAlarmClockList:[content substringWithRange:NSMakeRange(4, 32)]]
                };
    }else if ([funtion isEqualToString:@"02"] && content.length == 14){
        //久坐提醒
        operationID = mk_readSedentaryRemindOperation;
        dic = @{
                @"sedentaryRemind":[mk_fitpolo701Adopter getSedentaryRemindData:[content substringWithRange:NSMakeRange(4, 10)]]
                };
    }else if ([funtion isEqualToString:@"04"] && content.length == 16){
        //配置参数
        operationID = mk_readConfigurationParametersOperation;
        dic = @{
                @"configurationParameters":[mk_fitpolo701Adopter getConfigurationParameters:[content substringWithRange:NSMakeRange(4, 12)]]
                };
    }
    return [self dataParserGetDataSuccess:dic operationID:operationID];
}

#pragma mark - Private method
+ (NSDictionary *)dataParserGetDataSuccess:(NSDictionary *)returnData operationID:(mk_taskOperationID)operationID{
    if (!returnData) {
        return nil;
    }
    return @{@"returnData":returnData,@"operationID":@(operationID)};
}

#pragma mark - Public method

+ (NSDictionary *)parseReadData:(CBCharacteristic *)characteristic{
    NSString *readData = [mk_fitpoloAdopter hexStringFromData:characteristic.value];
    if (!mk_validStr(readData) || readData.length < 4) {
        return nil;
    }
    NSString *header = [readData substringWithRange:NSMakeRange(0, 2)];
    if ([header isEqualToString:@"96"]) {
        return [self parse96HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"a5"]){
        return [self parseA5HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"91"]){
        return [self parse91HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"92"]){
        return [self parse92HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"93"]){
        return [self parse93HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"94"]){
        return [self parse94HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"a8"]){
        return [self parseA8HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"90"]){
        return [self parse90HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"aa"]){
        return [self parseAAHeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }else if ([header isEqualToString:@"b1"]){
        return [self parseB1HeaderData:[readData substringWithRange:NSMakeRange(2, readData.length - 2)]];
    }
    return nil;
}

@end
