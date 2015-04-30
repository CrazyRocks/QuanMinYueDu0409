//
//  OWAnnotationButton.h
//  OWCoreText
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.


#import <UIKit/UIKit.h>

@class OWCoreTextLayouter;

@interface OWAnnotationButton : UIView <UIGestureRecognizerDelegate>
{
    @private
    NSString *content;
    UITapGestureRecognizer  *tapGesture;
}
@property (nonatomic, weak) OWCoreTextLayouter  *layouter;

-(id)initWithFrame:(CGRect)frame content:(NSString *)cnt;

- (id)initWithFrame:(CGRect)frame withDigestNoteContent:(NSString *)cnt;

@end
