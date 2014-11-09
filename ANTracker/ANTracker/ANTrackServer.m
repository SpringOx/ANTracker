//
//  ANTrackServer.m
//  ANTracker
//
//  Created by SpringOx on 14/11/9.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import "ANTrackServer.h"
#import <pthread.h>
#import <objc/runtime.h>
#import <mach/mach_host.h>
#import <mach/host_info.h>

#define TRACK_MAX_QUEUE_SIZE 1000 // Should not exceed INT32_MAX

void *const GlobalTrackingQueueIdentityKey = (void *)&GlobalTrackingQueueIdentityKey;

@implementation ANTrackerNode

+ (ANTrackerNode *)nodeWithTracker:(id<ANTracker>)tracker trackerQueue:(dispatch_queue_t)trackerQueue
{
    return [[ANTrackerNode alloc] initWithTracker:tracker trackerQueue:trackerQueue];
}

- (id)initWithTracker:(id <ANTracker>)_tracker trackerQueue:(dispatch_queue_t)_trackerQueue
{
    self = [super init];
    if (self)
    {
        tracker = _tracker;
        if (_trackerQueue)
        {
            trackerQueue = _trackerQueue;
#if !OS_OBJECT_USE_OBJC
            dispatch_retain(trackerQueue);
#endif
        }
    }
    return self;
}

- (void)dealloc
{
#if !OS_OBJECT_USE_OBJC
    if (trackerQueue) {dispatch_release(trackerQueue);}
#endif
}

@end

@interface ANTrackServer (PrivateAPI)

+ (void)track:(ANTrackType)type
       module:(NSString *)module
        event:(NSString *)event
        label:(NSString *)label
 accumulation:(NSNumber *)accumulation
    durations:(NSNumber *)durations
   attributes:(NSDictionary *)attributes;

+ (void)queueTrackEvent:(ANTrackInfo *)trackInfo;
+ (void)lt_track:(ANTrackInfo *)trackInfo;
+ (void)lt_addTracker:(id <ANTracker>)tracker;
+ (void)lt_removeTracker:(id <ANTracker>)tracker;
+ (void)lt_removeAllTrackers;

@end

@implementation ANTrackServer

/*
 */
static NSMutableArray *trackers;

/*
 */
static dispatch_queue_t trackingQueue;

/*
 */
static dispatch_group_t trackingGroup;

/*
 */
static dispatch_semaphore_t queueSemaphore;

/*
 */
static unsigned int numProcessors;

+ (void)initialize
{
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        trackers = [[NSMutableArray alloc] initWithCapacity:1];
        
        NSString *bi = [NSBundle mainBundle].bundleIdentifier;
        trackingQueue = dispatch_queue_create([bi UTF8String], NULL);
        trackingGroup = dispatch_group_create();
        
        void *nonNullValue = GlobalTrackingQueueIdentityKey;
        dispatch_queue_set_specific(trackingQueue, GlobalTrackingQueueIdentityKey, nonNullValue, NULL);
        
        queueSemaphore = dispatch_semaphore_create(TRACK_MAX_QUEUE_SIZE);
        
        host_basic_info_data_t hostInfo;
        mach_msg_type_number_t infoCount;
        
        infoCount = HOST_BASIC_INFO_COUNT;
        host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount);
        
        unsigned int result = (unsigned int)(hostInfo.max_cpus);
        unsigned int one = (unsigned int)(1);
        
        numProcessors = MAX(result, one);
    });
}

+ (void)startWithTrackers:(NSArray *)trackers
{
    if (0 == [trackers count]) {return;};
    
    for (id <ANTracker>tracker in trackers)
    {
        [self addTracker:tracker];
    }
}

+ (dispatch_queue_t)trackingQueue
{
    return trackingQueue;
}

+ (BOOL)concurrentIsEnabled
{
    return YES;
}

+ (void)track:(NSString *)module
        event:(NSString *)event
{
    [self track:ANTrackTypeNormal
         module:module
          event:event
          label:nil
   accumulation:nil
      durations:nil
     attributes:nil];
}

