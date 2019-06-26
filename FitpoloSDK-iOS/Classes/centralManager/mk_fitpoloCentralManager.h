//
//  mk_fitpoloCentralManager.h
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
/*
 Notification that the current peripheral connection status has changed and is thrown.
 */
extern NSString *const mk_peripheralConnectStateChangedNotification;
/*
 Current bracelet upgrade result notification.
 */
extern NSString *const mk_peripheralUpdateResultNotification;
/*
 Monitor the notification that the step data transmission change is thrown.
 */
extern NSString *const mk_listeningStateStepDataNotification;
/*
 Monitor the notification that the bracelet finding the cellphone is thrown.
 */
extern NSString *const mk_searchMobilePhoneNotification;

/*
 ****************************************** deviceModel ***************************************
 */
#pragma mark ****************************** deviceModel **********************************

@interface mk_fitpoloScanDeviceModel : NSObject

@property (nonatomic, strong)CBPeripheral *peripheral;

@property (nonatomic, assign)mk_fitpoloDeviceType deviceType;

@property (nonatomic, copy)NSString *deviceName;

@property (nonatomic, copy)NSString *deviceMac;

@property (nonatomic, copy)NSString *rssi;

@end

/*
 ****************************************** delegate ***************************************
 */
#pragma mark ****************************** delegate **********************************

#pragma mark - scanDelegate
@class mk_fitpoloCentralManager;
@protocol mk_scanPeripheralDelegate <NSObject>
/**
 Central strat scanning method.
 
 @param centralManager centralManager
 */
- (void)mk_centralStartScan:(mk_fitpoloCentralManager *)centralManager;
/**
 Central scan new.
 
 @param deviceModel deviceModel
 @param centralManager centralManager
 */
- (void)mk_centralDidDiscoverPeripheral:(mk_fitpoloScanDeviceModel *)deviceModel
                         centralManager:(mk_fitpoloCentralManager *)centralManager;
/**
 Central stop scanning.
 
 @param centralManager centralManager
 */
- (void)mk_centralStopScan:(mk_fitpoloCentralManager *)centralManager;

@end

#pragma mark - manager state delegate

@protocol mk_centralManagerStateDelegate <NSObject>

/**
 Central bluetooth status change.
 
 @param managerState central bluetooth status
 @param manager centralManager
 */
- (void)mk_centralStateChanged:(mk_fitpoloCentralManagerState)managerState manager:(mk_fitpoloCentralManager *)manager;

/**
 Center and peripheral connection status change.
 
 @param connectState 外设连接状态
 @param manager centralManager
 */
- (void)mk_peripheralConnectStateChanged:(mk_fitpoloConnectStatus)connectState manager:(mk_fitpoloCentralManager *)manager;

@end


@class MKFitpoloTaskOperation;
@interface mk_fitpoloCentralManager : NSObject
/**
 Current bluetooth status.
 */
@property (nonatomic, assign, readonly)mk_fitpoloCentralManagerState centralStatus;
/**
 centralManager
 */
@property (nonatomic, strong, readonly)CBCentralManager *centralManager;
/**
 Current connection status.
 */
@property (nonatomic, assign, readonly)mk_fitpoloConnectStatus connectStatus;

/**
 Current connected device.
 */
@property (nonatomic, strong, readonly)CBPeripheral *connectedPeripheral;

/**
 Current connected device type.
 */
@property (nonatomic, assign, readonly)mk_fitpoloDeviceType deviceType;

/**
 Scan delegate.
 */
@property (nonatomic, weak)id <mk_scanPeripheralDelegate>scanDelegate;

/**
 Central status delegate.
 */
@property (nonatomic, weak)id <mk_centralManagerStateDelegate>stateDelegate;

+ (mk_fitpoloCentralManager *)sharedInstance;

/*
 ****************************************** scan ***************************************
 */
#pragma mark ****************************** scan **********************************
/**
 scan
 
 @return result
 */
- (BOOL)scanDevice;

/**
 stop scan
 */
