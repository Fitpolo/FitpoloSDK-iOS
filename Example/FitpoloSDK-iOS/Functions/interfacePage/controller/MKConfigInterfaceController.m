//
//  MKConfigInterfaceController.m
//  FitpoloSDK-iOS_Example
//
//  Created by aa on 2019/6/14.
//  Copyright © 2019 Chengang. All rights reserved.
//

#import "MKConfigInterfaceController.h"


#import "MKReadDataTimeModel.h"
#import "MKAncsModel.h"
#import "MKConfigAlarmClockModel.h"
#import "MKConfigPeriodTimeModel.h"
#import "MKCustomScreenDisplayModel.h"
#import "MKConfigUserDataModel.h"

@interface MKConfigInterfaceController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKConfigInterfaceController

- (void)dealloc {
    NSLog(@"MKConfigInterfaceController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Config";
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKConfigInterfaceControllerCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKConfigInterfaceControllerCell"];
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
        //震动
        [MKDeviceInterface searchDeviceWithCount:2 sucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 1) {
        //设置设备显示的时间格式
        [MKDeviceInterface configTimeFormatter:mk_deviceTimeFormatter24H sucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 2) {
        //设置单位进制
        [MKDeviceInterface configUnit:mk_deviceUnitMetric sucBlock:^(id returnData) {
            [self showAlertWithMsg:@"Success"];
            NSLog(@"%@",returnData);
        } failedBlock:^(NSError *error) {
            [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
        }];
        return;
    }
    if (row == 3) {
        //设置ancs
        [self configANCSNotice];
        return;
    }
    if (row == 4) {
        //设置闹钟
        [self configAlarmClock];
        return;
    }
    if (row == 5) {
        //设置久坐提醒
        [self configSedentaryRemind];
        return;
    }
    if (row == 6) {
        //设置心率采集间隔
        [self configHeartRateAcquisitionInterval];
        return;
    }
    if (row == 7) {
        //设置翻腕亮屏
        [self configPalmingBrightScreen];
        return;
    }
    if (row == 8) {
        //设置显示上一次屏幕
        [self configRemindLastScreenDisplay];
        return;
    }
    if (row == 9) {
        //自定义屏幕显示
        [self configCustomScreenDisplay];
        return;
    }
    if (row == 10) {
        //设置日期
        [self configDate];
        return;
    }
    if (row == 11) {
        //设置个人信息
        [self configUserData];
        return;
    }
    if ([mk_fitpoloCentralManager sharedInstance].deviceType == mk_fitpolo701) {
        return;
    }
    if (row == 12) {
        //勿扰模式
        [self configDoNotDisturbMode];
        return;
    }
    if (row == 13) {
        //表盘样式
        [self configDialStyle];
        return;
    }
    if (row == 14) {
        //监听计步
        [self configStepChangeMeterMonitoringState];
        return;
    }
    if (row == 15) {
        //运动目标
        [self configMovingTarget];
        return;
    }
    if ([mk_fitpoloCentralManager sharedInstance].deviceType == mk_fitpolo705) {
        return;
    }
    if (row == 16) {
        //设置语言
        [self configLanguage];
        return;
    }
    if (row == 17) {
        //设置日期格式
        [self configDateFormatter];
        return;
    }
    if (row == 18) {
        //设置手环震动强度
        [self configVibrationIntensityOfDevice];
        return;
    }
    if (row == 19) {
        //设置屏幕显示列表
        [self configScreenList];
        return;
    }
    if (row == 20) {
        //设置记录计步数据间隔
        [self configMeterStepInterval];
        return;
    }
    if (row == 21) {
        //设置搜索手机功能
        [self configSearchPhone];
        return;
    }
}

#pragma mark -
- (void)configANCSNotice {
    MKAncsModel *ancsModel = [[MKAncsModel alloc] init];
    ancsModel.openQQ = YES;
    ancsModel.openSMS = YES;
    ancsModel.openPhone = YES;
    [MKDeviceInterface configANCSNotice:ancsModel sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configAlarmClock {
    MKClockStatusModel *statusModel = [[MKClockStatusModel alloc] init];
    statusModel.mondayIsOn = YES;
    statusModel.sundayIsOn = YES;
    MKConfigAlarmClockModel *clockModel = [[MKConfigAlarmClockModel alloc] init];
    clockModel.time = @"14:12";
    clockModel.clockType = MKAlarmClockNormal;
    clockModel.isOn = YES;
    clockModel.clockStatusProtocol = statusModel;
    [MKDeviceInterface configAlarmClock:@[clockModel] sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configSedentaryRemind {
    MKConfigPeriodTimeModel *timeModel = [[MKConfigPeriodTimeModel alloc] init];
    timeModel.isOn = YES;
    timeModel.startHour = 1;
    timeModel.startMin = 1;
    timeModel.endHour = 10;
    timeModel.endMin = 10;
    [MKDeviceInterface configSedentaryRemind:timeModel sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configHeartRateAcquisitionInterval {
    [MKDeviceInterface configHeartRateAcquisitionInterval:mk_heartRateAcquisitionInterval30Min sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configPalmingBrightScreen {
    MKConfigPeriodTimeModel *timeModel = [[MKConfigPeriodTimeModel alloc] init];
    timeModel.isOn = YES;
    timeModel.startHour = 1;
    timeModel.startMin = 1;
    timeModel.endHour = 10;
    timeModel.endMin = 10;
    [MKDeviceInterface configPalmingBrightScreen:timeModel sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configRemindLastScreenDisplay {
    [MKDeviceInterface configRemindLastScreenDisplay:YES sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configCustomScreenDisplay {
    MKCustomScreenDisplayModel *model = [[MKCustomScreenDisplayModel alloc] init];
    model.turnOnStepPage = YES;
    model.turnOnSportsDistancePage = YES;
    [MKDeviceInterface configCustomScreenDisplay:model sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configDate {
    MKConfigDateModel *model = [[MKConfigDateModel alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSArray *dateList = [dateString componentsSeparatedByString:@"-"];
    model.year = [dateList[0] integerValue];
    model.month = [dateList[1] integerValue];
    model.day = [dateList[2] integerValue];
    model.hour = [dateList[3] integerValue];
    model.minutes = [dateList[4] integerValue];
    model.seconds = [dateList[5] integerValue];
    [MKUserDataInterface configDate:model sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configUserData {
    MKConfigUserDataModel *dataModel = [[MKConfigUserDataModel alloc] init];
    dataModel.weight = 75;
    dataModel.height = 175;
    dataModel.gender = mk_fitpoloGenderMale;
    dataModel.userAge = 30;
    [MKUserDataInterface configUserData:dataModel sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configDoNotDisturbMode {
    MKConfigPeriodTimeModel *timeModel = [[MKConfigPeriodTimeModel alloc] init];
    timeModel.isOn = YES;
    timeModel.startHour = 1;
    timeModel.startMin = 1;
    timeModel.endHour = 10;
    timeModel.endMin = 10;
    [MKDeviceInterface configDoNotDisturbMode:timeModel sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configDialStyle {
    [MKDeviceInterface configDialStyle:mk_fitpoloDialStyle3 sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configStepChangeMeterMonitoringState {
    [MKUserDataInterface configStepChangeMeterMonitoringState:YES sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configMovingTarget {
    [MKUserDataInterface configMovingTarget:10000 sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configLanguage {
    [MKDeviceInterface configLanguage:mk_languageEnglishStyle sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configDateFormatter {
    [MKDeviceInterface configDateFormatter:mk_dateFormatterDY sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configVibrationIntensityOfDevice {
    [MKDeviceInterface configVibrationIntensityOfDevice:3 sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configScreenList {
    NSArray *screenList = @[@"01",@"07",@"08"];
    [MKDeviceInterface configScreenList:screenList sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configMeterStepInterval {
    [MKUserDataInterface configMeterStepInterval:30 sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
}

- (void)configSearchPhone {
    [MKUserDataInterface configSearchPhone:YES sucBlock:^(id returnData) {
        [self showAlertWithMsg:@"Success"];
        NSLog(@"%@",returnData);
    } failedBlock:^(NSError *error) {
        [self showAlertWithMsg:error.userInfo[@"errorInfo"]];
    }];
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
    [self.dataList addObject:@"vibration"];
    [self.dataList addObject:@"set the time format displayed by the device"];
    [self.dataList addObject:@"set unit decimal"];
    [self.dataList addObject:@"set ANCS"];
    [self.dataList addObject:@"set alarm"];
    [self.dataList addObject:@"set sedentary reminder"];
    [self.dataList addObject:@"set heart rate collection interval"];
    [self.dataList addObject:@"set light up screen by turning wrsit"];
    [self.dataList addObject:@"set display last time screen"];
    [self.dataList addObject:@"custom screen display"];
    [self.dataList addObject:@"set bracelet time"];
    [self.dataList addObject:@"set personal information"];
    if ([mk_fitpoloCentralManager sharedInstance].deviceType == mk_fitpolo701) {
        [self.tableView reloadData];
        return;
    }
    [self.dataList addObject:@"set do not disturb model"];
    [self.dataList addObject:@"set dial type"];
    [self.dataList addObject:@"monitor steps"];
    [self.dataList addObject:@"set sports target"];
    if ([mk_fitpoloCentralManager sharedInstance].deviceType == mk_fitpolo705) {
        [self.tableView reloadData];
        return;
    }
    [self.dataList addObject:@"set the bracelet display language"];
    [self.dataList addObject:@"set date format"];
    [self.dataList addObject:@"set vibrate intensity"];
    [self.dataList addObject:@"set current the screen display list"];
    [self.dataList addObject:@"set record steps intervial"];
    [self.dataList addObject:@"set finding mobilephone function"];
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
