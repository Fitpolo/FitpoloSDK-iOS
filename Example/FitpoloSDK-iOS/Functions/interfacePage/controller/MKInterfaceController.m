//
//  MKInterfaceController.m
//  FitpoloSDK-iOS_Example
//
//  Created by aa on 2019/6/14.
//  Copyright © 2019 Chengang. All rights reserved.
//

#import "MKInterfaceController.h"
#import "MKReadInterfaceController.h"
#import "MKConfigInterfaceController.h"

@interface MKInterfaceController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKInterfaceController

- (void)dealloc {
    NSLog(@"MKInterfaceController销毁");
    [[mk_fitpoloCentralManager sharedInstance] disconnectConnectedPeripheral];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Interface";
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
    if (indexPath.row == 0) {
        MKReadInterfaceController *vc = [[MKReadInterfaceController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (indexPath.row == 1) {
        MKConfigInterfaceController *vc = [[MKConfigInterfaceController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MKInterfaceControllerCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MKInterfaceControllerCell"];
    }
    cell.textLabel.text = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - private method
- (void)loadTableDatas {
    [self.dataList addObject:@"Read command"];
    [self.dataList addObject:@"Set command"];
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
