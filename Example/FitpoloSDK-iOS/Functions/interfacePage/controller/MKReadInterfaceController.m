//
//  MKReadInterfaceController.m
//  FitpoloSDK-iOS_Example
//
//  Created by aa on 2019/6/13.
//  Copyright © 2019 Chengang. All rights reserved.
//

#import "MKReadInterfaceController.h"
#import "MKReadDataTimeModel.h"

@interface MKReadInterfaceController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKReadInterfaceController

- (void)dealloc {
    NSLog(@"MKReadInterfaceController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Read";
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKReadInterfaceControllerCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKReadInterfaceControllerCell"];
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
    [self.dataList addObject:@"Read battery level"];
    [self.dataList addObject:@"Read firmware version number"];
    [self.dataList addObject:@"Read hardware parameters"];
    [self.dataList addObject:@"Read the last charge time"];
    [self.dataList addObject:@"Read unit information"];
    [self.dataList addObject:@"Read time format"];
    [self.dataList addObject:@"read light up screen by turning wrsit"];
    [self.dataList addObject:@"read HR collection intervial"];
    [self.dataList addObject:@"read sedentary reminder"];
    [self.dataList addObject:@"read ancs connect status"];
    [self.dataList addObject:@"read ANCS turn on option"];
    [self.dataList addObject:@"read alarm"];
    [self.dataList addObject:@"read last time screen display function"];
    [self.dataList addObject:@"read current screen display"];
    [self.dataList addObject:@"read steps datas"];
    [self.dataList addObject:@"read sleep datas"];
    [self.dataList addObject:@"read heart rate datas"];
    if ([mk_fitpoloCentralManager sharedInstance].deviceType == mk_fitpolo701) {
        [self.tableView reloadData];
        return;
    }
    [self.dataList addObject:@"read do not disturb model"];
    [self.dataList addObject:@"read dial types"];
    [self.dataList addObject:@"read personal information"];
    [self.dataList addObject:@"read sports target"];
    [self.dataList addObject:@"read sports datas"];
    [self.dataList addObject:@"read sports heart rate"];
    if ([mk_fitpoloCentralManager sharedInstance].deviceType == mk_fitpolo705) {
        [self.tableView reloadData];
        return;
    }
    [self.dataList addObject:@"read date format"];
    [self.dataList addObject:@"read bracelet vibration intensity"];
    [self.dataList addObject:@"Read the screen display list of the bracelet"];
    [self.dataList addObject:@"Read interval step data"];
    [self.tableView reloadData];
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
