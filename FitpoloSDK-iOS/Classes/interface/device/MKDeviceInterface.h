//
//  MKDeviceInterface.h
//  MKFitpoloDevice
//
//  Created by aa on 2018/12/14.
//  Copyright © 2018 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKDeviceInterfaceDefine.h"
#import "mk_fitpoloCentralManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKDeviceInterface : NSObject

#pragma mark - ************************通用接口*************************
/**
 Read device battery power.

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readBatteryWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                    failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Read firmware version No.

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readFirmwareVersionWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                            failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Read hardware parameters, H701 is only supported after version 29.

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readHardwareParametersWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                               failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Read last charging time,H701 is only supported after version 29.

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readLastChargingTimeWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                             failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Read unit information, @"00": metric, @"01" inch.

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readUnitWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                 failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Read time format, "00":24h,@"01":12h.

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readTimeFormatWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                       failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Reading light up the screen by turning the wrist, effective for a period of time.
 palmingBrightScreen =         {
 endHour = "";      //The hour when the above reading closed.
 endMin = "";       //The minute when rhw above reading closed.
 isOn = 1;          //if open the function light up screen by turning wrist,note, When the parameter is open, the start and end time periods are valid, otherwise it is always off.
 startHour = "";    //The hour when the above reading start.
 startMin = "";     //The minute when the above reading start.
 };

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readPalmingBrightScreenWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                                failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Read heart rate collection interval, in minutes.

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readHeartRateAcquisitionIntervalWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                                         failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Read sedentary remind, valie in a period of time.
 
 sedentaryRemind =         {
 endHour = 12;          //The hour when sedentary remind.
 endMin = 00;           //The minute when sedentary remind.
 isOn = 0;              //if open the function sedentary remind,note, When the parameter is open, the start and end time periods are valid, otherwise it is always off.
 startHour = 08;        //The hour when sedentary remind start.
 startMin = 00;         //The minute when sedentary remind start.
 };

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readSedentaryRemindWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                            failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Read ANCS connection status.

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readAncsConnectStatusWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                              failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Read ancs strat option.

 ancsOptionsModel =         {
 openFacebook = 0;
 openLine = 0;
 openPhone = 0;
 openQQ = 0;
 openSMS = 0;
 openSkype = 0;
 openSnapchat = 0;
 openTwitter = 0;
 openWeChat = 0;
 openWhatsapp = 0;
 openLine = 0;           //This functions H701 doesn't support.
 };
 
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readAncsOptionsWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                        failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Request alarm datas.

 (
 {
 clockType = 2;                 //alarm type: 0: take medicine 1:drink water, 3. normaly , 4 : sleep, 5 : exercise 6: running
 index = 0;                     //which alarm.
 isOn = 1;                      //If the alarm turned on.
 statusModel =             {
 fridayIsOn = 0;
 mondayIsOn = 1;                //Monday turn on.
 saturdayIsOn = 0;
 sundayIsOn = 1;                // Sunday turn on.
 thursdayIsOn = 0;
 tuesdayIsOn = 0;
 wednesdayIsOn = 0;
 };
 time = "14:12";                //alarm time.
 }
 );
 
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readAlarmClockDatasWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                            failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 If last time the screen display is turned on, if it is turned on, the last screen is displayed when the screen is bright, and the time screen is displayed when it is not turned on.

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readRemindLastScreenDisplayWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                                    failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Current screen display.
 H701 bracelet (_inside all are BOOL value)
 customScreenModel =         {
 turnOnCaloriesPage = 1;            //if show calory page 1: yes, 0: No，
 turnOnHeartRatePage = 1;           //if show heart rate page, 1: yes, o:no
 turnOnSportsDistancePage = 1;      //if show distance page, 1: yes, o: no
 turnOnSportsTimePage = 1;          //if show sport time page 1: yes, 0: no
 turnOnStepPage = 1;                // if show step page  1: yes, o: no
 };
 705、706、707手环(里面全是BOOL值)
 customScreenModel =         {
 turnOnHeartRatePage = 1;           //if show heart rate page, 1: yes, o:no
 turnOnStepPage = 0;                // if show step page  1: yes, o: no
 turnOnCaloriesPage = 1;            //if show calory page 1: yes, 0: No
 turnOnSportsDistancePage = 0;      //if show distance page, 1: yes, o: no
 turnOnSportsTimePage = 1;          //if show sport time page 1: yes, 0: no
 turnOnSleepPage = 0;               //if show sleep page  1: yes  0: no
 turnOnSecondRunning = 1;           //if show the second running page 1: yes 0: no
 turnOnThirdRunning = 0;            //if show the third running page 1: yes, 0: no
 };

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readCustomScreenDisplayWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                                failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

#pragma mark - *********************701特有*******************************
/**
 Request device memory datas
 
 @param sucBlock success callback
 @param failBlock fail callback
 */
+ (void)readPeripheralMemoryDataWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                                   failBlock:(mk_deviceInterfaceFailedBlock)failBlock;

/**
 Request inside version No.

 @param sucBlock success callback
 @param failBlock fail callback
 */
+ (void)readInternalVersionWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                              failBlock:(mk_deviceInterfaceFailedBlock)failBlock;

/**
 Request configuration parameters.

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readConfigParamsWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                         failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

#pragma mark - ***********************非701特有**************************

/**
 Read do not disturb mode.

 periodTime =         {
 isOn = 0;              //Whether the Do Not Disturb mode function is turned on, in the case of opening, the message of incoming call, SMS, APP notification, sedentary, goal achievement, etc. will be blocked from the beginning to the end of the time period.
 endHour = 07;          //The hour when do not disturb mode.
 endMin = 00;           //The minute when do not disturb mode close.
 startHour = 22;        //The hour when do not disturb mode start.
 startMin = 00;         //the minute when do not disturb mode start.
 };
 
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readDoNotDisturbWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                         failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Read device dial type.

 Current H705 has 3 type dials(01~03), H701 and H707 has 8 type dials (01~08).
 
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readDialStyleWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                      failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

#pragma mark - ***********************706、707特有*******************************

/**
 Read date format.

 @"00" : The current bracelet display date format is day/month.
 @"01" : The current bracelet display date format is month/ day.
 
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readDateFormatterWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                          failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Read the vibration intensity of the bracelet, 1~9, unit 100ms

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readVibrationIntensityOfDeviceWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                                       failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Read the screen display list of the bracelet, return a list, the current bracelet screen is displayed according to this list.
 
 706: Today's activities (00) sports mode (01) stopwatch (02) timer (03) heart rate (04) breathing training (05) last night sleep (06) more features (07) pairing code (08).
 707: Today's event (00) stopwatch (02) timer (03) heart rate (04) breathing training (05) sleep (06) more (07) information (0b) walking (0c) running (0d) riding (0e Basketball (0f) Football (10) Yoga (11) Jumping rope (12) Mountaineering (13).
 
 screenList =         (
 04,
 06,
 08,
 09,
 0a,
 0b
 );
 
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)readDeviceScreenListWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                             failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

@end

NS_ASSUME_NONNULL_END
