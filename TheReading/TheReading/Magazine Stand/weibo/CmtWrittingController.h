//
//  CmtWrittingController.h
//  LogicBook
//
//  Created by iMac001 on 12-3-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SendingProgressController;

@interface CmtWrittingController :UIViewController <UITextViewDelegate>{
    @private
    IBOutlet UIView *writtingPanel;
    IBOutlet UIView *toolPanel;
    IBOutlet UIButton *cancelBT;
    IBOutlet UIButton *sendBT;
    
    IBOutlet UITextView *textView;
    IBOutlet UILabel *inputCountLB, *titleLB, *placeholderLB;

    
    UIImageView *toolPanelMask;
}

- (void)initMask:(UIView *)mask;
-(void)animateInWritingPanel;

-(IBAction)close:(id)sender;
-(IBAction)sendMessage:(id)sender;

-(void)animageOut:(void (^)(void))bl;

- (void)sendingCompleted;
@end

