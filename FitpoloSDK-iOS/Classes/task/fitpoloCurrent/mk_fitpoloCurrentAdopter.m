//
//  mk_fitpoloCurrentAdopter.m
//  mk_fitpoloCentralManager
//
//  Created by aa on 2018/12/10.
//  Copyright © 2018 mk_fitpolo. All rights reserved.
//

#import "mk_fitpoloCurrentAdopter.h"
#import "mk_fitpoloDefines.h"
#import "mk_fitpoloAdopter.h"
#import "mk_fitpoloLogManager.h"

@implementation mk_fitpoloCurrentAdopter

+ (NSArray <NSDictionary *>*)getAlarmClockDataList:(NSString *)content{
    NSMutableArray *list = [NSMutableArray array];
    for (NSInteger i = 0; i < content.length / 8; i ++) {
        NSString *subContent = [content substringWithRange:NSMakeRange(i * 8, 8)];
        NSDictionary *tempDataDic = [self getClockStatusModelWithString:[subContent substringWithRange:NSMakeRange(2, 2)]];
        NSDictionary *dic = @{
                              @"clockType":@([self getClockTypeWithString:[subContent substringWithRange:NSMakeRange(0, 2)]]),
                              @"statusModel":tempDataDic[@"statusModel"],
                              @"isOn":tempDataDic[@"isOn"],
                              @"hour":[mk_fitpoloAdopter getDecimalStringWithHex:subContent range:NSMakeRange(4, 2)],
                              @"minutes":[mk_fitpoloAdopter getDecimalStringWithHex:subContent range:NSMakeRange(6, 2)],
                              };
        [list addObject:dic];
    }
    return [list mutableCopy];
}

+ (NSDictionary *)fetchAncsOptionsModel:(NSString *)content{
    NSInteger high = [mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(0, 2)];
    NSInteger low = [mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(2, 2)];
    
    //短信、电话、微信、、、、、、
    return @{
             @"openSnapchat":@((high & 0x01) == 0x01),
             @"openLine":@((high & 0x02) == 0x02),
             @"openSkype":@((low & 0x80) == 0x80),
             @"openTwitter":@((low & 0x40) == 0x40),
             @"openFacebook":@((low & 0x20) == 0x20),
             @"openWhatsapp":@((low & 0x10) == 0x10),
             @"openQQ":@((low & 0x08) == 0x08),
             @"openWeChat":@((low & 0x04) == 0x04),
             @"openPhone":@((low & 0x02) == 0x02),
             @"openSMS":@((low & 0x01) == 0x01)
             };
}

+ (NSDictionary *)getSedentaryRemindData:(NSString *)content{
    BOOL isOn = [[content substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"01"];
    NSString *startHour = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(2, 2)];
    NSString *startMin = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(4, 2)];
    NSString *endHour = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
    NSString *endMin = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 2)];
    return @{
             @"isOn":@(isOn),
             @"startHour":startHour,
             @"startMin":startMin,
             @"endHour":endHour,
             @"endMin":endMin,
             };
}

//Bit13跑步4界面, （必须为真）,Bit12跑步3界面,Bit11跑步2界面,Bit10跑步1界面, （必须为真）,Bit9跑步入口界面,（必须为真）,Bit8睡眠界面,Bit7运动时间界面,Bit6里程界面,bit5卡路里界面,bit4 计步界面,bit3血压界面，（必须为假）,bit2心率界面，bit1时间界面，（必须为真）,bit0配对界面，（必须为真）
+ (NSDictionary *)fetchCustomScreenModel:(NSString *)content{
    if (!content || content.length != 4) {
        return nil;
    }
    NSInteger screenHeight = [mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(0, 2)];
    NSInteger screenLow = [mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(2, 2)];
    return @{
             @"turnOnHeartRatePage":@((screenLow & 0x04) == 0x04),
             @"turnOnStepPage":@((screenLow & 0x10) == 0x10),
             @"turnOnCaloriesPage":@((screenLow & 0x20) == 0x20),
             @"turnOnSportsDistancePage":@((screenLow & 0x40) == 0x40),
             @"turnOnSportsTimePage":@((screenLow & 0x80) == 0x80),
             @"turnOnSleepPage":@((screenHeight & 0x01) == 0x01),
             @"turnOnSecondRunning":@((screenHeight & 0x08) == 0x08),
             @"turnOnThirdRunning":@((screenHeight & 0x10) == 0x10)
             };
}

