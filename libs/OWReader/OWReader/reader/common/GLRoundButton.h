//
//  GLRoundButton.h
//  LogicBook
//
//  Created by  on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GLRoundButtonDelegate;

@interface GLRoundButton : UIView{
    @private
    UILabel *titleLB;
    UIColor *normalColor;
    UIColor *touchedColor;
}
@property(nonatomic,assign)id<GLRoundButtonDelegate> delegate;

-(id)initWithFrame:(CGRect)frame title:(NSString*)title borderColor:(long)color radius:(float)radius;

-(void)setTitle:(NSString*)title borderColor:(long)color radius:(float)radius;
-(void)setImage:(NSString*)image borderColor:(long)color radius:(float)radius;
-(void)setNormalColor:(UIColor *)nc touchedColor:(UIColor *)tc;

- (void)normalState;
@end

@protocol GLRoundButtonDelegate <NSObject>

@optional
- (void)glRoundButtonTapped:(GLRoundButton *)sender;

@end
