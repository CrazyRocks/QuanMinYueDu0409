//
//  OWCoreTextLabel.h
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OWCoreTextLabel : UIView
{
    @private
    NSArray    *textLines;
}

@property(nonatomic, assign) NSInteger numberOfLines;

-(float)renderText:(NSAttributedString *)attriString;

- (void)renderByLineText:(NSArray *)lines;

@end
