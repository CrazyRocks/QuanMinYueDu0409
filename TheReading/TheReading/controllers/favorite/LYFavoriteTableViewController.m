//
//  FavoriteTableViewController.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-31.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "LYFavoriteTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <OWCoreText/OWCoreText.h>
#import "LYMessageView.h"
#import <OWCoreText/OWHTMLToAttriString.h>
#import "SectionHeader.h"
#import "ArticleDetailMainController.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface LYFavoriteTableViewController (){
    LYFavoriteManager *favoriteManager;
    
    //在本视图产生的删除行为，不用刷新视图，在文章页产生的删除，刷新视图
    BOOL isReloaded;
    RecommendArticleTableCell *tempCell;

}

@end

@implementation LYFavoriteTableViewController

- (id)init
{
    self = [super initWithNibName:@"LYFavoriteTableViewController" bundle:[NSBundle bundleForClass:[self class]] ];
    if (self) {
        [self setup];
        needShowNavigationBar = YES;
    }
    return self;
}

- (id)initWithNoneNavigationBar
{
    self = [super initWithNibName:@"LYFavoriteTableViewController" bundle:[NSBundle bundleForClass:[self class]] ];
    if(self) {
        needShowNavigationBar = NO;
        [self setup];
    }
    return self;
}

- (void)setup
{
    [CommonNetworkingManager sharedInstance].fromList = glFavoriteList;
    favoriteManager = [[LYFavoriteManager alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(intoEditMode) name:FAVORITE_INTOEDITSTATE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeEdit) name:FAVORITEEDIT_COMPLETE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteCells) name:FAVORITE_DELETE object:nil];
    isReloaded = NO;
}

- (BOOL)ifNeedsDrop_DownRefresh
{
    return YES;
}

- (BOOL)ifNeedsLoadingMore
{
    return YES;
}

- (void)updateStatusBarStyle
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidLoad
{
    tempCell = [[NSBundle mainBundle] loadNibNamed:@"RecommendArticleTableCell" owner:self options:nil][0];

    UIStyleObject *style = [[UIStyleManager sharedInstance] getStyle:@"文章搜索列表"];
    if (style.useBackgroundImage) {
       self.view.backgroundColor =
        _tableView.backgroundColor =
        [UIColor colorWithPatternImage:[UIImage imageNamed:style.background_Image]];
    }
    else {
       self.view.backgroundColor =
        _tableView.backgroundColor = style.background;
    }
    
    if (!needShowNavigationBar) {
        [navBar removeFromSuperview];
        navBar = Nil;
        
        [_tableView setFrame:self.view.bounds];
        [self.view addSubview:_tableView];
    }
    else
        [navBar setTitle:@"收藏"];
    
    [super viewDidLoad];
    
    _tableView.delegate = self;
   
    [messageLable setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_tableView setEditing:NO animated:YES];
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [self autoRefresh];
}

- (Class)cellClass
{
    return [RecommendArticleTableCell class];
}

- (void)configCell:(RecommendArticleTableCell *)cell data:(LYArticleTableCellData *)data indexPath:(NSIndexPath *)indexPath
{
    [cell setContent:data];
}

- (BOOL)isEditable
{
    return YES;
}

- (void)excuteRequest
{
    __weak typeof (self) weakSelf = self;
    httpRequest = [favoriteManager getList:pageIndex completionBlock:^(NSArray *list, NSInteger count){
        self.requestComplete(list, count);
        dataSource.delegate = weakSelf;
    } faultBlock:self.reqestFault];
}

-(void)intoEditMode
{
    isEditMode = YES;
    for(LYArticleTableCellData *cellDate in dataSource.items) {
        cellDate.isEditMode = YES;
    }
}

-(void)completeEdit
{
    isEditMode = NO;
    for (LYArticleTableCellData *cellDate in dataSource.items) {
        cellDate.isEditMode = NO;
        cellDate.willDeleted = NO;
    }
}

-(void)deleteCells
{
//    for(NSIndexPath *path in willDeletedCells)
//    {
//        NSArray *secotion = [sections objectAtIndex:path.section];
//        ArticleTableCellData *art = [secotion objectAtIndex:path.row];
//    }
//    [_tableView deleteRowsAtIndexPaths:nil withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark tableView delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYArticleTableCellData *bd = dataSource.items[indexPath.row];
    [tempCell setContent:bd];
    
    [tempCell setNeedsUpdateConstraints];
    [tempCell updateConstraintsIfNeeded];
    
    tempCell.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), 90);
    
    [tempCell setNeedsLayout];
    [tempCell layoutIfNeeded];
    
    CGFloat height = [tempCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [CommonNetworkingManager sharedInstance].articles = [dataSource.items copy];
    [CommonNetworkingManager sharedInstance].articleIndex = indexPath.row;
    
    ArticleDetailMainController *detailController = [[ArticleDetailMainController alloc] init];
    detailController.isRecommendArticleMode = YES;
    /*
     此写法解决【上一页面的“个人中心”按钮未消失，与当前页面的“收藏”按钮重合】问题
     */
    UINavigationController *navController = self.navigationController.navigationController ?: self.navigationController;
    [navController pushViewController:detailController animated:YES];
    [detailController renderContentView];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
 
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删 除";
}


- (void)dataSourceDelete:(NSIndexPath *)indexPath
{
    [[OWMessageView sharedInstance] showMessage:@"正在删除收藏" autoClose:NO];
    
    __weak LYFavoriteTableViewController *weakSelf = self;
    
    [favoriteManager setArticle:dataSource.items[indexPath.row] toFavorite:NO completion:^{
        [weakSelf deletedArticleByIndexPath:indexPath];
        
    } fault:^{
        [weakSelf showMessage:@"删除失败" autoClose:YES];
    }];

}

- (void)deletedArticleByIndexPath:(NSIndexPath *)indexPath
{
    isReloaded = YES;
    [dataSource.items removeObjectAtIndex:indexPath.row];
    [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self showMessage:@"删除成功" autoClose:YES];
}

- (void)showMessage:(NSString *)msg autoClose:(BOOL)autoClose
{
    if (![NSThread isMainThread]) {
        [NSThread mainThread];
    }
    [[OWMessageView sharedInstance] showMessage:msg autoClose:autoClose];

}


- (void)editing:(UIButton *)sender
{
    NSString *title;
    if (_tableView.isEditing) {
        [_tableView setEditing:NO animated:YES];
        title = @"编辑";
    }
    else {
        [_tableView setEditing:YES animated:YES];
        title = @"完成";
    }
    [sender setTitle:title forState:UIControlStateNormal];

}

- (void)comeback:(id)sender
{
    if (self.returnToPreController) {
        self.returnToPreController();
    }
    else
        [super comeback:sender];
}

- (void)setBackButtonImage:(UIImage *)img
{
    [backButton setImage:img forState:UIControlStateNormal];
}

@end
