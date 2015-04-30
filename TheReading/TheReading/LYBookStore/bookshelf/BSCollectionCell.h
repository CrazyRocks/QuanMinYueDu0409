//
//  MyBookItemView.h
//  KWFStore
//
//  Created by  iMac001 on 12-9-11.
//  Copyright (c) 2012年 kiwifish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWShakeView.h"
#import <OWKit/OWBottomAlignImageView.h>

@class MyBook;
@class LYBookShelfController, DownloadingProgressView;

@interface BSCollectionCell : UICollectionViewCell<OWShakeViewDelegate>
{
    MyBook      *_myBook;
    
    DownloadingProgressView *progressView;
    UIView             *progressMaskView;
    
    BOOL        isEditMode;
        
    IBOutlet OWShakeView *shakeView;
    
    IBOutlet OWBottomAlignImageView *coverView;
    
    IBOutlet UILabel    *bookNameLB, *sourceLB;
    
    //未下载，最近阅读标签
    IBOutlet UIImageView    *labelImageView;
    
    __weak IBOutlet LYSplitLineView *splitLine;
}

@property (nonatomic, assign) CGRect titleHomeRect;
@property (nonatomic, assign) CGRect messageHomeRect;

@property (nonatomic, assign) MyBook     *myBook;
@property (nonatomic, weak) LYBookShelfController *master;
//是否已过期，需要借阅？
@property (nonatomic, assign) BOOL  needBorrow;


-(CGRect)getCoverFrame;
- (UIImage *)getCover;

- (void)render;

//显示为最近阅读
- (void)showRecentlyRead;
//取消显示最近阅读标识
- (void)cancleRecentlyRead;

- (void)startShake;
- (void)stopShake;

@end

