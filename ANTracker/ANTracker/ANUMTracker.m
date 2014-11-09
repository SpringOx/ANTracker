//
//  ANUMTracker.m
//  Araneo
//
//  Created by SpringOx on 13-11-2.
//  Copyright (c) 2013年 SpringOx. All rights reserved.
//

#import "ANUMTracker.h"
#import "ANTracker.h"
#import "MobClick.h"

#warning 需要自行配置友盟统计平台提供的app_key
static NSString *const TRACKER_UMENG_APP_KEY = @"545a5d56fd98c50cdc007655";
static int const TRACKER_UMENG_SEND_INTERVAL = 60;
static NSString *const TRACKER_UMENG_CHANNEL_ID = @"AppStore";

@interface ANUMTracker()<ANTracker>
{
    dispatch_queue_t trackerQueue;
}

@end

@implementation ANUMTracker

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
#if !OS_OBJECT_USE_OBJC
    if (trackerQueue) dispatch_release(trackerQueue);
#endif
}

#pragma mark ANTracker Protocol

- (void)setConfig
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    [MobClick setCrashReportEnabled:YES];
#if DEBUG
    [MobClick setLogEnabled:YES];
#endif
    [MobClick setLogSendInterval:TRACKER_UMENG_SEND_INTERVAL];
    [MobClick startWithAppkey:TRACKER_UMENG_APP_KEY reportPolicy:(ReportPolicy)SEND_INTERVAL channelId:TRACKER_UMENG_CHANNEL_ID];
    
#if DEBUG
    // 获取友盟测试设备ID，springox(20141109)
    Class cls = NSClassFromString(@"UMANUtil");
    SEL deviceIDSelector = @selector(openUDIDString);
    NSString *deviceID = nil;
    if(cls && [cls respondsToSelector:deviceIDSelector]){
        deviceID = [cls performSelector:deviceIDSelector];
    }
    NSLog(@"{\"oid\": \"%@\"}", deviceID);
#endif
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
    if (nil != trackInfo->attributes)
    {
        [MobClick event:eventId attributes:trackInfo->attributes];
    }
    else if (nil != trackInfo->durations)
    {
        [MobClick event:eventId label:trackInfo->label durations:[trackInfo->durations intValue]];
    }
    else if (nil != trackInfo->accumulation)
    {
        [MobClick event:eventId label:trackInfo->label acc:[trackInfo->accumulation integerValue]];
    }
    else if (nil != trackInfo->label) {
        [MobClick event:eventId label:trackInfo->label];
    }
    else
    {
        [MobClick event:eventId];
    }
}

- (void)trackBeginAndEndEvent:(NSString *)eventId info:(ANTrackInfo *)trackInfo
{
    if (ANTrackTypeNormal == trackInfo->type) {
        return;
    }
    
    if (nil != trackInfo->attributes)
    {
        if (ANTrackTypeBegin == trackInfo->type)
        {
            [MobClick beginEvent:eventId primarykey:@"primarykey" attributes:trackInfo->attributes];
        }
        else
        {
            [MobClick endEvent:eventId primarykey:@"primarykey"];
        }
    }
    else if (nil != trackInfo->label)
    {
        if (ANTrackTypeBegin == trackInfo->type)
        {
            [MobClick beginEvent:eventId label:trackInfo->label];
        }
        else
        {
            [MobClick endEvent:eventId label:trackInfo->label];
        }
    }
    else
    {
        if (ANTrackTypeBegin == trackInfo->type)
        {
            [MobClick beginEvent:eventId];
        }
        else
        {
            [MobClick endEvent:eventId];
        }
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
        [MobClick beginLogPageView:trackInfo->page];
    }
    else
    {
        [MobClick endLogPageView:trackInfo->page];
    }
}

- (dispatch_queue_t)trackerQueue
{
    if (NULL == trackerQueue) {
        const char *trackerQueueName = NULL;
        if ([self respondsToSelector:@selector(trackerName)])
        {
            trackerQueueName = [[self trackerName] UTF8String];
        }
        trackerQueue = dispatch_queue_create(trackerQueueName, NULL);
        
        void *key = (__bridge void *)self;
        void *nonNullValue = (__bridge void *)self;
        dispatch_queue_set_specific(trackerQueue, key, nonNullValue, NULL);
    }
    return trackerQueue;
}

- (NSString *)trackerName
{
    return NSStringFromClass([self class]);
}

#pragma mark ANTracker Protocol--

@end
