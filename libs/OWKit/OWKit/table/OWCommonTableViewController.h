//
//  OWCommonTableViewController.h
//  Xcode6AppTest
//
//  Created by grenlight on 14/6/27.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "XibAdaptToScreenController.h"
#import "OWTableViewDataSource.h"
#import "OWTableViewEditableDataSource.h"
#import "TableLoadMoreView.h"
#import "OWBlockDefine.h"
#import "LYRefreshView2.h"

typedef enum {
    owCellAnimationLeft,
    OWCellAnimationRight,
}OWCellAnimationDirection;//此方向标注的是运动方向

typedef enum {
    glTableNormalState,
    glTableRefreshState,
    glTableloadingMoreState,
    //本地数据状态时，不出现【加载更多】
    glTableLocalDataState
}GLTableState;

@interface OWCommonTableViewController : XibAdaptToScreenController<RefreshViewDelegate,LoadMoreViewDelegate,UITableViewDelegate>
{
    IBOutlet UITableView    *_tableView;
    OWTableViewDataSource   * dataSource;
    
    //用于处理section收放动画
    NSMutableArray          * sectionsDataSource;
    
    void(^cellConfigBlock)(id, id, NSIndexPath *);
    
    LYRefreshView2        * refreshView;
    TableLoadMoreView       * loadMoreView;
    
    NSInteger                    pageIndex;
    NSInteger                    pageCount;
    
    //当前是否已经使用的是本地数据
    BOOL                    isLocalData;
    
    /*
     根据列表状态生成数据项更新动画
     刷新时向前插入数据
     加载更多时往尾部插入数据
     */
    GLTableState            _tableState;
    
    NSMutableArray          * sectionKeys;
    
    CGPoint                   tableContentOffset;
}

@property (nonatomic, copy) GLHttpRequstMultiResults requestComplete;
@property (nonatomic, copy) GLHttpRequstFault reqestFault;
//是否可编辑删除
- (BOOL)isEditable;

-(void)setTableState:(GLTableState)state;

- (void)configCell:(id)cell data:(id)data indexPath:(NSIndexPath *)indexPath;
- (Class)cellClass;

- (BOOL)ifNeedsDrop_DownRefresh;
- (BOOL)ifNeedsLoadingMore;
- (NSString *)refreshViewTitle;

- (void)autoRefresh;

- (void)excuteRequest;

-(void)parseDataToSection:(NSArray *)arr;

//扩展回调
- (void)extendRequestCompletion;
- (void)extendRequestFault;

//解析数据前
- (void)preParseDataToSection:(NSArray *)arr;
//解析数据后
- (void)endParseDataToSection:(NSArray *)arr;

- (void)stopRefreshAndLoadMoreAnimation;

//结点 展开/收起 动画 -------------------
//是否需要展开   *默认是展开的
- (BOOL)ifNeedsExpanding;
- (void)sectionExpanding:(NSInteger )section;
- (void)sectionClose:(NSInteger )section;

//用于作切换动画
- (void)animateIntoList:(OWCellAnimationDirection)direction;
- (void)animateOutList:(OWCellAnimationDirection)direction;
- (void)animateToOriginal;

@end

