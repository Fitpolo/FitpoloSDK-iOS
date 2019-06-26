//
//  mk_fitpoloCentralManager.m
//  mk_fitpoloCentralManager
//
//  Created by aa on 2018/12/10.
//  Copyright © 2018 mk_fitpolo. All rights reserved.
//

#import "mk_fitpoloCentralManager.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "mk_fitpoloAdopter.h"
#import "CBPeripheral+mk_fitpolo701.h"
#import "CBPeripheral+mk_fitpoloCurrent.h"
#import "mk_fitpoloTaskOperation.h"
#import "mk_fitpoloLogManager.h"

typedef NS_ENUM(NSInteger, currentManagerAction) {
    currentManagerActionDefault,
    currentManagerActionScan,
    currentManagerActionConnectPeripheral,
    currentManagerActionConnectPeripheralWithScan,
};

@interface NSObject (MKFitpoloSDK)

@end

@implementation NSObject (MKFitpoloSDK)

+ (void)load{
    [mk_fitpoloCentralManager sharedInstance];
}

@end

@implementation mk_fitpoloScanDeviceModel
@end

NSString *const mk_peripheralConnectStateChangedNotification = @"mk_peripheralConnectStateChangedNotification";
//外设固件升级结果通知,由于升级固件采用的是无应答定时器发送数据包，所以当产生升级结果的时候，需要靠这个通知来结束升级过程
NSString *const mk_peripheralUpdateResultNotification = @"mk_peripheralUpdateResultNotification";
//监听计步数据
NSString *const mk_listeningStateStepDataNotification = @"mk_listeningStateStepDataNotification";
//搜索手机通知
NSString *const mk_searchMobilePhoneNotification = @"mk_searchMobilePhoneNotification";

static mk_fitpoloCentralManager *manager = nil;
static dispatch_once_t onceToken;
static NSInteger const scanConnectMacCount = 2;

@interface mk_fitpoloCentralManager ()<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong)CBCentralManager *centralManager;

@property (nonatomic, strong)CBPeripheral *connectedPeripheral;

@property (nonatomic, strong)dispatch_queue_t centralManagerQueue;

@property (nonatomic, copy)mk_connectFailedBlock connectFailBlock;

@property (nonatomic, copy)mk_connectSuccessBlock connectSucBlock;

@property (nonatomic, assign)BOOL scanTimeout;

@property (nonatomic, assign)NSInteger scanConnectCount;

@property (nonatomic, copy)NSString *identifier;

@property (nonatomic, strong)dispatch_source_t scanTimer;

@property (nonatomic, strong)dispatch_source_t connectTimer;

@property (nonatomic, assign)currentManagerAction managerAction;

@property (nonatomic, assign)mk_fitpoloConnectStatus connectStatus;

@property (nonatomic, assign)mk_fitpoloCentralManagerState centralStatus;

@property (nonatomic, strong)NSOperationQueue *operationQueue;

@property (nonatomic, assign)BOOL connectTimeout;

@property (nonatomic, assign)BOOL isConnecting;

@property (nonatomic, assign)mk_fitpoloDeviceType deviceType;

@end

@implementation mk_fitpoloCentralManager

- (void)dealloc{
    NSLog(@"mk_fitpoloCentralManager销毁");
}

-(instancetype) initInstance {
    if (self = [super init]) {
        _centralManagerQueue = dispatch_queue_create("moko.com.centralManager", DISPATCH_QUEUE_SERIAL);
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:_centralManagerQueue];
    }
    return self;
}

+ (mk_fitpoloCentralManager *)sharedInstance{
    dispatch_once(&onceToken, ^{
        if (!manager) {
            manager = [[mk_fitpoloCentralManager alloc] initInstance];
        }
    });
    return manager;
}

