//
//  GLAsyncMessageController.m
//  LogicBook
//
//  Created by iMac001 on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GLAsyncMessageController.h"

@interface GLAsyncMessageController ()
{
    //是否已经在显示列表，没在则添加到显示列表
    bool isShow;
    CGPoint homeCenter;
    CGPoint schoolCenter;
}
@end

@implementation GLAsyncMessageController
static GLAsyncMessageController *instance;

- (id)init
{
    self = [super initWithNibName:@"GLAsyncMessageController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        CGRect mainFrame = [UIScreen mainScreen].bounds;
        CGRect msgFrame = self.view.frame;
        msgFrame.origin.y = CGRectGetHeight(mainFrame) -msgFrame.size.height;
        [self.view setFrame:msgFrame];
        schoolCenter = homeCenter = self.view.center;
        homeCenter.y += self.view.frame.size.height;
        isShow = NO;   
        [self.view setCenter:homeCenter];
    }
    return self;
}

+(GLAsyncMessageController *)sharedInstance
{
    @synchronized(self){
        if(instance==nil){
            instance = [[GLAsyncMessageController alloc]init];
        }
        return instance; 
    }
    
}

-(void)animatingOut
{
    isShow = NO;

    [UIView animateWithDuration:0.2 delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
        [self.view setCenter:homeCenter]; 
        
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

-(void)showMessage:(NSString *)msg autoClose:(BOOL)autoClose
{
    messageLB.text = msg;

    if(!isShow){
        [[[UIApplication sharedApplication]windows][0] addSubview:self.view];
        [UIView animateWithDuration:0.2 animations:^{
            [self.view setCenter:schoolCenter]; 
        } completion:^(BOOL finished) {
            if(autoClose)
                [self performSelector:@selector(animatingOut) withObject:nil afterDelay:3];
 
        }];
        isShow = YES;
    }
    else {
        [self performSelector:@selector(animatingOut) withObject:nil afterDelay:3];

    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