+ (NSDictionary *)getUserInfo:(NSString *)content{
    NSString *weight = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *height = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(2, 2)];
    NSString *month = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
    if (month.length == 1) {
        month = [@"0" stringByAppendingString:month];
    }
    NSString *day = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 2)];
    if (day.length == 1) {
        day = [@"0" stringByAppendingString:day];
    }
    NSString *gender = [content substringWithRange:NSMakeRange(10, 2)];
    NSString *stepDistance = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(12, 2)];
    NSString *userAge = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(4, 2)];
    return @{
             @"weight":weight,
             @"height":height,
             @"userAge":userAge,
             @"gender":gender,
             @"stepDistance":stepDistance,
             };
}

+ (NSDictionary *)getHardwareParameters:(NSString *)content{
    //flash的状态
    NSString *flashStatus = [content substringWithRange:NSMakeRange(0, 2)];
    //当前反光阀值
    NSString *reflThreshold = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(2, 4)];
    //当前反光值
    NSString *reflective = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 4)];
    //生产批次年
    NSString *productYear = [NSString stringWithFormat:@"%ld",(long)([mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(10, 2)] + 2000)];
    //生产批次周
    NSString *productWeek = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(12, 2)];
    return @{
             @"flashStatus":flashStatus,
             @"reflThreshold":reflThreshold,
             @"reflective":reflective,
             @"productYear":productYear,
             @"productWeek":productWeek,
             };
}

+ (NSString *)getFirmwareVersion:(NSString *)content{
    NSString *hardVersion = [content substringWithRange:NSMakeRange(0, 4)];
    NSString *function = [content substringWithRange:NSMakeRange(4, 4)];
    NSString *softVersion = [content substringWithRange:NSMakeRange(8, 4)];
    return [NSString stringWithFormat:@"%@.%@.%@",hardVersion,function,softVersion];
}

