//
//  CatelogueViewController.h
//  DragonSourceReader
//
//  Created by iMac001 on 11-12-13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLRoundButton.h"
#import "CatalogueTableController.h"
#import "BookmarkTableController.h"
#import "BookDigestTableController.h"
#import "catalogeViewBtn.h"

@class OWBookButton;

@interface CatalogueViewController :XibAdaptToScreenController<GLRoundButtonDelegate>{
    
    @private
    CGRect sysFrame;
    CGPoint listCenter;//列表视图的中心点

    __weak IBOutlet UIView   *barBG;
    __weak IBOutlet OWSplitLineView *splitLine;
    __weak IBOutlet OWBookButton    *continueButton;
    
    __weak IBOutlet KWFSegmentedControl *segmentControl;
    
    
    CatalogueTableController *catalogueList;
    BookmarkTableController  *bookmarkList;
    BookDigestTableController *bookDigestList;
    
    
    OWViewController    *currentController;
    
}

-(IBAction)intoCatelogueTable:(id)sender;
-(IBAction)intoBookmarkTable:(id)sender;

-(IBAction)add_n_removeView:(id)sender;

- (IBAction)segmentValueChanged:(id)sender;
- (IBAction)continueRead:(id)sender;

-(IBAction)intoBookDigestTable:(id)sender;



@end
