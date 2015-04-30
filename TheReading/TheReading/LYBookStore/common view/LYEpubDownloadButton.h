//
//  LYEpubDownloadButton.h
//  LYBookStore
//
//  Created by grenlight on 14-3-31.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    lyNormal,
    lyHighlighted,
    lyPrice,
    lyFree,
    lyContinueBorrow,//继借，不用重新下载
    lyCloud,
    lyPurchased,
    lyDownloaded,
    lyDownloading
}lYPurchaseStaus;

@class LYBookItemData, MyBook;
@interface LYEpubDownloadButton : UIView<UIAlertViewDelegate>
{    
    UILabel     *tileLable;
    
    lYPurchaseStaus currentStatus;
    
    LYBookItemData  *bookInfo;
    MyBook          *downloadingBook;
    
    NSInteger   downloadStatus;
}

- (void)setBookInfo:(LYBookItemData *)bookItem;

@end
