
typedef void(^mk_userDataInterfaceSucBlock)(id returnData);
typedef void(^mk_userDataInterfaceFailedBlock)(NSError *error);


@protocol MKReadDeviceDataTimeProtocol <NSObject>

/**
 大于2000
 */
@property (nonatomic, assign)NSInteger year;

@property (nonatomic, assign)NSInteger month;

@property (nonatomic, assign)NSInteger day;

@property (nonatomic, assign)NSInteger hour;

@property (nonatomic, assign)NSInteger minutes;

@end

@protocol MKConfigDateProtocol <NSObject,MKReadDeviceDataTimeProtocol>

@property (nonatomic, assign)NSInteger seconds;

@end


typedef NS_ENUM(NSInteger, mk_fitpoloGender) {
    mk_fitpoloGenderMale,
    mk_fitpoloGenderFemale,
};

@protocol mk_configUserDataProtocol <NSObject>

/**
 身高100cm~200cm
 */
@property (nonatomic, assign)NSInteger height;

/**
 体重30kg~150kg
 */
@property (nonatomic, assign)NSInteger weight;

@property (nonatomic, assign)mk_fitpoloGender gender;

/**
 年龄,1~100
 */
@property (nonatomic, assign)NSInteger userAge;

@end
