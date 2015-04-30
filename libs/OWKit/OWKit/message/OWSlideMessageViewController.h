//
//  GLAsyncMessageController.h
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWMsgBasicController.h"


@interface OWSlideMessageViewController : OWMsgBasicController
{
    CGPoint homeCenter, schoolCenter;
}
+ (OWSlideMessageViewController *)sharedInstance;

@end