//解析睡眠index，记录到本地日志
+ (NSDictionary *)getSleepIndexData:(NSString *)content{
    
    NSString *SN = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *startYear = [NSString stringWithFormat:@"%ld",(long)([mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(2, 2)] + 2000)];
    NSString *startMonth = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(4, 2)];
    NSString *startDay = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
    NSString *startHour = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 2)];
    NSString *startMin = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(10, 2)];
    NSString *endYear = [NSString stringWithFormat:@"%ld",(long)([mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(12, 2)] + 2000)];
    NSString *endMonth = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(14, 2)];
    NSString *endDay = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(16, 2)];
    NSString *endHour = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(18, 2)];
    NSString *endMin = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(20, 2)];
    NSString *deepSleepTime = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(22, 4)];
    NSString *lightSleepTime = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(26, 4)];
    NSString *awake = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(30, 4)];
    
    NSString *tempString1 = [NSString stringWithFormat:@"解析后的睡眠index数据:第%@条index",SN];
    NSString *tempString2 = [NSString stringWithFormat:@"开始于%@-%@-%@ %@:%@",startYear,startMonth,startDay,startHour,startMin];
    NSString *tempString3 = [NSString stringWithFormat:@"结束于%@-%@-%@ %@:%@",endYear,endMonth,endDay,endHour,endMin];
    NSString *tempString4 = [NSString stringWithFormat:@"深睡时长:%@",deepSleepTime];
    NSString *tempString5 = [NSString stringWithFormat:@"浅睡时长:%@",lightSleepTime];
    NSString *tempString6 = [NSString stringWithFormat:@"清醒时长:%@",awake];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[tempString1,tempString2,tempString3,tempString4,tempString5,tempString6] sourceInfo:mk_logDataSourceDevice];
    return @{
             @"SN":SN,
             @"startYear":startYear,
             @"startMonth":startMonth,
             @"startDay":startDay,
             @"startHour":startHour,
             @"startMin":startMin,
             @"endYear":endYear,
             @"endMonth":endMonth,
             @"endDay":endDay,
             @"endHour":endHour,
             @"endMin":endMin,
             @"deepSleepTime":deepSleepTime,
             @"lightSleepTime":lightSleepTime,
             @"awake":awake,
             };
}
//解析睡眠record，记录到本地日志
+ (NSDictionary *)getSleepRecordData:(NSString *)content{
    //对应的睡眠详情长度
    NSInteger len = [mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(4, 2)];
    if (len == 0) {
        return @{};
    }
    NSMutableArray *detailList = [NSMutableArray array];
    NSInteger index = 6;
    for (NSInteger i = 0; i < len; i ++) {
        NSString * hexStr = [content substringWithRange:NSMakeRange(index, 2)];
        NSArray * tempList = [self getSleepDetailList:hexStr];
        if (mk_validArray(tempList)) {
            [detailList addObjectsFromArray:tempList];
        }
        index += 2;
    }
    NSString *tempString = @"";
    for (NSString *temp in detailList) {
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@" %@",temp]];
    }
    NSString *SN = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *fragmentSN = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(2, 2)];
    NSString *tempString1 = [NSString stringWithFormat:@"解析后的睡眠index数据:对应第%@条睡眠index数据",SN];
    NSString *tempString2 = [NSString stringWithFormat:@"本条数据index数据下面是第%@条record数据",fragmentSN];
    NSString *tempString3 = [NSString stringWithFormat:@"解析后的睡眠详情:%@",tempString];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[tempString1,tempString2,tempString3] sourceInfo:mk_logDataSourceDevice];
    return @{
             @"SN":SN,
             @"fragmentSN":fragmentSN,
             @"detailList":detailList,
             };
}

+ (NSDictionary *)getSportData:(NSString *)content{
    //0步行1跑步2骑行3篮球4足球5瑜伽6跳绳7登山
    NSString *type = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(0,2)];
    if ([type isEqualToString:@"17"]) {
        //705的17是长度，直接对应706的跑步
        type = @"01";
    }
    NSString *year = [NSString stringWithFormat:@"%ld",(long)([mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(4, 2)] + 2000)];
    NSString *month = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
    if (month.length == 1) {
        month = [@"0" stringByAppendingString:month];
    }
    NSString *day = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 2)];
    if (day.length == 1) {
        day = [@"0" stringByAppendingString:day];
    }
    NSString *hour = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(10, 2)];
    if (hour.length == 1) {
        hour = [@"0" stringByAppendingString:hour];
    }
    NSString *minutes = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(12, 2)];
    if (minutes.length == 1) {
        minutes = [@"0" stringByAppendingString:minutes];
    }
    NSString *sportDate = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",year,
                           month,
                           day,
                           hour,
                           minutes];
    NSString *sportTime = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(14, 4)];
    NSString *stepNumber = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(18, 6)];
    NSString *calories = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(24, 4)];
    NSString *pace = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(28, 4)];
    NSString *distance = [NSString stringWithFormat:@"%.2f",(float)[mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(32, 4)] * 0.01];
    NSString *string1 = [NSString stringWithFormat:@"运动类型:%@",type];
    NSString *string2 = [NSString stringWithFormat:@"运动开始时间:%@",sportDate];
    NSString *string3 = [NSString stringWithFormat:@"运动时长:%@分钟",sportTime];
    NSString *string4 = [NSString stringWithFormat:@"运动消耗的卡路里:%@Cal",calories];
    NSString *string5 = [NSString stringWithFormat:@"运动配速:%@s",pace];
    NSString *string6 = [NSString stringWithFormat:@"运动里程:%@",distance];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[string1,string2,string3,string4,string5,string6] sourceInfo:mk_logDataSourceDevice];
    return @{
             @"sportType":type,
             @"sportDate":sportDate,
             @"sportTime":sportTime,
             @"stepCount":stepNumber,
             @"burnCalories":calories,
             @"pace":pace,
             @"distance":distance,
             };
}

