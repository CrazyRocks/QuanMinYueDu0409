//
//  catalogeViewBtn.m
//  JRReader
//
//  Created by grenlight on 14/11/17.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "catalogeViewBtn.h"
#import "LYBookSceneManager.h"
#import <OWKit/OWKit.h> 
#import "JRReaderNotificationName.h"

@implementation catalogeViewBtn

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)awakeFromNib
{
        [self setup];
}

-(void)setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sceneChanged) name:BOOK_SCENE_CHANGED object:nil];
    
//    self.backgroundColor = [UIColor greenColor];
    
    _icon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
    _icon.center = CGPointMake(_icon.center.x, self.frame.size.height/2);
    [self addSubview:_icon];
    
    _lab = [[UILabel alloc]initWithFrame:CGRectMake(22, 0, 40, 22)];
    _lab.center = CGPointMake(_lab.center.x, self.frame.size.height/2);
    _lab.textAlignment = 0;
    _lab.font = [UIFont systemFontOfSize:14];
    [self addSubview:_lab];
}

-(void)setStyleObj:(UIStyleObject *)styleObj
{
    
    textColor = styleObj.fontColor;
    selectColor = styleObj.fontColor_selected;
    
    [_lab setFont:[UIFont systemFontOfSize:styleObj.fontSize]];
    [self setNeedsDisplay];
}

-(void)setIconImageView:(NSString *)name SelectName:(NSString *)selName andTitle:(NSString *)title;
{
    imageName = [NSString stringWithFormat:@"%@",name];
    selectName = [NSString stringWithFormat:@"%@",selName];
    _lab.text = [NSString stringWithFormat:@"%@",title];
}

-(void)setNomlIcon
{
    currentName = imageName;
    _lab.textColor = textColor;
    [self updateIconImageWithName:imageName];
}

-(void)setSelectIcon
{
    currentName = selectName;
    _lab.textColor = selectColor;
    [self updateIconImageWithName:selectName];
}

-(void)updateIconImageWithName:(NSString *)name
{
    
//    NSLog(@"name ==============%@",name);
    
    NSString *sceneMode = [[LYBookSceneManager manager] sceneMode];
    NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle",sceneMode]];
    
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSInteger scale = [UIScreen mainScreen].scale;
    
    NSString *sourceName = name;
    if (scale > 1) {
        sourceName = [NSString stringWithFormat:@"%@@%zdx",name, scale] ;
    }
    
    NSString *normal = [bundle pathForResource:sourceName ofType:@"png"];
    
    if (normal) {
//        [self setImage:[UIImage imageWithContentsOfFile:normal] forState:UIControlStateNormal];
        _icon.image = [UIImage imageWithContentsOfFile:normal];
    }
    
//    NSString *selected = [bundle pathForResource:[NSString stringWithFormat:@"%@",name] ofType:@"png"];
//    if (selected) {
//        [self setImage:[UIImage imageWithContentsOfFile:selected] forState:UIControlStateHighlighted];
//        [self setImage:[UIImage imageWithContentsOfFile:selected] forState:UIControlStateSelected];
//    }
}




-(void)sceneChanged
{
    [self updateIconImageWithName:currentName];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
