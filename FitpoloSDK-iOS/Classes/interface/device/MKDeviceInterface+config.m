//
//  MKDeviceInterface+config.m
//  MKFitpoloDevice
//
//  Created by aa on 2018/12/19.
//  Copyright © 2018 MK. All rights reserved.
//

#import "MKDeviceInterface+config.h"
#import "mk_fitpoloDefines.h"
#import "mk_fitpoloCentralManager.h"
#import "MKDeviceInterfaceAdopter.h"
#import "mk_fitpoloAdopter.h"
#import "CBPeripheral+mk_fitpolo701.h"
#import "CBPeripheral+mk_fitpoloCurrent.h"

typedef NS_ENUM(NSInteger, mk_alarmClockIndex) {
    mk_alarmClockIndexFirst,         //第一组闹钟
    mk_alarmClockIndexSecond,        //第二组闹钟
};

#define connectedPeripheral (currentCentral.connectedPeripheral)
#define currentCentral ([mk_fitpoloCentralManager sharedInstance])

@implementation MKDeviceInterface (config)

#pragma mark - normal

+ (void)searchDeviceWithCount:(NSInteger)count
                     sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                  failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (count < 1 || count > 20) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *countString = [NSString stringWithFormat:@"%ld",(long)count];
    if (countString.length == 1) {
        countString = [@"0" stringByAppendingString:countString];
    }
    NSString *commandString = @"";
    if (currentCentral.deviceType == mk_fitpolo701) {
        commandString = [NSString stringWithFormat:@"%@%@%@",@"1702",countString,@"0a0a"];
    }else {
        commandString = [NSString stringWithFormat:@"%@%@%@",@"b21303",countString,@"0a0a"];
    }
    [self addConfigTaskWithTaskID:mk_vibrationOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)configTimeFormatter:(mk_deviceTimeFormatter)formatter
                   sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    NSString *format = (formatter == mk_deviceTimeFormatter24H ? @"00" : @"01");
    NSString *commandString = @"";
    if (currentCentral.deviceType == mk_fitpolo701) {
        //701
        commandString = [@"24" stringByAppendingString:format];
    }else{
        //705、706
        commandString = [@"b20801" stringByAppendingString:format];
    }
    [self addConfigTaskWithTaskID:mk_configTimeFormatOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)configUnit:(mk_deviceUnitType)unit
          sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
       failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    NSString *unitString = (unit == mk_deviceUnitMetric ? @"00" : @"01");
    NSString *commandString = @"";
    if (currentCentral.deviceType == mk_fitpolo701) {
        //701
        commandString = [@"23" stringByAppendingString:unitString];
    }else{
        //705、706
        commandString = [@"b20701" stringByAppendingString:unitString];
    }
    [self addConfigTaskWithTaskID:mk_configUnitOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)configANCSNotice:(id <MKANCSProtocol>)protocol
                sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
             failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    NSString *options = [MKDeviceInterfaceAdopter fetchAncsOptionsCommand:protocol];
    if (!mk_validStr(options)) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (currentCentral.deviceType == mk_fitpolo701) {
        //
        __weak typeof(self) weakSelf = self;
        [self peripheralOpenAncs:^(id returnData) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            NSString *commandString = [NSString stringWithFormat:@"%@%@%@%@%@",@"16",@"10",@"00",@"00",options];
            [strongSelf addConfigTaskWithTaskID:mk_configANCSOptionsOperation
                                       resetNum:NO
                                  commandString:commandString
                                       sucBlock:sucBlock
                                    failedBlock:failedBlock];
        } failedBlock:failedBlock];
        return;
    }
    
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"b20304",@"0000",options];
    [self addConfigTaskWithTaskID:mk_configANCSOptionsOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)configAlarmClock:(NSArray <id <MKSetAlarmClockProtocol>>*)clockList
                sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
             failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [self config701AlarmClock:clockList sucBlock:sucBlock failedBlock:failedBlock];
        return;
    }
    [self config705AlarmClock:clockList sucBlock:sucBlock failedBlock:failedBlock];
}

