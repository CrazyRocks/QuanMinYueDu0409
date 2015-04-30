//
//  BookShelfController.m
//  LogicBook
//
//  Created by 龙源 on 13-10-8.
//
//

#import "LYBookShelfController.h"
#import "BookshelfGradientBG.h"
#import "BSReaderViewController.h"
#import "MyBooksManager.h"
#import "BSCoreDataDelegate.h"
#import <CommonCrypto/CommonCryptor.h>
#import "zlib.h"
#import "LYBookDownloadManager.h"
#import "LYBookRenderManager.h"
#import "LYBookStoreController.h"
#import "LYBookConfig.h"
#import "LYBookAddUserGuide.h"
#import "LYBookSceneManager.h"
#import "LYBookHelper.h"
#import "BSCollectionCell.h"

@interface LYBookShelfController ()
{
    BookshelfGradientBG *bg;
    
    //需要刷新数据？
    BOOL    needRefresh;
    
    //是否已标示了最近阅读
    BOOL    showedRecentlyRead;
    
}

- (IBAction)rightButtonTapped:(id)sender;

@end

@implementation LYBookShelfController

- (id)init
{
    self = [super initWithNibName:@"LYBookShelfController"
                           bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithNoneNavigationBar
{
    self = [super initWithNibName:@"LYBookShelfController"
                           bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    [[LYBookSceneManager manager] reloadCss];
    self.bookType = lyBook;
    
    [self addNotification];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self releaseData];
}

- (void)releaseData
{
    //此处不能 call super，因为会导致监听事件被移除
    [statusManageView stopRequest];
    if (httpRequest && [httpRequest respondsToSelector:@selector(cancel)]) {
        [httpRequest cancel];
    }
}

- (void)addNotification
{
    __unsafe_unretained typeof (self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:BOOKSHELF_CHANGED object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        weakSelf->needRefresh = YES;
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"applicationDidBecomeActive" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if ([weakSelf isViewLoaded]) {
            weakSelf->needRefresh = YES;
            [weakSelf refresh];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"LYShelfSearch" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        weakSelf->keyString = note.userInfo[@"searchKey"];
        weakSelf->needRefresh = YES;
        if ([weakSelf isViewLoaded] && weakSelf.view.superview) {
            [weakSelf refresh];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refresh];
}

- (void)updateStatusBarStyle
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    //更新最近阅读标记
    if (selectedCell) {
        [selectedCell showRecentlyRead];
        if (lastReadCell) {
            [lastReadCell cancleRecentlyRead];
        }
        lastReadCell =selectedCell;
        selectedCell = nil;
    }	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [OWColor colorWithHex:0xfefefe] ;
    
    collectionView.backgroundColor = self.view.backgroundColor;
    
    [navBar setTitle:@"图书"];
    needRefresh = YES;
    
    NSString *nibName = @"BSCollectionCell";
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
    if (isPad) {
        flowLayout.itemSize = CGSizeMake(150, 127* 1.5 + 47);
    }
    else {
        flowLayout.itemSize = CGSizeMake(100, 174);
    }
    
    [collectionView registerNib:[UINib nibWithNibName:nibName bundle:[NSBundle bundleForClass:[self class]]] forCellWithReuseIdentifier:@"Cell"];
    collectionView.delegate = self;
    
    [self addNotification];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)];
}

#pragma mark layout changing

- (void)refresh
{
    if (!needRefresh) {
        return;
    }
    
    needRefresh = NO;
    isEditMode = NO;
    showedRecentlyRead = NO;
    
    if (keyString && ![keyString isEqualToString:@""]) {
        dataSource = [self generateDataSourceByKey];
    }
    else {
        dataSource = [self generateDataSourceByFilter];
    }
    
    collectionView.dataSource = self;
    [collectionView reloadData];
    
    messageBT.hidden = (dataSource.count > 0);
}

- (NSMutableArray *)generateDataSourceByFilter
{
    NSArray *allBooks = [[MyBooksManager sharedInstance] allMyBooks];
    NSMutableArray *ds = [NSMutableArray new];
    if (!filterString) {
        filterString = @"全部";
    }
    NSInteger isBook = (self.bookType == lyBook) ? 1 : 0 ;
    for (MyBook *book in allBooks) {
//        NSLog(@"fdafdada:%zd, %zd", [book.isBook integerValue], isBook);
        if ([book.isBook integerValue] == isBook) {
            if ([filterString isEqualToString:@"全部"]
                || [filterString isEqualToString:book.unitName]) {
                [ds addObject:book];
            }
        }
    }
    return ds;
}

- (NSMutableArray *)generateDataSourceByKey
{
    NSArray *allBooks = [[MyBooksManager sharedInstance] allMyBooks];
    NSMutableArray *ds = [NSMutableArray new];
    NSInteger isBook = (self.bookType == lyBook) ? 1 : 0 ;

    for (MyBook *book in allBooks) {
        if ([book.isBook integerValue] == isBook) {
            NSRange range = [book.bookName rangeOfString:keyString];
            if (range.length > 0) {
                [ds addObject:book];
            }
        }
    }
    return ds;
}


#pragma mark collection veiw delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)theCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    MyBook *bookInfo = dataSource[indexPath.row];
    
    //这个方法要6.0才支持
    BSCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setMyBook:bookInfo];
    cell.master = self;
    
    if (!showedRecentlyRead) {
        if ([bookInfo.lastReadCID intValue] > 0) {
            showedRecentlyRead = YES;
            [cell showRecentlyRead];
            lastReadCell = cell;
        }
    }
    
    if (isEditMode) {
        [cell startShake];
    }
    else {
        [cell stopShake];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)theCollectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (isEditMode) {
        [self endEdit];
        return;
    }
    MyBook *book = dataSource[indexPath.item];
    [MyBooksManager sharedInstance].currentReadBook = book;
    
    BSCollectionCell *cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
    if ([book.isDownloaded boolValue]) {
        CGRect frame = [cell getCoverFrame];
        frame = [[UIApplication sharedApplication].keyWindow convertRect:frame fromView:cell];
        
        BSReaderViewController *controller = [[BSReaderViewController alloc] init];
        [[OWNavigationController sharedInstance] pushViewController:controller animated:NO];
        [controller openFromRect:frame cover:[cell getCover]];
        
        selectedCell = cell;
    }
    else {
        
        [[LYBookDownloadManager sharedInstance] download:book];
    }
}