+ (NSString *)getLastChargingTime:(NSString *)content{
    NSString *year = [NSString stringWithFormat:@"%ld",(long)([mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(0, 2)] + 2000)];
    NSString *sportDate = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",year,
                           [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(2, 2)],
                           [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(4, 2)],
                           [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)],
                           [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 2)]];
    return sportDate;
}

+ (NSString *)getTimeSpaceWithStatus:(BOOL)isOn
                           startHour:(NSInteger)startHour
                        startMinutes:(NSInteger)startMinutes
                             endHour:(NSInteger)endHour
                          endMinutes:(NSInteger)endMinutes{
    if (isOn) {
        if (startHour < 0 || startHour > 23) {
            return @"";
        }
        if (startMinutes < 0 || startMinutes > 59) {
            return @"";
        }
        if (endHour < 0 || endHour > 23) {
            return @"";
        }
        if (endMinutes < 0 || endMinutes > 59) {
            return @"";
        }
    }
    //开始的时
    NSString *startHourHex = [NSString stringWithFormat:@"%1lx",(unsigned long)startHour];
    if (startHourHex.length == 1) {
        startHourHex = [@"0" stringByAppendingString:startHourHex];
    }
    //开始的分
    NSString *startMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)startMinutes];
    if (startMinHex.length == 1) {
        startMinHex = [@"0" stringByAppendingString:startMinHex];
    }
    //结束的时
    NSString *endHourHex = [NSString stringWithFormat:@"%1lx",(unsigned long)endHour];
    if (endHourHex.length == 1) {
        endHourHex = [@"0" stringByAppendingString:endHourHex];
    }
    //结束的分
    NSString *endMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)endMinutes];
    if (endMinHex.length == 1) {
        endMinHex = [@"0" stringByAppendingString:endMinHex];
    }
    
    return [NSString stringWithFormat:@"%@%@%@%@",startHourHex,startMinHex,endHourHex,endMinHex];
}
//解析读取回来的计步数据，并记录到本地
+ (NSDictionary *)getStepDetailData:(NSString *)content{
    NSString *SN = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *year = [NSString stringWithFormat:@"%ld",(long)([mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(2, 2)] + 2000)];
    NSString *month = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(4, 2)];
    NSString *day = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
    NSString *stepNumber = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 8)];
    NSString *activityTime = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(16, 4)];
    NSString *distance = [NSString stringWithFormat:@"%.1f",(float)[mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(20, 4)] / 10.0];
    NSString *calories = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(24, 4)];
    NSString *tempString1 = [NSString stringWithFormat:@"解析后的计步数据:第%@条数据",SN];
    NSString *tempString2 = [NSString stringWithFormat:@"计步时间:%@-%@-%@",year,month,day];
    NSString *tempString3 = [NSString stringWithFormat:@"步数是:%@",stepNumber];
    NSString *tempString4 = [NSString stringWithFormat:@"运动时间:%@",activityTime];
    NSString *tempString5 = [NSString stringWithFormat:@"运动距离:%@",distance];
    NSString *tempString6 = [NSString stringWithFormat:@"消耗卡路里:%@",calories];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[tempString1,tempString2,tempString3,tempString4,tempString5,tempString6] sourceInfo:mk_logDataSourceDevice];
    return @{
             @"SN":SN,
             @"year":year,
             @"month":month,
             @"day":day,
             @"stepNumber":stepNumber,
             @"activityTime":activityTime,
             @"distance":distance,
             @"calories":calories,
             };
}