+ (void)singletonDestroyed{
    onceToken = 0;
    manager = nil;
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    mk_fitpoloCentralManagerState managerState = mk_fitpoloCentralManagerStateUnable;
    if (central.state == CBCentralManagerStatePoweredOn) {
        managerState = mk_fitpoloCentralManagerStateEnable;
    }
    self.centralStatus = managerState;
    if ([self.stateDelegate respondsToSelector:@selector(mk_centralStateChanged:manager:)]) {
        mk_fitpolo_main_safe(^{
            [self.stateDelegate mk_centralStateChanged:managerState manager:manager];
        });
    }
    if (central.state == CBCentralManagerStatePoweredOn) {
        return;
    }
    if (self.connectedPeripheral) {
        [self.connectedPeripheral setFitpoloCurrentCharacteNil];
        self.connectedPeripheral = nil;
        [self.operationQueue cancelAllOperations];
    }
    if (self.connectStatus == mk_fitpoloConnectStatusConnected) {
        [self updateManagerStateConnectState:mk_fitpoloConnectStatusDisconnect];
    }
    if (self.managerAction == currentManagerActionDefault) {
        return;
    }
    if (self.managerAction == currentManagerActionScan) {
        self.managerAction = currentManagerActionDefault;
        self.deviceType = mk_fitpoloUnknow;
        [self.centralManager stopScan];
        mk_fitpolo_main_safe(^{
            if ([self.scanDelegate respondsToSelector:@selector(mk_centralStopScan:)]) {
                [self.scanDelegate mk_centralStopScan:manager];
            }
        });
        return;
    }
    if (self.managerAction == currentManagerActionConnectPeripheralWithScan) {
        [self.centralManager stopScan];
    }
    [self connectPeripheralFailed];
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI{
    if ([RSSI integerValue] == 127) {
        return;
    }
    dispatch_async(_centralManagerQueue, ^{
        [self scanNewPeripheral:peripheral advDic:advertisementData rssi:RSSI];
    });
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    [mk_fitpoloLogManager writeCommandToLocalFile:@[@"连接设备成功，尚未发现特征"] sourceInfo:mk_logDataSourceAPP];
    if (self.connectTimeout || self.deviceType == mk_fitpoloUnknow) {
        return;
    }
    self.connectedPeripheral = peripheral;
    self.connectedPeripheral.delegate = self;
    if (self.deviceType == mk_fitpolo701) {
        [self.connectedPeripheral setFitpolo701CharacterNil];
        [self.connectedPeripheral discoverServices:@[[CBUUID UUIDWithString:@"FFC0"]]];
        return;
    }
    [self.connectedPeripheral setFitpoloCurrentCharacteNil];
    [self.connectedPeripheral discoverServices:@[[CBUUID UUIDWithString:@"FFB0"],[CBUUID UUIDWithString:@"FFC0"]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if (error) {
        [mk_fitpoloLogManager writeCommandToLocalFile:@[@"设备连接出现了错误:%@",[error localizedDescription]]
                                          sourceInfo:mk_logDataSourceAPP];
    }
    [self connectPeripheralFailed];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"断开连接");
    if (error) {
        [mk_fitpoloLogManager writeCommandToLocalFile:@[@"设备断开了连接:%@",[error localizedDescription]]
                                          sourceInfo:mk_logDataSourceAPP];
    }
    if (self.deviceType == mk_fitpoloUnknow) {
        return;
    }
    if (self.connectStatus != mk_fitpoloConnectStatusConnected) {
        //如果是连接过程中发生的断开连接不处理
        [mk_fitpoloLogManager writeCommandToLocalFile:@[@"连接过程中的断开连接不需处理"] sourceInfo:mk_logDataSourceAPP];
        return;
    }
    if (self.deviceType == mk_fitpolo701) {
        [self.connectedPeripheral setFitpolo701CharacterNil];
    }else{
        [self.connectedPeripheral setFitpoloCurrentCharacteNil];
    }
    self.deviceType = mk_fitpoloUnknow;
    self.connectedPeripheral = nil;
    [self updateManagerStateConnectState:mk_fitpoloConnectStatusDisconnect];
    [self.operationQueue cancelAllOperations];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        [mk_fitpoloLogManager writeCommandToLocalFile:@[@"发现服务出错:%@",[error localizedDescription]]
                                          sourceInfo:mk_logDataSourceAPP];
        [self connectPeripheralFailed];
        return;
    }
    if (self.connectTimeout || self.deviceType == mk_fitpoloUnknow) {
        return;
    }
    if (self.deviceType == mk_fitpolo701) {
        [self.connectedPeripheral setFitpolo701CharacterNil];
        for (CBService *service in peripheral.services) {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFC0"]]) {
                //通用服务
                [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"FFC1"],
                                                      [CBUUID UUIDWithString:@"FFC2"]]
                                         forService:service];
            }
            break;
        }
        return;
    }
    //
    [self.connectedPeripheral setFitpoloCurrentCharacteNil];
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFB0"]]) {
            //通用服务
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"FFB0"],
                                                  [CBUUID UUIDWithString:@"FFB1"],
                                                  [CBUUID UUIDWithString:@"FFB2"],
                                                  [CBUUID UUIDWithString:@"FFB3"]]
                                     forService:service];
        }else if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFC0"]]){
            //升级服务
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"FFC1"],
                                                  [CBUUID UUIDWithString:@"FFC2"]]
                                     forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        [mk_fitpoloLogManager writeCommandToLocalFile:@[@"发现特征出错:%@",[error localizedDescription]]
                                          sourceInfo:mk_logDataSourceAPP];
        [self connectPeripheralFailed];
        return;
    }
    if (self.connectTimeout || self.deviceType == mk_fitpoloUnknow) {
        return;
    }
    if (self.deviceType == mk_fitpolo701) {
        [self.connectedPeripheral update701CharacteristicsForService:service];
        if ([self.connectedPeripheral fitpolo701ConnectSuccess]) {
            [self connectPeripheralSuccess];
        }
        return;
    }
    //
    [self.connectedPeripheral updateCurrentCharacteristicsForService:service];
    if ([self.connectedPeripheral fitpoloCurrentConnectSuccess]) {
        //发现所有的特征不能认为是连接成功，必须等到要监听的所有特征都监听成功了才认为是连接成功
        [self connectPeripheralSuccess];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        [mk_fitpoloLogManager writeCommandToLocalFile:@[@"接受数据出错:%@",[error localizedDescription]]
                                          sourceInfo:mk_logDataSourceAPP];
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFC2"]]){
        NSString *content = [mk_fitpoloAdopter hexStringFromData:characteristic.value];
        if (mk_validStr(content) && content.length == 4) {
            //升级监听
            NSString *header = [content substringWithRange:NSMakeRange(0, 2)];
            if ([header isEqualToString:@"a7"]){
                //升级结果
                NSString *origData = [NSString stringWithFormat:@"手环升级数据:%@",content];
                [mk_fitpoloLogManager writeCommandToLocalFile:@[origData] sourceInfo:mk_logDataSourceDevice];
                //抛出升级结果通知，@"00"成功@"01"超时@"02"校验码错误@"03"文件错误
                [[NSNotificationCenter defaultCenter] postNotificationName:mk_peripheralUpdateResultNotification
                                                                    object:nil
                                                                  userInfo:@{@"updateResult" : [content substringWithRange:NSMakeRange(2, 2)]}];
            }
        }
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB2"]]){
        //判断是不是实时计步数据
        NSData *readData = characteristic.value;
        NSString *content = [mk_fitpoloAdopter hexStringFromData:readData];
        if (!mk_validData(readData) || !mk_validStr(content) || content.length < 6) {
            return;
        }
        if ([[content substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"b5"]) {
            //应答帧头b5
            NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
            if ([function isEqualToString:@"04"] && content.length == 26){
                //手环反馈过来的计步实时数据
                NSDictionary *dataDic = [self getListeningStateStepData:[content substringWithRange:NSMakeRange(6, 20)]];
                [[NSNotificationCenter defaultCenter] postNotificationName:mk_listeningStateStepDataNotification
                                                                    object:nil
                                                                  userInfo:@{@"stepData" : dataDic}];
                return;
            }
        }
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFB1"]]){
        //寻找手机功能
        NSData *readData = characteristic.value;
        NSString *content = [mk_fitpoloAdopter hexStringFromData:readData];
        if (content.length >= 6 && [[content substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"b3"]) {
            NSString *function = [content substringWithRange:NSMakeRange(2, 2)];
            if ([function isEqualToString:@"17"] && [[content substringWithRange:NSMakeRange(6, 2)] isEqualToString:@"01"]) {
                //手机需要响铃+震动
                [[NSNotificationCenter defaultCenter] postNotificationName:mk_searchMobilePhoneNotification object:nil];
                return;
            }
        }
    }
    @synchronized(self.operationQueue) {
        NSArray *operations = [self.operationQueue.operations copy];
        for (mk_fitpoloTaskOperation *operation in operations) {
            if (operation.executing) {
                [operation peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:NULL];
                break;
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
        [mk_fitpoloLogManager writeCommandToLocalFile:@[@"设置监听属性回调发生了错误",[error localizedDescription]]
                                          sourceInfo:mk_logDataSourceAPP];
        return;
    }
    if (self.connectTimeout || self.deviceType == mk_fitpoloUnknow) {
        return;
    }
    [mk_fitpoloLogManager writeCommandToLocalFile:@[@"设置监听属性回调成功",characteristic.UUID.UUIDString] sourceInfo:mk_logDataSourceAPP];
    if (self.deviceType == mk_fitpolo701) {
        [self.connectedPeripheral update701NotifySuccess:characteristic];
        if ([self.connectedPeripheral fitpolo701ConnectSuccess]) {
            //发现所有的特征不能认为是连接成功，必须等到要监听的所有特征都监听成功了才认为是连接成功
            [self connectPeripheralSuccess];
        }
        return;
    }
    [self.connectedPeripheral updateCurrentNotifySuccess:characteristic];
    if ([self.connectedPeripheral fitpoloCurrentConnectSuccess]) {
        //发现所有的特征不能认为是连接成功，必须等到要监听的所有特征都监听成功了才认为是连接成功
        [self connectPeripheralSuccess];
    }
}

#pragma mark - ***********************public method************************
#pragma mark - scan method
- (BOOL)scanDevice{
    if (self.isConnecting) {
        return NO;
    }
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        //蓝牙状态不可用
        return NO;
    }
    self.managerAction = currentManagerActionScan;
    if ([self.scanDelegate respondsToSelector:@selector(mk_centralStartScan:)]) {
        mk_fitpolo_main_safe(^{
            [self.scanDelegate mk_centralStartScan:manager];
        });
    }
    [mk_fitpoloLogManager writeCommandToLocalFile:@[@"开始扫描"] sourceInfo:mk_logDataSourceAPP];
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFC0"]] options:nil];
    return YES;
}

- (void)stopScan{
    if ([self.scanDelegate respondsToSelector:@selector(mk_centralStopScan:)]) {
        mk_fitpolo_main_safe(^{
            [self.scanDelegate mk_centralStopScan:manager];
        });
    }
    [mk_fitpoloLogManager writeCommandToLocalFile:@[@"停止扫描"] sourceInfo:mk_logDataSourceAPP];
    if (self.isConnecting) {
        //连接过程中不允许调用
        return;
    }
    [self.centralManager stopScan];
    self.managerAction = currentManagerActionDefault;
}

#pragma mark - connect method

- (void)connectWithIdentifier:(NSString *)identifier
                   deviceType:(mk_fitpoloDeviceType)deviceType
              connectSucBlock:(mk_connectSuccessBlock)successBlock
             connectFailBlock:(mk_connectFailedBlock)failedBlock{
    if (self.isConnecting) {
        [mk_fitpoloAdopter operationConnectingErrorBlock:failedBlock];
        return;
    }
    self.isConnecting = YES;
    if (![mk_fitpoloAdopter checkIdenty:identifier]) {
        //参数错误
        self.isConnecting = NO;
        [mk_fitpoloAdopter operationConnectFailedBlock:failedBlock];
        return;
    }
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        //蓝牙状态不可用
        self.isConnecting = NO;
        [mk_fitpoloAdopter operationCentralBlePowerOffBlock:failedBlock];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self mk_connectWithIdentifier:identifier
                        deviceType:deviceType
                      successBlock:^(CBPeripheral *connectedPeripheral) {
                          if (successBlock) {
                              successBlock(connectedPeripheral);
                          }
                          [weakSelf clearConnectBlock];
                      }
                         failBlock:^(NSError *error) {
                             if (failedBlock) {
                                 failedBlock(error);
                             }
                             [weakSelf clearConnectBlock];
                         }];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral
               deviceType:(mk_fitpoloDeviceType)deviceType
          connectSucBlock:(mk_connectSuccessBlock)successBlock
         connectFailBlock:(mk_connectFailedBlock)failedBlock{
    if (self.isConnecting) {
        [mk_fitpoloAdopter operationConnectingErrorBlock:failedBlock];
        return;
    }
    self.isConnecting = YES;
    if (!peripheral) {
        self.isConnecting = NO;
        [mk_fitpoloAdopter operationConnectFailedBlock:failedBlock];
        return;
    }
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        //蓝牙状态不可用
        self.isConnecting = NO;
        [mk_fitpoloAdopter operationCentralBlePowerOffBlock:failedBlock];
        return;
    }
    self.deviceType = deviceType;
    __weak typeof(self) weakSelf = self;
    [self connectWithPeripheral:peripheral sucBlock:^(CBPeripheral *connectedPeripheral) {
        if (successBlock) {
            successBlock(connectedPeripheral);
        }
        [weakSelf clearConnectBlock];
    } failedBlock:^(NSError *error) {
        if (failedBlock) {
            failedBlock(error);
        }
        [weakSelf clearConnectBlock];
    }];
}

/**
 断开当前连接的外设
 */
- (void)disconnectConnectedPeripheral{
    if (!self.connectedPeripheral
        || self.centralManager.state != CBCentralManagerStatePoweredOn
        || self.deviceType == mk_fitpoloUnknow) {
        return;
    }
    [self.connectedPeripheral setFitpoloCurrentCharacteNil];
    [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
    self.isConnecting = NO;
}

#pragma mark ****************************** task **********************************

- (BOOL)sendUpdateData:(NSData *)updateData{
    if (self.deviceType == mk_fitpoloUnknow
        || !mk_validData(updateData)
        || self.connectStatus != mk_fitpoloConnectStatusConnected) {
        return NO;
    }
    if (self.deviceType == mk_fitpolo701 && (!self.connectedPeripheral.commandSend || !self.connectedPeripheral.commandNotify)) {
        //701
        return NO;
    }
    if ((self.deviceType == mk_fitpolo705 || self.deviceType == mk_fitpolo706)
        && (!self.connectedPeripheral.updateWrite || !self.connectedPeripheral.updateNotify)) {
        //705、706
        return NO;
    }
    CBCharacteristic *character = (self.deviceType == mk_fitpolo701 ? self.connectedPeripheral.commandSend : self.connectedPeripheral.updateWrite);
    [self.connectedPeripheral writeValue:updateData
                       forCharacteristic:character
                                    type:CBCharacteristicWriteWithoutResponse];
    NSString *string = [NSString stringWithFormat:@"%@:%@",@"固件升级数据",[mk_fitpoloAdopter hexStringFromData:updateData]];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[string] sourceInfo:mk_logDataSourceAPP];
    return YES;
}

- (void)addTaskWithTaskID:(mk_taskOperationID)operationID
                 resetNum:(BOOL)resetNum
              commandData:(NSString *)commandData
           characteristic:(CBCharacteristic *)characteristic
             successBlock:(mk_communicationSuccessBlock)successBlock
             failureBlock:(mk_communicationFailedBlock)failureBlock{
    mk_fitpoloTaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                                      resetNum:resetNum
                                                                   commandData:commandData
                                                                characteristic:characteristic
                                                                  successBlock:successBlock
                                                                  failureBlock:failureBlock];
    if (!operation) {
        return;
    }
    @synchronized(self.operationQueue) {
        [self.operationQueue addOperation:operation];
    }
}

