//
//  OfflineViewController.h
//  PublicLibrary
//
//  Created by grenlight on 14-5-29.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <OWKit/OWKit.h>

@interface OfflineViewController : XibAdaptToScreenController
{
   __weak IBOutlet KWFSegmentedControl *segmentControl;
}
@property (nonatomic, copy) ReturnMethod returnToPreController;

- (IBAction)segmentedValueChanged:(id)sender;

@end
