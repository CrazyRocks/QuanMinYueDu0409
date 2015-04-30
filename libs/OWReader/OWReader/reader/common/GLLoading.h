//
//  GLLoading.h
//  LogicBook
//
//  Created by iMac001 on 12-2-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLLoading : UIView
{
    UIActivityIndicatorView *loading;
}

+(GLLoading *)sharedInstance;
-(void)startAnimating;
-(void)stopAnimating;

@end
