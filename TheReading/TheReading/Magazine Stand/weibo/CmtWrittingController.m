//
//  CmtWrittingController.m
//  LogicBook
//
//  Created by iMac001 on 12-3-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CmtWrittingController.h"
#import "GLCommentManager.h"
#import "LYSinaWeibo.h"
#import "SendingProgressController.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>

@interface CmtWrittingController (){
    
    //书写面板的正常坐标及动画预置坐标
    CGPoint               wpCenter, wpPreCenter;
    
    //输入字符数统计
    NSInteger                  myInputCount;
    
    LYSinaWeibo             *sinaEngine;
    
    UIView                *bg;
    
    SendingProgressController *progressController;
    
}

@end

@implementation CmtWrittingController


- (id)init
{
    self = [super initWithNibName:@"CmtWrittingController" bundle:Nil];
    if (self) {
        sinaEngine = [GLCommentManager sharedInstance].weiboEngine;
        [self initMask];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(0, 20, appWidth, appHeight)];
    
    bg = [[UIView alloc] initWithFrame:self.view.bounds];
    bg.backgroundColor = [UIColor blackColor];
    bg.alpha = 0;
    
    [self.view insertSubview:bg atIndex:0];
    //设置默认内容
    [textView setText:[GLCommentManager sharedInstance].defaultMessage];
    
    writtingPanel.layer.shadowColor = [UIColor blackColor].CGColor;
    writtingPanel.layer.shadowOpacity = 0.7;
    writtingPanel.layer.shadowOffset = CGSizeMake(0, 0);
    writtingPanel.layer.shadowRadius = 3;
  
    [[NSNotificationCenter defaultCenter]
     addObserverForName:UIKeyboardWillShowNotification
     object: nil
     queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *note) {
         CGRect mainFrame = [UIScreen mainScreen].bounds;
         mainFrame.size.height = appHeight;
         
         NSDictionary *userInfo = [note userInfo];
         NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
         CGRect keyboardRect = [aValue CGRectValue];
         //        keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
         if (writtingPanel) {
             CGRect wFrame = writtingPanel.frame;
             wFrame.size.height = appHeight - 44 - keyboardRect.size.height;
             [writtingPanel setFrame:wFrame];
             wpCenter = CGPointMake(mainFrame.size.width/2, 44+wFrame.size.height/2);
             wpPreCenter = wpCenter;
             wpPreCenter.y -= wFrame.size.height;
             UIBezierPath *path = [UIBezierPath bezierPathWithRect:writtingPanel.bounds];
             writtingPanel.layer.shadowPath = path.CGPath;
         }
     } ];
    
    [sendBT setEnabled:NO];
    
}

- (void)initMask
{
    UIView *windowView = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(appWidth, 44+20), YES, 2);
    [windowView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (!toolPanelMask) {
        toolPanelMask = [[UIImageView alloc]initWithFrame:CGRectMake(0, -20, appWidth, 64)];
    }
    toolPanelMask.image = img;
    
}

-(void)initMask:(UIView *)mask
{
    CGRect mainFrame = [UIScreen mainScreen].bounds;
    
    [self.view addSubview:toolPanelMask];
    
    toolPanel.backgroundColor = mask.backgroundColor;
    [toolPanel setAlpha:0];
    [self.view addSubview:toolPanel];
    
    wpCenter = CGPointMake(mainFrame.size.width/2, 44+writtingPanel.frame.size.height/2);
    wpPreCenter = wpCenter;
    wpPreCenter.y -= writtingPanel.frame.size.height;
    
    [writtingPanel setCenter:wpPreCenter];
    [self.view insertSubview:writtingPanel atIndex:1];

}

-(void)animateInWritingPanel
{
    [[UIApplication sharedApplication].windows[0] addSubview:self.view];
    
    textView.delegate = self;
    textView.editable = YES;
    [textView becomeFirstResponder];
    
    [UIView animateWithDuration:0.25 delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [toolPanel setAlpha:1];
                         [writtingPanel setCenter:wpCenter];
                         [bg setAlpha:0.7];
                     }
                     completion:^(BOOL finished) {
                         [toolPanelMask setHidden:YES];
                     }];

}

-(void)animageOut:(void (^)(void))bl
{
    [toolPanelMask setHidden:NO];
//    textView.editable = NO;
    
    [UIView animateWithDuration:0.25 delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [toolPanel setAlpha:0];
                         [writtingPanel setCenter:wpPreCenter];
                         [bg setAlpha:0];

                     }
                     completion:^(BOOL finished) {
                         if (bl) {
                             bl();
                         }
                         
                     }];
}

-(IBAction)close:(id)sender
{
    [[GLCommentManager sharedInstance] sendAndSync:nil];
}

-(IBAction)sendMessage:(id)sender
{
    if (textView.text == nil || [textView.text isEqualToString:@""]
        || [textView.text isEqualToString:@" "]
        || [textView.text isEqualToString:@" "]) {
        [[OWMessageView sharedInstance] showMessage:@"写点内容吧！" autoClose:YES];
    }
    else {
        [sendBT setEnabled:NO];      
        [self startSending];
        
        GLCommentManager *cmtManager = [GLCommentManager sharedInstance];
        [cmtManager sendAndSync:textView.text];
    }
}

-(void)reAnimateIn:(NSString *)txt
{
    textView.editable = true;
    [textView becomeFirstResponder];

    if (txt) {
        NSInteger textLength = textView.text.length + txt.length;
        if ( textLength<= 140) {
            textView.text = [NSString stringWithFormat:@"%@%@",textView.text,txt];
            inputCountLB.text = [NSString stringWithFormat:@"%li",(long)(140-textLength)];
        }
    }
}


-(void)dealloc
{
    sinaEngine = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    textView.delegate = nil;
//    NSLog(@"CmtWrittingController----------- dealloc");
}


#pragma progressing

- (void)startSending
{
    if (!progressController) {
        progressController = [[SendingProgressController alloc] init];
    }
    [progressController.view setAlpha:0];
    [toolPanel insertSubview:progressController.view atIndex:1];
    [progressController progressing];
    
    [titleLB setAlpha:0];

    [UIView animateWithDuration:0.3 animations:^{
        [progressController.view setAlpha:1];
    }];
}

- (void)sendingCompleted
{
    [progressController completed];
}

#pragma textView delegate

- (BOOL)textView:(UITextView *)tv shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSInteger temp = [textView.text length];
    temp -= range.length;
    
    if (text) {
        temp += text.length;
    }
    
    if (temp > 140) {
        return NO;
    }
    
    myInputCount = temp;
    inputCountLB.text = [NSString stringWithFormat:@"%li",(long)(140-myInputCount)];
    
    [placeholderLB setHidden:(myInputCount > 0)];
    [sendBT setEnabled:(myInputCount > 0)];
    
    return YES;
}

@end
