//
//  GuideViewController.h
//  GoodSui
//
//  Created by 龙源 on 13-8-29.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//
#import <OWKit/OWKit.h> 


@interface GuideViewController : OWViewController<UIScrollViewDelegate>
{
    __weak IBOutlet UIScrollView *_scrollView;
    __weak IBOutlet UIPageControl  *pageControl;
}
+ (GuideViewController *)sharedInstance;

@end
