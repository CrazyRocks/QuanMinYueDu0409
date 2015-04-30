//
//  OWKitGlogal.h
//  OWKit
//
//  Created by grenlight on 14/8/4.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#ifndef OWKit_OWKitGlobal_h
#define OWKit_OWKitGlobal_h


#define isiOS7 ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue]>=7)

#define isiOS8  ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue]>=8)

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define PLATFORM (isPad ? 3 : 2)

#define viewFrameOffsetY    (isiOS7 ? 0 : (-20))
//#define viewFrameOffsetY    0

#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define appWidth   [[UIScreen mainScreen] bounds].size.width
#define appHeight  ([[UIScreen mainScreen] bounds].size.height)

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#endif
