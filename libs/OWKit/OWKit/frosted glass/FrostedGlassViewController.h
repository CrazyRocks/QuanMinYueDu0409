//
//  FrostedGlassViewController.h
//  PublicLibrary
//
//  Created by grenlight on 13-12-4.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "FrostedGlassBackgroundView.h"
#import <OWKit/OWKit.h>

@interface FrostedGlassViewController : XibAdaptToScreenController

@property (nonatomic, strong) FrostedGlassBackgroundView    *backgroundView;

- (void)generateFrostedGlassImage;

@end
