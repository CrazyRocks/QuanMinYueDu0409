//
//  SearchViewController.m
//  LYBookStore
//
//  Created by grenlight on 14/10/30.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchCell.h"
#import "LYBookRenderManager.h"
#import "SearchModel.h"


@interface SearchViewController ()
{
    CALayer *layer;
}
@end

@implementation SearchViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [OWColor colorWithHexString:@"#2F312E"];
    
    self.view.frame = CGRectMake(0, 0, appWidth, appHeight);
    
    
    searchs = [[NSMutableArray alloc]init];
    
    layer = [[CALayer alloc]init];
    layer.frame = CGRectMake(0, searchTextField.bounds.size.height - 0.5f, 1000, 0.5f);
    layer.backgroundColor = [OWColor colorWithHexString:@"#D3D3D3"].CGColor;
    [searchTextField.layer insertSublayer:layer above:searchTextField.layer];
    [searchTextField setReturnKeyType:UIReturnKeySearch];
    
    
    searchTableView.backgroundColor = [UIColor clearColor];
    searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    shimmer = [[OWShimmeringView alloc]initWithMessage:@"正在努力寻找中..."];
    
    shimmer.frontColor = [UIColor whiteColor];
    
    shimmer.center = self.view.center;
    
    [shimmer setHidden:YES];
    
    [self.view addSubview:shimmer];
    
    mask.hidden = YES;
    
    bar.backgroundColor = [OWColor colorWithHexString:@"#161616"];
    
}

-(void)showKeyBorad
{
    [searchTextField becomeFirstResponder];
}

-(IBAction)editorCancel:(UITapGestureRecognizer *)tap
{
    
    [searchTextField resignFirstResponder];
    
    mask.hidden = YES;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    mask.hidden = NO;
}





-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    
    [searchTextField resignFirstResponder];
    
    [self searchStringFromBook:searchTextField.text];
    
    return YES;
}

-(void)searchStringFromBook:(NSString *)string
{
    
    if (string.length < 2) {
        
        [[OWMessageView sharedInstance] showMessage:@"至少2个关键字" autoClose:YES];
        
        return;
    }
    
    
    mask.hidden = YES;
    
    if (searchs.count > 0) {
        [searchs removeAllObjects];
        [searchTableView reloadData];
    }
    
//    NSLog(@"base String %@",string);
    
    [shimmer setHidden:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        
        NSMutableArray *arr = [[LYBookRenderManager sharedInstance] searchBaseStringInAllCatalogs:string];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self performSelector:@selector(showpppp) withObject:nil afterDelay:0];
            
            searchs = arr;
            [searchTableView reloadData];
            
        });
        
    });
    
    
}

-(void)showpppp
{
    [shimmer setHidden:YES];
}



-(void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(updateStatusBarStyle) withObject:nil afterDelay:0.5];
}

- (void)updateStatusBarStyle
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    hearder = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([SearchHeader class]) owner:self options:nil]  lastObject];
    
    if (searchs.count >0) {
        hearder.titleLab.hidden = NO;
        
        NSString *number = [NSString stringWithFormat:@"%lu",(unsigned long)searchs.count];
        
        NSString *string = [NSString stringWithFormat:@"本次搜索共 %@ 条",number];
        
        NSMutableAttributedString *attributedStr01 = [[NSMutableAttributedString alloc] initWithString: string];
        
        [attributedStr01 addAttribute: NSForegroundColorAttributeName value:[OWColor colorWithHexString:@"A93523"] range: NSMakeRange(6, number.length)];
        
        hearder.titleLab.attributedText = attributedStr01;
        
    }else{
        
        hearder.titleLab.hidden = YES;
        
    }
    
    return hearder;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return searchs.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"searchCell";
    
    SearchCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    
    if (cell == nil) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([SearchCell class]) owner:self options:nil]  lastObject];
        
    }
    
    cell.model = [searchs objectAtIndex:indexPath.row];
    
    [cell setCellViewContent];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SearchModel *model = [searchs objectAtIndex:indexPath.row];
    
    [[LYBookRenderManager sharedInstance] intoBookSearch:model];
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_OPEN_CONTENT object:nil];
    
    [self dismissViewControllerAnimated:YES completion:^{
       
        
    }];
    
}


-(IBAction)canel:(id)sender
{
    
    [OWAnimator basicAnimate:canelBtn toScale:CGPointZero duration:0.2f delay:0 completion:^{
        
           [OWAnimator spring:canelBtn toScale:CGPointMake(1, 1) delay:0];
        
    }];
    
    
    [self dismissViewControllerAnimated:YES completion:^{
       
        
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat sectionHeaderHeight = 50;
    
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    searchTableView = nil;
    [searchs removeAllObjects];
    searchs = nil;
}

#pragma mark 键盘


-(BOOL)shouldAutorotate
{
    return NO;
}


@end
