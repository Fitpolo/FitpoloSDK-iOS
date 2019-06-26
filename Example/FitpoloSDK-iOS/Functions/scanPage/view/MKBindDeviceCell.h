//
//  MKBindDeviceCell.h
//  MKFitpolo
//
//  Created by aa on 2018/12/12.
//  Copyright © 2018 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class mk_fitpoloScanDeviceModel;
@interface MKBindDeviceCell : UICollectionViewCell

@property (nonatomic, strong)NSIndexPath *indexPath;

@property (nonatomic, strong)mk_fitpoloScanDeviceModel *deviceModel;

@end

NS_ASSUME_NONNULL_END