+ (NSDictionary *)fetchStepIntervalData:(NSString *)content {
    NSMutableArray *stepList = [NSMutableArray array];
    for (NSInteger i = 0; i < 2; i ++) {
        NSString *stepContent = [content substringWithRange:NSMakeRange(i * 14, 14)];
        NSString *year = [NSString stringWithFormat:@"%ld",(long)([mk_fitpoloAdopter getDecimalWithHex:stepContent range:NSMakeRange(0, 2)] + 2000)];
        NSString *month = [mk_fitpoloAdopter getDecimalStringWithHex:stepContent range:NSMakeRange(2, 2)];
        if (month.length == 1) {
            month = [@"0" stringByAppendingString:month];
        }
        NSString *day = [mk_fitpoloAdopter getDecimalStringWithHex:stepContent range:NSMakeRange(4, 2)];
        if (day.length == 1) {
            day = [@"0" stringByAppendingString:day];
        }
        NSString *hour = [mk_fitpoloAdopter getDecimalStringWithHex:stepContent range:NSMakeRange(6, 2)];
        if (hour.length == 1) {
            hour = [@"0" stringByAppendingString:hour];
        }
        NSString *minute = [mk_fitpoloAdopter getDecimalStringWithHex:stepContent range:NSMakeRange(8, 2)];
        if (minute.length == 1) {
            minute = [@"0" stringByAppendingString:minute];
        }
        NSString *stepNumber = [mk_fitpoloAdopter getDecimalStringWithHex:stepContent range:NSMakeRange(10, 4)];
        NSDictionary *dic = @{
                              @"stepDate":[NSString stringWithFormat:@"%@-%@-%@-%@-%@",year,month,day,hour,minute],
                              @"stepNumber":stepNumber,
                              };
        [stepList addObject:dic];
    }
    return @{
             @"stepList":stepList,
             };
}

//解析心率数据，并记录到本地
+ (NSDictionary *)getHeartRateList:(NSString *)content{
    NSMutableArray *list = [NSMutableArray array];
    for (NSInteger i = 0; i < content.length / 12; i ++) {
        NSString *subContemt = [content substringWithRange:NSMakeRange(i * 12, 12)];
        NSString *year = [NSString stringWithFormat:@"%ld",(long)([mk_fitpoloAdopter getDecimalWithHex:subContemt range:NSMakeRange(0, 2)] + 2000)];
        NSString *month = [mk_fitpoloAdopter getDecimalStringWithHex:subContemt range:NSMakeRange(2, 2)];
        NSString *day = [mk_fitpoloAdopter getDecimalStringWithHex:subContemt range:NSMakeRange(4, 2)];
        NSString *hour = [mk_fitpoloAdopter getDecimalStringWithHex:subContemt range:NSMakeRange(6, 2)];
        NSString *min = [mk_fitpoloAdopter getDecimalStringWithHex:subContemt range:NSMakeRange(8, 2)];
        NSString *heartRate = [mk_fitpoloAdopter getDecimalStringWithHex:subContemt range:NSMakeRange(10, 2)];
        NSString *string1 = [NSString stringWithFormat:@"心率时间:%@-%@-%@ %@:%@",year,month,day,hour,min];
        NSString *string2 = [NSString stringWithFormat:@"心率值:%@",heartRate];
        [mk_fitpoloLogManager writeCommandToLocalFile:@[string1,string2] sourceInfo:mk_logDataSourceDevice];
        NSDictionary *dic = @{
                              @"year":year,
                              @"month":month,
                              @"day":day,
                              @"hour":hour,
                              @"minute":min,
                              @"heartRate":heartRate
                              };
        [list addObject:dic];
    }
    
    
    return @{
             @"heartList":list,
             };
}

//706:今日活动(00)运动模式(01)秒表(02)计时器(03)心率(04)呼吸训练(05)昨晚睡眠(06)更多功能(07)配对码(08)
//707:今日活动(00)秒表(02)计时器(03)心率(04)呼吸训练(05)睡眠(06)更多(07)信息(0b)步行(0c)跑步(0d)骑行(0e)篮球(0f)足球(10)瑜伽(11)跳绳(12)登山(13)
+ (NSArray *)fetch706CurrentScreenList:(NSString *)content {
    NSInteger totalCount = [mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(0, 2)];
    NSMutableArray *screenList = [NSMutableArray array];
    for (NSInteger i = 0; i < totalCount; i ++) {
        NSString *display = [content substringWithRange:NSMakeRange(2 + i * 2, 2)];
        [screenList addObject:display];
    }
    return screenList;
}

