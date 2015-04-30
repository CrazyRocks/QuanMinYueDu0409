//
//  SendingMessageController.m
//  GLWeiBo
//
//  Created by  iMac001 on 12-11-28.
//  Copyright (c) 2012年  iMac001. All rights reserved.
//

#import "SendingMessageController.h"

@interface SendingMessageController ()
{

}
@end

@implementation SendingMessageController

static SendingMessageController *instance;


+(SendingMessageController *)sharedInstance
{
    @synchronized(self){
        if(instance==nil){
            instance = [[SendingMessageController alloc]init];
        }
        return instance;
    }
}

-(void) setup
{
    CGRect mainFrame = CGRectMake(0, 0, 320, 20);
    self.view.alpha = 0;
    [self.view setFrame:mainFrame];
    [[[UIApplication sharedApplication] windows][0] addSubview:self.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
	// Do any additional setup after loading the view.
}

-(void)showMessage:(NSString *)msg autoClose:(BOOL)autoClose{
    __unsafe_unretained SendingMessageController *weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        if(weakSelf.view) {
            [weakSelf.view setAlpha:1];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            weakSelf->messageLB.text = msg;
            if(autoClose)
                [weakSelf performSelector:@selector(animatingOut) withObject:nil afterDelay:3];
        }
    });
}

-(void)animatingOut
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.view removeFromSuperview];
    instance = nil;

}


@end
