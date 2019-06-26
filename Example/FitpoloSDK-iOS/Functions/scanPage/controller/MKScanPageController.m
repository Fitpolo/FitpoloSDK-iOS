//
//  MKScanPageController.m
//  FitpoloSDK-iOS_Example
//
//  Created by aa on 2019/6/13.
//  Copyright © 2019 Chengang. All rights reserved.
//

#import "MKScanPageController.h"
#import "MKBindDeviceCell.h"
#import "MKBindDeviceLayout.h"

#import "mk_fitpoloCentralGlobalHeader.h"

#import "MKInterfaceController.h"

static NSString *const MKBindDeviceCellIdenty = @"MKBindDeviceCellIdenty";
static NSString *const MKRefreshButtonAnimationKey = @"MKRefreshButtonAnimationKey";

@interface MKScanPageController ()<UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout,
mk_scanPeripheralDelegate>

@property (nonatomic, strong)UICollectionView *collectionView;

@property (nonatomic, strong)NSMutableArray *dataList;

@property (nonatomic, strong)NSMutableArray *filterList;

@property (nonatomic, strong)dispatch_source_t scanTimer;

/**
 请求版本号失败次数
 */
@property (nonatomic, assign)NSInteger requestFailedCount;

@property (nonatomic, strong)dispatch_queue_t bandDeviceQueue;

@property (nonatomic, strong)dispatch_semaphore_t semaphore;

/**
 *  标题label
 */
@property (nonatomic,strong) UILabel  *titleLabel;

/**
 *  右按钮
 */
@property (nonatomic,strong) UIButton *rightButton;

@end

@implementation MKScanPageController
#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKBindDeviceController销毁");
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.scanTimer) {
        dispatch_cancel(self.scanTimer);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //禁止右划退出手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [mk_fitpoloCentralManager sharedInstance].scanDelegate = self;
    [self loadSubViews];
    [self updateRefreshButtonStatus:YES];
    // Do any additional setup after loading the view.
}

#pragma mark - super method
- (void)rightButtonMethod{
    [self updateRefreshButtonStatus:!self.rightButton.selected];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filterList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MKBindDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MKBindDeviceCellIdenty forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.deviceModel = self.filterList[indexPath.row];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake((kScreenWidth - 3 * 11.f) / 2, 175.f);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self connectDeviceWithIndex:indexPath.row];
}

#pragma mark - mk_scanPeripheralDelegate

- (void)mk_centralStartScan:(mk_fitpoloCentralManager *)centralManager {
    
}

- (void)mk_centralDidDiscoverPeripheral:(mk_fitpoloScanDeviceModel *)deviceModel
                         centralManager:(mk_fitpoloCentralManager *)centralManager {
    @synchronized (self.dataList) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deviceMac == %@", deviceModel.deviceMac];
        NSArray *array = [self.dataList filteredArrayUsingPredicate:predicate];
        BOOL contain = ([array isKindOfClass:NSArray.class] && array.count > 0);
        if (contain) {
            return;
        }
        [self.dataList addObject:deviceModel];
        @synchronized (self.filterList) {
            [self.filterList removeAllObjects];
            [self.filterList addObjectsFromArray:[self filterDeviceList]];
            [self.collectionView reloadData];
        }
    }
}

- (void)mk_centralStopScan:(mk_fitpoloCentralManager *)centralManager {
    
}

#pragma mark - scan
- (void)updateRefreshButtonStatus:(BOOL)selected{
    self.rightButton.selected = selected;
    [self.rightButton.layer removeAnimationForKey:MKRefreshButtonAnimationKey];
    if (self.scanTimer) {
        dispatch_cancel(self.scanTimer);
    }
    [[mk_fitpoloCentralManager sharedInstance] stopScan];
    if ([mk_fitpoloCentralManager sharedInstance].centralStatus == mk_fitpoloCentralManagerStateUnable) {
        [self.view makeToast:@"mobile phone bluetooth is currently unavailable" duration:0.8 position:CSToastPositionCenter style:nil];
        return;
    }
    if (!self.rightButton.selected) {
        //停止扫描
        return;
    }
    //开始扫描
    [self.rightButton.layer addAnimation:[self circleLayerAnimation] forKey:MKRefreshButtonAnimationKey];
    @synchronized (self.dataList) {
        [self.dataList removeAllObjects];
    }
    @synchronized (self.filterList) {
        [self.filterList removeAllObjects];
    }
    [[mk_fitpoloCentralManager sharedInstance] scanDevice];
    self.scanTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.scanTimer, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC),  30 * NSEC_PER_SEC, 0);
    __weak __typeof(&*self)weakSelf = self;
    dispatch_source_set_event_handler(self.scanTimer, ^{
        dispatch_cancel(weakSelf.scanTimer);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[mk_fitpoloCentralManager sharedInstance] stopScan];
            [weakSelf.rightButton.layer removeAnimationForKey:MKRefreshButtonAnimationKey];
            weakSelf.rightButton.selected = NO;
        });
    });
    dispatch_resume(self.scanTimer);
}

#pragma mark - filter data

- (NSArray *)filterDeviceList{
    @synchronized (self.dataList) {
        if (self.dataList.count == 0) {
            return @[];
        }
        return [self.dataList copy];
    }
}

