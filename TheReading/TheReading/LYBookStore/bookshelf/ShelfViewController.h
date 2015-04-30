//
//  ShelfViewController.h
//  LYEPUBReader
//
//  Created by grenlight on 14/6/13.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <OWKit/OWKit.h>
#import "OWBookButton.h"
#import "ShelfSearchController.h"
#import "LYShelfSlideMenuController.h"

@interface ShelfViewController : XibAdaptToScreenController<ShelfSearchDelegate,UIScrollViewDelegate>
{
    __weak IBOutlet KWFSegmentedControl *segmentControl;
    __weak IBOutlet OWBookButton       *barcodeButton, *layoutButton;
    __weak IBOutlet UIScrollView       *contentView;
    
    BOOL    isFilterPanelVisible, isHorizontalLayout;
    UIView  *filterBGMask;
    
    CGPoint   touchStart;
    CGPoint   menuHomeCenter, menuSchoolCenter, menuOriginalCenter;
}

@property (nonatomic, strong) LYShelfSlideMenuController  *slideMenuController;
@property (nonatomic, strong) UIPanGestureRecognizer      *panGuestureRecognizer;

@property (nonatomic, assign) BOOL                         touchMoving;
@property (nonatomic, assign) BOOL                         isMenuOpened;

- (IBAction)segmentedValueChanged:(id)sender;
- (IBAction)scanButtonTapped:(id)sender;
- (IBAction)setting:(id)sender;

- (void)fadeInMaskView;
- (void)fadeOutMaskView;

- (IBAction)filter:(id)sender;
- (void)showFilter;
- (void)hideFilter;
- (void)hideFilterRetainMask;

- (IBAction)layout:(id)sender;

//整理书架
- (void)editShelf;

- (void)showSearchBar;

@end
