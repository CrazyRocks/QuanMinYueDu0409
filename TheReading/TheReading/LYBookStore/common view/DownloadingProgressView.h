//
//  DownloadingProgressView.h
//  KWFBooks
//
//  Created by 龙源 on 13-10-12.
//
//

#import <UIKit/UIKit.h>

@class MyBook;

@interface DownloadingProgressView : UIProgressView
{
    MyBook *book;
}
- (void)setBookItem:(MyBook *)bookItem;

@end