#pragma mark - private method
//0x00:吃药;0x01:喝水;0x03:普通;0x04:睡觉;0x05:锻炼;0x06:跑步
+ (mk_alarmClockType)getClockTypeWithString:(NSString *)type{
    if (!mk_validStr(type) || type.length != 2) {
        return mk_alarmClockNormal;
    }
    if ([type isEqualToString:@"00"]) {
        return mk_alarmClockMedicine;
    }else if ([type isEqualToString:@"01"]){
        return mk_alarmClockDrink;
    }else if ([type isEqualToString:@"03"]){
        return mk_alarmClockNormal;
    }else if ([type isEqualToString:@"04"]){
        return mk_alarmClockSleep;
    }else if ([type isEqualToString:@"05"]){
        return mk_alarmClockExcise;
    }else if ([type isEqualToString:@"06"]){
        return mk_alarmClockSport;
    }
    return mk_alarmClockNormal;
}

//Bit0-Bit6：代表周一至周日，为真代表打开 Bit7：1代表打开闹钟，0代表关闭闹钟
+ (NSDictionary *)getClockStatusModelWithString:(NSString *)modelString{
    NSInteger statusValue = [mk_fitpoloAdopter getDecimalWithHex:modelString range:NSMakeRange(0, 2)];
    return @{
             @"statusModel":@{
                     @"mondayIsOn":@((statusValue & 0x01) == 0x01),
                     @"tuesdayIsOn":@((statusValue & 0x02) == 0x02),
                     @"wednesdayIsOn":@((statusValue & 0x04) == 0x04),
                     @"thursdayIsOn":@((statusValue & 0x08) == 0x08),
                     @"fridayIsOn":@((statusValue & 0x10) == 0x10),
                     @"saturdayIsOn":@((statusValue & 0x20) == 0x20),
                     @"sundayIsOn":@((statusValue & 0x40) == 0x40)
                     },
             @"isOn":@((statusValue & 0x80) == 0x80),
             };
}

+ (NSArray *)getSleepDetailList:(NSString *)detail{
    if (!mk_validStr(detail) || detail.length != 2) {
        return nil;
    }
    NSDictionary *hexDic = @{
                             @"0":@"0000",@"1":@"0001",@"2":@"0010",
                             @"3":@"0011",@"4":@"0100",@"5":@"0101",
                             @"6":@"0110",@"7":@"0111",@"8":@"1000",
                             @"9":@"1001",@"A":@"1010",@"a":@"1010",
                             @"B":@"1011",@"b":@"1011",@"C":@"1100",
                             @"c":@"1100",@"D":@"1101",@"d":@"1101",
                             @"E":@"1110",@"e":@"1110",@"F":@"1111",
                             @"f":@"1111",
                             };
    NSString *binaryString = @"";
    for (int i=0; i<[detail length]; i++) {
        NSRange rage;
        rage.length = 1;
        rage.location = i;
        NSString *key = [detail substringWithRange:rage];
        binaryString = [NSString stringWithFormat:@"%@%@",
                        binaryString,
                        [NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]];
        
    }
    if (binaryString.length != 8) {
        return nil;
    }
    NSMutableArray * list = [[NSMutableArray alloc] init];
    NSInteger index = 0;
    for (NSInteger i = 0; i < 4; i ++) {
        NSString * string = [binaryString substringWithRange:NSMakeRange(index, 2)];
        if ([string isEqualToString:@"11"]) {
            string = @"00";
        }
        [list addObject:string];
        index += 2;
    }
    NSMutableArray * resultArr = (NSMutableArray *)[[list reverseObjectEnumerator] allObjects];
    return resultArr;
}

@end
