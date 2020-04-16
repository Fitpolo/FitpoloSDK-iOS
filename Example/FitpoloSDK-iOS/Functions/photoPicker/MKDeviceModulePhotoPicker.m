//
//  MKDeviceModulePhotoPicker.m
//  MKFitpolo
//
//  Created by 程昂 on 2020/3/31.
//  Copyright © 2020 MK. All rights reserved.
//

#import "MKDeviceModulePhotoPicker.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@interface NSInvocation (MKCategoryModule)

+ (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector;

+ (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector arguments:(void*)firstArgument,...;

@end

@implementation NSInvocation (MKCategoryModule)

+ (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector
{
    return [[self class] invocationWithTarget:target selector:selector arguments:NULL];
}

+ (NSInvocation *)invocationWithTarget:(id)target selector:(SEL)selector arguments:(void*)firstArgument,...
{
    NSMethodSignature *signature = [[target class] instanceMethodSignatureForSelector:selector];
    NSInvocation *invoction = [NSInvocation invocationWithMethodSignature:signature];
    [invoction setTarget:target];
    [invoction setSelector:selector];
    
    if (firstArgument)
        {
        va_list arg_list;
        va_start(arg_list, firstArgument);
        [invoction setArgument:firstArgument atIndex:2];
        
        for (NSUInteger i = 0; i < signature.numberOfArguments; i++) {
            void *argument = va_arg(arg_list, void *);
            [invoction setArgument:argument atIndex:i];
        }
        va_end(arg_list);
        }
    
    return invoction;
}

@end

@interface MKDeviceModulePhotoPicker ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy)void (^pickPhotoBlock)(UIImage *bigImage, UIImage *smallImage);

@property (nonatomic, assign)CGSize imageSize;

@end

@implementation MKDeviceModulePhotoPicker

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKPhotoPicker销毁");
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //获取相册选取或者拍照的原始图片
    UIImage *bigImage;
    if (picker.allowsEditing) {
        bigImage = [info objectForKey:UIImagePickerControllerEditedImage];
    }else{
        bigImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    //1、子线程1：保存图片到相册
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//如果是相机，则保存图片到相册
            UIImageWriteToSavedPhotosAlbum(bigImage,self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        });
    }
    dispatch_queue_t queueSave = dispatch_queue_create("savePending",DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queueSave, ^{
        //将大图处理成小图
        UIImage *smallImage = [self thumbnailWithImageWithoutScale:bigImage size:self.imageSize];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.pickPhotoBlock) {
                self.pickPhotoBlock(bigImage, smallImage);
            }
            [picker dismissViewControllerAnimated:NO completion:nil];
        });
    });
}
//保存到相册失败
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        return;
    }
}

#pragma mark - event method

- (void)openCamera{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:imagePicker animated:YES completion:nil];
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:@"The camera is not available"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)openPhoto{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - public method
/**
 相机或者相册选择照片
 
 @param block 选择之后的回调，bigImage:原图，smallImage:处理之后的小图
 */
- (void)showPhotoPickerBlock:(void (^)(UIImage *bigImage, UIImage *smallImage))block imageSize:(CGSize)size{
    self.pickPhotoBlock = nil;
    self.pickPhotoBlock = block;
    self.imageSize = size;
    [self showActionSheet];
}

#pragma mark - private method
- (void)showActionSheet{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self handleAccessCameraWithTarget:self selecter:@selector(openCamera)];
                                                         }];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self handleAccessPhotosWithTarget:self selecter:@selector(openPhoto)];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    [alertController addAction:cameraAction];
    [alertController addAction:photoAction];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)isAllowAccessCamera{
    AVAuthorizationStatus AVStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return (AVStatus == AVAuthorizationStatusAuthorized);
}

- (BOOL)isAllowAccessPhotos{
    PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
    return (photoAuthorStatus == PHAuthorizationStatusAuthorized);
}

/**
 *  2016年09月03日 add by 胡仕君： 处理调用相机
 *
 *  @param target   响应方法的界面
 *  @param selector 允许使用相机资源后调用的方法
 */
- (void)handleAccessCameraWithTarget:(id) target selecter:(SEL)selector{
    NSInvocation *invocation = [NSInvocation invocationWithTarget:target selector:selector];
    [self handleAccessCamera:invocation];
}

/**
 *  2016年09月03日 add by 胡仕君： 处理调用相册
 *
 *  @param target   响应方法的界面
 *  @param selector 允许使用相册资源后调用的方法
 */
- (void)handleAccessPhotosWithTarget:(id) target selecter:(SEL)selector{
    NSInvocation *invocation = [NSInvocation invocationWithTarget:target selector:selector];
    [self handleAccessPhotos:invocation];
}

- (void)handleAccessCamera:(NSInvocation *)allowInvocation{
    if ([self isAllowAccessCamera]){
        [allowInvocation invoke];
        return;
    }
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    NSString *promtpMessage = @"此功能需要开启相机授权，请在设置-隐私-相机中开启fitpolo的权限";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:promtpMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                     }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    //授权
    if(status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted){
        if ([allowInvocation.target isKindOfClass:[UIViewController class]]) {
            [allowInvocation.target presentViewController:alertController animated:YES completion:nil];
            return;
        }
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
        return;
    }
    //未授权
    if(status == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){
            dispatch_sync(dispatch_get_main_queue(), ^{
                if(granted){
                    [allowInvocation invoke];
                    return ;
                }
                if ([allowInvocation.target isKindOfClass:[UIViewController class]]) {
                    [allowInvocation.target presentViewController:alertController animated:YES completion:nil];
                    return;
                }
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
            });
        }];
    }
}

- (void)handleAccessPhotos:(NSInvocation *)allowInvocation{
    if ([self isAllowAccessPhotos]){
        [allowInvocation invoke];
        return;
    }
    
    PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
    if (photoAuthorStatus == PHAuthorizationStatusNotDetermined) {
        [allowInvocation invoke];
        return;
    }
    
    NSString *promtpMessage = @"此功能需要开启照片授权，请在设置-隐私-照片中开启fitpolo的权限";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:promtpMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                     }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    if ([allowInvocation.target isKindOfClass:[UIViewController class]]) {
        [allowInvocation.target presentViewController:alertController animated:YES completion:nil];
        return;
    }
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

@end
