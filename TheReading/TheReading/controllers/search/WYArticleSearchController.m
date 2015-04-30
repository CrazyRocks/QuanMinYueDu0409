//
//  WYArticleSearchController.m
//  PublicLibrary
//
//  Created by grenlight on 14-3-8.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "WYArticleSearchController.h"
#import "ArticleSearchResultsController.h"
#import <OWCoreText/OWHTMLToAttriString.h>
#import "LYMagazinesStand.h"
#import <OWKit/OWKit.h>

@interface WYArticleSearchController ()
{
    ArticleSearchResultsController  *resultController;
    UITapGestureRecognizer  *tap;

}
@end

@implementation WYArticleSearchController

@synthesize searchField;

- (id)init
{
    self = [super init];
    if (self) {
        resultController = [[ArticleSearchResultsController alloc] init];
        [self addChildViewController:resultController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    searchBar.backgroundColor = self.view.backgroundColor;
    
    searchBT.titleLabel.textColor = [OWColor colorWithHexString:@"#bb1100"];
    
    searchField.delegate = self;
    searchField.returnKeyType = UIReturnKeySearch;
    
    [resultController.view setAlpha:0];
    [self.view insertSubview:resultController.view atIndex:0];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(60, 0, 0, 0);
    [resultController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(padding);
    }];
    
    [self performSelector:@selector(focusIn) withObject:nil afterDelay:0.3];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)focusIn
{
    if (!tap) {
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusOut)];
    }
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    [UIView animateWithDuration:0.2 animations:^{
        [resultController.view setAlpha:0];
    }];
    [searchField becomeFirstResponder];
}

- (void)focusOut
{
    [searchField resignFirstResponder];
    [self.view removeGestureRecognizer:tap];
}

#pragma mark textfield delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self submitSearch];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self focusIn];
}

- (void)searchButtonTapped:(id)sender
{
    [self submitSearch];
}

- (void)submitSearch
{
    NSString *keyword = [searchField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!keyword || keyword.length==0) {
        return;
    }
    [self focusOut];
    
    [resultController beginSearch:keyword];
    [UIView animateWithDuration:0.25 animations:^{
        [resultController.view setAlpha:1];
    }];
}


@end
