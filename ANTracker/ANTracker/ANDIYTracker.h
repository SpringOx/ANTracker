//
//  ANDIYTracker.h
//  ANTracker
//
//  Created by SpringOx on 14/11/8.
//  Copyright (c) 2014年 SpringOx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANTracker.h"

@interface ANDIYTrackInfo : ANTrackInfo
{
@public
    NSString *diy;
}

- (id)initWithType:(ANTrackType)_type
               diy:(NSString *)_diy;

@end

@interface ANDIYTracker : NSObject

@end
