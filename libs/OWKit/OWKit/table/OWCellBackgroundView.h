//
//  OWCellBackgroundView.h
//  KWFBooks
//
//  Created by gren light on 13-3-25.
//
//

#import <UIKit/UIKit.h>

typedef enum  {
    OWCellBackgroundViewPositionTop,
    OWCellBackgroundViewPositionMiddle,
    OWCellBackgroundViewPositionBottom,
    OWCellBackgroundViewPositionSingle
} OWCellBackgroundViewPosition;

@interface OWCellBackgroundView : UIView
{
}

@property(nonatomic, retain) NSString *borderColor;
@property (nonatomic, assign) float borderWidth;

@property (nonatomic, retain) NSString *splitColor;
@property (nonatomic, assign) float splitWidth;

@property(nonatomic, retain) NSString *fillColor;
@property(nonatomic) OWCellBackgroundViewPosition position;
@property (nonatomic, assign) float paddingLeft;
@property (nonatomic, assign) float cornerRadius;
@property (nonatomic, assign) float glowRadius;


//表格项的选择背景不需要绘制边框及glow
@property (nonatomic, assign) BOOL isSelectedBackgroundView;


@end
