//
//  PageImage.h
//  DragonSourceEPUB
//
//  Created by iMac001 on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYPageImage : UIImageView{
  @private
    UITapGestureRecognizer *singleTap;
}

-(void)addTapGesture;
-(void)releaseSource;

@end
