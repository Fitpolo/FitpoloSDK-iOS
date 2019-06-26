//
//  MKUserDataInterface+Config.h
//  MKFitpolo
//
//  Created by aa on 2019/1/14.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKUserDataInterface.h"

NS_ASSUME_NONNULL_BEGIN

@interface MKUserDataInterface (Config)

/**
 Synchronize the current phone system time to the bracelet.

 @param protocol protocol
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configDate:(id <MKConfigDateProtocol>)protocol
          sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
       failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock;

/**
 Set user info.
 
 @param protocol protocol
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configUserData:(id <mk_configUserDataProtocol>)protocol
              sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
           failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock;

#pragma mark - 705、706、707

/**
 Turn on the bracelet monitoring step function, 701 does not support. When you open the monitor, register mk_listeningStateStepDataNotification notification, when the number of steps in the bracelet changes, it can be monitored in real time.

 @param open open
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configStepChangeMeterMonitoringState:(BOOL)open
                                    sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                                 failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock;

/**
 Set sport target, H701 doesn't support.
 
 @param target sport target 1~60000
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configMovingTarget:(NSInteger)target
                  sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
               failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock;

#pragma mark - 706、707

/**
 Set the interval between recording step count data

 @param interval interval,0~60
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configMeterStepInterval:(NSInteger)interval
                       sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
                    failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock;

/**
Set finding cellphone functions.
 
 @param open In the case of opening, the registration mk_searchMobilePhoneNotification notification will be notified when the bracelet triggers the search for mobile phone function.
 @param sucBlock success callback
 @param failedBlock fail callback
 */
+ (void)configSearchPhone:(BOOL)open
                 sucBlock:(mk_userDataInterfaceSucBlock)sucBlock
              failedBlock:(mk_userDataInterfaceFailedBlock)failedBlock;

@end

NS_ASSUME_NONNULL_END
