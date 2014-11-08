//
//  ANTracker.h
//  Araneo
//
//  Created by SpringOx on 13-4-30.
//  Copyright (c) 2013年 SpringOx. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ANTracker;

@class ANTrackInfo;
@class ANTrackServer;

@protocol ANTracker <NSObject>

@required
/*
 */
- (void)trackEvent:(ANTrackInfo *)trackInfo;
/*
 */
- (void)trackPage:(ANTrackInfo *)trackInfo;

@optional
/*
 */
- (void)setConfig;
/*
 */
- (void)didAddTracker;
/*
 */
- (void)willRemoveTracker;
/*
 */
- (BOOL)asynchronousEabled;
/*
 */
- (dispatch_queue_t)trackerQueue;
/*
 */
- (NSString *)trackerName;

@end

@interface ANTrackerNode : NSObject {
    
@public
	id <ANTracker> tracker;
	dispatch_queue_t trackerQueue;
}

+ (ANTrackerNode *)nodeWithTracker:(id <ANTracker>)tracker trackerQueue:(dispatch_queue_t)trackerQueue;

@end

typedef enum _ANTrackType
{
    ANTrackTypeBegin = 0,
    ANTrackTypeEnd,
    ANTrackTypeNormal,
} ANTrackType;

@interface ANTrackInfo : NSObject
{
@public
    ANTrackType type;
    NSString *module;
    NSString *event;
    NSString *label;
    NSNumber *accumulation;
    NSNumber *durations;
    NSDictionary *attributes;
    NSString *page;
    NSInteger tag;
}

/*
 */
- (id)initWithType:(ANTrackType)_type
            module:(NSString *)_module
             event:(NSString *)_event
             label:(NSString *)_label
      accumulation:(NSNumber *)_accumulation
         durations:(NSNumber *)_durations
        attributes:(NSDictionary *)_attributes;

/*
 */
- (id)initWithType:(ANTrackType)_type
              page:(NSString *)_page;

@end

@interface ANTrackServer : NSObject

/*
 */
+ (void)startWithTrackers:(NSArray *)trackers;

/*
 */
+ (dispatch_queue_t)trackingQueue;

/*
 */
+ (void)track:(NSString *)module
        event:(NSString *)event;

/*
 */
+ (void)track:(NSString *)module
        event:(NSString *)event
        label:(NSString *)label;

/*
 */
+ (void)track:(NSString *)module
        event:(NSString *)event
        label:(NSString *)label
 accumulation:(NSInteger)accumulation;

/*
 */
+ (void)track:(NSString *)module
        event:(NSString *)event
        label:(NSString *)label
    durations:(NSTimeInterval)durations;

/*
 */
+ (void)track:(NSString *)module
        event:(NSString *)event
   attributes:(NSDictionary *)attributes;

/*
 */
+ (void)trackEventBegin:module
                  event:event
                  label:(NSString *)label;

/*
 */
+ (void)trackEventEnd:module
                event:event
                label:(NSString *)label;

/*
 */
+ (void)trackPageBegin:(NSString *)page;

/*
 */
+ (void)trackPageEnd:(NSString *)page;

/*
 */
+ (void)addTracker:(id <ANTracker>)tracker;

/*
 */
+ (void)removeTracker:(id <ANTracker>)tracker;

/*
 */
+ (void)removeAllTrackers;

@end
