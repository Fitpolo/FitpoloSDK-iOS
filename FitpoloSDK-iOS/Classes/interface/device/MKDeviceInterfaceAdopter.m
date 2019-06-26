//
//  MKDeviceInterfaceAdopter.m
//  MKFitpoloDevice
//
//  Created by aa on 2018/12/19.
//  Copyright © 2018 MK. All rights reserved.
//

#import "MKDeviceInterfaceAdopter.h"

@implementation MKDeviceInterfaceAdopter

+ (NSString *)fetchAncsOptionsCommand:(id <MKANCSProtocol>)protocol{
    if (!protocol) {
        return nil;
    }
    //短信、电话、微信、qq、whatsapp、facebook、twitter、skype、snapchat、line
    unsigned long lowByte = 0;
    unsigned long highByte = 0;
    if (protocol.openSMS) lowByte |= 0x01;
    if (protocol.openPhone) lowByte |= 0x02;
    if (protocol.openWeChat) lowByte |= 0x04;
    if (protocol.openQQ) lowByte |= 0x08;
    if (protocol.openWhatsapp) lowByte |= 0x10;
    if (protocol.openFacebook) lowByte |= 0x20;
    if (protocol.openTwitter) lowByte |= 0x40;
    if (protocol.openSkype) lowByte |= 0x80;
    if (protocol.openSnapchat) highByte |= 0x01;
    if (protocol.openLine) highByte |= 0x02;
    NSString *lowString = [[NSString alloc] initWithFormat:@"%1lx",lowByte];
    if (lowString.length == 1) {
        lowString = [@"0" stringByAppendingString:lowString];
    }
    NSString *highString = [[NSString alloc] initWithFormat:@"%1lx",highByte];
    if (highString.length == 1) {
        highString = [@"0" stringByAppendingString:highString];
    }
    return [highString stringByAppendingString:lowString];
}

+ (NSDictionary *)conversionTimeDictionary:(NSDictionary *)timeDic{
    NSString *startHour = timeDic[@"startHour"];
    if (!startHour) {
        return nil;
    }
    NSString *startMin = timeDic[@"startMin"];
    if (!startMin) {
        return nil;
    }
    NSString *endHour = timeDic[@"endHour"];
    if (!endHour) {
        return nil;
    }
    NSString *endMin = timeDic[@"endMin"];
    if (!endMin) {
        return nil;
    }
    if (startHour.length == 1) {
        startHour = [@"0" stringByAppendingString:startHour];
    }
    if (startMin.length == 1) {
        startMin = [@"0" stringByAppendingString:startMin];
    }
    if (endHour.length == 1) {
        endHour = [@"0" stringByAppendingString:endHour];
    }
    if (endMin.length == 1) {
        endMin = [@"0" stringByAppendingString:endMin];
    }
    NSDictionary *resultDic = @{
                                @"startHour":startHour,
                                @"startMin":startMin,
                                @"endHour":endHour,
                                @"endMin":endMin,
                                @"isOn":timeDic[@"isOn"],
                                };
    return resultDic;
}

+ (NSArray <NSDictionary *>*)parseAlarmClockList:(NSArray <NSDictionary *>*)list{
    if (!list) {
        return nil;
    }
    if (list.count == 0) {
        return @[];
    }
    NSMutableArray *tempList = [NSMutableArray array];
    for (NSDictionary *dic in list) {
        NSArray *temp = dic[@"clockList"];
        if (mk_validArray(temp)) {
            [tempList addObjectsFromArray:temp];
        }
    }
    NSMutableArray *resultList = [NSMutableArray array];
    for (NSInteger i = 0;i < tempList.count; i ++) {
        NSDictionary *dataDic = tempList[i];
        NSString *hourString = dataDic[@"hour"];
        if (hourString.length == 1) {
            hourString = [@"0" stringByAppendingString:hourString];
        }
        NSString *minString = dataDic[@"minutes"];
        if (minString.length == 1) {
            minString = [@"0" stringByAppendingString:minString];
        }
        NSString *time = [NSString stringWithFormat:@"%@:%@",hourString,minString];
        NSDictionary *dic = @{
                              @"index":[NSString stringWithFormat:@"%ld",(long)i],
                              @"clockType":@([self fetchMKAlarmClockTypeWithType:[dataDic[@"clockType"] integerValue]]),
                              @"isOn":dataDic[@"isOn"],
                              @"statusModel":dataDic[@"statusModel"],
                              @"time":time,
                              };
        
        [resultList addObject:dic];
    }
    return [resultList copy];
}