+ (void)track:(NSString *)module
        event:(NSString *)event
        label:(NSString *)label
{
    [self track:ANTrackTypeNormal
         module:module
          event:event
          label:label
   accumulation:nil
      durations:nil
     attributes:nil];
}

+ (void)track:(NSString *)module
        event:(NSString *)event
        label:(NSString *)label
 accumulation:(NSInteger)accumulation
{
    [self track:ANTrackTypeNormal
         module:module
          event:event
          label:label
   accumulation:[NSNumber numberWithInteger:accumulation]
      durations:nil
     attributes:nil];
}

+ (void)track:(NSString *)module
        event:(NSString *)event
        label:(NSString *)label
    durations:(NSTimeInterval)durations
{
    [self track:ANTrackTypeNormal
         module:module
          event:event
          label:label
   accumulation:nil
      durations:[NSNumber numberWithDouble:durations]
     attributes:nil];
}

+ (void)track:(NSString *)module
        event:(NSString *)event
   attributes:(NSDictionary *)attributes
{
    [self track:ANTrackTypeNormal
         module:module
          event:event
          label:nil
   accumulation:nil
      durations:nil
     attributes:attributes];
}

+ (void)trackEventBegin:module
                  event:event
                  label:(NSString *)label
{
    [self track:ANTrackTypeBegin
         module:module
          event:event
          label:label
   accumulation:nil
      durations:nil
     attributes:nil];
}

+ (void)trackEventEnd:module
                event:event
                label:(NSString *)label
{
    [self track:ANTrackTypeEnd
         module:module
          event:event
          label:label
   accumulation:nil
      durations:nil
     attributes:nil];
}

+ (void)trackEventBegin:module
                  event:event
             attributes:(NSDictionary *)attributes
{
    [self track:ANTrackTypeBegin
         module:module
          event:event
          label:nil
   accumulation:nil
      durations:nil
     attributes:attributes];
}

+ (void)trackEventEnd:module
                event:event
           attributes:(NSDictionary *)attributes
{
    [self track:ANTrackTypeEnd
         module:module
          event:event
          label:nil
   accumulation:nil
      durations:nil
     attributes:attributes];
}

+ (void)trackPageBegin:(NSString *)page
{
    [self track:ANTrackTypeBegin
           page:page];
}

+ (void)trackPageEnd:(NSString *)page
{
    [self track:ANTrackTypeEnd
           page:page];
}

+ (void)trackWithInfo:(ANTrackInfo *)info
{
    [self lt_track:info];
}

+ (void)addTracker:(id <ANTracker>)tracker
{
    if (nil == tracker) {return;}
    
    dispatch_async(trackingQueue, ^{
        @autoreleasepool {
            [self lt_addTracker:tracker];
        }
    });
}

+ (void)removeTracker:(id <ANTracker>)tracker
{
    if (nil == tracker) {return;}
    
    dispatch_async(trackingQueue, ^{
        @autoreleasepool {
            [self lt_removeTracker:tracker];
        }
    });
}

+ (void)removeAllTrackers
{
    dispatch_async(trackingQueue, ^{
        @autoreleasepool {
            [self lt_removeAllTrackers];
        }
    });
}

#pragma mark PrivateAPI

+ (void)track:(ANTrackType)type
       module:(NSString *)module
        event:(NSString *)event
        label:(NSString *)label
 accumulation:(NSNumber *)accumulation
    durations:(NSNumber *)durations
   attributes:(NSDictionary *)attributes
{
    if (0 == [module length]) {return;}
    
    ANTrackInfo *trackInfo = [[ANTrackInfo alloc] initWithType:type
                                                        module:module
                                                         event:event
                                                         label:label
                                                  accumulation:accumulation
                                                     durations:durations
                                                    attributes:attributes];
    
    [self queueTrackEvent:trackInfo];
}

+ (void)track:(ANTrackType)type
         page:(NSString *)page
{
    if (0 == [page length]) {return;}
    
    ANTrackInfo *trackInfo = [[ANTrackInfo alloc] initWithType:type
                                                          page:page];
    [self queueTrackEvent:trackInfo];
}

