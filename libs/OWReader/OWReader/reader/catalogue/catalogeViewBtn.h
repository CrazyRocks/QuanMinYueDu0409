//
//  catalogeViewBtn.h
//  JRReader
//
//  Created by grenlight on 14/11/17.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIStyleObject.h"
@interface catalogeViewBtn : UIButton
{
    NSString *imageName;
    NSString *selectName;
    
    NSString *currentName;
    
    UIColor *textColor;
    UIColor *selectColor;
    
}
@property (nonatomic, retain) UIStyleObject *styleObj;
@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UILabel *lab;

-(void)setIconImageView:(NSString *)name SelectName:(NSString *)selName andTitle:(NSString *)title;

-(void)setNomlIcon;

-(void)setSelectIcon;

@end
