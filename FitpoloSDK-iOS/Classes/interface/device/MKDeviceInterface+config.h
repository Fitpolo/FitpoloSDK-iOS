//
//  MKDeviceInterface+config.h
//  MKFitpoloDevice
//
//  Created by aa on 2018/12/19.
//  Copyright © 2018 MK. All rights reserved.
//

#import "MKDeviceInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKDeviceInterface (config)

#pragma mark - normal

/**
 Device vibrate.

 @param count vibrate  time 1~20
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)searchDeviceWithCount:(NSInteger)count
                     sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                  failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Set device display time format.
 
 @param formatter Time format, currently supports 24 hours and 12 hours.
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configTimeFormatter:(mk_deviceTimeFormatter)formatter
                   sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Set the unit.

 @param unit Metric, imperial
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configUnit:(mk_deviceUnitType)unit
          sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
       failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Set ancs.

 @param protocol protocol
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configANCSNotice:(id <MKANCSProtocol>)protocol
                sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
             failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Set alarm.

 @param clockList alarm list
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configAlarmClock:(NSArray <id <MKSetAlarmClockProtocol>>*)clockList
                sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
             failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 sedentary reming

 @param protocol protocol
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configSedentaryRemind:(id <MKPeriodTimeSetProtocol>)protocol
                     sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                  failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Heart rate collection intervial.

 @param interval intervial
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configHeartRateAcquisitionInterval:(mk_heartRateAcquisitionInterval)interval
                                  sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                               failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Set light up screen by turning wrsit.

 @param protocol protocol
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configPalmingBrightScreen:(id <MKPeriodTimeSetProtocol>)protocol
                         sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                      failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Set whether the device remembers the last screen display.
 
 @param remind YES: Remember, display the screen page when the screen was off . NO: sreen display time page.
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configRemindLastScreenDisplay:(BOOL)remind
                             sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                          failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Custom screen display.

 @param protocol protocol
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configCustomScreenDisplay:(id <MKCustomScreenDisplayProtocol>)protocol
                         sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                      failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Shut down device.

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)powerOffDeviceWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                       failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Clear bracelet datas.

 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)clearDeviceDataWithSucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                        failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

#pragma mark - H701 doesn't support.

/**
 Set do not disturb mode, H701 doesn't support.

 @param protocol protocol
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configDoNotDisturbMode:(id <MKPeriodTimeSetProtocol>)protocol
                      sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                   failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Set watch dial, H701 don't support, H705 current has 3 dials type, H706 has 8 dials type .

 @param dialStyle dial style
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configDialStyle:(mk_fitpoloDialStyle)dialStyle
               sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
            failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

#pragma mark - H701 and H705 doesn't support.
/**
 Set H706 bracelet current display language.
 
 @param style Current support Chinese and English.
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configLanguage:(mk_languageStyle)style
              sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
           failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Braclet set display date format.

 @param formatter formatter
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configDateFormatter:(mk_dateFormatter)formatter
                   sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Bracelet vibrate intensity.

 @param power vibrate intensity 1~9
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configVibrationIntensityOfDevice:(NSInteger)power
                                sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                             failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

/**
 Bracelet sets the current screen display list.
 H706:Today's activities (00) sports mode (01) stopwatch (02) timer (03) heart rate (04) breathing training (05) last night sleep (06) more features (07) pairing code (08)
 H707:Today's event (00) stopwatch (02) timer (03) heart rate (04) breathing training (05) sleep (06) more (07) information (0b) walking (0c) running (0d) riding (0e) basketball (0f) Football (10) Yoga (11) Jumping rope (12) Mountaineering (13)
 @param screenList @[]
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configScreenList:(NSArray <NSString *>*)screenList
                sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
             failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

#pragma mark - Only H709 supports

/// H709 bracelet dial upgrade.
/// When the dial UI is upgraded, you need to call this interface to tell the bracelet which bracelet to upgrade. Only after the call is successful, you can call the [[mk_fitpoloUpdateCenter sharedInstance] startUpdateProcessWithPackageData: successBlock: progressBlock: failedBlock:] method to upgrade.
/// Note: The mage size must be 240px * 240px.The image data sent to the bracelet should be RGB565 data instead of the commonly used RGB888 data.I
/// @param index Currently only two dials support upgrade, 0 (corresponding to the third dial setting page) / and 1 (corresponding to the fourth dial setting page).
/// @param sucBlock success callback
/// @param failedBlock fail callback
+ (void)configH709DialStyleCustomUI:(MKH709CustomUIIndex)index
                           sucBlock:(mk_deviceInterfaceSucBlock)sucBlock
                        failedBlock:(mk_deviceInterfaceFailedBlock)failedBlock;

@end

NS_ASSUME_NONNULL_END
