//
//  NotesViewController.h
//  LYBookStore
//
//  Created by grenlight on 14/10/21.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

//#import "XibAdaptToScreenController.h"
#import "BookDigest.h"
#import "JRBookDigestManager.h"

#import <OWCoreText/JRDigestModel.h>
#import <OWCoreText/GLCTPageInfo.h>
#import "NotesLabel.h"


@protocol NotesViewControllerDelegate <NSObject>
//不包其他括方法
-(void)completeEditor:(NSString *)string withSharedString:(NSString *)shareString;
//包括其他书摘方法
-(void)completeEditor:(NSString *)string withSharedString:(NSString *)shareString withSames:(NSMutableArray *)array;

-(void)completeEditorIsModelType;


@end



@interface NotesViewController : UIViewController
{
    __unsafe_unretained IBOutlet NotesLabel *digestLab;
    __unsafe_unretained IBOutlet UIView *notsNavBar;
    __unsafe_unretained IBOutlet UIButton *backBtn;
    __unsafe_unretained IBOutlet UIButton *completeBtn;
    
    __unsafe_unretained IBOutlet UITextView *noteTextView;
    
    __weak IBOutlet NSLayoutConstraint      *bottomConstraint;
    
    NSMutableArray *sames;
    
    NSString *tmpSharedStr;
    NSRange tmpRange;
    GLCTPageInfo *tmpPageInfo;
    NSMutableArray *tmpNumbers;
    
    BOOL isMore;
    
    BOOL isEditor;
    
}


@property (nonatomic,retain) BookDigest *model;
@property (assign) id<NotesViewControllerDelegate>delegate;
@property (nonatomic, retain) NSDictionary *editorInfo;

- (void)updateStatusBarStyle;

-(IBAction)completeBtnAction:(id)sender;
-(IBAction)backBtnAction:(id)sender;

- (IBAction)hideKeyboard:(id)sender;

-(void)setSubViewContent:(NSString *)bookDigestString Range:(NSRange)range PageInfo:(GLCTPageInfo *)pageInfo Numbers:(NSMutableArray *)numbers isMore:(BOOL)more andBaseNoteString:(NSMutableString *)baseNote andSames:(NSMutableArray *)array;


-(void)setSubViewContentWithBookDigestModel:(BookDigest *)model;


@end
