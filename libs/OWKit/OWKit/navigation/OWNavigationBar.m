//
//  KWFNavigationBar.m
//  KWFBooks
//
//  Created by  iMac001 on 12-11-16.
//
//

#import "OWNavigationBar.h"
#import <QuartzCore/QuartzCore.h>
#import "UIStyleManager.h"
#import "OWGradientBackgroundView.h"
#import "OWColor.h"

@implementation OWNavigationBar

@synthesize titleLB;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self setup];
}

- (UIStyleObject *)getStyle
{
    return [[UIStyleManager sharedInstance]
            getStyle:@"顶部导航栏"];
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];

    bg = [[OWGradientBackgroundView alloc] initWithFrame:self.bounds];
    bg.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [self insertSubview:bg atIndex:0];
   
    titleLB = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, CGRectGetWidth(self.bounds)-80, 44)];
    titleLB.backgroundColor = [UIColor clearColor];
    titleLB.textAlignment = NSTextAlignmentCenter;
    titleLB.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleWidth;
    [self insertSubview:titleLB atIndex:1];
    
    [self updateStyle];
}

- (void)updateStyle
{
    UIStyleObject *style = [self getStyle];
    if (!style) {
        return;
    }

    [bg drawByStyle:style];

    [titleLB setFont:[UIFont systemFontOfSize:style.fontSize]];
    [titleLB setTextColor:style.fontColor];
}

-(void)setTitle:(NSString *)title
{
    [titleLB setText:title];
}

@end
