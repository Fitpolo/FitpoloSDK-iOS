//
//  mk_fitpolo701Adopter.m
//  mk_fitpoloCentralManager
//
//  Created by aa on 2018/12/10.
//  Copyright © 2018 mk_fitpolo. All rights reserved.
//

#import "mk_fitpolo701Adopter.h"
#import "mk_fitpoloDefines.h"
#import "mk_fitpoloAdopter.h"
#import "mk_fitpoloLogManager.h"

@implementation mk_fitpolo701Adopter

+ (NSDictionary *)getHardwareParameters:(NSString *)content{
    //flash的状态
    NSString *flashStatus = [content substringWithRange:NSMakeRange(2, 2)];
    //当前反光阀值
    NSString *reflThreshold = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(4, 4)];
    //当前反光值
    NSString *reflective = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 4)];
    //最后一次充电年
    NSString *year = [NSString stringWithFormat:@"%ld",(long)([mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(12, 2)] + 2000)];
    //最后一次充电月
    NSString *month = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(14, 2)];
    //最后一次充电日
    NSString *day = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(16, 2)];
    //最后一次充电时
    NSString *hour = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(18, 2)];
    //最后一次充电分
    NSString *min = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(20, 2)];
    //手环最后一次充电时间
    NSString *chargingTime = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",year,month,day,hour,min];
    //生产批次年
    NSString *productYear = [NSString stringWithFormat:@"%ld",(long)([mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(22, 2)] + 2000)];
    //生产批次周
    NSString *productWeek = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(24, 2)];
    BOOL ancsConnectStatus = [[content substringWithRange:NSMakeRange(26, 2)] isEqualToString:@"01"];
    NSDictionary *dic = @{
                          @"flashStatus":flashStatus,
                          @"reflThreshold":reflThreshold,
                          @"reflective":reflective,
                          @"chargingTime":chargingTime,
                          @"productYear":productYear,
                          @"productWeek":productWeek,
                          @"ancsConnectStatus":@(ancsConnectStatus)
                          };
    return dic;
}

+ (NSDictionary *)getAncsOptions:(NSString *)content{
    NSInteger high = [mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(content.length - 4, 2)];
    NSInteger low = [mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(content.length - 2, 2)];
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

+ (NSDictionary *)getMemoryData:(NSString *)content{
    NSString *stepCount = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *battery = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(4, 2)];
    NSString *tempString1 = [NSString stringWithFormat:@"解析后的memory数据:计步数据个数:%@", stepCount];
    NSString *tempString2 = [NSString stringWithFormat:@"解析后的memory数据:电池电量:%@", battery];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[tempString1,tempString2] sourceInfo:mk_logDataSourceDevice];
    return @{
             @"stepCount":stepCount,
             @"battery":battery,
             };
}

+ (NSDictionary *)getStepData:(NSString *)content{
    NSString *origData = [NSString stringWithFormat:@"手环返回计步数据:92%@",content];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[origData] sourceInfo:mk_logDataSourceDevice];
    NSString *SN = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *year = [NSString stringWithFormat:@"%ld",(long)([mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(2, 2)] + 2000)];
    NSString *month = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(4, 2)];
    NSString *day = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(6, 2)];
    NSString *stepNumber = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 8)];
    NSString *activityTime = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(16, 4)];
    NSString *distance = [NSString stringWithFormat:@"%.1f",(float)([mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(20, 4)] / 10.0)];
    NSString *calories = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(24, 4)];
    
    NSString *tempString1 = [NSString stringWithFormat:@"解析后的计步数据:第%@条数据", SN];
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

+ (NSDictionary *)getSleepIndexData:(NSString *)content{
    NSString *origData = [NSString stringWithFormat:@"返回的睡眠index数据:93%@", content];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[origData] sourceInfo:mk_logDataSourceDevice];
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