- (void)addNeedPartOfDataTaskWithTaskID:(mk_taskOperationID)operationID
                            commandData:(NSString *)commandData
                         characteristic:(CBCharacteristic *)characteristic
                           successBlock:(mk_communicationSuccessBlock)successBlock
                           failureBlock:(mk_communicationFailedBlock)failureBlock{
    mk_fitpoloTaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                                      resetNum:YES
                                                                   commandData:commandData
                                                                characteristic:characteristic
                                                                  successBlock:successBlock
                                                                  failureBlock:failureBlock];
    if (!operation) {
        return;
    }
    SEL selNeedPartOfData = sel_registerName("needPartOfData:");
    if ([operation respondsToSelector:selNeedPartOfData]) {
        ((void (*)(id, SEL, NSNumber*))(void *) objc_msgSend)((id)operation, selNeedPartOfData, @(YES));
    }
    @synchronized(self.operationQueue) {
        [self.operationQueue addOperation:operation];
    }
}

- (void)addNeedResetNumTaskWithTaskID:(mk_taskOperationID)operationID
                               number:(NSInteger)number
                          commandData:(NSString *)commandData
                       characteristic:(CBCharacteristic *)characteristic
                         successBlock:(mk_communicationSuccessBlock)successBlock
                         failureBlock:(mk_communicationFailedBlock)failureBlock{
    if (number < 1) {
        return;
    }
    mk_fitpoloTaskOperation *operation = [self generateOperationWithOperationID:operationID
                                                                      resetNum:NO
                                                                   commandData:commandData
                                                                characteristic:characteristic
                                                                  successBlock:successBlock
                                                                  failureBlock:failureBlock];
    if (!operation) {
        return;
    }
    SEL setNum = sel_registerName("setRespondCount:");
    NSString *numberString = [NSString stringWithFormat:@"%ld",(long)number];
    if ([operation respondsToSelector:setNum]) {
        ((void (*)(id, SEL, NSString*))(void *) objc_msgSend)((id)operation, setNum, numberString);
    }
    @synchronized(self.operationQueue) {
        [self.operationQueue addOperation:operation];
    }
}

