//
//  NotesViewController.m
//  LYBookStore
//
//  Created by grenlight on 14/10/21.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "NotesViewController.h"
#import "PageViewController.h"
//#import "IFlySpeechRecognizer.h"
#import "NetworkSynchronizationForBook.h"

@interface NotesViewController ()<UIGestureRecognizerDelegate>
{
    CGRect textFrame;
    
    UIGestureRecognizer *_recognizer;
    
//    IFlySpeechRecognizer *fly;
    
}
@end

@implementation NotesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, appWidth, appHeight);
    
    textFrame = noteTextView.frame;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(handleKeyboardDidShow:)
               name:UIKeyboardDidShowNotification
             object:nil];
    //注册通知，监听键盘消失事件
    [nc addObserver:self
           selector:@selector(handleKeyboardDidHidden)
               name:UIKeyboardDidHideNotification
             object:nil];
    
    [digestLab setTextColor:[OWColor colorWithHexString:@"#D4A979"]];
    [noteTextView setTextColor:[OWColor colorWithHexString:@"#D4A979"]];
    [noteTextView setFont:[UIFont systemFontOfSize:20]];
    
    notsNavBar.backgroundColor = [OWColor colorWithHexString:@"#161616"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [noteTextView becomeFirstResponder];

}

#pragma mark 键盘监听

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)handleKeyboardDidShow:(NSNotification*)paramNotification
{
    //获取键盘高度
    NSValue *keyboardRectAsObject=[[paramNotification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect;
    [keyboardRectAsObject getValue:&keyboardRect];
    
    [UIView animateWithDuration:0.2 animations:^{
        bottomConstraint.constant = CGRectGetHeight(keyboardRect) +2;
        [self.view layoutIfNeeded];
    }];
}

- (void)handleKeyboardDidHidden
{
    bottomConstraint.constant = 20;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)updateStatusBarStyle
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark 按钮点击事件
- (void)hideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

//完成编辑
-(IBAction)completeBtnAction:(id)sender
{
    if (noteTextView.text == nil || [noteTextView.text isEqualToString:@""]) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您尚未添加注释，注释内容不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        
        [alert show];
        
        return;
    }
        
    if (isEditor) {
        [self isEditorIsYes];
    }else{
        [self isEditorIsNO];
    }    
}

-(void)isEditorIsNO
{
    if (!isMore) {
        
        if ([self.delegate respondsToSelector:@selector(completeEditor:withSharedString:)])
        {
            [self.delegate completeEditor:noteTextView.text withSharedString:digestLab.text];
        }
        
    }else{
        
        if ([self.delegate respondsToSelector:@selector(completeEditor:withSharedString:withSames:)]) {
            
            [self.delegate completeEditor:noteTextView.text withSharedString:digestLab.text withSames:sames];
        }
        
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollYes" object:nil];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
    }];
}

-(void)isEditorIsYes
{
    self.model.digestNote = noteTextView.text;
    
    [[NetworkSynchronizationForBook manager] saveBookDigestToSever:self.model];
    
    [[JRBookDigestManager sharedInstance] updateData:self.model];
    
    if ([self.delegate respondsToSelector:@selector(completeEditorIsModelType)]) {
        [self.delegate completeEditorIsModelType];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollYes" object:nil];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
    }];
}

//取消编辑
-(IBAction)backBtnAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollYes" object:nil];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }];
}

#pragma mark 配置初始化属性
-(void)setSubViewContent:(NSString *)bookDigestString Range:(NSRange)range PageInfo:(GLCTPageInfo *)pageInfo Numbers:(NSMutableArray *)numbers isMore:(BOOL)more andBaseNoteString:(NSMutableString *)baseNote andSames:(NSMutableArray *)array

{
    if (more) {
        isMore = more;
        
        tmpSharedStr = bookDigestString;
        tmpRange = range;
        tmpPageInfo = pageInfo;
        tmpNumbers = numbers;
        sames = array;
        
        digestLab.text = bookDigestString;
        noteTextView.text = baseNote;
    }
    else{
        //设置选择文段
        digestLab.text = bookDigestString;
    }
}


#pragma mark 传入model模型的方法
-(void)setSubViewContentWithBookDigestModel:(BookDigest *)model
{
    if (model) {
        self.model = model;
        digestLab.text = model.summary;
        isEditor = YES;
        
        if (model.digestNote != nil && ![model.digestNote isEqualToString:@""]) {
            noteTextView.text = model.digestNote;
        }
        [noteTextView becomeFirstResponder];
    }
}


- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIDeviceOrientationPortrait;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}





@end
