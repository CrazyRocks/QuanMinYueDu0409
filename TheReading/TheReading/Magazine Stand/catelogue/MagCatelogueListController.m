//
//  MagazineCatelogueTableViewController.m
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-10-18.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import "MagCatelogueListController.h"
#import "MagCatelogueCell.h"
#import "ArticleDetailMainController.h"
#import <QuartzCore/QuartzCore.h>
#import <OWCoreText/OWCoreText.h>
#import "MagCatSectionHeader.h"
#import <OWCoreText/OWHTMLToAttriString.h>
#import "LYMagazineGlobal.h"
#import <LYService/LYService.h> 
#import <OWKit/OWKit.h> 
#import <SDWebImage/UIImageView+WebCache.h>

@interface MagCatelogueListController ()
{
    LYMagazineManager   *requestManager;
}

//继续阅读
- (IBAction)continueRead:(id)sender;

@end

@implementation MagCatelogueListController

- (id)init
{
    self = [super initWithNibName:@"MagCatelogueListController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        [CommonNetworkingManager sharedInstance].fromList = glMagazineList;
        requestManager = [[LYMagazineManager alloc] init];
        pageIndex = 1;
        magazineFirstSectionIndexes = [[NSMutableArray alloc] init];
        magInfos = [[NSMutableArray alloc] init];
        articles = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)releaseData
{
    [requestManager cancelRequest];
    [super releaseData];
}

- (void)comeback:(id)sender
{
    [requestManager cancelRequest];
    [[NSNotificationCenter defaultCenter] postNotificationName:MAG_BACKTO_SHELF object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    continueButton.hidden = YES;
    
    self.view.backgroundColor = [OWColor colorWithHex:0xf2f2ef];
    _tableView.backgroundColor = [OWColor colorWithHex:0xf2f2ef];
    [navBar setTitle:[[CommonNetworkingManager sharedInstance].currentMagazine magName]];
        
    if ([LYMagazineGlobal sharedInstance].isLocalMagazine) {
        [navBar setHidden:YES];
        _tableView.frame = self.view.frame;
    }
    else {
        [navBar setTitle:[[CommonNetworkingManager sharedInstance] currentMagazine].magName];
    }
    
}

- (Class)cellClass
{
    return [MagCatelogueCell class];
}

- (void)configCell:(MagCatelogueCell *)cell data:(LYMagCatelogueTableCellData *)data indexPath:(NSIndexPath *)indexPath
{
    [cell setContent:data];
}

- (void)reloading:(id)sender
{
    [self excuteRequest];
}

- (void)updateStatusBarStyle
{
    [super updateStatusBarStyle];

     [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];       
}


-(void)excuteRequest
{
    if ([LYMagazineGlobal sharedInstance].isLocalMagazine) {
        [self requestLocalData];
    }
    else {
        [self requestRemoteData];
    }
}

- (void)requestLocalData
{
    pageIndex = 1;
    loadMoreView.isLastPage = YES;
    isLocalData = YES;
    
    MagCatSectionHeader *tableHeader = [[NSBundle bundleForClass:[self class]] loadNibNamed:@"MagCatSectionHeader_Local" owner:self options:nil][0];
    [tableHeader setLocalMagInfo:[[CommonNetworkingManager sharedInstance] currentMagazine]];
    _tableView.tableHeaderView = tableHeader;
    
    NSArray *arr = [[LYMagazineShelfManager sharedInstance] getMagazineCatalogues:(id)[[CommonNetworkingManager sharedInstance] currentMagazine]];
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (LYMagazineCatalogue *cat in arr) {
        LYMagCatelogueTableCellData *cellData = [[LYMagCatelogueTableCellData alloc] init];
        cellData.sectionName = cat.column;
        cellData.title = cat.title;
        cellData.titleID = cat.titleID;
        cellData.magGUID = cat.magGUID;
        cellData.magYear = [cat.magYear stringValue];
        cellData.magIssue = [cat.magIssue stringValue];
        [items addObject:cellData];
    }
    [self groupDataToSection:items magInfo:nil];
}

- (void)requestRemoteData
{
    isLocalData = NO;
    __weak MagCatelogueListController *weakSelf = self;
    void(^magCatCompletion)(NSArray *,LYMagazineInfo *) = ^(NSArray *result, LYMagazineInfo *magInfo) {
        if (result && result.count > 0) {
            [weakSelf groupDataToSection:result magInfo:magInfo];
        }
    };
    [requestManager getMagazineCatelogue:magCatCompletion
                                   fault:weakSelf.reqestFault];
}

-(void)groupDataToSection:(NSArray *)arr magInfo:(LYMagazineInfo *)magInfo
{
    if (magInfo) {
        [magInfos addObject:magInfo];
    }
    if (dataSource && dataSource.items.count > 0) {
        [magazineFirstSectionIndexes
         addObject:[NSNumber numberWithInteger:dataSource.items.count]];
    }
    else {
        [magazineFirstSectionIndexes addObject:@(0)];
        sectionKeys = [[NSMutableArray alloc] init];
    }
    continueButton.hidden = NO;
    
    [articles addObjectsFromArray:arr];

    NSMutableArray *sections = [[NSMutableArray alloc] init];
    NSString *currentSectionName ;
    NSMutableArray *sectionData;
    
    for (LYMagCatelogueTableCellData *cell in arr) {
        if (!currentSectionName ||
            (![cell.sectionName isEqualToString:currentSectionName] &&
             cell.sectionName)) {
            currentSectionName = cell.sectionName;
            if (!currentSectionName) {
                currentSectionName = @"其它";
            }
            sectionData = [[NSMutableArray alloc] init];
            [sectionData addObject:cell];
            [sections addObject:sectionData ];
            [sectionKeys addObject:[currentSectionName copy]];
        }
        else {
            [sectionData addObject:cell];
        }
    }
//    dataSource = [[OWTableViewDataSource alloc] initWithItems:sections configureCellBlock:cellConfigBlock];
//    dataSource.sections = sectionKeys;
    NSInteger pagecount = 20;
    if ([LYMagazineGlobal sharedInstance].isLocalMagazine) {
        pagecount = 1;
    }
    self.requestComplete(sections, pagecount);
    return;
    
    if (!dataSource || !dataSource.items || dataSource.items.count == 0) {
        self.requestComplete(sections, pagecount);
    }
    else {
        _tableState = glTableloadingMoreState;
        [self parseDataToSection:sections];
    }
}

#pragma mark table delegate

-(UIView *)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!dataSource || !dataSource.items || dataSource.items.count == 0)
        return nil;
    
    MagCatSectionHeader *headerView;

    if (![LYMagazineGlobal sharedInstance].isLocalMagazine) {
        for (uint i = 0; i < magazineFirstSectionIndexes.count; i++) {
            NSNumber *index = magazineFirstSectionIndexes[i];
            if ([index intValue] == section) {
                headerView = [[NSBundle bundleForClass:[self class]] loadNibNamed:@"MagCatSectionHeader_MagInfo" owner:self options:nil][0];
                LYMagazineInfo *info = magInfos[i];
                [headerView setTitle:dataSource.sections[section]];
                [headerView setMagInfo:info];
                
                return headerView;
            }
        }
    }
   
    headerView = [[NSBundle bundleForClass:[self class]]  loadNibNamed:@"MagCatSectionHeader" owner:self options:nil][0];
    [headerView setTitle:dataSource.sections[section]];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!dataSource || dataSource.items.count == 0) {
        return 0;
    }
    if (![LYMagazineGlobal sharedInstance].isLocalMagazine) {
        for (NSNumber *index in magazineFirstSectionIndexes) {
            if ([index intValue] == section) {
                return 204;
            }
        }
    }
    
    return 54;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LYMagCatelogueTableCellData *cellData = ((NSArray *)dataSource.items[indexPath.section])[indexPath.row];
    float cellHeight = ceilf([cellData cellHeight]);
    if (cellHeight < 40)
        cellHeight = 40;
    
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    uint articleIndex = 0;
    
    for (uint i = 0; i < indexPath.section; i++) {
        NSArray *items = (NSArray *)dataSource.items[i];
        articleIndex += items.count;
    }
    articleIndex += indexPath.row;
    
    [CommonNetworkingManager sharedInstance].articles = articles;
    [CommonNetworkingManager sharedInstance].articleIndex = articleIndex;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MAG_OPEN_CONTENT object:nil];
}


- (void)continueRead:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MAG_CONTINUE_READ object:nil];
}
@end