- (void)addUpdateFirmwareTaskWithCrcData:(NSData *)crcData
                             packageSize:(NSData *)packageSize
                            successBlock:(mk_communicationSuccessBlock)successBlock
                             failedBlock:(mk_communicationFailedBlock)failedBlock{
    if (!mk_validData(crcData) || !mk_validData(packageSize)) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failedBlock];
        return;
    }
    NSData *headerData = [mk_fitpoloAdopter stringToData:@"28"];
    NSMutableData *commandData = [NSMutableData dataWithData:headerData];
    [commandData appendData:crcData];
    [commandData appendData:packageSize];
    NSString *commandString = [mk_fitpoloAdopter hexStringFromData:commandData];
    CBCharacteristic *character = (self.deviceType == mk_fitpolo701 ? self.connectedPeripheral.commandSend : self.connectedPeripheral.updateWrite);
    mk_fitpoloTaskOperation *operation = [self generateOperationWithOperationID:mk_startUpdateOperation
                                                                      resetNum:NO
                                                                   commandData:commandString
                                                                characteristic:character
                                                                  successBlock:successBlock
                                                                  failureBlock:failedBlock];
    if (!operation) {
        return;
    }
    operation.receiveTimeout = 5.f;
    @synchronized(self.operationQueue) {
        [self.operationQueue addOperation:operation];
    }
}

