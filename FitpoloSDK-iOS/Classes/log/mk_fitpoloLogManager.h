//
//  mk_fitpoloLogManager.h
//  mk_fitpoloCentralManager
//
//  Created by aa on 2018/12/10.
//  Copyright © 2018 mk_fitpolo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, mk_logDataDirection) {
    mk_logDataSourceAPP,          //datas come from app-->device dates
    mk_logDataSourceDevice,       //datas come from device-->app
};

NS_ASSUME_NONNULL_BEGIN

@interface mk_fitpoloLogManager : NSObject

/**
 Write commands to local files, currenctly local only retains one week of data.
 
 @param dataList The data to be written, you can write a series of data, the array must be a string.
 @param source app-->device或者是device-->app
 */
+ (void)writeCommandToLocalFile:(NSArray *)dataList sourceInfo:(mk_logDataDirection )source;

/**
 Read locally stored command data.
 
 @return Stored command data.
 */
+ (NSData *)readCommandDataFromLocalFile;

@end

NS_ASSUME_NONNULL_END
