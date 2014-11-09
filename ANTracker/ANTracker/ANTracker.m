//
//  ANTracker.m
//  Araneo
//
//  Created by SpringOx on 13-4-30.
//  Copyright (c) 2013年 SpringOx. All rights reserved.
//

#import "ANTracker.h"

@implementation ANTrackInfo

- (id)initWithType:(ANTrackType)_type
            module:(NSString *)_module
             event:(NSString *)_event
             label:(NSString *)_label
      accumulation:(NSNumber *)_accumulation
         durations:(NSNumber *)_durations
        attributes:(NSDictionary *)_attributes;
{
    self = [super init];
    if (self)
    {
        type = _type;
        module = _module;
        event = _event;
        label = _label;
        accumulation = _accumulation;
        durations = _durations;
        attributes = _attributes;
    }
    return self;
}

- (id)initWithType:(ANTrackType)_type
              page:(NSString *)_page
{
    self = [super init];
    if (self)
    {
        type = _type;
        page = _page;
    }
    return self;
}

@end
