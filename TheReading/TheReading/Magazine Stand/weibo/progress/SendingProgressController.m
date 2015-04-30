//
//  SendingProgressController.m
//  KWFBooks
//
//  Created by 龙源 on 13-6-9.
//
//

#import "SendingProgressController.h"
#import <OWKit/OWKit.h>

@interface SendingProgressController ()
{
    CGRect  firstFrame, lastFrame;
}
@end

@implementation SendingProgressController

@synthesize sended;

- (id)init
{
    self = [super initWithNibName:@"SendingProgressController" bundle:nil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sendingFault)
                                                     name:@"COMMENT_SENDING_FAULT" object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    thumbView.image = [OWImage imageWithNoneDeformable:[OWImage imageWithName:@"progress_thumb"]
                                            edgeInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    lastFrame = thumbView.frame;
    firstFrame = lastFrame;
    firstFrame.size.width = 117 - 20;
    
    [thumbView setFrame:CGRectMake(CGRectGetMinX(lastFrame), CGRectGetMinY(lastFrame), 20, CGRectGetHeight(lastFrame))];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)progressing
{
    [UIView animateWithDuration:1.2 animations:^{
        [thumbView setFrame:firstFrame];
    }];
}

- (void)completed
{
    [UIView animateWithDuration:0.25 animations:^{
        [thumbView setFrame:lastFrame];
    } completion:^(BOOL finished) {
        [titleLB setText:@"发送成功"];
    }];
}

- (void)sendingFault
{
    [titleLB setText:@"发送失败"];
 
}



@end
