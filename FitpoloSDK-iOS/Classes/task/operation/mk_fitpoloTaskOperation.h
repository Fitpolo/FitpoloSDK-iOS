//
//  mk_fitpoloTaskOperation.h
//  mk_fitpoloCentralManager
//
//  Created by aa on 2018/12/10.
//  Copyright © 2018 mk_fitpolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "mk_fitpoloTaskIDDefines.h"
#import "mk_fitpoloDefines.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const mk_additionalInformation;
extern NSString *const mk_dataInformation;
extern NSString *const mk_dataStatusLev;

@interface mk_fitpoloTaskOperation : NSOperation<CBPeripheralDelegate>
/**
 Accept timer timeout, default is 2s.
 */
@property (nonatomic, assign)NSTimeInterval receiveTimeout;

/**
 Initialize the communication thread.
 
 @param operationID Current thread task ID.
 @param deviceType Current device type.
 @param resetNum If need modify the total number of data that the task needs to accept according to the total number of data returned by the peripheral, YES needs, NO does not need.
 @param commandBlock send command to callback.
 @param completeBlock Data communication completion callback.
 @return operation
 */
- (instancetype)initOperationWithID:(mk_taskOperationID)operationID
                         deviceType:(mk_fitpoloDeviceType)deviceType
                           resetNum:(BOOL)resetNum
                       commandBlock:(void (^)(void))commandBlock
                      completeBlock:(void (^)(NSError *error, mk_taskOperationID operationID, id returnData))completeBlock;

@end

NS_ASSUME_NONNULL_END
