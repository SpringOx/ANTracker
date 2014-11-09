//
//  ANTracker.h
//  Araneo
//
//  Created by SpringOx on 13-4-30.
//  Copyright (c) 2013年 SpringOx. All rights reserved.
//

#import <Foundation/Foundation.h>

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
    Class target;   // 用于指定info的具体execute对象(tracker)的类型
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
- (Class)infoClass;
/*
 */
- (dispatch_queue_t)trackerQueue;
/*
 */
- (NSString *)trackerName;

@end
