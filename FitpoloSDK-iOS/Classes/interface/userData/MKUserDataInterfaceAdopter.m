//
//  MKUserDataInterfaceAdopter.m
//  MKFitpoloUserData
//
//  Created by aa on 2019/1/2.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKUserDataInterfaceAdopter.h"
#import "mk_fitpoloDefines.h"

@implementation MKUserDataInterfaceAdopter

+ (BOOL)validTimeProtocol:(id <MKReadDeviceDataTimeProtocol>)protocol{
    if (!protocol) {
        return NO;
    }
    if (protocol.year < 2000 || protocol.year > 2099) {
        return NO;
    }
    if (protocol.month < 1 || protocol.month > 12) {
        return NO;
    }
    if (protocol.day < 1 || protocol.day > 31) {
        return NO;
    }
    if (protocol.hour < 0 || protocol.hour > 23) {
        return NO;
    }
    if (protocol.minutes < 0 || protocol.minutes > 59) {
        return NO;
    }
    return YES;
}

+ (NSString *)getTimeString:(id <MKReadDeviceDataTimeProtocol>)protocol{
    if (!protocol) {
        return nil;
    }
    
    unsigned long yearValue = protocol.year - 2000;
    NSString *yearString = [NSString stringWithFormat:@"%1lx",yearValue];
    if (yearString.length == 1) {
        yearString = [@"0" stringByAppendingString:yearString];
    }
    NSString *monthString = [NSString stringWithFormat:@"%1lx",(long)protocol.month];
    if (monthString.length == 1) {
        monthString = [@"0" stringByAppendingString:monthString];
    }
    NSString *dayString = [NSString stringWithFormat:@"%1lx",(long)protocol.day];
    if (dayString.length == 1) {
        dayString = [@"0" stringByAppendingString:dayString];
    }
    NSString *hourString = [NSString stringWithFormat:@"%1lx",(long)protocol.hour];
    if (hourString.length == 1) {
        hourString = [@"0" stringByAppendingString:hourString];
    }
    NSString *minString = [NSString stringWithFormat:@"%1lx",(long)protocol.minutes];
    if (minString.length == 1) {
        minString = [@"0" stringByAppendingString:minString];
    }
    return [NSString stringWithFormat:@"%@%@%@%@%@",yearString,monthString,dayString,hourString,minString];
}

+ (NSArray *)getSleepDataList:(NSArray *)indexList recordList:(NSArray *)recordList{
    if (!mk_validArray(indexList) || !mk_validArray(recordList)) {
        return nil;
    }
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (NSDictionary *dic in indexList) {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        NSArray *sleepDetailList = [self getDetailSleepList:dic[@"SN"] recordList:recordList];
        [tempDic setObject:sleepDetailList forKey:@"detailedSleep"];
        [resultArray addObject:tempDic];
    }
    return [resultArray copy];
}

+ (NSArray <NSDictionary *>*)fetchStepModelList:(NSArray *)resultList{
    if (!resultList || resultList.count == 0) {
        return nil;
    }
    NSMutableArray *dataList = [NSMutableArray array];
    for (NSDictionary *dic in resultList) {
        NSString *year = dic[@"year"];
        NSString *month = dic[@"month"];
        if (month.length == 1) {
            month = [@"0" stringByAppendingString:month];
        }
        NSString *day = dic[@"day"];
        if (day.length == 1) {
            day = [@"0" stringByAppendingString:day];
        }
        NSDictionary *tempDic = @{
                                  @"sportDate":[NSString stringWithFormat:@"%@-%@-%@",year,month,day],
                                  @"stepCount":dic[@"stepNumber"],
                                  @"sportTime":dic[@"activityTime"],
                                  @"distance":dic[@"distance"],
                                  @"burnCalories":dic[@"calories"]
                                  };
        [dataList addObject:tempDic];
    }
    return [dataList copy];
}

+ (NSArray <NSDictionary *>*)fetchSleepModelList:(NSArray *)resultList{
    if (!resultList || resultList.count == 0) {
        return nil;
    }
    NSMutableArray *dataList = [NSMutableArray array];
    for (NSDictionary *dic in resultList) {
        NSString *startMonth = dic[@"startMonth"];
        if (startMonth.length == 1) {
            startMonth = [@"0" stringByAppendingString:startMonth];
        }
        NSString *startDay = dic[@"startDay"];
        if (startDay.length == 1) {
            startDay = [@"0" stringByAppendingString:startDay];
        }
        NSString *endMonth = dic[@"endMonth"];
        if (endMonth.length == 1) {
            endMonth = [@"0" stringByAppendingString:endMonth];
        }
        NSString *endDay = dic[@"endDay"];
        if (endDay.length == 1) {
            endDay = [@"0" stringByAppendingString:endDay];
        }
        NSString *startHour = dic[@"startHour"];
        if (startHour.length == 1) {
            startHour = [@"0" stringByAppendingString:startHour];
        }
        NSString *startMin = dic[@"startMin"];
        if (startMin.length == 1) {
            startMin = [@"0" stringByAppendingString:startMin];
        }
        NSString *endHour = dic[@"endHour"];
        if (endHour.length == 1) {
            endHour = [@"0" stringByAppendingString:endHour];
        }
        NSString *endMin = dic[@"endMin"];
        if (endMin.length == 1) {
            endMin = [@"0" stringByAppendingString:endMin];
        }
        NSDictionary *tempDic = @{
                                  @"startDate":[NSString stringWithFormat:@"%@-%@-%@",dic[@"startYear"],startMonth,startDay],
                                  @"endDate":[NSString stringWithFormat:@"%@-%@-%@",dic[@"endYear"],endMonth,endDay],
                                  @"startTime":[NSString stringWithFormat:@"%@:%@",startHour,startMin],
                                  @"endTime":[NSString stringWithFormat:@"%@:%@",endHour,endMin],
                                  @"awake":dic[@"awake"],
                                  @"lightSleep":dic[@"lightSleepTime"],
                                  @"deepSleep":dic[@"deepSleepTime"],
                                  @"detailList":dic[@"detailedSleep"],
                                  };
        [dataList addObject:tempDic];
    }
    return [dataList copy];
}

