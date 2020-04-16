//
//  mk_fitpoloUpdateCenter.h
//  MKFitpolo
//
//  Created by aa on 2019/1/16.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^mk_fitpoloUpdateProcessSuccessBlock)(void);
typedef void(^mk_fitpoloUpdateProcessFailedBlock)(NSError *error);
typedef void(^mk_fitpoloUpdateProgressBlock)(CGFloat progress);

@interface mk_fitpoloUpdateCenter : NSObject

@property (nonatomic, assign, readonly)BOOL updating;

+ (mk_fitpoloUpdateCenter *)sharedInstance;

+ (void)attempDealloc;

- (void)startUpdateProcessWithPackageData:(NSData *)packageData
                             successBlock:(mk_fitpoloUpdateProcessSuccessBlock)successBlock
                            progressBlock:(mk_fitpoloUpdateProgressBlock)progressBlock
                              failedBlock:(mk_fitpoloUpdateProcessFailedBlock)failedBlock;

@end

NS_ASSUME_NONNULL_END