- (void)stopScan;

/*
 ****************************************** connect ***************************************
 */
#pragma mark ****************************** connect **********************************
/**
 Connect the specified peripherals according to the identifier and connection method.
 
 @param identifier The identifier of the peripheral to be connected, currently supports the device UUID, device mac address(xx-xx-xx-xx-xx-xx).
 @param deviceType Target device type.
 @param successBlock connect success callback
 @param failedBlock connect failed callback
 */
- (void)connectWithIdentifier:(NSString *)identifier
                   deviceType:(mk_fitpoloDeviceType)deviceType
              connectSucBlock:(mk_connectSuccessBlock)successBlock
             connectFailBlock:(mk_connectFailedBlock)failedBlock;
/**
 connect peripheral
 
 @param peripheral peripheral
 @param deviceType Target device type.
 @param successBlock connect success callback
 @param failedBlock connect failed callback
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral
               deviceType:(mk_fitpoloDeviceType)deviceType
          connectSucBlock:(mk_connectSuccessBlock)successBlock
         connectFailBlock:(mk_connectFailedBlock)failedBlock;
/**
 Disconnect the currently connected peripheral.
 */
- (void)disconnectConnectedPeripheral;

/*
 ****************************************** task ***************************************
 */
#pragma mark ****************************** task **********************************

- (BOOL)sendUpdateData:(NSData *)updateData;
/**
 Add a communication task (app-->peripheral) to the queue.
 
 @param operationID Task ID.
 @param resetNum Is it necessary to return the total number of communication data by the peripheral.
 @param commandData Communication data.
 @param characteristic Characteristics used in communication.
 @param successBlock success callback
 @param failureBlock failed callback
 */
- (void)addTaskWithTaskID:(mk_taskOperationID)operationID
                 resetNum:(BOOL)resetNum
              commandData:(NSString *)commandData
           characteristic:(CBCharacteristic *)characteristic
             successBlock:(mk_communicationSuccessBlock)successBlock
             failureBlock:(mk_communicationFailedBlock)failureBlock;
/**
 Add a communication task (app-->peripheral) to the queue, When only some data is obtained at the end of the task, return this part of the data to the successful callback.
 
 @param operationID Task ID.
 @param commandData Communication data.
 @param characteristic Characteristics used in communication.
 @param successBlock success callback
 @param failureBlock failed callback
 */
- (void)addNeedPartOfDataTaskWithTaskID:(mk_taskOperationID)operationID
                            commandData:(NSString *)commandData
                         characteristic:(CBCharacteristic *)characteristic
                           successBlock:(mk_communicationSuccessBlock)successBlock
                           failureBlock:(mk_communicationFailedBlock)failureBlock;
/**
 添加一个通信任务(app-->peripheral)到队列,该任务需要设置本次通信数据条数
 
 @param operationID Task ID.
 @param number Set datas number.
 @param commandData Communication data.
 @param characteristic Characteristics used in communication.
 @param successBlock success callback
 @param failureBlock failed callback
 */
- (void)addNeedResetNumTaskWithTaskID:(mk_taskOperationID)operationID
                               number:(NSInteger)number
                          commandData:(NSString *)commandData
                       characteristic:(CBCharacteristic *)characteristic
                         successBlock:(mk_communicationSuccessBlock)successBlock
                         failureBlock:(mk_communicationFailedBlock)failureBlock;
/**
 Braclet start upgrade firmware.
 
 @param crcData The locally upgraded checksum, two bytes, is obtained from the local firmware as crc16.
 @param packageSize Firmware size of this upgrade, 4 bytes.
 @param successBlock success callback
 @param failedBlock failed callback
 */
- (void)addUpdateFirmwareTaskWithCrcData:(NSData *)crcData
                             packageSize:(NSData *)packageSize
                            successBlock:(mk_communicationSuccessBlock)successBlock
                             failedBlock:(mk_communicationFailedBlock)failedBlock;

@end

NS_ASSUME_NONNULL_END