/**
 把originalArray数组按照range进行截取，生成一个新的数组并返回该数组
 
 @param originalArray 原数组
 @param range 截取范围
 @return 截取后生成的数组
 */
+ (NSArray *)interceptionOfArray:(NSArray *)originalArray
                        subRange:(NSRange)range{
    if (!mk_validArray(originalArray)) {
        return nil;
    }
    if (range.location > originalArray.count - 1 || range.length > originalArray.count || (range.location + range.length > originalArray.count)) {
        return nil;
    }
    NSMutableArray *desArray = [NSMutableArray array];
    for (NSInteger i = 0; i < range.length; i ++) {
        [desArray addObject:originalArray[range.location + i]];
    }
    return desArray;
}

+ (NSString *)getAlarmClockType:(MKAlarmClockType)clockType{
    switch (clockType) {
        case MKAlarmClockMedicine:
            return @"00";
        case MKAlarmClockDrink:
            return @"01";
        case MKAlarmClockNormal:
            return @"03";
        case MKAlarmClockSleep:
            return @"04";
        case MKAlarmClockExcise:
            return @"05";
        case MKAlarmClockSport:
            return @"06";
    }
}

+ (NSString *)fetchAlarlClockSetInfo:(BOOL)isOn statusModel:(id <MKAlarmClockStatusProtocol>)statusModel{
    unsigned long byte = 0;
    if (statusModel.mondayIsOn) byte |= 0x01;
    if (statusModel.tuesdayIsOn) byte |= 0x02;
    if (statusModel.wednesdayIsOn) byte |= 0x04;
    if (statusModel.thursdayIsOn) byte |= 0x08;
    if (statusModel.fridayIsOn) byte |= 0x10;
    if (statusModel.saturdayIsOn) byte |= 0x20;
    if (statusModel.sundayIsOn) byte |= 0x40;
    if (isOn) byte |= 0x80;
    NSString *byteHexString = [NSString stringWithFormat:@"%1lx",byte];
    if (byteHexString.length == 1) {
        byteHexString = [@"0" stringByAppendingString:byteHexString];
    }
    return byteHexString;
}

+ (NSString *)fetch705ClockCommand:(id <MKSetAlarmClockProtocol>)model{
    NSArray *timeList = [model.time componentsSeparatedByString:@":"];
    if ([timeList[0] integerValue] < 0
        || [timeList[0] integerValue] > 23
        || [timeList[1] integerValue] < 0
        || [timeList[1] integerValue] > 59) {
        return nil;
    }
    NSString *clockType = [self getAlarmClockType:model.clockType];
    NSString *clockSetting = [self fetchAlarlClockSetInfo:model.isOn statusModel:model.clockStatusProtocol];
    NSString *hexHour = [NSString stringWithFormat:@"%1lx",(unsigned long)[timeList[0] integerValue]];
    if (hexHour.length == 1) {
        hexHour = [@"0" stringByAppendingString:hexHour];
    }
    NSString *hexMin = [NSString stringWithFormat:@"%1lx",(unsigned long)[timeList[1] integerValue]];
    if (hexMin.length == 1) {
        hexMin = [@"0" stringByAppendingString:hexMin];
    }
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@%@",clockType,clockSetting,hexHour,hexMin];
    return commandString;
}

