//
//  MK701InterfaceController.m
//  FitpoloSDK-iOS_Example
//
//  Created by aa on 2019/6/13.
//  Copyright © 2019 Chengang. All rights reserved.
//

#import "MK701InterfaceController.h"
#import "MKReadDataTimeModel.h"

@interface MK701InterfaceController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MK701InterfaceController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"701 Interface";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo([[UIApplication sharedApplication] statusBarFrame].size.height + 44);
        make.bottom.mas_equalTo(-39.f);
    }];
    [self loadTableDatas];
    // Do any additional setup after loading the view.
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self testInterface:indexPath.row];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MK701InterfaceControllerCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MK701InterfaceControllerCell"];
    }
    cell.textLabel.text = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - interface

- (void)testInterface:(NSInteger)row {
    if ([mk_fitpoloCentralManager sharedInstance].deviceType == mk_fitpoloUnknow) {
        return;
    }
    if (row == 0) {
        //Battery
        [MKDeviceInterface readBatteryWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 1) {
        //Read firmware version
        [MKDeviceInterface readFirmwareVersionWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 2) {
        //Read hardware parameters
        [MKDeviceInterface readHardwareParametersWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 3) {
        [MKDeviceInterface readLastChargingTimeWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 4) {
        [MKDeviceInterface readUnitWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 5) {
        [MKDeviceInterface readTimeFormatWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 6) {
        //翻腕亮屏
        [MKDeviceInterface readPalmingBrightScreenWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 7) {
        //心率采集间隔
        [MKDeviceInterface readHeartRateAcquisitionIntervalWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 8) {
        //久坐提醒
        [MKDeviceInterface readSedentaryRemindWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 9) {
        //ancs连接状态
        [MKDeviceInterface readAncsConnectStatusWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 10) {
        //ancs开启选项
        [MKDeviceInterface readAncsOptionsWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 11) {
        //读取闹钟
        [MKDeviceInterface readAlarmClockDatasWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
    }
    if (row == 12) {
        //读取上一次屏幕显示功能
        [MKDeviceInterface readRemindLastScreenDisplayWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 13) {
        //读取当前屏幕显示
        [MKDeviceInterface readCustomScreenDisplayWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 14) {
        //计步
        MKReadDataTimeModel *timeModel = [[MKReadDataTimeModel alloc] init];
        timeModel.year = 2000;
        timeModel.month = 1;
        timeModel.day = 1;
        timeModel.hour = 1;
        timeModel.minutes = 1;
        [MKUserDataInterface readStepDataWithTimeStamp:timeModel sucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 15) {
        //睡眠
        MKReadDataTimeModel *timeModel = [[MKReadDataTimeModel alloc] init];
        timeModel.year = 2000;
        timeModel.month = 1;
        timeModel.day = 1;
        timeModel.hour = 1;
        timeModel.minutes = 1;
        [MKUserDataInterface readSleepDataWithTimeStamp:timeModel sucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 16) {
        //心率
        MKReadDataTimeModel *timeModel = [[MKReadDataTimeModel alloc] init];
        timeModel.year = 2000;
        timeModel.month = 1;
        timeModel.day = 1;
        timeModel.hour = 1;
        timeModel.minutes = 1;
        [MKUserDataInterface readHeartDataWithTimeStamp:timeModel sucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    
    if ([mk_fitpoloCentralManager sharedInstance].deviceType == mk_fitpolo701) {
        return;
    }
    if (row == 17) {
        //读取勿扰模式
        [MKDeviceInterface readDoNotDisturbWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 18) {
        //读取表盘样式
        [MKDeviceInterface readDialStyleWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 19) {
        //读取个人信息
        [MKUserDataInterface readUserDataWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 20) {
        //读取运动目标
        [MKUserDataInterface readMovingTargetWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 21) {
        //读取运动数据
        MKReadDataTimeModel *timeModel = [[MKReadDataTimeModel alloc] init];
        timeModel.year = 2000;
        timeModel.month = 1;
        timeModel.day = 1;
        timeModel.hour = 1;
        timeModel.minutes = 1;
        [MKUserDataInterface readSportDataWithTimeStamp:timeModel sucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 22) {
        //读取运动心率
        MKReadDataTimeModel *timeModel = [[MKReadDataTimeModel alloc] init];
        timeModel.year = 2000;
        timeModel.month = 1;
        timeModel.day = 1;
        timeModel.hour = 1;
        timeModel.minutes = 1;
        [MKUserDataInterface readSportHeartRateDataWithTimeStamp:timeModel sucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if ([mk_fitpoloCentralManager sharedInstance].deviceType == mk_fitpolo705) {
        return;
    }
    if (row == 23) {
        //读取日期格式
        [MKDeviceInterface readDateFormatterWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 24) {
        //读取手环震动强度
        [MKDeviceInterface readVibrationIntensityOfDeviceWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 25) {
        //读取手环的屏幕显示列表
        [MKDeviceInterface readDeviceScreenListWithSucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 26) {
        //读取间隔计步数据
        MKReadDataTimeModel *timeModel = [[MKReadDataTimeModel alloc] init];
        timeModel.year = 2000;
        timeModel.month = 1;
        timeModel.day = 1;
        timeModel.hour = 1;
        timeModel.minutes = 1;
        [MKUserDataInterface readStepIntervalDataWithTimeStamp:timeModel sucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
}

#pragma mark - private method
- (void)showAlertWithMsg:(NSString *)msg{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Dismiss"
                                                                             message:msg
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *moreAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:moreAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)loadTableDatas {
    [self.dataList addObject:@"Battery"];
    [self.dataList addObject:@"Read firmware version"];
    [self.dataList addObject:@"Read hardware parameters"];
    [self.dataList addObject:@"Read last charging time"];
    [self.dataList addObject:@"Read unit"];
    [self.dataList addObject:@"Read time format"];
    [self.dataList addObject:@"读取翻腕亮屏"];
    [self.dataList addObject:@"读取心率采集间隔"];
    [self.dataList addObject:@"读取久坐提醒"];
    [self.dataList addObject:@"读取ancs连接状态"];
    [self.dataList addObject:@"读取ancs开启选项"];
    [self.dataList addObject:@"读取闹钟"];
    [self.dataList addObject:@"读取上一次屏幕显示功能"];
    [self.dataList addObject:@"读取当前屏幕显示"];
    [self.dataList addObject:@"读取计步数据"];
    [self.dataList addObject:@"读取睡眠数据"];
    [self.dataList addObject:@"读取心率数据"];
    if ([mk_fitpoloCentralManager sharedInstance].deviceType == mk_fitpolo701) {
        [self.tableView reloadData];
        return;
    }
    [self.dataList addObject:@"读取勿扰模式"];
    [self.dataList addObject:@"读取表盘样式"];
    [self.dataList addObject:@"读取个人信息"];
    [self.dataList addObject:@"读取运动目标"];
    [self.dataList addObject:@"读取运动数据"];
    [self.dataList addObject:@"读取运动心率"];
    if ([mk_fitpoloCentralManager sharedInstance].deviceType == mk_fitpolo705) {
        [self.tableView reloadData];
        return;
    }
    [self.dataList addObject:@"读取日期格式"];
    [self.dataList addObject:@"读取手环震动强度"];
    [self.dataList addObject:@"读取手环的屏幕显示列表"];
    [self.dataList addObject:@"读取间隔计步数据"];
}



#pragma mark - setter & getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
