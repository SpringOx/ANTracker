//
//  ANTrackServer.h
//  ANTracker
//
//  Created by SpringOx on 14/11/9.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANTracker.h"

@interface ANTrackerNode : NSObject {
    
@public
    id <ANTracker> tracker;
    dispatch_queue_t trackerQueue;
}

+ (ANTrackerNode *)nodeWithTracker:(id <ANTracker>)tracker trackerQueue:(dispatch_queue_t)trackerQueue;

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
+ (void)trackWithInfo:(ANTrackInfo *)info;

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