#pragma mark - ***************private method******************
#pragma mark - scan
- (void)scanNewPeripheral:(CBPeripheral *)peripheral advDic:(NSDictionary *)advDic rssi:(NSNumber *)rssi{
    if (self.managerAction == currentManagerActionDefault
        || !mk_validDict(advDic)) {
        return;
    }
    mk_fitpoloScanDeviceModel *dataModel = [self parseDeviceModel:advDic rssi:rssi];
    if (dataModel.deviceType == mk_fitpoloUnknow) {
        return;
    }
    dataModel.peripheral = peripheral;
    NSString *name = [NSString stringWithFormat:@"扫描到的设备名字:%@", dataModel.deviceName];
    NSString *uuid = [NSString stringWithFormat:@"设备UUID:%@", peripheral.identifier.UUIDString];
    NSString *mac = [NSString stringWithFormat:@"设备MAC地址:%@", dataModel.deviceMac];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[name,uuid,mac] sourceInfo:mk_logDataSourceAPP];
    if (self.managerAction == currentManagerActionScan) {
        //扫描情况下
        if ([self.scanDelegate respondsToSelector:@selector(mk_centralDidDiscoverPeripheral:centralManager:)]) {
            mk_fitpolo_main_safe(^{
                [self.scanDelegate mk_centralDidDiscoverPeripheral:dataModel centralManager:manager];
            });
        }
        return;
    }
    if (self.managerAction != currentManagerActionConnectPeripheralWithScan
        || self.scanTimeout
        || self.scanConnectCount > 2) {
        return;
    }
    if (![self isTargetPeripheral:dataModel]) {
        return;
    }
    self.connectedPeripheral = peripheral;
    //开始连接目标设备
    [self centralConnectPeripheral:peripheral];
}

- (mk_fitpoloScanDeviceModel *)parseDeviceModel:(NSDictionary *)advDic rssi:(NSNumber *)rssi{
    if (!mk_validDict(advDic)) {
        return nil;
    }
    NSData *data = advDic[CBAdvertisementDataManufacturerDataKey];
    if (data.length != 9) {
        return nil;
    }
    NSString *temp = data.description;
    temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"<" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSString *macAddress = [NSString stringWithFormat:@"%@-%@-%@-%@-%@-%@",
                            [temp substringWithRange:NSMakeRange(0, 2)],
                            [temp substringWithRange:NSMakeRange(2, 2)],
                            [temp substringWithRange:NSMakeRange(4, 2)],
                            [temp substringWithRange:NSMakeRange(6, 2)],
                            [temp substringWithRange:NSMakeRange(8, 2)],
                            [temp substringWithRange:NSMakeRange(10, 2)]];
    NSString *deviceType = [temp substringWithRange:NSMakeRange(12, 2)];
    mk_fitpoloScanDeviceModel *dataModel = [[mk_fitpoloScanDeviceModel alloc] init];
    dataModel.deviceMac = [macAddress uppercaseString];
    if ([deviceType isEqualToString:@"02"]) {
        //701
        dataModel.deviceType = mk_fitpolo701;
    }else if ([deviceType isEqualToString:@"05"]) {
        //705
        dataModel.deviceType = mk_fitpolo705;
    }else if ([deviceType isEqualToString:@"06"]) {
        //706
        dataModel.deviceType = mk_fitpolo706;
    }else if ([deviceType isEqualToString:@"07"]) {
        //707
        dataModel.deviceType = mk_fitpolo707;
    }
    dataModel.deviceName = advDic[CBAdvertisementDataLocalNameKey];
    dataModel.rssi = [NSString stringWithFormat:@"%ld",(long)[rssi integerValue]];
    return dataModel;
}

