//
//  OWActivityIndicatorView.h
//  ActivityIndicatorDemo
//
//  Created by grenlight on 13-12-9.
//
//

#import <UIKit/UIKit.h>

@interface OWActivityIndicatorView : UIView
{
    id          displayLink;
    
    int32_t     currStep;
    float       anglePerStep;
    
    CGRect      finRect;

}

@property (nonatomic) NSUInteger                    steps;
@property (nonatomic) NSUInteger                    frameInterval;
@property (nonatomic) CGSize                        finSize;
@property (nonatomic, strong) UIColor               *color;

@property (nonatomic, assign) BOOL        isAnimating;

-(void)startAnimating;
-(void)stopAnimating;

@end