+ (NSDictionary *)getSleepRecordData:(NSString *)content{
    NSString *origData = [NSString stringWithFormat:@"返回的睡眠record数据:94%@", content];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[origData] sourceInfo:mk_logDataSourceDevice];
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
    NSString *SN = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *fragmentSN = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(2, 2)];
    
    NSString *tempString = @"";
    for (NSString *temp in detailList) {
        tempString = [tempString stringByAppendingString:[NSString stringWithFormat:@" %@",temp]];
    }
    NSString *tempString1 = [NSString stringWithFormat:@"解析后的睡眠index数据:对应第%@条睡眠index数据",SN];
    NSString *tempString2 = [NSString stringWithFormat:@"本条数据index数据下面是第%@条record数据",fragmentSN];
    NSString *tempString3 = [NSString stringWithFormat:@"解析后的睡眠详情:%@",tempString];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[tempString1,tempString2,tempString3,] sourceInfo:mk_logDataSourceDevice];
    
    return @{
             @"SN":SN,
             @"fragmentSN":fragmentSN,
             @"detailList":detailList,
             };
}

+ (NSArray *)getHeartRateData:(NSString *)content{
    NSString *origData = [NSString stringWithFormat:@"手环心率数据数据:a8%@",content];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[origData] sourceInfo:mk_logDataSourceDevice];
    NSMutableArray *dataList = [NSMutableArray arrayWithCapacity:3];
    for (NSInteger i = 0; i < 3; i ++) {
        NSString *tempContent = [content substringWithRange:NSMakeRange(i * 12, 12)];
        NSString *year = [NSString stringWithFormat:@"%ld",(long)([mk_fitpoloAdopter getDecimalWithHex:tempContent range:NSMakeRange(0, 2)] + 2000)];
        NSString *month = [mk_fitpoloAdopter getDecimalStringWithHex:tempContent range:NSMakeRange(2, 2)];
        NSString *day = [mk_fitpoloAdopter getDecimalStringWithHex:tempContent range:NSMakeRange(4, 2)];
        NSString *hour = [mk_fitpoloAdopter getDecimalStringWithHex:tempContent range:NSMakeRange(6, 2)];
        NSString *min = [mk_fitpoloAdopter getDecimalStringWithHex:tempContent range:NSMakeRange(8, 2)];
        NSString *heartRate = [mk_fitpoloAdopter getDecimalStringWithHex:tempContent range:NSMakeRange(10, 2)];
        
        NSString *timeString = [NSString stringWithFormat:@"心率时间:%@-%@-%@ %@:%@",year,month,day,hour,min];
        NSString *heartRateString = [NSString stringWithFormat:@"心率值:%@",heartRate];
        [mk_fitpoloLogManager writeCommandToLocalFile:@[timeString,heartRateString] sourceInfo:mk_logDataSourceDevice];
        [dataList addObject:@{
                              @"year":year,
                              @"month":month,
                              @"day":day,
                              @"hour":hour,
                              @"minute":min,
                              @"heartRate":heartRate
                              }];
    }
    return [NSArray arrayWithArray:dataList];
}

+ (NSDictionary *)getFirmwareVersion:(NSString *)content{
    NSString *origData = [NSString stringWithFormat:@"固件版本号数据:90%@",content];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[origData] sourceInfo:mk_logDataSourceDevice];
    NSString *major = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(0, 2)];
    NSString *minor = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(2, 2)];
    NSString *revision = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(4, 2)];
    NSString *firmwareVersion = [NSString stringWithFormat:@"%@.%@.%@",major,minor,revision];
    NSString *tempString = [NSString stringWithFormat:@"固件版本号解析后的数据:%@",firmwareVersion];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[tempString] sourceInfo:mk_logDataSourceDevice];
    return @{
             @"firmwareVersion":firmwareVersion
             };
}