#pragma mark - connect
- (void)connectDeviceWithIndex:(NSInteger)index{
    [self updateRefreshButtonStatus:NO];
    mk_fitpoloScanDeviceModel *deviceModel = self.filterList[index];
    [[MKHudManager share] showHUDWithTitle:@"Connecting..." inView:self.view isPenetration:NO];
    self.rightButton.enabled = NO;
    [[mk_fitpoloCentralManager sharedInstance] connectPeripheral:deviceModel.peripheral deviceType:deviceModel.deviceType connectSucBlock:^(CBPeripheral *connectedPeripheral) {
        [self readDeviceVersion:deviceModel];
    } connectFailBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        self.rightButton.enabled = YES;
        [self.view makeToast:error.userInfo[@"errorInfo"] duration:0.8 position:CSToastPositionCenter style:nil];
    }];
}

#pragma mark - 命令交互

- (void)readDeviceVersion:(mk_fitpoloScanDeviceModel *)deviceModel{
    dispatch_async(self.bandDeviceQueue, ^{
        NSString *version = nil;
        if (deviceModel.deviceType == mk_fitpolo701) {
            //701
            //3次之内请求内部版本号成功即可，否则报错
            for (NSInteger i = 0; i < 3; i ++) {
                version = [self fetchInternalVersion];
                if (version) {
                    break;
                }
            }
        }else {
            //新手环
            for (NSInteger i = 0; i < 3; i ++) {
                version = [self fetchFirmwareVersion];
                if (version) {
                    break;
                }
            }
        }
        if (!version) {
            //报错
            dispatch_async(dispatch_get_main_queue(), ^{
                [[MKHudManager share] hide];
                self.rightButton.enabled = YES;
                [self.view makeToast:@"connect error" duration:0.8 position:CSToastPositionCenter style:nil];
            });
            return ;
        }
        //设置当前手机时间格式给手环，12H、24H
        [self configTimeFormatter];
        //震动
        [self vibrationInstruction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MKHudManager share] hide];
            self.rightButton.enabled = YES;
            MKInterfaceController *vc = [[MKInterfaceController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
//            [self readVersionSuccess:deviceModel version:version];
        });
    });
    
}

- (NSString *)fetchInternalVersion {
    __block NSString *internalVersion = nil;
    [MKDeviceInterface readInternalVersionWithSucBlock:^(id returnData) {
        internalVersion = returnData[@"result"][@"internalVersion"];
        dispatch_semaphore_signal(self.semaphore);
    } failBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return internalVersion;
}

- (NSString *)fetchFirmwareVersion {
    __block NSString *firmware = nil;
    [MKDeviceInterface readFirmwareVersionWithSucBlock:^(id returnData) {
        firmware = returnData[@"result"][@"firmwareVersion"];
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return firmware;
}

- (BOOL)configTimeFormatter {
    __block BOOL success = NO;
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    mk_deviceTimeFormatter formatter = mk_deviceTimeFormatter24H;
    //时间进制信息，00：24h，01：12h
    if (hasAMPM) {
        formatter = mk_deviceTimeFormatter12H;
    }
    [MKDeviceInterface configTimeFormatter:formatter sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

- (BOOL)vibrationInstruction {
    __block BOOL success = NO;
    [MKDeviceInterface searchDeviceWithCount:1 sucBlock:^(id returnData) {
        success = YES;
        dispatch_semaphore_signal(self.semaphore);
    } failedBlock:^(NSError *error) {
        dispatch_semaphore_signal(self.semaphore);
    }];
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    return success;
}

#pragma mark -
- (CABasicAnimation *)circleLayerAnimation{
    CABasicAnimation *transformAnima = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    transformAnima.duration = 2.f;
    transformAnima.fromValue = @(0);
    transformAnima.toValue = @(2 * M_PI);
    transformAnima.autoreverses = NO;
    transformAnima.repeatCount = MAXFLOAT;
    transformAnima.removedOnCompletion = NO;
    transformAnima.fillMode = kCAFillModeForwards;
    return transformAnima;
}

- (void)loadSubViews{
    self.view.backgroundColor = [UIColor colorWithRed:242 / 255.0 green:242 / 255.0 blue:242 / 255.0 alpha:1];
    UIBarButtonItem *rightbuttonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    [self.navigationItem setRightBarButtonItem:rightbuttonItem];
    self.navigationItem.titleView = self.titleLabel;
    [self.rightButton setImage:[UIImage imageNamed:@"deviceModule_refreshIcon.png"] forState:UIControlStateNormal];
    //去掉导航栏细线
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo([[UIApplication sharedApplication] statusBarFrame].size.height + 44);
        make.bottom.mas_equalTo(-39.f);
    }];
}

#pragma mark - setter & getter
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        MKBindDeviceLayout *layout = [[MKBindDeviceLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(0, 11.f, 0, 11.f);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.backgroundColor = [UIColor whiteColor];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_collectionView registerClass:[MKBindDeviceCell class] forCellWithReuseIdentifier:MKBindDeviceCellIdenty];
    }
    return _collectionView;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSMutableArray *)filterList{
    if (!_filterList) {
        _filterList = [NSMutableArray array];
    }
    return _filterList;
}

- (dispatch_queue_t)bandDeviceQueue {
    if (!_bandDeviceQueue) {
        _bandDeviceQueue = dispatch_queue_create("com.moko.bandDeviceQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _bandDeviceQueue;
}

- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 40.0f, 2.0f, 40.0f, 40.0f)];
        [_rightButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
        [_rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightButton setTitleColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.4] forState:UIControlStateHighlighted];
        [_rightButton addTarget:self action:@selector(rightButtonMethod) forControlEvents:UIControlEventTouchUpInside];
        [_rightButton setNeedsLayout];
    }
    return _rightButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 7.0f, kScreenWidth - 120.0f, 30.0f)];
        _titleLabel.font = [UIFont systemFontOfSize:18.f];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.tintColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = @"Scan";
    }
    return _titleLabel;
}

@end