+ (NSString *)fetch701SedentaryRemindCommand:(id <MKPeriodTimeSetProtocol>)protocol{
    NSMutableArray *tempDataList = [NSMutableArray array];
    for (NSInteger i = 0; i < 16; i ++) {
        [tempDataList addObject:@"00"];
    }
    if (protocol.isOn) {
        [tempDataList replaceObjectAtIndex:1 withObject:@"ff"];
    }
    //久坐提醒开始的时
    NSString *startHourHex = [NSString stringWithFormat:@"%1lx",(unsigned long)protocol.startHour];
    if (startHourHex.length == 1) {
        startHourHex = [@"0" stringByAppendingString:startHourHex];
    }
    [tempDataList replaceObjectAtIndex:2 withObject:startHourHex];
    //久坐提醒开始的分
    NSString *startMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)protocol.startMin];
    if (startMinHex.length == 1) {
        startMinHex = [@"0" stringByAppendingString:startMinHex];
    }
    [tempDataList replaceObjectAtIndex:3 withObject:startMinHex];
    //久坐提醒结束的时
    NSString *endHourHex = [NSString stringWithFormat:@"%1lx",(unsigned long)protocol.endHour];
    if (endHourHex.length == 1) {
        endHourHex = [@"0" stringByAppendingString:endHourHex];
    }
    [tempDataList replaceObjectAtIndex:4 withObject:endHourHex];
    //久坐提醒结束的分
    NSString *endMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)protocol.endMin];
    if (endMinHex.length == 1) {
        endMinHex = [@"0" stringByAppendingString:endMinHex];
    }
    [tempDataList replaceObjectAtIndex:5 withObject:endMinHex];
    NSString *commandString = @"2a";
    for (NSString *string in tempDataList) {
        commandString = [commandString stringByAppendingString:string];
    }
    return commandString;
}

+ (NSString *)fetch705SedentaryRemindCommand:(id <MKPeriodTimeSetProtocol>)protocol{
    //开始的时
    NSString *tempTime = [self fetchTimeString:protocol];
    NSString *status = (protocol.isOn ? @"01" : @"00");
    NSString *commandString = [NSString stringWithFormat:@"%@%@%@",@"b20405",status,tempTime];
    return commandString;
}

+ (NSString *)fetchTimeString:(id <MKPeriodTimeSetProtocol>)protocol{
    if (!protocol) {
        return @"";
    }
    if (protocol.isOn) {
        if (protocol.startHour < 0 || protocol.startHour > 23) {
            return @"";
        }
        if (protocol.startMin < 0 || protocol.startMin > 59) {
            return @"";
        }
        if (protocol.endHour < 0 || protocol.endHour > 23) {
            return @"";
        }
        if (protocol.endMin < 0 || protocol.endMin > 59) {
            return @"";
        }
    }
    NSString *startHourHex = [NSString stringWithFormat:@"%1lx",(unsigned long)protocol.startHour];
    if (startHourHex.length == 1) {
        startHourHex = [@"0" stringByAppendingString:startHourHex];
    }
    //开始的分
    NSString *startMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)protocol.startMin];
    if (startMinHex.length == 1) {
        startMinHex = [@"0" stringByAppendingString:startMinHex];
    }
    //结束的时
    NSString *endHourHex = [NSString stringWithFormat:@"%1lx",(unsigned long)protocol.endHour];
    if (endHourHex.length == 1) {
        endHourHex = [@"0" stringByAppendingString:endHourHex];
    }
    //结束的分
    NSString *endMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)protocol.endMin];
    if (endMinHex.length == 1) {
        endMinHex = [@"0" stringByAppendingString:endMinHex];
    }
    NSString *tempTime = [NSString stringWithFormat:@"%@%@%@%@",startHourHex,startMinHex,endHourHex,endMinHex];
    return tempTime;
}