+ (void)configSedentaryRemind:(id <MKPeriodTimeSetProtocol>)protocol
                     sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                  failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (!protocol) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (protocol.startHour < 0 || protocol.startHour > 23) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (protocol.startMin < 0 || protocol.startMin > 59) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (protocol.endHour < 0 || protocol.endHour > 23) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    if (protocol.endMin < 0 || protocol.endMin > 59) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = @"";
    if (currentCentral.deviceType == mk_fitpolo701) {
        commandString = [MKDeviceInterfaceAdopter fetch701SedentaryRemindCommand:protocol];
    }else{
        commandString = [MKDeviceInterfaceAdopter fetch705SedentaryRemindCommand:protocol];
    }
    [self addConfigTaskWithTaskID:mk_configSedentaryRemindOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)configHeartRateAcquisitionInterval:(mk_heartRateAcquisitionInterval)interval
                                  sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                               failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    NSString *commandString = @"";
    if (currentCentral.deviceType == mk_fitpolo701) {
        NSString *type = @"00";
        if (interval == mk_heartRateAcquisitionInterval10Min) {
            type = @"01";
        }else if (interval == mk_heartRateAcquisitionInterval20Min){
            type = @"02";
        }else if (interval == mk_heartRateAcquisitionInterval30Min){
            type = @"03";
        }
        commandString = [NSString stringWithFormat:@"%@%@%@%@",@"16",@"17",type,@"00"];
    }else{
        NSInteger tempInter = 0;
        if (interval == mk_heartRateAcquisitionInterval10Min) {
            tempInter = 10;
        }else if (interval == mk_heartRateAcquisitionInterval20Min){
            tempInter = 20;
        }else if (interval == mk_heartRateAcquisitionInterval30Min){
            tempInter = 30;
        }
        NSString *intervalHex = [NSString stringWithFormat:@"%1lx",(unsigned long)tempInter];
        if (intervalHex.length == 1) {
            intervalHex = [@"0" stringByAppendingString:intervalHex];
        }
        commandString = [@"b20b01" stringByAppendingString:intervalHex];
    }
    [self addConfigTaskWithTaskID:mk_configHeartRateAcquisitionIntervalOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)configPalmingBrightScreen:(id <MKPeriodTimeSetProtocol>)protocol
                         sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                      failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (!protocol) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = @"";
    NSString *state = @"00";
    if (currentCentral.deviceType == mk_fitpolo701 && !protocol.isOn) {
        state = @"01";
    }else if (currentCentral.deviceType != mk_fitpolo701 && protocol.isOn) {
        state = @"01";
    }
    if (currentCentral.deviceType == mk_fitpolo701) {
        commandString = [@"25" stringByAppendingString:state];
    }else{
        NSString *tempTime = [MKDeviceInterfaceAdopter fetchTimeString:protocol];
        if (!mk_validStr(tempTime)) {
            [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
            return;
        }
        commandString = [NSString stringWithFormat:@"%@%@%@",@"b20d05",state,tempTime];
    }
    [self addConfigTaskWithTaskID:mk_openPalmingBrightScreenOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)configRemindLastScreenDisplay:(BOOL)remind
                             sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                          failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    NSString *status = (remind ? @"01" : @"00");
    NSString *commandStirng = (currentCentral.deviceType == mk_fitpolo701 ? [@"27" stringByAppendingString:status] : [@"b20a01" stringByAppendingString:status]);
    [self addConfigTaskWithTaskID:mk_remindLastScreenDisplayOperation
                         resetNum:NO
                    commandString:commandStirng
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)configCustomScreenDisplay:(id <MKCustomScreenDisplayProtocol>)protocol
                         sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                      failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (!protocol) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *commandString = @"";
    if (currentCentral.deviceType == mk_fitpolo701) {
        NSString *screenDisplay = [MKDeviceInterfaceAdopter fetch701ScreenDisplay:protocol];
        commandString = [NSString stringWithFormat:@"%@%@%@%@",@"16",@"19",@"000000",screenDisplay];
    }else{
        NSString *screenDisplay = [MKDeviceInterfaceAdopter fetch705ScreenDisplay:protocol];
        commandString = [@"b209040000" stringByAppendingString:screenDisplay];
    }
    [self addConfigTaskWithTaskID:mk_configScreenDisplayOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)powerOffDeviceWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                       failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock {
    NSString *commandString = (currentCentral.deviceType == mk_fitpolo701 ? @"160c" : @"b21200");
    [self addConfigTaskWithTaskID:mk_powerOffDeviceOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)clearDeviceDataWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                        failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock {
    CBCharacteristic *character = (currentCentral.deviceType == mk_fitpolo701
                                   ? connectedPeripheral.commandSend
                                   : connectedPeripheral.updateWrite);
    [currentCentral addTaskWithTaskID:mk_clearDeviceDataOperation
                             resetNum:NO
                          commandData:@"160A"
                       characteristic:character
                         successBlock:^(id returnData) {
                             [mk_fitpoloAdopter operationSetParamsResult:returnData sucBlock:sucBlock failedBlock:failedBlock];
                         } failureBlock:failedBlock];
}

#pragma mark - 非701特有
+ (void)configDoNotDisturbMode:(id <MKPeriodTimeSetProtocol>)protocol
                      sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                   failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    NSString *tempTime = [MKDeviceInterfaceAdopter fetchTimeString:protocol];
    NSString *status = (protocol.isOn ? @"01" : @"00");
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"b20c05",status,tempTime];
    [self addConfigTaskWithTaskID:mk_configDoNotDisturbTimeOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)configDialStyle:(mk_fitpoloDialStyle)dialStyle
               sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
            failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    if (currentCentral.deviceType == mk_fitpolo705) {
        if (!(dialStyle == mk_fitpoloDialStyle1 || dialStyle == mk_fitpoloDialStyle2 || dialStyle == mk_fitpoloDialStyle3)) {
            [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
            return;
        }
    }
    NSString *style = [MKDeviceInterfaceAdopter fetchDialStyle:dialStyle];
    NSString *commandString = [@"b21001" stringByAppendingString:style];
    [self addConfigTaskWithTaskID:mk_configDialStyleOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

#pragma mark - 706、707特有

+ (void)configLanguage:(mk_languageStyle)style
              sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
           failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701 || currentCentral.deviceType == mk_fitpolo705) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    NSString *language = (style == mk_languageChineseStyle ? @"00" : @"01");
    NSString *commandString = [@"b21b01" stringByAppendingString:language];
    [self addConfigTaskWithTaskID:mk_configLanguageOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)configDateFormatter:(mk_dateFormatter)formatter
                   sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701 || currentCentral.deviceType == mk_fitpolo705) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    NSString *style = (formatter == mk_dateFormatterDY ? @"00" : @"01");
    NSString *commandString = [@"b21c01" stringByAppendingString:style];
    [self addConfigTaskWithTaskID:mk_configDateFormatterOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)configVibrationIntensityOfDevice:(NSInteger)power
                                sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                             failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (currentCentral.deviceType == mk_fitpolo701 || currentCentral.deviceType == mk_fitpolo705) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    if (power < 1 || power > 9) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSString *temp = [NSString stringWithFormat:@"%1lx",(unsigned long)power];
    if (temp.length == 1) {
        temp = [@"0" stringByAppendingString:temp];
    }
    NSString *commandString = [@"b21d01" stringByAppendingString:temp];
    [self addConfigTaskWithTaskID:mk_configVibrationIntensityOfDeviceOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

+ (void)configScreenList:(NSArray <NSString *>*)screenList
                sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
             failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock {
    if (currentCentral.deviceType == mk_fitpolo701 || currentCentral.deviceType == mk_fitpolo705) {
        [mk_fitpoloAdopter operationUnsupportCommandErrorBlock:failedBlock];
        return;
    }
    NSString *lengthValue = [NSString stringWithFormat:@"%1lx",(unsigned long)[screenList count]];
    if (lengthValue.length == 1) {
        lengthValue = [@"0" stringByAppendingString:lengthValue];
    }
    NSString *screenSetting = @"";
    for (NSInteger i = 0; i < screenList.count; i ++) {
        screenSetting = [screenSetting stringByAppendingString:screenList[i]];
    }
    NSInteger tempCount = 32 - screenSetting.length;
    for (NSInteger i = 0; i < tempCount; i ++) {
        screenSetting = [screenSetting stringByAppendingString:@"0"];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"b21e11",lengthValue,screenSetting];
    [self addConfigTaskWithTaskID:mk_configScreenListOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:sucBlock
                      failedBlock:failedBlock];
}

#pragma mark - private method

+ (void)addConfigTaskWithTaskID:(mk_taskOperationID)taskID
                       resetNum:(BOOL)resetNum
                  commandString:(NSString *)commandString
                       sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                    failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
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

+ (void)peripheralOpenAncs:(mk_deviceInterfaceSucBlock)successBlock
               failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    [self addConfigTaskWithTaskID:mk_openANCSOperation
                         resetNum:NO
                    commandString:@"160f"
                         sucBlock:successBlock
                      failedBlock:failedBlock];
}

#pragma mark - 701闹钟

+ (void)config701AlarmClock:(NSArray <id <MKSetAlarmClockProtocol>>*)list
                   sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    NSArray *firstList = nil;
    NSArray *secList = nil;
    if (!mk_validArray(list)) {
        //关闭全部闹钟
    }else if (list.count <= 4){
        //一组闹钟
        firstList = list;
    }else if (list.count > 4 && list.count <= 8){
        //两组闹钟
        firstList = [MKDeviceInterfaceAdopter interceptionOfArray:list subRange:NSMakeRange(0, 4)];
        secList = [MKDeviceInterfaceAdopter interceptionOfArray:list subRange:NSMakeRange(4, list.count - 4)];
    }else{
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self peripheralSet701AlarmClock:mk_alarmClockIndexFirst
                      alarmClockList:firstList
                            sucBlock:^(id returnData) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf peripheralSet701AlarmClock:mk_alarmClockIndexSecond
                                alarmClockList:secList
                                      sucBlock:sucBlock
                                     failBlock:failedBlock];
    }
                           failBlock:failedBlock];
}

