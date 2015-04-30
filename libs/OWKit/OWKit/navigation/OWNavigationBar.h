//
//  KWFNavigationBar.h
//  KWFBooks
//
//  Created by  iMac001 on 12-11-16.
//
//

#import <UIKit/UIKit.h>

@class UIStyleObject, OWGradientBackgroundView;

@interface OWNavigationBar : UIView
{
    @private
    OWGradientBackgroundView *bg;
}
@property (nonatomic, strong)UILabel   *titleLB;

- (void)setTitle:(NSString *)title;

- (UIStyleObject *)getStyle;
- (void)updateStyle;

@end
