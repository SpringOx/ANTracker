//
//  ANDIYTracker.m
//  ANTracker
//
//  Created by SpringOx on 14/11/8.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import "ANDIYTracker.h"
#import "ANTracker.h"

@implementation ANDIYTrackInfo

- (id)initWithType:(ANTrackType)_type
               diy:(NSString *)_diy
{
    self = [super init];
    if (self) {
        
        type = _type;
        diy = _diy;
    }
    return self;
}

@end

@interface ANDIYTracker()<ANTracker>

@end

@implementation ANDIYTracker

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
    // statistical package config
}

- (void)trackEvent:(ANTrackInfo *)trackInfo
{
    if ([trackInfo isKindOfClass:[ANDIYTrackInfo class]]) {
        NSLog(@"DIY Tracker :%@", ((ANDIYTrackInfo *)trackInfo)->diy);
    }
}

- (void)trackPage:(ANTrackInfo *)trackInfo
{
    if ([trackInfo isKindOfClass:[ANDIYTrackInfo class]]) {
        NSLog(@"DIY Tracker :%@", ((ANDIYTrackInfo *)trackInfo)->diy);
    }
}

- (void)didAddTracker
{
    // do nothing
}

- (void)willRemoveTracker
{
    // do nothing
}

- (NSString *)trackerName
{
    return NSStringFromClass([self class]);
}

#pragma mark ANTracker Protocol--

@end