/**
 设置闹钟(701)
 
 @param index 闹钟组别
 @param list 闹钟数据,最多4个,如果个数少于一个或者直接nil的情况下，关闭该组别所有闹钟
 @param successBlock success callback
 @param failedBlock fail callback
 */
+ (void)peripheralSet701AlarmClock:(mk_alarmClockIndex)index
                    alarmClockList:(NSArray <id <MKSetAlarmClockProtocol>>*)list
                          sucBlock:(mk_deviceInterfaceSucBlock)successBlock
                         failBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    if (list.count > 4) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSInteger i = 0; i < 16; i ++) {
        [tempArray addObject:@"00"];
    }
    for (NSInteger i = 0; i < list.count; i ++) {
        id <MKSetAlarmClockProtocol>clockModel = list[i];
        NSArray *timeList = [clockModel.time componentsSeparatedByString:@":"];
        if ([timeList[0] integerValue] < 0 || [timeList[0] integerValue] > 23) {
            [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
            return;
        }
        if ([timeList[1] integerValue] < 0 || [timeList[1] integerValue] > 59) {
            [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
            return;
        }
        NSString *clockType = [MKDeviceInterfaceAdopter getAlarmClockType:clockModel.clockType];
        [tempArray replaceObjectAtIndex:i * 4 withObject:clockType];
        NSString *clockSetting = [MKDeviceInterfaceAdopter fetchAlarlClockSetInfo:clockModel.isOn statusModel:clockModel.clockStatusProtocol];
        [tempArray replaceObjectAtIndex:(i * 4 + 1) withObject:clockSetting];
        NSString *hexHour = [NSString stringWithFormat:@"%1lx",(unsigned long)[timeList[0] integerValue]];
        if (hexHour.length == 1) {
            hexHour = [@"0" stringByAppendingString:hexHour];
        }
        [tempArray replaceObjectAtIndex:(i * 4 + 2) withObject:hexHour];
        NSString *hexMin = [NSString stringWithFormat:@"%1lx",(unsigned long)[timeList[1] integerValue]];
        if (hexMin.length == 1) {
            hexMin = [@"0" stringByAppendingString:hexMin];
        }
        [tempArray replaceObjectAtIndex:(i * 4 + 3) withObject:hexMin];
    }
    NSString *indexString = (index == mk_alarmClockIndexFirst ? @"00" : @"01");
    NSString *commandString = [@"26" stringByAppendingString:indexString];
    for (NSString *string in tempArray) {
        commandString = [commandString stringByAppendingString:string];
    }
    [self addConfigTaskWithTaskID:mk_configAlarmClockOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:successBlock
                      failedBlock:failedBlock];
}

#pragma mark - 705、706闹钟

+ (void)config705AlarmClock:(NSArray <id <MKSetAlarmClockProtocol>>*)list
                   sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock{
    dispatch_async(dispatch_queue_create("com.moko.deviceModuleConfigClockQueue", 0), ^{
        if (list.count > 8) {
            //报错
            [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
            return;
        }
        //默认关闭
        NSInteger numbers = 0;
        if (list.count > 0 && list.count <= 4) {
            //一组
            numbers = 1;
        }else if (list.count > 4 && list.count <= 8){
            //e两组
            numbers = 2;
        }
        BOOL success = [self setClockTotalNumbersToPeripheral:numbers];
        if (!success) {
            [mk_fitpoloAdopter operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        if (numbers == 0) {
            //关闭全部闹钟
            [self operationClockSucBlock:sucBlock];
            return;
        }
        NSArray *tempList1 = (numbers == 1 ? list : [MKDeviceInterfaceAdopter interceptionOfArray:list subRange:NSMakeRange(0, 4)]);
        BOOL setResult = [self setClockDatasToPeripheral:tempList1];
        if (!setResult) {
            [mk_fitpoloAdopter operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        if (numbers == 1) {
            //一组设置成功
            [self operationClockSucBlock:sucBlock];
            return;
        }
        //两组
        NSArray *tempList2 = [MKDeviceInterfaceAdopter interceptionOfArray:list subRange:NSMakeRange(4, list.count - 4)];
        BOOL result = [self setClockDatasToPeripheral:tempList2];
        if (!result) {
            [mk_fitpoloAdopter operationSetParamsErrorBlock:failedBlock];
            return ;
        }
        //两组设置成功
        [self operationClockSucBlock:sucBlock];
    });
}

/**
 发送闹钟组数(705、706)
 
 @param numbers 组数，最多2组
 */
+ (BOOL)setClockTotalNumbersToPeripheral:(NSInteger)numbers{
    if (numbers > 2 || numbers < 0) {
        return NO;
    }
    NSString *numbersHex = [NSString stringWithFormat:@"%1lx",(long)numbers];
    if (numbersHex.length == 1) {
        numbersHex = [@"0" stringByAppendingString:numbersHex];
    }
    NSString *commandString = [@"b20101" stringByAppendingString:numbersHex];
    __block BOOL success = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self addConfigTaskWithTaskID:mk_configAlarmClockNumbersOperation
                         resetNum:NO
                    commandString:commandString
                         sucBlock:^(id returnData) {
                             success = YES;
                             dispatch_semaphore_signal(semaphore);
                         } failedBlock:^(NSError *error) {
                             success = NO;
                             dispatch_semaphore_signal(semaphore);
                         }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

+ (BOOL)setClockDatasToPeripheral:(NSArray <id <MKSetAlarmClockProtocol>>*)list{
    if (!mk_validArray(list)) {
        return NO;
    }
    NSString *clockDatas = @"";
    for (NSInteger i = 0; i < list.count; i ++) {
        NSString *command = [MKDeviceInterfaceAdopter fetch705ClockCommand:list[i]];
        if (!mk_validStr(command)) {
            return NO;
        }
        clockDatas = [clockDatas stringByAppendingString:command];
    }
    NSString *lenHex = [NSString stringWithFormat:@"%1lx",(unsigned long)(clockDatas.length / 2)];
    if (lenHex.length == 1) {
        lenHex = [@"0" stringByAppendingString:lenHex];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"b202",lenHex,clockDatas];
    __block BOOL success = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self addConfigTaskWithTaskID:mk_configAlarmClockOperation resetNum:NO commandString:commandString sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(semaphore);
    } failedBlock:^(NSError *error) {
        success = NO;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

+ (void)operationClockSucBlock:(mk_deviceInterfaceSucBlock)sucBlock{
    NSDictionary *dic = @{
                          @"msg":@"success",
                          @"code":@"1",
                          @"result":@{},
                          };
    if (sucBlock) {
        mk_fitpolo_main_safe(^{
            sucBlock(dic);
        });
    }
}

@end
