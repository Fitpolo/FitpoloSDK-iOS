//
//  MKDeviceModulePhotoPicker.h
//  MKFitpolo
//
//  Created by 程昂 on 2020/3/31.
//  Copyright © 2020 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKDeviceModulePhotoPicker : NSObject

/**
 相机或者相册选择照片
 
 @param block 选择之后的回调，bigImage:原图，smallImage:按照size大小处理之后的小图
 @param size 输出size大小的图片
 */
- (void)showPhotoPickerBlock:(void (^)(UIImage *bigImage, UIImage *smallImage))block imageSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
