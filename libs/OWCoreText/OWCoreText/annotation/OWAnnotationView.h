//
//  OWAnnotationView.h
//  GLViewTest
//
//  Created by iMac001 on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OWCoreTextLayouter;

@interface OWAnnotationView : UIView{
    UIFont *font;
    UIScrollView *scrollView;
}
@property (nonatomic, weak) OWCoreTextLayouter  *layouter;

//设置汽泡的位置
-(void)setContent:(NSString *)cnt  andAnglePoint:(CGPoint)point;

@end
