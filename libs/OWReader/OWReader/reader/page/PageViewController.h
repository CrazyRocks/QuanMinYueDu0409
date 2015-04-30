//
//  CoreTextPageViewController.h
//  DragonSourceEPUB
//
//  Created by iMac001 on 12-1-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OWCoreText/OWCoreText.h>
#import "TouchReader.h"
#import <OWCoreText/GLCTPageInfo.h>
#import "DigestManagementViewController.h"
#import "NotesViewController.h"


@protocol PageViewDelegate;



@interface PageViewController : OWViewController<OWSinglePageViewDelegate,NotesViewControllerDelegate,DigestManagementViewControllerDelegate>
{
    float touchLocationX;
    float touchLocationY;
    BOOL canDropDown;//能否下拉
    BOOL isDropDown;//是下拉
    BOOL canDropUp;//能否上提
    BOOL isDropUp;//是上提
    CGPoint home;
    
    CGPoint startPoint;
    
    __unsafe_unretained IBOutlet TouchReader *loop;
    
    __weak IBOutlet UIView           *pageView;
    __weak IBOutlet UIView           *footerView;
    __weak IBOutlet UILabel          *catelogueLB;
    __weak IBOutlet UILabel          *pageNumberLB;
    
    __weak IBOutlet OWSplitLineView  *splitLine;

    OWSinglePageView          *pageContentView;
    
    bool pageFooterIsShow;
    
    NSMutableArray *screeningArray;
    
    GLCTPageInfo *baseInfo;
    
    NSMutableArray *notsArray;
    
    UIPanGestureRecognizer *twoPan;
    
    __unsafe_unretained IBOutlet UIImageView *mask;
}
@property (nonatomic, retain) DigestManagementViewController *digestManagementCtrl;

@property(nonatomic,assign)id<PageViewDelegate> delegate;

@property(nonatomic,assign)bool isCurrentPage;

-(void)setPageInfo:(OWCoreTextLayouter *)layouter :(NSInteger)pageNum;
-(void)setPagePosition:(CGRect )rect;
-(void)setUnPagePosition:(CGRect)rect;


-(void)clearPageChooseLines;

-(void)commpleteBookNoteEditor:(NSString *)string;

-(void)setVideoPlayerShow;

-(void)noSetPageInfo:(OWCoreTextLayouter *)layouter updateNumber:(NSInteger)pageNum;


-(GLCTPageInfo *)getGLCTPageInfo;

-(void)updatePageNumber:(NSString *)info;

-(NSString *)getPageNumber;

-(void)getsTheCurrentView;



@end


@protocol PageViewDelegate <NSObject>

@required
-(void)pageView_ScrollEnable:(BOOL)bl;
//正在滚动，
- (void)pageView_Scrolling;


-(void)showCatalogesView:(UIPanGestureRecognizer *)pan;


@end
