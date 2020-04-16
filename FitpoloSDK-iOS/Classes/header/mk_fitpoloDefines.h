#import <CoreBluetooth/CoreBluetooth.h>

#define mk_validStr(f)         (f!=nil && [f isKindOfClass:[NSString class]] && ![f isEqualToString:@""])
#define mk_validDict(f)        (f!=nil && [f isKindOfClass:[NSDictionary class]] && [f count]>0)
#define mk_validArray(f)       (f!=nil && [f isKindOfClass:[NSArray class]] && [f count]>0)
#define mk_validData(f)        (f!=nil && [f isKindOfClass:[NSData class]])

typedef void(^mk_connectFailedBlock)(NSError *error);
typedef void(^mk_connectSuccessBlock)(CBPeripheral *connectedPeripheral);
typedef void(^mk_communicationSuccessBlock)(id returnData);
typedef void(^mk_communicationFailedBlock)(NSError *error);

#ifndef mk_fitpolo_main_safe
#define mk_fitpolo_main_safe(block)\
if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(dispatch_get_main_queue())) == 0) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

#pragma mark -
static NSString *const mk_communicationDataNum = @"mk_communicationDataNum";

#pragma mark - enumeration

typedef NS_ENUM(NSInteger, mk_fitpoloDeviceType) {
    mk_fitpoloUnknow,
    mk_fitpolo701,
    mk_fitpolo705,
    mk_fitpolo706,
    mk_fitpolo707,
    mk_fitpolo709,
};

typedef NS_ENUM(NSInteger, mk_fitpoloConnectStatus) {
    mk_fitpoloConnectStatusUnknow,                                           //Unknown state
    mk_fitpoloConnectStatusConnecting,                                       //connecting
    mk_fitpoloConnectStatusConnected,                                        //connect success
    mk_fitpoloConnectStatusConnectedFailed,                                  //connect fail
    mk_fitpoloConnectStatusDisconnect,                                       //disconnect
};
typedef NS_ENUM(NSInteger, mk_fitpoloCentralManagerState) {
    mk_fitpoloCentralManagerStateUnable,                           //unavailable
    mk_fitpoloCentralManagerStateEnable,                           //available
};

/**
 alarm model
 
 */
typedef NS_ENUM(NSInteger, mk_alarmClockType) {
    mk_alarmClockNormal,           //normal
    mk_alarmClockMedicine,         //take medicine
    mk_alarmClockDrink,            //drink water
    mk_alarmClockSleep,            //sleep
    mk_alarmClockExcise,           //exercise
    mk_alarmClockSport,            //sports
};
