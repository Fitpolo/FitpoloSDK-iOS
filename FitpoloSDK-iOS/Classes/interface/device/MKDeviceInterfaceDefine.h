#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^mk_deviceInterfaceSucBlock)(id returnData);
typedef void(^mk_deviceInterfaceFailedBlock)(NSError *error);

typedef NS_ENUM(NSInteger, mk_deviceTimeFormatter) {
    mk_deviceTimeFormatter24H,      //显示24小时进制
    mk_deviceTimeFormatter12H,      //显示12小时进制
};

typedef NS_ENUM(NSInteger, mk_deviceUnitType) {
    mk_deviceUnitMetric,    //公制
    mk_deviceUnitImperial,  //英制
};

typedef NS_ENUM(NSInteger, mk_heartRateAcquisitionInterval) {
    mk_heartRateAcquisitionIntervalClose,    //关闭心率采集功能
    mk_heartRateAcquisitionInterval10Min,    //10分钟
    mk_heartRateAcquisitionInterval20Min,    //20分钟
    mk_heartRateAcquisitionInterval30Min,    //30分钟
};
//表盘样式
typedef NS_ENUM(NSInteger, mk_fitpoloDialStyle) {
    mk_fitpoloDialStyle1,   //(705、706)
    mk_fitpoloDialStyle2,   //(705、706)
    mk_fitpoloDialStyle3,   //(705、706)
    mk_fitpoloDialStyle4,   //(706)
    mk_fitpoloDialStyle5,   //(706)
    mk_fitpoloDialStyle6,   //(706)
    mk_fitpoloDialStyle7,   //(706)
    mk_fitpoloDialStyle8,   //(706)
};

//706日期制式
typedef NS_ENUM(NSInteger, mk_dateFormatter) {
    mk_dateFormatterDY,         //日/月格式
    mk_dateFormatterYD,         //月/日格式
};
typedef NS_ENUM(NSInteger, mk_languageStyle) {
    mk_languageChineseStyle,    //中文
    mk_languageEnglishStyle,    //英文
};


#pragma mark - ********************************protocol************************************

#pragma mark ====================ancs部分=======================
@protocol MKANCSProtocol <NSObject>
//打开短信提醒
@property (nonatomic, assign)BOOL openSMS;
//打开电话提醒
@property (nonatomic, assign)BOOL openPhone;
//打开微信提醒
@property (nonatomic, assign)BOOL openWeChat;
//打开qq提醒
@property (nonatomic, assign)BOOL openQQ;
//打开whatsapp提醒
@property (nonatomic, assign)BOOL openWhatsapp;
//打开facebook提醒
@property (nonatomic, assign)BOOL openFacebook;
//打开twitter提醒
@property (nonatomic, assign)BOOL openTwitter;
//打开skype提醒
@property (nonatomic, assign)BOOL openSkype;
//打开snapchat提醒
@property (nonatomic, assign)BOOL openSnapchat;
//打开Line
@property (nonatomic, assign)BOOL openLine;

@end


#pragma mark ====================自定义屏幕显示=======================

@protocol MKCustomScreenDisplayProtocol <NSObject>

//心率页面
@property (nonatomic, assign)BOOL turnOnHeartRatePage;
//计步页面
@property (nonatomic, assign)BOOL turnOnStepPage;
//卡路里页面
@property (nonatomic, assign)BOOL turnOnCaloriesPage;
//运动距离页面
@property (nonatomic, assign)BOOL turnOnSportsDistancePage;
//运动时间页面
@property (nonatomic, assign)BOOL turnOnSportsTimePage;
//睡眠页面,703、705特有
@property (nonatomic, assign)BOOL turnOnSleepPage;
//跑步2页面,703、705特有
@property (nonatomic, assign)BOOL turnOnSecondRunning;
//跑步3页面,703、705特有
@property (nonatomic, assign)BOOL turnOnThirdRunning;

@end

#pragma mark ====================闹钟相关=======================

@protocol MKAlarmClockStatusProtocol <NSObject>
//周一是否打开
@property (nonatomic, assign)BOOL mondayIsOn;
//周二是否打开
@property (nonatomic, assign)BOOL tuesdayIsOn;
//周三是否打开
@property (nonatomic, assign)BOOL wednesdayIsOn;
//周四是否打开
@property (nonatomic, assign)BOOL thursdayIsOn;
//周五是否打开
@property (nonatomic, assign)BOOL fridayIsOn;
//周六是否打开
@property (nonatomic, assign)BOOL saturdayIsOn;
//周日是否打开
@property (nonatomic, assign)BOOL sundayIsOn;
@end

/**
 闹钟类型
 
 吃药0、喝水1、普通2、睡眠3、锻炼4、运动5
 */
typedef NS_ENUM(NSInteger, MKAlarmClockType) {
    MKAlarmClockMedicine,         //吃药
    MKAlarmClockDrink,            //喝水
    MKAlarmClockNormal,           //普通
    MKAlarmClockSleep,            //睡眠
    MKAlarmClockExcise,           //锻炼
    MKAlarmClockSport,            //运动
};

@protocol MKSetAlarmClockProtocol <NSObject>
//闹钟index
@property (nonatomic, assign)NSInteger index;
//闹钟时间，必须是HH:mm
@property (nonatomic, copy)NSString *time;
//闹钟状态，周一至周日
@property (nonatomic, strong)id <MKAlarmClockStatusProtocol>clockStatusProtocol;
//闹钟类型，一共6种，吃药0、喝水1、普通2、睡眠3、锻炼4、运动5
@property (nonatomic, assign)MKAlarmClockType clockType;
//当前闹钟状态，YES打开，NO关闭
@property (nonatomic, assign)BOOL isOn;

@end


/**
 设置关于时间段的协议，比如翻腕亮屏、勿扰时段等
 */
@protocol MKPeriodTimeSetProtocol <NSObject>

/**
 开始时,0~23
 */
@property (nonatomic, assign)NSInteger startHour;

/**
 开始分,0~59
 */
@property (nonatomic, assign)NSInteger startMin;

/**
 结束时,0~23
 */
@property (nonatomic, assign)NSInteger endHour;

/**
 结束分,0~59
 */
@property (nonatomic, assign)NSInteger endMin;

/**
 YES:打开，NO:关闭,这种状态下，开始时间和结束时间就没有任何意义了
 */
@property (nonatomic, assign)BOOL isOn;

@end
