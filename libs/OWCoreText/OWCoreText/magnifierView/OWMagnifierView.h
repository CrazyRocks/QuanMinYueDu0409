//
//  OWMagnifierView.h
//  KWFBooks
//
//  Created by gren light on 12-9-4.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface FastCATiledLayer : CATiledLayer
@end


@interface OWMagnifierView : UIView
{
    FastCATiledLayer             *contentLayer;
    UIImage                      *contentImage;
    CGPoint                       touchPoint;
    
    float                         diameter;
    float                         radius;

}
-(void)magnify:(CGPoint)point viewChanged:(BOOL)bl;
@end