#pragma mark alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self rightButtonTapped:nil];
    }
}

#pragma mark delete items
- (void)deleteSelectedItem:(BSCollectionCell *)cell
{
    NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
    MyBook *book = dataSource[indexPath.row];
    [[MyBooksManager sharedInstance] deleteBook:book];
    [dataSource removeObjectAtIndex:indexPath.row];
    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
    
    if (dataSource.count == 0) {
        [self endEdit];
        messageBT.hidden = (dataSource.count > 0);
    }
    //为了有多个书架实列的场景下状态同步
    [[NSNotificationCenter defaultCenter] postNotificationName:BOOKSHELF_CHANGED object:nil];
}

#pragma mark scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [bg setContentOffsetY:scrollView.contentOffset.y];

    //显示或隐藏搜索栏
    if (scrollView.contentOffset.y < -5) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BOOKSHELF_SHOW_SEARCHBAR object:nil];
    }
    else if (scrollView.contentOffset.y > 5) {
        [[NSNotificationCenter defaultCenter] postNotificationName:BOOKSHELF_HIDE_SEARCHBAR object:nil];
    }
    
}

#pragma mark edit mode
- (void)beginEdit
{
    [self.view addGestureRecognizer:tap];

    isEditMode = YES;
    [self startShake];
}

- (void)endEdit
{
    [self.view removeGestureRecognizer:tap];
    isEditMode = NO;
    [self stopShake];
}

#pragma mark shake
- (void)startShake
{
    for (BSCollectionCell *cell in collectionView.visibleCells) {
        [cell startShake];
    }
}

- (void)stopShake
{
    for (BSCollectionCell *cell in collectionView.visibleCells) {
        [cell stopShake];
    }
}

#pragma mark barcode operate
- (void)rightButtonTapped:(id)sender
{
    [[LYBookAddUserGuide sharedUserGuide] removeUserCuide];
    if ([LYBookConfig sharedInstance].bookShelfMode == lyStoreMode) {
        [[OWNavigationController sharedInstance] pushViewController:[[LYBookStoreController alloc] init]
                                                      animationType:owNavAnimationTypeDegressPathEffect];
    }
}

- (void)completeEdit:(id)sender
{
    [self endEdit];
}

- (void)hideNavigationBar
{
    navBar.hidden = YES;
    collectionView.frame = self.view.bounds;
}

- (void)setReturnToPreControllerBlock:(ReturnMethod)returnToPreController
{
    self.returnToPreController = returnToPreController;
}

- (void)comeback:(id)sender
{    
    if (self.returnToPreController) {
        self.view.userInteractionEnabled = YES;
        self.returnToPreController();
    }
    else
        [super comeback:sender];
}
@end
