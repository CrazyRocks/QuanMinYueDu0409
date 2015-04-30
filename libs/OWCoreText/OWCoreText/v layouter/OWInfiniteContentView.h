//
//  OWContentView.h
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWInfiniteContentLayoutFrame.h"

@class OWCoreTextLayouter, OWMagnifierView;

@interface OWInfiniteContentView : UIView
{
    NSAttributedString      *_attributedString;
   __unsafe_unretained OWCoreTextLayouter      *_layouter;
	OWInfiniteContentLayoutFrame   *_layoutFrame;
	
	NSMutableDictionary            *customViewsForAttachmentsIndex;
    
    NSArray                        *visibleLines;
    
    NSMutableArray                 *annotations;
    
    //放大镜
    OWMagnifierView                *magnifierView;
}
@property(assign)BOOL autoLayoutCustomSubviews;
@property(assign)OWCoreTextLayouter *layouter;

-(void)layoutSubviewsInRect:(CGRect)rect;

@end

