//
//  MKUserDataInterface.h
//  MKFitpoloUserData
//
//  Created by aa on 2019/1/2.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKUserDataInterfaceDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKUserDataInterface : NSObject

/**
 Read conting steps data.
 
 (
 {
 burnCalories = 388;         //Calories burned, kilocalories
 distance = "4.7";          //Distance of movement, in km
 sportDate = "2019-06-09";  //Date of exercise
 sportTime = 49;            //Exercise time in minutes
 stepCount = 7380;           //Exercise steps
 }
 {
 burnCalories = 10;
 distance = "0.0";
 sportDate = "2019-06-10";
 sportTime = 5;
 stepCount = 500;
 };
 )
 
 @param protocol The timestamp requests the step data, and the returned data is the step data after the time point.
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readStepDataWithTimeStamp:(id <MKReadDeviceDataTimeProtocol>)protocol
                         sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                      failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock;

/**
 Read sleep datas.

 (
 {
 awake = 0;         //Wake up time , in minute.
 deepSleep = 155;   //Deep sleep time, in minute.
 endDate = "2019-06-07";    //Sleep end date.
 endTime = "07:50";         //Sleep end time.
 lightSleep = 360;  //Light sleep time, in minute.
 startDate = "2019-06-06";  //Sleep start date.
 startTime = "23:15";       //Sleep start time.
 detailList =         (//Sleep details, recorded the specific sleep situation from the beginning of sleep to the end of sleep, 01: light sleep, 10: deep sleep, 11: awake
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 10,
 10,
 10,
 10,
 10,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 10,
 10,
 10,
 10,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 10,
 10,
 10,
 10,
 01,
 01,
 01,
 01,
 01,
 01,
 10,
 10,
 10,
 10,
 10,
 01,
 01,
 01,
 
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 10,
 10,
 10,
 10,
 01,
 01,
 01,
 01,
 01,
 10,
 10,
 10,
 10,
 10,
 10,
 10,
 10,
 10,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 01,
 00
 );
 },
 )
 
 @param protocol The timestamp requests the step data, and the returned data is the sleep data after that time point.
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readSleepDataWithTimeStamp:(id <MKReadDeviceDataTimeProtocol>)protocol
                          sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                       failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock;

/**
 Read heart rate data.

 {
 //average daily heart rate datas
 averageDailyList =     (
 {
 dateString = "2019-05-22";
 maxHeartRate = 60;             //average daily max heart rate
 minHeartRate = 60;             //average daily min heart rate
 }
 );
 //heart rate details
 detailList =     (
 {
 dateInfo = "2019-05-22-18-30";     //Measured heart rate year-month-day-hour-minute.
 dateString = "2019-05-22";         //The date of the measured heart rate.
 dayInfo = 22;                      //Day of the measured heart rate
 heartRate = 60;                    //Heart rate value
 hourInfo = 18;                     //Hour of the measured heart rate
 minInfo = 30;                      //Minute of the measured heart rate
 monthInfo = 05;                    //Month of the measured heart rate
 yearInfo = 2019;                   //Year of the measured heart rate
 },
 {
 dateInfo = "2019-05-22-19-00";
 dateString = "2019-05-22";
 dayInfo = 22;
 heartRate = 60;
 hourInfo = 19;
 minInfo = 00;
 monthInfo = 05;
 yearInfo = 2019;
 }
 );
 }
 
 @param protocol The timestamp requests the step data, and the returned data is the heart rate data after that time point.
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readHeartDataWithTimeStamp:(id <MKReadDeviceDataTimeProtocol>)protocol
                          sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                       failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock;
#pragma mark - 705、706、707
/**
 Read user info, H701 doesn't support.
 
 userInfo =         {
 gender = 01;           //Gender 00: male  01:female
 height = 170;          //Height : in cm
 stepDistance = 75;     //Step distance, distance per step, unit cm
 userAge = 25;          //User age
 weight = 60;           //User weight, in kg
 };
 
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readUserDataWithSucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                     failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock;

/**
 Get sports goals, 701 does not support.
 
 {
 movingTarget = 8000;       //unit in steps
 };
 
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readMovingTargetWithSucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                         failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock;

/**
 Get sports data, there are currently 8 kinds of walking, running, cycling, basketball, football, yoga, skipping, climbing, 705 currently only supports running.
 
 (
 {
 burnCalories = 13;                             //Calories burned in this sport.
 distance = "0.07";                             //Sports distance in this exercise.
 pace = 1457;                                   //Pace in this sport.
 sportDate = "2019-05-20-10-05";                //Date of this sport.
 sportTime = 1;                                 //Time of this sport.
 sportType = 6;                                 //Sport type, 0 walk  1 run 2 ride 3 basketball 4 football 5 yoga 6 jump rope 7 mountaineering.
 stepCount = 116;                               //Steps of this sport.
 }
 );
 
 @param protocol The timestamp requests the step data, and the returned data is the motion data after the time point.
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readSportDataWithTimeStamp:(id <MKReadDeviceDataTimeProtocol>)protocol
                          sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                       failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock;

/**
 Get 705, 706 sport heart rate.

 {
 averageDailyList =     (
 {
 dateString = "2019-05-20";
 maxHeartRate = 95;                 //everage daily max
 minHeartRate = 95;                 //everage daily min
 }
 );
 detailList =     (
 {
 dateInfo = "2019-05-20-10-06";     //year- month-date - hour- min of the measured HR.
 dateString = "2019-05-20";         //Year- month-date of the measured HR
 dayInfo = 20;
 heartRate = 95;
 hourInfo = 10;
 minInfo = 06;
 monthInfo = 05;
 yearInfo = 2019;
 }
 );
 }
 
 @param protocol The timestamp requests the step data, and the returned data is the exercise heart rate data after the time point.
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readSportHeartRateDataWithTimeStamp:(id <MKReadDeviceDataTimeProtocol>)protocol
                                   sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                                failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock;

#pragma mark - 706、707

/**
 Get 706 interval step data.

 @param protocol The timestamp request interval step data, the returned data is the step data after the time point.
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readStepIntervalDataWithTimeStamp:(id <MKReadDeviceDataTimeProtocol>)protocol
                                 sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                              failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock;

@end

NS_ASSUME_NONNULL_END
