//
//  OWAnnotationTextView.h
//  KWFBooks
//
//  Created by gren light on 12-9-1.
//
//

#import <UIKit/UIKit.h>

@class OWCoreTextLayouter;

@interface OWAnnotationTextView : UIView
{
    NSArray *textLines;
}

-(float)drawText:(NSString *)text byLayouter:(OWCoreTextLayouter *)layouter;

@end
