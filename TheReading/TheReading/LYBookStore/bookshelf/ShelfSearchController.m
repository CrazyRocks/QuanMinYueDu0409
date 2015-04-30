//
//  ShelfSearchController.m
//  LYBookStore
//
//  Created by grenlight on 14/8/25.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "ShelfSearchController.h"

@interface ShelfSearchController ()

@end

@implementation ShelfSearchController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    searchField.backgroundColor = [OWColor colorWithHex:0xefefef];
    searchField.clipsToBounds = YES;
    searchField.layer.cornerRadius = 3;
    
    searchField.delegate = self;
}

- (void)quitSearch
{
    [searchField resignFirstResponder];
}

- (void)filterButtonTapped:(id)sender
{
    [self quitSearch];
    
    if (self.delegate) {
        [self.delegate shelfFilterButtonTapped];
    }
}


- (void)beginSearch
{
    NSString *keywords = [searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!keywords) {
        keywords = @"";
    }
    NSDictionary *info = @{@"searchKey": keywords};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LYShelfSearch" object:nil userInfo:info];
}

#pragma mark textField delegate

//在iOS 7.0.3下，拼音输入法选中文是不会触发这个事件
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!displayLink) {
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(beginSearch)];
        [displayLink setFrameInterval:8];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (displayLink) {
        [displayLink invalidate];
        displayLink = Nil;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}


@end