+ (NSString *)fetch701ScreenDisplay:(id <MKCustomScreenDisplayProtocol>)displayModel{
    if (!displayModel) {
        return nil;
    }
    unsigned long byte = 1;
    //计步页面、心率页面、运动距离页面、卡路里页面、运动时间页面
    if (displayModel.turnOnStepPage) byte |= 0x02;
    if (displayModel.turnOnHeartRatePage) byte |= 0x04;
    if (displayModel.turnOnSportsDistancePage) byte |= 0x08;
    if (displayModel.turnOnCaloriesPage) byte |= 0x10;
    if (displayModel.turnOnSportsTimePage) byte |= 0x20;
    NSString *byteHexString = [NSString stringWithFormat:@"%1lx",byte];
    if (byteHexString.length == 1) {
        byteHexString = [@"0" stringByAppendingString:byteHexString];
    }
    return byteHexString;
}
//Bit13跑步4界面, （必须为真）,Bit12跑步3界面,Bit11跑步2界面,Bit10跑步1界面, （必须为真）,Bit9跑步入口界面,（必须为真）,Bit8睡眠界面,Bit7运动时间界面,Bit6里程界面,bit5卡路里界面,bit4 计步界面,bit3血压界面，（必须为假）,bit2心率界面，bit1时间界面，（必须为真）,bit0配对界面，（必须为真）
+ (NSString *)fetch705ScreenDisplay:(id <MKCustomScreenDisplayProtocol>)screenModel{
    unsigned long highByte = 0;
    unsigned long lowByte = 1;
    lowByte |= 0x03;
    if (screenModel.turnOnHeartRatePage) lowByte |= 0x04;
    lowByte &= 0xf7;
    if (screenModel.turnOnStepPage) lowByte |= 0x10;
    if (screenModel.turnOnCaloriesPage) lowByte |= 0x20;
    if (screenModel.turnOnSportsDistancePage) lowByte |= 0x40;
    if (screenModel.turnOnSportsTimePage) lowByte |= 0x80;
    
    if (screenModel.turnOnSleepPage) highByte |= 0x01;
    highByte |= 0x06;
    if (screenModel.turnOnSecondRunning) highByte |= 0x08;
    if (screenModel.turnOnThirdRunning) highByte |= 0x10;
    highByte |= 0x20;
    NSString *highHex = [NSString stringWithFormat:@"%1lx",highByte];
    if (highHex.length == 1) {
        highHex = [@"0" stringByAppendingString:highHex];
    }
    NSString *lowHex = [NSString stringWithFormat:@"%1lx",lowByte];
    if (lowHex.length == 1) {
        lowHex = [@"0" stringByAppendingString:lowHex];
    }
    return [highHex stringByAppendingString:lowHex];
}

+ (NSString *)fetchDialStyle:(mk_fitpoloDialStyle)style {
    switch (style) {
        case mk_fitpoloDialStyle1:
            return @"01";
        case mk_fitpoloDialStyle2:
            return @"02";
        case mk_fitpoloDialStyle3:
            return @"03";
        case mk_fitpoloDialStyle4:
            return @"04";
        case mk_fitpoloDialStyle5:
            return @"05";
        case mk_fitpoloDialStyle6:
            return @"06";
        case mk_fitpoloDialStyle7:
            return @"07";
        case mk_fitpoloDialStyle8:
            return @"08";
    }
}

#pragma mark - private method
+ (MKAlarmClockType)fetchMKAlarmClockTypeWithType:(mk_alarmClockType)type{
    switch (type) {
        case mk_alarmClockMedicine:
            return MKAlarmClockMedicine;
        case mk_alarmClockDrink:
            return MKAlarmClockDrink;
        case mk_alarmClockNormal:
            return MKAlarmClockNormal;
        case mk_alarmClockSleep:
            return MKAlarmClockSleep;
        case mk_alarmClockExcise:
            return MKAlarmClockExcise;
        case mk_alarmClockSport:
            return MKAlarmClockSport;
    }
}

@end
