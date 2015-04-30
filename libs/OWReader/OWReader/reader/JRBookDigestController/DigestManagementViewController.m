//
//  DigestManagementViewController.m
//  LYBookStore
//
//  Created by grenlight on 14/10/21.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "DigestManagementViewController.h"
#import <OWCoreText/RunObject.h>
#import "JRBookDigestManager.h"
#import "MyBooksManager.h"

#define COR 0
#define BTNTAG 80000

#define ORG @"#eb6b00"
#define BLU @"#257fd2"
#define YEL @"#73b708"
#define RED @"#9540d1"


#define OTHERBORDER_COLOR @"#c1c1c1"

#define OTHERBTNCOR 3

//#import "Bookmark+BookDigest.h"
#import "NetworkSynchronizationForBook.h"

@interface DigestManagementViewController ()

@end

@implementation DigestManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.frame = CGRectMake(0, 0, appWidth, appHeight);
    
    colorBtns = [[NSMutableArray alloc]init];
    
    [colorBtns addObject:orangeBtn];
    [colorBtns addObject:blueBtn];
    [colorBtns addObject:yellowBtn];
    [colorBtns addObject:redBtn];
    
    _rootView.layer.cornerRadius = 10;
//    _rootView.layer.shadowColor = [OWColor colorWithHexString:@"#262626"].CGColor;
    _rootView.layer.shadowOffset = CGSizeMake(1, 1);
    _rootView.layer.shadowOpacity = 3;
    _rootView.alpha = 0.0f;
    
    bg.backgroundColor = [OWColor colorWithHexString:@"#262626"];
    bg.alpha = 0.9;
    
    
    
//    //删除按钮样式
//    deleteBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    deleteBtn.layer.borderWidth = 1;
//    deleteBtn.backgroundColor = [UIColor clearColor];
//    deleteBtn.layer.cornerRadius = COR;
//    [deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    
//    //橘黄色按钮
//    orangeBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    orangeBtn.layer.borderWidth = 1;
//    orangeBtn.backgroundColor = [OWColor colorWithHexString:ORG];
//    orangeBtn.layer.cornerRadius = COR;
//    [orangeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    
//    //蓝色色按钮
//    blueBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    blueBtn.layer.borderWidth = 1;
//    blueBtn.backgroundColor = [OWColor colorWithHexString:BLU];
//    blueBtn.layer.cornerRadius = COR;
//    [blueBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    
//    //黄色按钮
//    yellowBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    yellowBtn.layer.borderWidth = 1;
//    yellowBtn.backgroundColor = [OWColor colorWithHexString:YEL];
//    yellowBtn.layer.cornerRadius = COR;
//    [yellowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    
//    //红按钮
//    redBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    redBtn.layer.borderWidth = 1;
//    redBtn.backgroundColor = [OWColor colorWithHexString:RED];
//    redBtn.layer.cornerRadius = COR;
//    [redBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    
    //复制按钮
    [copyBtn setTitleColor:[OWColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    copyBtn.layer.borderWidth = 0.5f;
    copyBtn.layer.borderColor = [OWColor colorWithHexString:OTHERBORDER_COLOR].CGColor;
    copyBtn.layer.cornerRadius = OTHERBTNCOR;
    
    //批注按钮
    [addNoteBtn setTitleColor:[OWColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    addNoteBtn.layer.borderColor = [OWColor colorWithHexString:OTHERBORDER_COLOR].CGColor;
    addNoteBtn.layer.borderWidth = 0.5f;
    addNoteBtn.layer.cornerRadius = OTHERBTNCOR;
    
    //分享按钮
    [shareBtn setTitleColor:[OWColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
    shareBtn.layer.borderColor = [OWColor colorWithHexString:OTHERBORDER_COLOR].CGColor;
    shareBtn.layer.borderWidth = 0.5;
    shareBtn.layer.cornerRadius = OTHERBTNCOR;
    
    
}

-(void)setStartRectAndEndRect:(NSMutableDictionary *)dic AndModel:(BookDigest *)bookDigest withEdige:(UIEdgeInsets)edgeInsets
{
    self.model = bookDigest;
}

#pragma mark 颜色按钮
-(IBAction)deleteBtnAction:(id)sender
{
    
    [[NetworkSynchronizationForBook manager] deleteBookDigestToSever:self.model];
    
    BOOL isDelete = [[JRBookDigestManager sharedInstance] delegateThisBookDigestAndNotes:self.model];
    
    if (isDelete)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:LYBOOK_BOOKMARK_CHANGED object:nil];
    }
    
    NSLog(@"isDelete ===  %d",isDelete);
    
    if ([self.delegate respondsToSelector:@selector(changeColorComplete)])
    {
        [self.delegate changeColorComplete];
    }
    
    [self removeView];
}
-(IBAction)orangeBtnAction:(id)sender
{
//    UIColor *color = [UIColor orangeColor];
    
    [self changeLineColor:ORG];
}
-(IBAction)blueBtnAction:(id)sender
{
//    UIColor *color = [UIColor blueColor];
    
    [self changeLineColor:BLU];
}
-(IBAction)yellowBtnAction:(id)sender
{
//    UIColor *color = [UIColor yellowColor];
    
    [self changeLineColor:YEL];
}
-(IBAction)redBtnAction:(id)sender
{
//    UIColor *color = [UIColor redColor];
    
    [self changeLineColor:RED];
}

-(void)changeLineColor:(NSString *)color
{
    self.model.lineColor = color;
    
//    NSLog(@"%@",self.model.lineColor);
    
    [[JRBookDigestManager sharedInstance] updateData:self.model];
    
    if([self.delegate respondsToSelector:@selector(changeColorComplete)])
    {
        [self.delegate changeColorComplete];
    }
    
    [self removeView];
    
}


#pragma mark 功能按钮
-(IBAction)addNoteBtnAction:(id)sender
{
    
    if ([self.delegate respondsToSelector:@selector(addNoteToBookDigest:)]) {
        [self.delegate addNoteToBookDigest:self.model];
    }
    
    [self removeView];
    
}

-(IBAction)copyBtnAction:(id)sender
{
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if (self.model) {
        [pasteboard setString:self.model.summary]; //将文字复制进粘帖版
        
        [[OWMessageView sharedInstance] showMessage:@"已保存至剪切板" autoClose:YES];
    }
    
    [self removeView];
}
-(IBAction)shareBtnAction:(id)sender
{
//    if ([self.delegate respondsToSelector:@selector(addNoteToBookDigest:)]) {
//        [self.delegate addNoteToBookDigest:self.model];
//    }
    [[OWMessageView sharedInstance] showMessage:@"还没有这个功能" autoClose:YES];
    
    [self removeView];
}

-(void)addViewAnimation
{
    
    [OWAnimator basicAnimate:_rootView toScale:CGPointZero duration:0.f delay:0 completion:^{
        
        [OWAnimator spring:_rootView toScale:CGPointMake(1, 1) delay:0.4f];
        
    }];
    
    [UIView animateWithDuration:0.4 animations:^{
        _rootView.alpha = 1.0f;
    }];
    
    _rootView.alpha = 1.0f;
    
//    self.view.backgroundColor = [UIColor blackColor];
}

-(void)removeView
{
    _rootView.alpha = 0.0f;
    [self.view removeFromSuperview];
}

#pragma mark 手势
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self.view removeFromSuperview];
    [self removeView];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self.view removeFromSuperview];
     [self removeView];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self.view removeFromSuperview];
     [self removeView];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self.view removeFromSuperview];
     [self removeView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