+ (NSDictionary *)fetchHeartModelList:(NSArray *)resultList{
    if (!resultList || resultList.count == 0) {
        return nil;
    }
    NSMutableArray *dataList = [NSMutableArray array];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
    for (NSDictionary *tempHeartDic in resultList) {
        if ([tempHeartDic[@"heartRate"] integerValue] > 40) {
            NSString *monthString = tempHeartDic[@"month"];
            if (monthString.length == 1) {
                monthString = [@"0" stringByAppendingString:monthString];
            }
            NSString *dayString = tempHeartDic[@"day"];
            if (dayString.length == 1) {
                dayString = [@"0" stringByAppendingString:dayString];
            }
            NSString *hourString = tempHeartDic[@"hour"];
            if (hourString.length == 1) {
                hourString = [@"0" stringByAppendingString:hourString];
            }
            NSString *minString = tempHeartDic[@"minute"];
            if (minString.length == 1) {
                minString = [@"0" stringByAppendingString:minString];
            }
            //入库的时候作为心率数据的key
            NSString *tempDateInfo = [NSString stringWithFormat:@"%@-%@-%@-%@-%@",tempHeartDic[@"year"],monthString,dayString,hourString,minString];
            NSString *tempDateString = [NSString stringWithFormat:@"%@-%@-%@",tempHeartDic[@"year"],monthString,dayString];
            //过滤掉心率值小于40的数据
            NSDictionary *dic = @{
                                  @"yearInfo":tempHeartDic[@"year"],
                                  @"monthInfo":monthString,
                                  @"dayInfo":dayString,
                                  @"hourInfo":hourString,
                                  @"minInfo":minString,
                                  @"heartRate":tempHeartDic[@"heartRate"],
                                  @"dateInfo":tempDateInfo,
                                  @"dateString":tempDateString,
                                  };
            [dataList addObject:dic];
            [dataDic setObject:@"1" forKey:[NSString stringWithFormat:@"%@-%@-%@",tempHeartDic[@"year"],monthString,dayString]];
        }
    }
    
    NSArray *allKeys = [dataDic allKeys];
    NSMutableArray *dailyArray = [NSMutableArray array];
    for (NSString *string in allKeys) {
        NSInteger count = 0;
        NSMutableArray *tempHeartList = [NSMutableArray array];
        for (NSDictionary *dic in dataList) {
            if ([dic[@"dateString"] isEqualToString:string]) {
                count ++;
                [tempHeartList addObject:dic[@"heartRate"]];
            }
        }
        if (count > 0) {
            NSInteger max =[[tempHeartList valueForKeyPath:@"@max.integerValue"] integerValue];
            
            NSInteger min =[[tempHeartList valueForKeyPath:@"@min.integerValue"] integerValue];
            NSDictionary *dic = @{
                                  @"dateString":string,
                                  @"maxHeartRate":[NSString stringWithFormat:@"%ld",(long)max],
                                  @"minHeartRate":[NSString stringWithFormat:@"%ld",(long)min],
                                  @"detailNeedPull":@(YES),
                                  @"needPull":@(YES),
                                  };
            [dailyArray addObject:dic];
        }
        
    }
    
    return @{
             @"detailList":dataList,
             @"averageDailyList":dailyArray,
             };
}

+ (NSArray *)getDetailSleepList:(NSString *)SN recordList:(NSArray *)recordList{
    NSMutableArray * tempList = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < recordList.count; i ++) {
        NSDictionary *recordDic = recordList[i];
        if ([recordDic[@"SN"] isEqualToString:SN]) {
            [tempList addObject:recordDic];
        }
    }
    NSArray *sortedArray = [tempList sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *dic1, NSDictionary *dic2){
        NSInteger index1 = [dic1[@"fragmentSN"] integerValue];
        NSInteger index2 = [dic2[@"fragmentSN"] integerValue];
        return [[NSNumber numberWithInteger:index1]
                compare:[NSNumber numberWithInteger:index2]];
    }];
    NSMutableArray *resultList = [NSMutableArray array];
    for (NSInteger m = 0; m < [sortedArray count]; m ++) {
        NSDictionary *dic = [sortedArray objectAtIndex:m];
        NSArray *list = dic[@"detailList"];
        if (mk_validArray(list)) {
            [resultList addObjectsFromArray:list];
        }
    }
    
    return resultList;
}

@end
