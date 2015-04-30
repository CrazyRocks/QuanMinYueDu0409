//
//  GLConfig.m
//  GLConfiguration
//
//  Created by iMac001 on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BSConfig.h"

@implementation BSConfig

static BSConfig *sharedInstance;

@synthesize isHierarchyStyle;

- (void)initializeSharedInstance{
    isHierarchyStyle =NO;
}

+ (BSConfig *) sharedInstance{
    @synchronized(self){
        if (sharedInstance == nil){
            sharedInstance = [[self alloc] init];
            [sharedInstance initializeSharedInstance];
        }
        return(sharedInstance);
    }
}
@end
