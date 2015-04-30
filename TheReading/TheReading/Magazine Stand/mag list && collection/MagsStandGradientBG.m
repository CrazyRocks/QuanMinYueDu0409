//
//  BookshelfGradientBG.m
//  KWFBooks
//
//  Created by 龙源 on 13-10-10.
//
//

#import "MagsStandGradientBG.h"

@implementation MagsStandGradientBG

static float gradientHeight = 120.0f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = [UIImage imageNamed:@"magazinesStand_bg"];
        frontImageView = [[UIImageView alloc] initWithImage:image];
        backImageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:frontImageView];
        frontCenter = frontImageView.center;
        backCenter = frontCenter;
        frontCenter.y -= gradientHeight;
        
        [frontImageView setCenter:frontCenter];
        [backImageView setCenter:backCenter];
        [self insertSubview:backImageView belowSubview:frontImageView];
        
        offsetCount = 0;
        currentOffsetY = 0;
        
        originalCenter = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
//        __unsafe_unretained MagsStandGradientBG *weakSelf = self;
//        [[NSNotificationCenter defaultCenter]
//         addObserverForName:OWNER_CONTENTOFFSET_CHANGED
//         object:nil
//         queue:[NSOperationQueue mainQueue]
//         usingBlock:^(NSNotification *note) {
//             [weakSelf setCenter:
//              CGPointMake(originalCenter.x, originalCenter.y + [note.userInfo[@"offsetY"] floatValue])];
//         }];
    }
    return self;
}

- (void)setContentOffsetY:(float)offsetY
{
    int gradientCount = floorf(offsetY/gradientHeight);
    float newOffsetY = offsetY - gradientCount*gradientHeight;
    
    [frontImageView setCenter:CGPointMake(frontCenter.x, frontCenter.y - newOffsetY)];
    [backImageView setCenter:CGPointMake(backCenter.x, backCenter.y - newOffsetY)];

    float alpha = 1 - newOffsetY/gradientHeight;
    [frontImageView setAlpha:alpha];
    currentOffsetY = offsetY;
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
