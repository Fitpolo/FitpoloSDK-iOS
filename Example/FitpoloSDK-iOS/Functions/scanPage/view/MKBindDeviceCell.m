//
//  MKBindDeviceCell.m
//  MKFitpolo
//
//  Created by aa on 2018/12/12.
//  Copyright © 2018 MK. All rights reserved.
//

#import "MKBindDeviceCell.h"

static CGFloat const deviceIconWidth = 56.f;
static CGFloat const deviceIconHeight = 102.f;

@interface MKBindDeviceCell ()

@property (nonatomic, strong)UIView *backView;

@property (nonatomic, strong)UILabel *nameLabel;

@property (nonatomic, strong)UIImageView *deviceIcon;

@property (nonatomic, strong)UILabel *macLabel;

@end

@implementation MKBindDeviceCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.backView];
        [self.backView addSubview:self.nameLabel];
        [self.backView addSubview:self.deviceIcon];
        [self.backView addSubview:self.macLabel];
    }
    return self;
}

#pragma mark - super method
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(14.f);
        make.height.mas_equalTo([UIFont systemFontOfSize:15.f].lineHeight);
    }];
    [self.deviceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.backView.mas_centerX);
        make.width.mas_equalTo(deviceIconWidth);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo(deviceIconHeight);
    }];
    [self.macLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(self.deviceIcon.mas_bottom).mas_offset(10.f);
        make.height.mas_equalTo([UIFont systemFontOfSize:12.f].lineHeight);
    }];
}

#pragma mark - public method
- (void)setDeviceModel:(mk_fitpoloScanDeviceModel *)deviceModel{
    _deviceModel = nil;
    _deviceModel = deviceModel;
    if (!_deviceModel) {
        return;
    }
    if (_deviceModel.deviceName) {
        self.nameLabel.text = _deviceModel.deviceName;
    }else{
        self.nameLabel.text = @"N/A";
    }
    NSString *iconName = @"";
    if (_deviceModel.deviceType == mk_fitpolo701) {
        iconName = @"deviceModule_fitpolo701Icon.png";
    }else if (_deviceModel.deviceType == mk_fitpolo705){
        iconName = @"deviceModule_fitpolo705Icon.png";
    }else if (_deviceModel.deviceType == mk_fitpolo706){
        iconName = @"deviceModule_fitpolo706Icon.png";
    }else if (_deviceModel.deviceType == mk_fitpolo707) {
        iconName = @"deviceModule_fitpolo707Icon.png";
    }else if (_deviceModel.deviceType == mk_fitpolo709) {
        iconName = @"deviceModule_fitpolo709Icon.png";
    }
    self.deviceIcon.image = [UIImage imageNamed:iconName];
    if (_deviceModel.deviceMac) {
        NSArray *list = [_deviceModel.deviceMac componentsSeparatedByString:@"-"];
        if (list.count == 6) {
            self.macLabel.text = [NSString stringWithFormat:@"%@%@",list[4],list[5]];
        }else{
            self.macLabel.text = @"N/A";
        }
    }else{
        self.macLabel.text = @"N/A";
    }
}

#pragma mark - setter & getter
- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc] init];
        _backView.backgroundColor = [UIColor whiteColor];
        
        _backView.layer.masksToBounds = YES;
        _backView.layer.cornerRadius = 5.f;
    }
    return _backView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor colorWithRed:55 / 255.f green:136 / 255.f blue:230 / 255.f alpha:1];
        _nameLabel.font = [UIFont systemFontOfSize:15.f];
    }
    return _nameLabel;
}

- (UIImageView *)deviceIcon{
    if (!_deviceIcon) {
        _deviceIcon = [[UIImageView alloc] init];
    }
    return _deviceIcon;
}

- (UILabel *)macLabel{
    if (!_macLabel) {
        _macLabel = [[UILabel alloc] init];
        _macLabel.textAlignment = NSTextAlignmentCenter;
        _macLabel.textColor = [UIColor blackColor];
        _macLabel.font = [UIFont systemFontOfSize:12.f];
    }
    return _macLabel;
}

@end
