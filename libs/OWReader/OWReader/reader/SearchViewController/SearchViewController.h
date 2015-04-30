//
//  SearchViewController.h
//  LYBookStore
//
//  Created by grenlight on 14/10/30.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OWKit/OWShimmeringView.h>
#import "LYBookRenderManager.h"
#import "SearchHeader.h"
#import "JRReaderNotificationName.h"

@interface SearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIGestureRecognizerDelegate>
{
    
    __unsafe_unretained IBOutlet UIView *bar;
    __unsafe_unretained IBOutlet UIView *mask;
    __unsafe_unretained IBOutlet UITableView *searchTableView;
    
    __unsafe_unretained IBOutlet UIButton *canelBtn;
    
    NSMutableArray *searchs;
    
    __unsafe_unretained IBOutlet UITextField *searchTextField;
    
    OWShimmeringView *shimmer;
    
    SearchHeader *hearder;
    
}

@property (nonatomic, retain) UIGestureRecognizer *recognizer;

-(IBAction)canel:(id)sender;

-(IBAction)editorCancel:(UITapGestureRecognizer *)tap;

-(void)showKeyBorad;

@end