- (BOOL)isTargetPeripheral:(mk_fitpoloScanDeviceModel *)deviceModel{
    if (!deviceModel) {
        return NO;
    }
    NSString *macLow = [[deviceModel.deviceMac lowercaseString] substringWithRange:NSMakeRange(12, 5)];
    if ([self.identifier isEqualToString:macLow]) {
        return YES;
    }
    if ([self.identifier isEqualToString:[deviceModel.deviceMac lowercaseString]]) {
        return YES;
    }
    if ([self.identifier isEqualToString:[deviceModel.peripheral.identifier.UUIDString lowercaseString]]) {
        return YES;
    }
    return NO;
}

#pragma mark - connect
- (void)connectWithPeripheral:(CBPeripheral *)peripheral
                     sucBlock:(mk_connectSuccessBlock)sucBlock
                  failedBlock:(mk_connectFailedBlock)failedBlock{
    if (self.connectedPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
        [self.operationQueue cancelAllOperations];
        [self.connectedPeripheral setFitpoloCurrentCharacteNil];
    }
    [mk_fitpoloLogManager writeCommandToLocalFile:@[@"开始连接手环"] sourceInfo:mk_logDataSourceAPP];
    self.connectedPeripheral = nil;
    self.connectedPeripheral = peripheral;
    self.managerAction = currentManagerActionConnectPeripheral;
    self.connectSucBlock = sucBlock;
    self.connectFailBlock = failedBlock;
    [self centralConnectPeripheral:peripheral];
}

- (void)centralConnectPeripheral:(CBPeripheral *)peripheral{
    if (!peripheral) {
        return;
    }
    if (self.scanTimer) {
        dispatch_cancel(self.scanTimer);
    }
    [self.centralManager stopScan];
    [self updateManagerStateConnectState:mk_fitpoloConnectStatusConnecting];
    [self initConnectTimer];
    [self.centralManager connectPeripheral:peripheral options:@{}];
}

- (void)initConnectTimer{
    self.connectTimeout = NO;
    self.connectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,_centralManagerQueue);
    dispatch_source_set_timer(self.connectTimer, dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC),  20 * NSEC_PER_SEC, 0);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.connectTimer, ^{
        weakSelf.connectTimeout = YES;
        [weakSelf connectPeripheralFailed];
    });
    dispatch_resume(self.connectTimer);
}

- (void)mk_connectWithIdentifier:(NSString *)identifier
                      deviceType:(mk_fitpoloDeviceType)deviceType
                    successBlock:(mk_connectSuccessBlock)successBlock
                       failBlock:(mk_connectFailedBlock)failedBlock{
    self.deviceType = deviceType;
    if (self.connectedPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
        [self.operationQueue cancelAllOperations];
        [self.connectedPeripheral setFitpoloCurrentCharacteNil];
        [self.connectedPeripheral setFitpolo701CharacterNil];
    }
    self.connectedPeripheral = nil;
    self.identifier = [identifier lowercaseString];
    self.managerAction = currentManagerActionConnectPeripheralWithScan;
    self.connectSucBlock = successBlock;
    self.connectFailBlock = failedBlock;
    //通过扫描方式连接设备的时候，开始扫描应该视为开始连接
    [self updateManagerStateConnectState:mk_fitpoloConnectStatusConnecting];
    [self startConnectPeripheralWithScan];
}

- (void)startConnectPeripheralWithScan{
    [self.centralManager stopScan];
    self.scanTimeout = NO;
    self.scanTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,_centralManagerQueue);
    dispatch_source_set_timer(self.scanTimer, dispatch_time(DISPATCH_TIME_NOW, 6.0 * NSEC_PER_SEC), 6.0 * NSEC_PER_SEC, 0);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(self.scanTimer, ^{
        [weakSelf scanTimerTimeoutProcess];
    });
    dispatch_resume(self.scanTimer);
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFC0"]] options:nil];
}

- (void)scanTimerTimeoutProcess{
    [self.centralManager stopScan];
    if (self.managerAction != currentManagerActionConnectPeripheralWithScan) {
        return;
    }
    self.scanTimeout = YES;
    self.scanConnectCount ++;
    //扫描方式来连接设备
    if (self.scanConnectCount > scanConnectMacCount) {
        //如果扫描连接超时，则直接连接失败，停止扫描
        [self connectPeripheralFailed];
        return;
    }
    //如果小于最大的扫描连接次数，则开启下一轮扫描
    self.scanTimeout = NO;
    [mk_fitpoloLogManager writeCommandToLocalFile:@[@"开启新一轮扫描设备去连接"] sourceInfo:mk_logDataSourceAPP];
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"FFC0"]] options:nil];
}

- (void)resetOriSettings{
    if (self.connectTimer) {
        dispatch_cancel(self.connectTimer);
    }
    if (self.scanTimer) {
        dispatch_cancel(self.scanTimer);
    }
    if (self.managerAction == currentManagerActionConnectPeripheralWithScan) {
        [self.centralManager stopScan];
    }
    self.managerAction = currentManagerActionDefault;
    self.scanTimeout = NO;
    self.scanConnectCount = 0;
    self.connectTimeout = NO;
    self.isConnecting = NO;
}

