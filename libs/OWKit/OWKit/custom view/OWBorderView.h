//
//  OWBorderView.h
//  Xcode6AppTest
//
//  Created by grenlight on 14/6/26.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWControlCSS.h"

@interface OWBorderView : UIView
{
    @private
    OWControlCSS *css;
}
- (void)setStyle:(OWControlCSS *)cssStyle;

@end
