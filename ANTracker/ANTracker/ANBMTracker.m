//
//  ANBMTracker.m
//  ANTracker
//
//  Created by SpringOx on 14/11/8.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import "ANBMTracker.h"
#import "ANTracker.h"
#import "BaiduMobStat.h"

#warning 需要自行配置百度移动统计平台提供的app_key
static NSString *const TRACKER_BM_APP_KEY = @"78528e52cd";
static int const TRACKER_BM_SEND_INTERVAL = 1;
static NSString *const TRACKER_BM_CHANNEL_ID = @"AppStore";

@interface ANBMTracker()<ANTracker>
{
    
}

@end

@implementation ANBMTracker

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setConfig];
    }
    return self;
}

- (void)dealloc
{
    // do nothing
}

#pragma mark ANTracker Protocol

- (void)setConfig
{
    BaiduMobStat* statTracker = [BaiduMobStat defaultStat];
    statTracker.enableExceptionLog = YES; // 是否允许截获并发送崩溃信息，请设置YES或者NO
    statTracker.channelId = TRACKER_BM_CHANNEL_ID;//设置您的app的发布渠道
    statTracker.logStrategy = BaiduMobStatLogStrategyCustom;//根据开发者设定的发送策略,发送日志
    statTracker.logSendInterval = TRACKER_BM_SEND_INTERVAL;  //为1时表示发送日志的时间间隔为1小时,当logStrategy设置为BaiduMobStatLogStrategyCustom时生效
    statTracker.logSendWifiOnly = YES; //是否仅在WIfi情况下发送日志数据
    statTracker.sessionResumeInterval = 60;//设置应用进入后台再回到前台为同一次session的间隔时间[0~600s],超过600s则设为600s，默认为30s
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    statTracker.shortAppVersion  = version; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
#if DEBUG
    statTracker.enableDebugOn = YES; //调试的时候打开，会有log打印，发布时候关闭
#endif
    /*如果有需要，可自行传入adid
     NSString *adId = @"";
     if([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0f){
     adId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
     }
     statTracker.adid = adId;
     */
    [statTracker startWithAppId:TRACKER_BM_APP_KEY];//设置您在mtj网站上添加的app的appkey,此处AppId即为应用的appKey
}

- (void)trackEvent:(ANTrackInfo *)trackInfo
{
    if (0 == [trackInfo->module length])
    {
        return;
    }
    
    if (ANTrackTypeNormal == trackInfo->type) {
        if (0 < [trackInfo->event length])
        {
            NSString *eventId = [NSString stringWithFormat:@"%@-%@", trackInfo->module, trackInfo->event];
            [self trackNormalEvent:eventId info:trackInfo];
        }
        else
        {
            NSString *eventId = trackInfo->module;
            [self trackNormalEvent:eventId info:trackInfo];
        }
    }
    else
    {
        if (0 < [trackInfo->event length])
        {
            NSString *eventId = [NSString stringWithFormat:@"%@-%@", trackInfo->module, trackInfo->event];
            [self trackBeginAndEndEvent:eventId info:trackInfo];
        }
        else {
            NSString *eventId = trackInfo->module;
            [self trackBeginAndEndEvent:eventId info:trackInfo];
        }
    }
}

- (void)trackNormalEvent:(NSString *)eventId info:(ANTrackInfo *)trackInfo
{
    if (nil != trackInfo->durations)
    {
        [[BaiduMobStat defaultStat] logEventWithDurationTime:eventId eventLabel:trackInfo->label durationTime: [trackInfo->durations unsignedLongValue]];
    }
    else
    {
        [[BaiduMobStat defaultStat] logEvent:eventId eventLabel:trackInfo->label];
    }
}

- (void)trackBeginAndEndEvent:(NSString *)eventId info:(ANTrackInfo *)trackInfo
{
    if (ANTrackTypeNormal == trackInfo->type) {
        return;
    }
    
    if (ANTrackTypeBegin == trackInfo->type)
    {
        [[BaiduMobStat defaultStat] eventStart:eventId eventLabel:trackInfo->label];
    }
    else
    {
        [[BaiduMobStat defaultStat] eventEnd:eventId eventLabel:trackInfo->label];
    }
}

- (void)trackPage:(ANTrackInfo *)trackInfo
{
    if (0 == [trackInfo->page length])
    {
        return;
    }
    
    if (ANTrackTypeNormal == trackInfo->type)
    {
        return;
    }
    
    if (ANTrackTypeBegin == trackInfo->type)
    {
        [[BaiduMobStat defaultStat] pageviewStartWithName:trackInfo->page];
    }
    else
    {
        [[BaiduMobStat defaultStat] pageviewEndWithName:trackInfo->page];
    }
}

- (dispatch_queue_t)trackerQueue
{
    return NULL;
}

- (NSString *)trackerName
{
    return NSStringFromClass([self class]);
}

#pragma mark ANTracker Protocol--

@end