- (void)connectPeripheralFailed{
    [self resetOriSettings];
    if (self.connectedPeripheral) {
        [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
        self.connectedPeripheral.delegate = nil;
        [self.connectedPeripheral setFitpoloCurrentCharacteNil];
    }
    self.connectedPeripheral = nil;
    [self updateManagerStateConnectState:mk_fitpoloConnectStatusConnectedFailed];
    [mk_fitpoloAdopter operationConnectFailedBlock:self.connectFailBlock];
}

- (void)connectPeripheralSuccess{
    if (self.connectTimeout) {
        return;
    }
    [self resetOriSettings];
    [self updateManagerStateConnectState:mk_fitpoloConnectStatusConnected];
    NSString *tempString = [NSString stringWithFormat:@"连接的设备UUID:%@",self.connectedPeripheral.identifier.UUIDString];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[tempString] sourceInfo:mk_logDataSourceAPP];
    mk_fitpolo_main_safe(^{
        if (self.connectSucBlock) {
            self.connectSucBlock(self.connectedPeripheral);
        }
    });
}

- (void)clearConnectBlock{
    if (self.connectSucBlock) {
        self.connectSucBlock = nil;
    }
    if (self.connectFailBlock) {
        self.connectFailBlock = nil;
    }
}

- (void)updateManagerStateConnectState:(mk_fitpoloConnectStatus)state{
    self.connectStatus = state;
    mk_fitpolo_main_safe(^{
        [[NSNotificationCenter defaultCenter] postNotificationName:mk_peripheralConnectStateChangedNotification object:nil];
        if ([self.stateDelegate respondsToSelector:@selector(mk_peripheralConnectStateChanged:manager:)]) {
            [self.stateDelegate mk_peripheralConnectStateChanged:state manager:manager];
        }
    });
}

