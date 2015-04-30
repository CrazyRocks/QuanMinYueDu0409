//
//  OWLineBtn.h
//  OWCoreText
//
//  Created by grenlight on 14-10-8.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>

extern void CGPathPrint(CGPathRef path, FILE* file);


@interface OWLineBtn : UIView


-(CAShapeLayer*)layer;

-(id)initWithPoints:(NSArray*)points;


@end
