//
//  mk_fitpoloCurrentParser.h
//  mk_fitpoloCentralManager
//
//  Created by aa on 2018/12/10.
//  Copyright © 2018 mk_fitpolo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface mk_fitpoloCurrentParser : NSObject

+ (NSDictionary *)parseReadDataFromCharacteristic:(CBCharacteristic *)characteristic;

@end

NS_ASSUME_NONNULL_END