#pragma mark - 数据通信处理方法
- (void)sendCommandToPeripheral:(NSString *)commandData characteristic:(CBCharacteristic *)characteristic{
    if (!self.connectedPeripheral || !mk_validStr(commandData) || !characteristic) {
        return;
    }
    NSData *data = [mk_fitpoloAdopter stringToData:commandData];
    if (!mk_validData(data)) {
        return;
    }
    [self.connectedPeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

- (BOOL)canSendData{
    if (!self.connectedPeripheral) {
        return NO;
    }
    return (self.connectedPeripheral.state == CBPeripheralStateConnected);
}

- (mk_fitpoloTaskOperation *)generateOperationWithOperationID:(mk_taskOperationID)operationID
                                                    resetNum:(BOOL)resetNum
                                                 commandData:(NSString *)commandData
                                              characteristic:(CBCharacteristic *)characteristic
                                                successBlock:(mk_communicationSuccessBlock)successBlock
                                                failureBlock:(mk_communicationFailedBlock)failureBlock{
    if (![self canSendData]) {
        [mk_fitpoloAdopter operationDisconnectedErrorBlock:failureBlock];
        return nil;
    }
    if (self.deviceType == mk_fitpoloUnknow) {
        [mk_fitpoloAdopter operationDeviceTypeErrorBlock:failureBlock];
        return nil;
    }
    if (!mk_validStr(commandData)) {
        [mk_fitpoloAdopter operationParamsErrorBlock:failureBlock];
        return nil;
    }
    if (!characteristic) {
        [mk_fitpoloAdopter operationCharacteristicErrorBlock:failureBlock];
        return nil;
    }
    __weak typeof(self) weakSelf = self;
    mk_fitpoloTaskOperation *operation = [[mk_fitpoloTaskOperation alloc] initOperationWithID:operationID deviceType:self.deviceType resetNum:resetNum commandBlock:^{
        [weakSelf sendCommandToPeripheral:commandData characteristic:characteristic];
        [weakSelf writeDataToLog:commandData operation:operationID];
    } completeBlock:^(NSError * _Nonnull error, mk_taskOperationID operationID, id  _Nonnull returnData) {
        if (error) {
            mk_fitpolo_main_safe(^{
                if (failureBlock) {
                    failureBlock(error);
                }
            });
            return ;
        }
        if (!returnData) {
            [mk_fitpoloAdopter operationRequestDataErrorBlock:failureBlock];
            return ;
        }
        NSString *lev = returnData[mk_dataStatusLev];
        if ([lev isEqualToString:@"1"]) {
            //通用无附加信息的
            NSArray *dataList = (NSArray *)returnData[mk_dataInformation];
            if (!dataList) {
                [mk_fitpoloAdopter operationRequestDataErrorBlock:failureBlock];
                return;
            }
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":(dataList.count == 1 ? dataList[0] : dataList),
                                        };
            mk_fitpolo_main_safe(^{
                if (successBlock) {
                    successBlock(resultDic);
                }
            });
            return;
        }
        //对于有附加信息的
        NSDictionary *resultDic = @{@"msg":@"success",
                                    @"code":@"1",
                                    @"result":returnData[mk_dataInformation],
                                    };
        mk_fitpolo_main_safe(^{
            if (successBlock) {
                successBlock(resultDic);
            }
        });
    }];
    return operation;
}

- (void)writeDataToLog:(NSString *)commandData operation:(mk_taskOperationID)operationID{
    if (!mk_validStr(commandData)) {
        return;
    }
    NSString *commandType = [self getCommandType:operationID];
    if (!mk_validStr(commandType)) {
        return;
    }
    NSString *string = [NSString stringWithFormat:@"%@:%@",commandType,commandData];
    [mk_fitpoloLogManager writeCommandToLocalFile:@[string] sourceInfo:mk_logDataSourceAPP];
}

- (NSString *)getCommandType:(mk_taskOperationID)operationID{
    switch (operationID) {
        case mk_readAlarmClockOperation:
            return @"读取手环闹钟数据";
        case mk_readAncsOptionsOperation:
            return @"读取手环ancs选项";
        case mk_readSedentaryRemindOperation:
            return @"读取手环久坐提醒数据";
        case mk_readMovingTargetOperation:
            return @"读取手环运动目标值";
        case mk_readUnitDataOperation:
            return @"读取手环单位信息";
        case mk_readTimeFormatDataOperation:
            return @"读取手环时间进制";
        case mk_readCustomScreenDisplayOperation:
            return @"读取手环屏幕显示";
        case mk_readRemindLastScreenDisplayOperation:
            return @"读取是否显示上一次屏幕";
        case mk_readHeartRateAcquisitionIntervalOperation:
            return @"读取心率采集间隔";
        case mk_readDoNotDisturbTimeOperation:
            return @"读取勿扰时段";
        case mk_readPalmingBrightScreenOperation:
            return @"读取翻腕亮屏信息";
        case mk_readUserInfoOperation:
            return @"读取个人信息";
        case mk_readSportsDataOperation:
            return @"读取运动信息";
        case mk_readLastChargingTimeOperation:
            return @"读取上一次手环充电时间";
        case mk_readBatteryOperation:
            return @"读取手环电池电量";
        case mk_vibrationOperation:
            return @"手环震动";
        case mk_configUnitOperation:
            return @"设置单位信息";
        case mk_configANCSOptionsOperation:
            return @"设置ancs通知选项";
        case mk_configDateOperation:
            return @"设置日期";
        case mk_configUserInfoOperation:
            return @"设置个人信息";
        case mk_configTimeFormatOperation:
            return @"设置时间进制格式";
        case mk_openPalmingBrightScreenOperation:
            return @"设置翻腕亮屏";
        case mk_configAlarmClockOperation:
            return @"设置闹钟";
        case mk_remindLastScreenDisplayOperation:
            return @"设置上一次屏幕显示";
        case mk_configSedentaryRemindOperation:
            return @"设置久坐提醒";
        case mk_configHeartRateAcquisitionIntervalOperation:
            return @"设置心率采集间隔";
        case mk_configScreenDisplayOperation:
            return @"设置屏幕显示";
        case mk_readHardwareParametersOperation:
            return @"获取硬件参数";
        case mk_readFirmwareVersionOperation:
            return @"获取固件版本号";
        case mk_readStepDataOperation:
            return @"获取计步数据";
        case mk_readSleepIndexOperation:
            return @"获取睡眠index数据";
        case mk_readSleepRecordOperation:
            return @"获取睡眠record数据";
        case mk_readHeartDataOperation:
            return @"获取心率数据";
        case mk_startUpdateOperation:
            return @"开启手环升级";
        case mk_configMovingTargetOperation:
            return @"设置运动目标";
        case mk_configDoNotDisturbTimeOperation:
            return @"设置勿扰时段";
        case mk_readSportHeartDataOperation:
            return @"获取运动心率数据";
        case mk_configAlarmClockNumbersOperation:
            return @"设置闹钟组数";
        case mk_readANCSConnectStatusOperation:
            return @"获取手环ancs连接状态";
        case mk_readDialStyleOperation:
            return @"获取手环表盘样式";
        case mk_configDialStyleOperation:
            return @"设置表盘样式";
        case mk_stepChangeMeterMonitoringStatusOperation:
            return @"改变计步监听功能状态";
        case mk_readMemoryDataOperation:
            return @"获取memory数据";
        case mk_readInternalVersionOperation:
            return @"获取内部版本号";
        case mk_readConfigurationParametersOperation:
            return @"获取配置参数";
        case mk_openANCSOperation:
            return @"701手环开启ancs选项";
        case mk_readDateFormatterOperation:
            return @"读取706日期制式";
        case mk_configDateFormatterOperation:
            return @"设置706日期制式";
        case mk_readLanguageOperation:
            return @"读取706当前显示语言";
        case mk_configLanguageOperation:
            return @"设置706当前显示的语言";
        case mk_readVibrationIntensityOfDeviceOperation:
            return @"读取706当前震动强度";
        case mk_configVibrationIntensityOfDeviceOperation:
            return @"设置706当前震动强度";
        case mk_readScreenListOperation:
            return @"读取706屏幕显示列表";
        case mk_configScreenListOperation:
            return @"设置706屏幕显示列表";
        case mk_powerOffDeviceOperation:
            return @"关机设备";
        case mk_clearDeviceDataOperation:
            return @"恢复出厂设置";
        case mk_configStepIntervalOperation:
            return @"设置706计步间隔";
        case mk_readStepIntervalDataOperation:
            return @"读取706间隔计步数据";
        case mk_configSearchPhoneOperation:
            return @"设置搜索手机功能";
        case mk_defaultTaskOperationID:
            return @"";
    }
}

/**
 监听状态下手环返回的实时计步数据
 
 @param content 手环原始数据
 @return @{}
 */
- (NSDictionary *)getListeningStateStepData:(NSString *)content{
    NSString *stepNumber = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(0, 8)];
    NSString *activityTime = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(8, 4)];
    NSString *distance = [NSString stringWithFormat:@"%.1f",(float)[mk_fitpoloAdopter getDecimalWithHex:content range:NSMakeRange(12, 4)] / 10.0];
    NSString *calories = [mk_fitpoloAdopter getDecimalStringWithHex:content range:NSMakeRange(16, 4)];
    
    return @{
             @"stepCount":stepNumber,
             @"sportTime":activityTime,
             @"distance":distance,
             @"burnCalories":calories
             };
}

#pragma mark - setter & getter
- (NSOperationQueue *)operationQueue{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

@end
