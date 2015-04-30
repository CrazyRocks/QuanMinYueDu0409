//
//  OWMessageController.m
//  OWUIKit
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.
//

#import "OWMsgBasicController.h"
#import "OWColor.h"

@interface OWMsgBasicController()
{
   
}
@end

@implementation OWMsgBasicController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect mainFrame = [UIScreen mainScreen].bounds;
    [self.view setFrame:mainFrame];
    self.view.backgroundColor = [OWColor colorWithHexString:@"#02000000"];

    CGPoint homeCenter = CGPointMake(CGRectGetMidX(mainFrame), CGRectGetMidY(mainFrame));
    isShow = NO;
    [messagePanel setCenter:homeCenter];
}

-(void)showMessage:(NSString *)msg autoClose:(BOOL)autoClose
{
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    [messageLB setText: msg];
    if (!isShow) {
        [self animatingIn:autoClose];
        isShow = YES;
    }
    else {
        [self performSelector:@selector(animatingOut) withObject:nil afterDelay:1];
    }
}

- (void)animatingIn:(BOOL)autoClose
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.view setAlpha:1];
    } completion:^(BOOL finished) {
        if(autoClose)
            [self performSelector:@selector(animatingOut) withObject:nil afterDelay:1];
        
    }];
}

-(void)animatingOut
{
    isShow = NO;
    [UIView animateWithDuration:0.25 delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        [self.view setAlpha:0];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];

    }];
}

-(void)closeMessage
{
    isShow = NO;
    [self.view removeFromSuperview];
}

@end
