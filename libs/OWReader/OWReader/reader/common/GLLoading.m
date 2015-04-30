//
//  GLLoading.m
//  LogicBook
//
//  Created by iMac001 on 12-2-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GLLoading.h"

@implementation GLLoading

static GLLoading *instance;

- (void)initializeSharedInstance
{
    self.backgroundColor = [UIColor clearColor];
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(25, 25);
    loading = [[UIActivityIndicatorView alloc]initWithFrame:frame];
    loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    loading.autoresizingMask = UIViewAutoresizingFlexibleHeight|
    UIViewAutoresizingFlexibleWidth;
    [self addSubview:loading];
    [loading startAnimating];
    
}

+(GLLoading *)sharedInstance
{
    @synchronized(self){
        if (instance == nil){
            instance = [[self alloc] init];
            [instance initializeSharedInstance];
        }
        return(instance);
    }
}

-(void)didMoveToSuperview
{
    [self startAnimating];
}

-(void)removeFromSuperview
{
    [self stopAnimating];
    [super removeFromSuperview];
}

-(void)startAnimating
{
    [loading setHidden:NO];
    [loading startAnimating];

}

-(void)stopAnimating
{
    [loading stopAnimating];
    [loading setHidden:YES];
}

@end
