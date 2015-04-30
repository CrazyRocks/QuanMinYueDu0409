//
//  Shadow.h
//  QuartzTest
//
//  Created by iMac001 on 11-11-3.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
    glSHADOWDIRECTION_RIGHT,
    glSHADOWDIRECTION_LEFT,
    glSHADOWDIRECTION_ALL
}ShadowDirection;
@interface Shadow : UIView{
    @private
    float blurDistance;
    ShadowDirection shadowDirection;
}
-(id)initWithFrame:(CGRect)frame blur:(CGFloat)blur shadowDirection:(ShadowDirection)direction;
@end