+ (void)queueTrackEvent:(ANTrackInfo *)trackInfo
{
    dispatch_semaphore_wait(queueSemaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_block_t trackBlock = ^{
        @autoreleasepool {
            [self lt_track:trackInfo];
        }
    };
    
    dispatch_async(trackingQueue, trackBlock);
}

+ (void)lt_track:(ANTrackInfo *)trackInfo
{
    if ([self concurrentIsEnabled] && 1 < numProcessors)
    {
        // Group不是一般的异步，应该是能够支持并发线程，所以要捕捉是否禁止并发，springox
        for (ANTrackerNode *trackerNode in trackers)
        {
            // 每一个Info支持指定过滤Tracker类型，springox(20141108)
            if (NULL != trackInfo->target &&
                ![trackerNode->tracker isKindOfClass:trackInfo->target]) {
                continue;
            }
            // 每一个Tracker支持指定过滤Info类型，springox(20141108)
            if ([trackerNode->tracker respondsToSelector:@selector(infoClass)] &&
                NULL != [trackerNode->tracker infoClass] &&
                ![trackInfo isKindOfClass:[trackerNode->tracker infoClass]]) {
                continue;
            }
            
            dispatch_group_async(trackingGroup, trackerNode->trackerQueue, ^{
                @autoreleasepool {
                    if (nil != trackInfo->page)
                    {
                        [trackerNode->tracker trackPage:trackInfo];
                    }
                    else
                    {
                        [trackerNode->tracker trackEvent:trackInfo];
                    }
                }
            });
        }
        
        dispatch_group_wait(trackingGroup, DISPATCH_TIME_FOREVER);
        
        dispatch_semaphore_signal(queueSemaphore);
    }
    else
    {
        for (ANTrackerNode *trackerNode in trackers)
        {
            // 常规自定义异步，不支持并发线程，springox
            @autoreleasepool {
                [trackerNode->tracker trackEvent:trackInfo];
            }
        }
    }
}

+ (void)lt_addTracker:(id <ANTracker>)tracker
{
    dispatch_queue_t trackerQueue = NULL;
    
    if ([tracker respondsToSelector:@selector(trackerQueue)])
    {
        trackerQueue = [tracker trackerQueue];
    }
    
    if (NULL == trackerQueue)
    {
        const char *trackerQueueName = NULL;
        if ([tracker respondsToSelector:@selector(trackerName)])
        {
            trackerQueueName = [[tracker trackerName] UTF8String];
        }
        
        trackerQueue = dispatch_queue_create(trackerQueueName, NULL);
    }
    
    ANTrackerNode *trackerNode = [ANTrackerNode nodeWithTracker:tracker trackerQueue:trackerQueue];
    [trackers addObject:trackerNode];
    
    if ([tracker respondsToSelector:@selector(didAddTracker)])
    {
        dispatch_async(trackerNode->trackerQueue, ^{
            @autoreleasepool {
                [tracker didAddTracker];
            }
        });
    }
}

+ (void)lt_removeTracker:(id<ANTracker>)tracker
{
    ANTrackerNode *trackerNode = nil;
    
    for (ANTrackerNode *node in trackers)
    {
        if (tracker == node->tracker)
        {
            trackerNode = node;
            break;
        }
    }
    
    if (nil == trackerNode) {
        return;
    }
    
    if ([tracker respondsToSelector:@selector(willRemoveTracker)])
    {
        dispatch_async(trackerNode->trackerQueue, ^{
            @autoreleasepool {
                [tracker willRemoveTracker];
            }
        });
    }
    
    [trackers removeObject:trackerNode];
}

+ (void)lt_removeAllTrackers
{
    for (ANTrackerNode *node in trackers)
    {
        if ([node->tracker respondsToSelector:@selector(willRemoveTracker)])
        {
            dispatch_async(node->trackerQueue, ^{
                @autoreleasepool {
                    [node->tracker willRemoveTracker];
                }
            });
        }
    }
    
    [trackers removeAllObjects];
}

@end