+ (NSArray <NSDictionary *>*)getAlarmClockList:(NSString *)content{
    NSMutableArray *list = [NSMutableArray array];
    for (NSInteger i = 0; i < 4; i ++) {
        NSString *subContent = [content substringWithRange:NSMakeRange(i * 8, 8)];
        if (![[subContent substringWithRange:NSMakeRange(2, 2)] isEqualToString:@"00"]) {
            //@"00000000"此类闹钟属于无效数据
            NSDictionary *tempDic = [self getClockStatusModelWithString:[subContent substringWithRange:NSMakeRange(2, 2)]];
            NSDictionary *dic = @{
                                  @"clockType":@([self getClockType:[subContent substringWithRange:NSMakeRange(0, 2)]]),
                                  @"statusModel":tempDic[@"statusModel"],
                                  @"isOn":tempDic[@"isOn"],
                                  @"hour":[mk_fitpoloAdopter getDecimalStringWithHex:subContent range:NSMakeRange(4, 2)],
                                  @"minutes":[mk_fitpoloAdopter getDecimalStringWithHex:subContent range:NSMakeRange(6, 2)],
                                  };
            [list addObject:dic];
        }
    }
    return [list mutableCopy];
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

+ (NSDictionary *)getConfigurationParameters:(NSString *)content{
    NSString *unit = [content substringWithRange:NSMakeRange(0, 2)];
    NSString *timeFormat = [content substringWithRange:NSMakeRange(2, 2)];
    NSDictionary *displayModel = [self getScreenDisplayModelWithContent:[content substringWithRange:NSMakeRange(4, 2)]];
    BOOL remindLastScreenDisplay = [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"];
    NSString *heartRateAcquisitionInterval = @"0";
    NSString *tempHeart = [content substringWithRange:NSMakeRange(8, 2)];
    if ([tempHeart isEqualToString:@"01"]) {
        heartRateAcquisitionInterval = @"10";
    }else if ([tempHeart isEqualToString:@"02"]){
        heartRateAcquisitionInterval = @"20";
    }else if ([tempHeart isEqualToString:@"03"]){
        heartRateAcquisitionInterval = @"30";
    }
    BOOL palmingBrightScreen = [[content substringWithRange:NSMakeRange(10, 2)] isEqualToString:@"00"];
    return @{
             @"unit":unit,
             @"timeFormat":timeFormat,
             @"screenDisplayModel":displayModel,
             @"remindLastScreenDisplay":@(remindLastScreenDisplay),
             @"heartRateAcquisitionInterval":heartRateAcquisitionInterval,
             @"palmingBrightScreen":@(palmingBrightScreen)
             };
}

#pragma mark - private method

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

//0x00:吃药;0x01:喝水;0x03:普通;0x04:睡觉;0x05:锻炼;0x06:跑步
+ (mk_alarmClockType)getClockType:(NSString *)content{
    if ([content isEqualToString:@"00"]) {
        return mk_alarmClockMedicine;
    }
    if ([content isEqualToString:@"01"]) {
        return mk_alarmClockDrink;
    }
    if ([content isEqualToString:@"03"]) {
        return mk_alarmClockNormal;
    }
    if ([content isEqualToString:@"04"]) {
        return mk_alarmClockSleep;
    }
    if ([content isEqualToString:@"05"]) {
        return mk_alarmClockExcise;
    }
    if ([content isEqualToString:@"06"]) {
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

+ (NSDictionary *)getScreenDisplayModelWithContent:(NSString *)content{
    NSInteger screenValue = [mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(0, 2)];
    return @{
             @"turnOnStepPage":@((screenValue & 0x02) == 0x02),
             @"turnOnHeartRatePage":@((screenValue & 0x04) == 0x04),
             @"turnOnSportsDistancePage":@((screenValue & 0x08) == 0x08),
             @"turnOnCaloriesPage":@((screenValue & 0x10) == 0x10),
             @"turnOnSportsTimePage":@((screenValue & 0x20) == 0x20)
             };
}

@end
