//
//  LYBookStoreRootController.h
//  LYBookStore
//
//  Created by grenlight on 14/6/29.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <OWKit/OWKit.h>
#import <LYService/LYMenuData.h> 

@interface LYBookStoreRootController : XibAdaptToScreenController
{
    IBOutlet OWBundleButton   *backButton;

    IBOutlet KWFSegmentedControl *segmentControl;
    
    NSInteger selectedIndex;
}
@property (nonatomic, copy) ReturnMethod returnToPreController;
@property (nonatomic, strong) LYMenuData *menu;

- (void)setBackButtonImage:(UIImage *)img;

- (IBAction)segmentedValueChanged:(id)sender;

@end
