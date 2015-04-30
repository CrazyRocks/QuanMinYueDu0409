//
//  PageImage.h
//  DragonSourceEPUB
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.

#import <UIKit/UIKit.h>

@interface PageImage : UIImageView{
  @private
    UITapGestureRecognizer *singleTap;
}
-(void)addTapGesture;
-(void)releaseSource;
@end
