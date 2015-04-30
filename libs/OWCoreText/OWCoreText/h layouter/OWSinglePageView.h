
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.

#import <CoreText/CoreText.h>
#import "OWCoreTextLayouter.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OWCoreTextLayoutLine.h"
#import "OWCoreTextLayoutFrame.h"


#import "IQIrregularView.h"
#import "OWChooseMask.h"
#import "RunObject.h"

#import "JRDigestModel.h"

//视频
#import "ALMoviePlayerController.h"
#import "WordRectView.h"

#import "VideoBtn.h"


#import "BookPin.h"

@class OWSinglePageView;
@class OWCoreTextLayoutFrame;
@class OWTextAttachment;
@class GLCTPageInfo;


@protocol OWSinglePageViewDelegate <NSObject>

@optional
- (void)pageContentLoadComplete:(GLCTPageInfo *)info;
//是全屏内容（图片，...）,可能需要隐藏页码
- (void)isFullScreenContent;

//存储文摘
-(NSMutableArray *)saveBookDigest:(NSString *)digestString withRange:(NSRange)range withPageInfo:(GLCTPageInfo *)info AndNumberArray:(NSMutableArray *)numbersArray;

//调用批注编辑界面
-(void)callNoteEditCtrlWithStr:(NSString *)digestString withRange:(NSRange)range withPageInfo:(GLCTPageInfo *)info AndNumberArray:(NSMutableArray *)numbersArray;

-(void)btnActionIntoVideo:(VideoBtn *)btn;


-(void)addAideoToPlay:(VideoBtn *)btn;
//分享
- (void)shareSelectedText:(NSString *)str;
//搜索
- (void)searchSelectedText:(NSString *)str;

@end



@interface OWSinglePageView : UIView <MaskDelegate,ALMoviePlayerControllerDelegate,VideoBtnDelegate>
{
	OWCoreTextLayoutFrame *_layoutFrame;
    
    CGPoint starPoint;
    CGPoint endPoint;
    
    //选择后的字符串对象
    NSString *shareStr;
    
    //所有字符的Rect集合
    NSMutableArray *allRunRect;
    
    //选择文字的起始节点
    NSInteger star;
    NSInteger end;
    
    NSMutableArray *needDraws;
    
    
    NSMutableArray *noteBtns;
    
    
    NSMutableArray *digestNoteBtns;
    
    
    NSMutableArray *videos;
    NSMutableArray *audios;
}

@property BOOL isNeedDrawAnimation;




@property (nonatomic, retain) WordRectView *rectView;

@property (nonatomic, retain) NSMutableArray *digestArray;





@property (nonatomic, retain) BookPin *starSlider;

@property (nonatomic, retain) BookPin *endSlider;






@property (nonatomic, retain) OWChooseMask *mask;

@property (nonatomic, retain) IQIrregularView *chooseLayer;

@property (assign) id<OWSinglePageViewDelegate> delegate;
@property (nonatomic, assign) 	UIEdgeInsets edgeInsets;

- (id)initWithFrame:(CGRect)frame layouter:(OWCoreTextLayouter *)layouter;

- (void)resetLayouter:(OWCoreTextLayouter *)layouter;

- (void)drawPage:(NSInteger)pageNum;

- (void)drawAnnotation;

//画线
- (void)drawLineFrame;

-(void)drawNoteLineWithStartPoint:(CGPoint)startP EndPoint:(CGPoint)endP isShowMask:(BOOL)isShowMask;

-(void)clearChooseLine;//清除选择

-(void)clearDigestArray:(NSMutableArray *)array;

//显示菜单
-(void)showMenu;

//搜索文字是否填有下划线
-(RunObject *)findPointIsInDigestRect:(CGPoint)point;

-(NSMutableDictionary *)findTouchPointRunObjc:(JRDigestModel *)model;

-(void)drawVideoPlayer;

-(void)stopBtnAnimation;

@end



