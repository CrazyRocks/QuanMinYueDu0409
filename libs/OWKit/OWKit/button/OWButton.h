//
//  GLButton.h
//  KWFBooks
//
//  Created by gren light on 13-2-23.
//
//

#import <UIKit/UIKit.h>

@class OWControlCSS;
@interface OWButton : UIButton
{
    OWControlCSS     *css;
    BOOL            needFill;

}

- (void)setTitle:(NSString *)title style:(OWControlCSS *)cssStyle;

- (void)setTitle:(NSString *)title;

@end
