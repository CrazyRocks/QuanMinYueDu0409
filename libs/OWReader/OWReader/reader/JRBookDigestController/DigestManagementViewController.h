//
//  DigestManagementViewController.h
//  LYBookStore
//
//  Created by grenlight on 14/10/21.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//


#import "XibAdaptToScreenController.h"
#import "BookDigest.h"


@protocol DigestManagementViewControllerDelegate <NSObject>

-(void)changeColorComplete;

-(void)addNoteToBookDigest:(BookDigest *)model;









@end



















@interface DigestManagementViewController : XibAdaptToScreenController
{
    CGRect startRect;
    CGRect endRect;
    
    __unsafe_unretained IBOutlet UIButton *deleteBtn;
    __unsafe_unretained IBOutlet UIButton *orangeBtn;
    __unsafe_unretained IBOutlet UIButton *blueBtn;
    __unsafe_unretained IBOutlet UIButton *yellowBtn;
    __unsafe_unretained IBOutlet UIButton *redBtn;
    
    
    __unsafe_unretained IBOutlet UIButton *addNoteBtn;
    __unsafe_unretained IBOutlet UIButton *copyBtn;
    __unsafe_unretained IBOutlet UIButton *shareBtn;
    
    __unsafe_unretained IBOutlet UIImageView *bg;
    
    NSMutableArray *colorBtns;
}

@property (assign) id<DigestManagementViewControllerDelegate>delegate;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *rootView;
@property (nonatomic, retain) BookDigest *model;

-(void)addViewAnimation;

-(void)UpdateTheRootViewPosition;

-(void)setStartRectAndEndRect:(NSMutableDictionary *)dic AndModel:(BookDigest *)bookDigest withEdige:(UIEdgeInsets)edgeInsets;


-(IBAction)deleteBtnAction:(id)sender;
-(IBAction)orangeBtnAction:(id)sender;
-(IBAction)blueBtnAction:(id)sender;
-(IBAction)yellowBtnAction:(id)sender;
-(IBAction)redBtnAction:(id)sender;


-(IBAction)addNoteBtnAction:(id)sender;
-(IBAction)copyBtnAction:(id)sender;
-(IBAction)shareBtnAction:(id)sender;






@end
