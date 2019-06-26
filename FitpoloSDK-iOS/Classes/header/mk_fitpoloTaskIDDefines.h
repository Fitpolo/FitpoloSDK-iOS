
typedef NS_ENUM(NSInteger, mk_taskOperationID) {
    mk_defaultTaskOperationID,           //default
#pragma mark - read
    mk_readAlarmClockOperation,           //读取闹钟数据
    mk_readAncsOptionsOperation,          //读取ancs选项
    mk_readSedentaryRemindOperation,      //读取久坐提醒
    mk_readMovingTargetOperation,         //读取运动目标
    mk_readUnitDataOperation,             //读取单位信息
    mk_readTimeFormatDataOperation,       //读取时间进制
    mk_readCustomScreenDisplayOperation,  //读取当前显示的屏幕信息
    mk_readRemindLastScreenDisplayOperation,  //读取是否显示上一次屏幕
    mk_readHeartRateAcquisitionIntervalOperation,     //读取手环心率采集间隔
    mk_readDoNotDisturbTimeOperation,     //读取勿扰时段
    mk_readPalmingBrightScreenOperation,  //获取翻腕亮屏信息
    mk_readUserInfoOperation,             //获取用户设置的个人信息
    mk_readDialStyleOperation,            //获取表盘样式
    mk_readHardwareParametersOperation,    //获取硬件参数
    mk_readFirmwareVersionOperation,       //获取固件版本号
    mk_readSleepIndexOperation,            //获取睡眠index数据
    mk_readSleepRecordOperation,           //获取睡眠record数据
    mk_readSportsDataOperation,            //获取运动数据
    mk_readLastChargingTimeOperation,      //获取上一次充电时间
    mk_readBatteryOperation,               //获取手环电量
    mk_readANCSConnectStatusOperation,     //获取当前手环跟手机的ancs连接状态
    
#pragma mark - config
    mk_configAlarmClockNumbersOperation,     //设置闹钟组数
    mk_configAlarmClockOperation,            //设置闹钟
    mk_configSedentaryRemindOperation,       //设置久坐提醒
    mk_configMovingTargetOperation,          //设置运动目标
    mk_configUnitOperation,                  //切换进制单位
    mk_configTimeFormatOperation,            //设置时间进制
    mk_configScreenDisplayOperation,         //设置屏幕显示
    mk_remindLastScreenDisplayOperation,  //记住上一次屏幕显示
    mk_configHeartRateAcquisitionIntervalOperation,  //设置心率采集间隔
    mk_configDoNotDisturbTimeOperation,      //设置勿扰模式
    mk_openPalmingBrightScreenOperation,  //设置翻腕亮屏
    mk_configUserInfoOperation,              //设置个人信息
    mk_configDateOperation,                  //设置日期
    mk_configDialStyleOperation,             //设置表盘样式
    mk_vibrationOperation,                //震动指令
    mk_configANCSOptionsOperation,           //设置开启ancs的选项
    mk_openANCSOperation,                 //701手环需要先开启ancs
    mk_powerOffDeviceOperation,           //关机
    mk_clearDeviceDataOperation,          //清空手环数据
    
#pragma mark - 计步
    mk_readStepDataOperation,              //获取计步数据
    mk_stepChangeMeterMonitoringStatusOperation ,    //计步数据监听状态
    mk_startUpdateOperation,              //开启升级
    
#pragma mark - 心率
    mk_readHeartDataOperation,             //获取心率数据
    mk_readSportHeartDataOperation,        //获取运动心率数据
    
#pragma mark - 701特有
    mk_readInternalVersionOperation,      //获取内部版本号
    mk_readMemoryDataOperation,           //获取内存数据
    mk_readConfigurationParametersOperation,    //获取配置参数
    
    #pragma mark - 706特有
    mk_readDateFormatterOperation,         //获取706手环当前显示的日期制式
    mk_configDateFormatterOperation,       //设置706手环当前显示的日期格式
    mk_readLanguageOperation,              //获取706手环当前显示的语言
    mk_configLanguageOperation,            //设置706手环当前显示的语言
    mk_readVibrationIntensityOfDeviceOperation, //读取706震动强度
    mk_configVibrationIntensityOfDeviceOperation,   //设置706震动强度
    mk_readScreenListOperation,             //读取706当前屏幕显示列表
    mk_configScreenListOperation,           //配置706当前屏幕显示列表
    mk_configStepIntervalOperation,         //配置706计步间隔
    mk_readStepIntervalDataOperation,       //读取706间隔计步数据
    mk_configSearchPhoneOperation,          //搜索手机功能
};
