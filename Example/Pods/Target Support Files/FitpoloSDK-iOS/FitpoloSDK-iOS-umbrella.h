#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "mk_fitpoloCentralGlobalHeader.h"
#import "mk_fitpoloAdopter.h"
#import "CBPeripheral+mk_fitpolo701.h"
#import "CBPeripheral+mk_fitpoloCurrent.h"
#import "mk_fitpoloCentralManager.h"
#import "mk_fitpoloDefines.h"
#import "mk_fitpoloTaskIDDefines.h"
#import "MKDeviceInterface+config.h"
#import "MKDeviceInterface.h"
#import "MKDeviceInterfaceAdopter.h"
#import "MKDeviceInterfaceDefine.h"
#import "MKDeviceInterfaceHeader.h"
#import "MKUserDataInterface+Config.h"
#import "MKUserDataInterface.h"
#import "MKUserDataInterfaceAdopter.h"
#import "MKUserDataInterfaceDefines.h"
#import "MKUserDataInterfaceHeader.h"
#import "mk_fitpoloLogManager.h"
#import "mk_fitpolo701Adopter.h"
#import "mk_fitpolo701Parser.h"
#import "mk_fitpoloCurrentAdopter.h"
#import "mk_fitpoloCurrentParser.h"
#import "mk_fitpoloTaskOperation.h"
#import "mk_fitpoloUpdateCenter.h"

FOUNDATION_EXPORT double FitpoloSDK_iOSVersionNumber;
FOUNDATION_EXPORT const unsigned char FitpoloSDK_iOSVersionString[];

