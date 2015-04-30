//
//  CoreTextPageViewController.m
//  DragonSourceEPUB
//
//  Created by iMac001 on 12-1-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PageViewController.h"
#import "GLNoiceBackgroundView.h"
#import <OWCoreText/OWCoreText.h>
#import "BookmarkController.h"
#import "LYBookmarkManager.h"
#import "LYBookRenderManager.h"
#import "JRBookDigestManager.h"
#import "ModelTransformationTool.h"

#import "NetworkSynchronizationForBook.h"

#import "BSGlobalAttri.h"

#import "LYBookSceneManager.h"

@interface PageViewController(){
    BOOL isBookmark;
    NSString *bookMarkImagePath ;
    BookmarkController *bmController;
    
    //当前页码，只在页码有更新的情况下才重新渲染文本
    //渲染文本完成后才更新当前页码，用以支持取消渲染
    NSInteger currentPage;
    OWCoreTextLayouter *currentLayouter;
    
    LYBookmarkManager *bmManager;
    
    NSString *tmpSharedStr;
    NSRange tmpRange;
    GLCTPageInfo *tmpPageInfo;
    NSMutableArray *tmpNumbers;
    
    //工具当前是否已显示
    BOOL toolShow;
}

@end

@implementation PageViewController

@synthesize isCurrentPage, delegate;

- (id)init
{
    self = [super initWithNibName:@"PageViewController" bundle:[NSBundle bundleForClass:[self class]]];
    if (self) {
        currentPage = 0;
        pageFooterIsShow = YES;
        bookMarkImagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"bookmark_add" ofType:@"png"];
        
        //[添加书签]工具
        bmController = [[BookmarkController alloc] init];
//        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeDown)];
//        swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
//        [self.view addGestureRecognizer:swipeGesture];
       
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAudioBtnAnimation) name:@"stopBtnAnimation" object:nil];
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:BOOK_PARSER_BEGAIN object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePageCountToFloat) name:BOOK_PARSER_BEGAIN object:nil];
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setFrame:CGRectMake(0, 0, appWidth, appHeight-20)];

    footerView.backgroundColor = [UIColor clearColor];
    
    screeningArray = [[NSMutableArray alloc]init];
    
    //加入书摘管理的界面
    if (!_digestManagementCtrl) {
        _digestManagementCtrl = [[DigestManagementViewController alloc]init];
        _digestManagementCtrl.view.backgroundColor = [UIColor clearColor];
        _digestManagementCtrl.delegate = self;
    }
    
    loop.frame = self.view.bounds;
    
    catelogueLB.textColor = [OWColor colorWithHex:PAGEFOOTER_COLOR];
    pageNumberLB.textColor = [OWColor colorWithHex:PAGEFOOTER_COLOR];

    pageView.clearsContextBeforeDrawing = NO;
    pageView.backgroundColor = [UIColor clearColor];
    pageView.layer.shadowColor = [UIColor blackColor].CGColor;
    pageView.layer.shadowOpacity = 0.8;
    pageView.layer.shadowOffset = CGSizeMake(0, 0);
    pageView.layer.shadowRadius = 0.25f;

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(3, 0)];
    [path addLineToPoint:CGPointMake(appWidth-3, 0)];
    [path addLineToPoint:CGPointMake(appWidth-3, 0.1)];
    [path addLineToPoint:CGPointMake(3, 0.1)];
    
    pageView.layer.shadowPath = path.CGPath;
    
    home = pageView.center;
    
    bmManager = [LYBookmarkManager sharedInstance];
    [self.view addSubview:bmController.view];
    
    if (pageContentView == nil) {
        pageContentView = [[OWSinglePageView alloc] initWithFrame:self.view.bounds
                                                         layouter:nil];
        pageContentView.edgeInsets = [BSGlobalAttri sharedInstance].textInsets;
        pageContentView.delegate = self;
        pageContentView.backgroundColor = [UIColor clearColor];
        [pageView insertSubview:pageContentView atIndex:0];
        
        UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
        [pageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(pageView).with.insets(padding);
        }];
    }
    toolShow = NO;
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSceneMode) name:BOOK_SCENE_CHANGED object:nil];
    
    [self loadSceneMode];
    
    //长按手势
    UILongPressGestureRecognizer *preelong = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(addLoop:)];
    preelong.delegate = self;
    preelong.minimumPressDuration = 1.0f;
    [self.view addGestureRecognizer:preelong];
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(oneTapView:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearPageChooseLines) name:@"reload_page_content" object:nil];
    
    catelogueLB.textColor = [OWColor colorWithHexString:@"#a78675"];
    pageNumberLB.textColor = [OWColor colorWithHexString:@"#a78675"];
    
    
    twoPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(showCatalogs:)];
    twoPan.delegate = self;
    twoPan.minimumNumberOfTouches = 2;
    [self.view addGestureRecognizer:twoPan];
    
}

//双只拖动事件
-(void)showCatalogs:(UIPanGestureRecognizer *)recognizer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MOVE_ROOT" object:recognizer];
}



-(void)oneTapView:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self.view];
    
    RunObject *run = [pageContentView findPointIsInDigestRect:point];
    
    if (run != nil) {
        
        NSMutableArray *digests = [JRBookDigestManager sharedInstance].currentBookDigest;
        NSMutableArray *currentDigest = [self screeningDigests:digests];
        
        BookDigest *tmpDigest;
        
        //查找当前页所点击的书摘
        for (BookDigest *obj in currentDigest) {
            
            NSArray *newArray = [NSKeyedUnarchiver unarchiveObjectWithData:obj.numbers];
            
            for (NSNumber *number in newArray) {
                
                if ([number longLongValue] == run.number) {
                    
                    tmpDigest = obj;
                    
                    break;
                }
            }

        }
        
        NSMutableDictionary *startAndEndRect;
        
        if (tmpDigest) {
            
            JRDigestModel *model = [ModelTransformationTool coreDataTransformationUseModel:tmpDigest];
            startAndEndRect = [pageContentView findTouchPointRunObjc:model];
            
        }
        
        if (startAndEndRect != nil) {
            [_digestManagementCtrl setStartRectAndEndRect:startAndEndRect AndModel:tmpDigest withEdige:pageContentView.edgeInsets];
        }
        
        
        //配置属性
//        _digestManagementCtrl.model = tmpDigest;

        [[UIApplication sharedApplication].keyWindow addSubview:_digestManagementCtrl.view];
        [_digestManagementCtrl addViewAnimation];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hiddenNavBar" object:nil];
        
    }else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"OneTap" object:nil];
    }
    
}





- (void)changeSceneMode
{
    [self loadSceneMode];
}

- (void)loadSceneMode
{
    UIStyleObject *viewStyle = [[LYBookSceneManager manager].styleManager getStyle:@"目录页"];
     [OWAnimator basicAnimate:pageView toColor:viewStyle.background duration:0.35 delay:0];
    self.view.backgroundColor = viewStyle.background;
    
    UIStyleObject *lineStyle = [[LYBookSceneManager manager].styleManager getStyle:@"目录列表cell"];
    [splitLine drawByStyle:lineStyle];
}


- (void)setPagePosition:(CGRect)rect
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view setFrame:rect];
        home = pageView.center;
        [self clearPageChooseLines];
    });
    
}

- (void)setUnPagePosition:(CGRect)rect
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.view setFrame:rect];
        home = pageView.center;
        
    });
    
}


-(void)setPageInfo:(OWCoreTextLayouter *)layouter :(NSInteger)pageNum
{
    
    loop.isCurrent = self.isCurrentPage;
    
    if(pageNum == currentPage){
      return;
    }
    footerView.hidden = NO;
    
    __block NSString *pageNumStr , *catelogueStr;
    if(layouter == nil){
        currentPage = 0;
        catelogueStr = @"";
    }
    else {
        currentPage = pageNum;
        catelogueStr = layouter.catName;
    }
    if(pageNum == 0 || [[LYBookRenderManager sharedInstance] pageCount] < 1)
        pageNumStr = @"";
    else 
        pageNumStr =[NSString stringWithFormat:@"%li/%li", (long)pageNum, (long)[[LYBookRenderManager sharedInstance] pageCount]];

//    [UIView animateWithDuration:0.3 delay:0
//                        options:UIViewAnimationOptionAutoreverse
//                     animations:^{
//        pageContentView.alpha = 0;
//    } completion:^(BOOL finished) {
//        pageContentView.alpha = 1;
//    }];
    
    [pageContentView resetLayouter:layouter];
    
    currentLayouter = layouter;
    [pageNumberLB setText:pageNumStr];
    [catelogueLB setText:catelogueStr];
    [pageContentView drawPage:pageNum];
}

#pragma mark 新增方法 仅更新页码
-(void)noSetPageInfo:(OWCoreTextLayouter *)layouter updateNumber:(NSInteger)pageNum
{
    
    __block NSString *pageNumStr , *catelogueStr;
    
    if(layouter == nil){
        currentPage = 0;
        catelogueStr = @"";
    }
    else {
        currentPage = pageNum;
        catelogueStr = layouter.catName;
    }
    
    if(pageNum == 0 || [[LYBookRenderManager sharedInstance] pageCount] < 1)
        pageNumStr = @"";
    else
        pageNumStr =[NSString stringWithFormat:@"%li/%li", (long)pageNum, (long)[[LYBookRenderManager sharedInstance] pageCount]];
    
    [pageNumberLB setText:pageNumStr];
    [catelogueLB setText:catelogueStr];
    [pageContentView drawPage:pageNum];
}





//下拉动画
- (void)droppingDown:(float)offsetY
{
//    CGPoint movePoint;
    
    CGPoint center = home;
    
//    NSLog(@"home.y ====== %f",home.y);
    
    float centerY =  center.y + offsetY ;
    
//    NSLog(@"centerY ====== %f",centerY);
    
    if(centerY < home.y){
        center.y = home.y;
        canDropDown = NO;
    }
    else
        center.y = centerY ;
    
//    if (centerY >= home.y && centerY <= home.y + 80) {
//        movePoint = CGPointMake(home.x, centerY);
////        canDropDown = NO;
//    }else{
//        movePoint = CGPointMake(home.x, home.y + 80);
////        canDropDown = NO;
//    }
    
    [UIView animateWithDuration:0.3  animations:^{
                         [pageView setCenter:CGPointMake(center.x, centerY)];
                     }];
    
    [bmController movingView:offsetY];
}


#pragma mark 添加放大镜与文字选择
-(void)addLoop:(UILongPressGestureRecognizer *)press
{
    
    CGPoint endPoint;
    
    if (press.state == UIGestureRecognizerStateBegan)
    {
        
        [pageContentView clearChooseLine];
        
        CGPoint point = [press locationInView:self.view];
        
        //设置初始点击位置
        startPoint = point;
        
        endPoint = CGPointMake(startPoint.x+5, startPoint.y);
        
        NSLog(@"%@",NSStringFromCGPoint(point));
        
//        NSString *pStr = NSStringFromCGPoint(point);
        
        if (isCurrentPage) {
            
        }
        
        [loop addLoop:startPoint];
        
        [pageContentView drawNoteLineWithStartPoint:startPoint EndPoint:endPoint isShowMask:NO];
        
        //需要添加获取文字
        
    }
    else if (press.state  == UIGestureRecognizerStateChanged)
    {
//        NSLog(@"改变");
        
        CGPoint point = [press locationInView:self.view];
        
        endPoint = point;
        
//        NSString *pStr = NSStringFromCGPoint(point);
        
        [loop moveLoop:point];
        
        //需要添加获取文字
        
        [pageContentView drawNoteLineWithStartPoint:startPoint EndPoint:endPoint isShowMask:NO];
        
    }
    else if (press.state == UIGestureRecognizerStateEnded)
    {
        
        CGPoint point = [press locationInView:self.view];
        
        endPoint = point;
        
//        NSString *pStr = NSStringFromCGPoint(point);
        
        [loop removeLoop:point];
        
        [pageContentView drawNoteLineWithStartPoint:startPoint EndPoint:endPoint isShowMask:YES];
        
        [pageContentView showMenu];
        
    }
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    isDropDown = isDropUp = YES;
    canDropUp = canDropDown = NO;
    touchLocationY = [[touches anyObject] locationInView:[pageView superview] ].y;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    float newTLY =  [[touches anyObject] locationInView:[pageView superview]].y;
    float offsetY = (newTLY - touchLocationY) ;

    if(isDropUp && isDropDown){
        [delegate pageView_Scrolling];

        if(offsetY > 0){
            canDropDown = YES;
            [self droppingDown:offsetY];
            isDropUp = NO;
        }
        else {
            canDropUp = YES;
            isDropDown = NO;
        }
    }
    else {
        if(isDropDown){
            if(canDropDown){
                [self droppingDown:offsetY];
            }
        }
        else {
            if(canDropUp){
            }
        }
    }

}
- (void)dropDownGoHome{
    
    canDropDown = NO;
    [delegate pageView_ScrollEnable:YES];
    [UIView animateWithDuration:0.25 animations:^{
        [pageView setCenter:home];
    } completion:^(BOOL finished) {

    }];
  
    [bmController goHome];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(isDropDown){
      [self dropDownGoHome];
    }
    else {
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(isDropDown){
        [self dropDownGoHome];
    }
}


#pragma mark OWSinglePageView delegate
- (void)pageContentLoadComplete:(GLCTPageInfo *)info
{
    
    baseInfo = info;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //配置书签属性 这里传递的属性为了存储
        [bmController setPageInfo:info catalogue:catelogueLB.text catIndex:[currentLayouter navIndex]];
        BOOL isBookmarked = [[LYBookmarkManager sharedInstance] IsBookmarked:info];
        [bmController isMarked:isBookmarked];
        
    });
    
}

- (void)isFullScreenContent
{
    footerView.hidden = YES;
}

-(void)clearPageChooseLines;
{
    
    //清楚选择
    [pageContentView clearChooseLine];
    
    NSMutableArray *digests = [JRBookDigestManager sharedInstance].currentBookDigest;
    
    NSMutableArray *tmp = [[NSMutableArray alloc]init];
    
    for (BookDigest *obj in digests) {
    
        [tmp addObject:[ModelTransformationTool coreDataTransformationUseModel:obj]];
    
    }
    
    //如果有数据走筛选方法并return
    if (tmp.count > 0) {
        
        NSMutableArray *ttmp = [self screeningDigests:tmp];
        
        [pageContentView clearDigestArray:ttmp];
        
    }
    
}

-(BOOL)isHaveSameObjArray:(NSArray *)array withBaseArray:(NSMutableArray *)baseArray withPageInfo:(GLCTPageInfo *)info
{
    
    for (NSNumber *obj in array) {
        
        for (NSNumber *ob in baseArray) {
            
            if ([obj integerValue] == [ob integerValue]) {
                return YES;
            }
        }
    }
    
    return NO;
}




#pragma mark OWSingPageViewDelegate 
//存储书摘以及注释
-(NSMutableArray *)saveBookDigest:(NSString *)digestString withRange:(NSRange)range withPageInfo:(GLCTPageInfo *)info AndNumberArray:(NSMutableArray *)numbersArray 
{
    
    if (catelogueLB.text != nil && currentLayouter != nil)
    {
        
        //先获取判断是否有重叠的书摘
        NSMutableArray *digests1 = [JRBookDigestManager sharedInstance].currentBookDigest;
        
        //筛选本章中已存在的书摘
        NSMutableArray *currentDigest1 = [self screeningDigests:digests1];
        
        //创建存放含有重叠字符的书摘
        NSMutableArray *sames = [[NSMutableArray alloc]init];
        
        NSMutableString *baseString = [[NSMutableString alloc]init];
        
        for (BookDigest *obj in currentDigest1) {
            
            NSArray *newArray = [NSKeyedUnarchiver unarchiveObjectWithData:obj.numbers];
            
            if ([self isHaveSameObjArray:newArray withBaseArray:numbersArray withPageInfo:info]) {
                
                [sames addObject:obj];
                
            }
            
        }
        
#pragma mark 如果包含了别的书摘那么进行合并工作
        if (sames.count > 0)
        {
            
            NSMutableString *shareStr = [[NSMutableString alloc]init];
            
            [shareStr appendString:digestString];
            
            for (BookDigest *obj in sames) {
                
                NSArray *newArray = [NSKeyedUnarchiver unarchiveObjectWithData:obj.numbers];
                
                [numbersArray addObjectsFromArray:newArray];
                
                if (obj.digestNote != nil) {
                    
                        [baseString appendString:@","];
                        [baseString appendString:obj.digestNote];
                }
            }

            NSSet *set = [NSSet setWithArray:numbersArray];
            
            //--------------------
            //处理后所含的位置model number属性
            NSArray *tmpArray = [set allObjects];
            NSArray *numbers = [tmpArray sortedArrayUsingSelector:@selector(compare:)];
            NSMutableArray *tmp = [[NSMutableArray alloc]initWithArray:numbers];
            
            //处理后model用的range
            NSRange range1 = NSMakeRange([[tmp objectAtIndex:0] intValue], tmp.count);
            //合并字符串
            
            NSString *summer = [self getStringFromPageInfo:info andNumbers:tmp withSames:sames];
            //--------------------
            
            BOOL isSave = [[JRBookDigestManager sharedInstance] saveBookDigestsendRange:range1 DigestString:summer PageInfo:info Catalogue:catelogueLB.text CatIndex:[currentLayouter navIndex] NumbersArray:tmp Note:baseString];
            
            [[NetworkSynchronizationForBook manager] saveBookDigestToSever:[JRBookDigestManager sharedInstance].currentNeedSaveBookDigest];
            
            for (BookDigest *digest in sames) {
                
                
               [[NetworkSynchronizationForBook manager] deleteBookDigestToSever:digest];
               BOOL isDelete = [[JRBookDigestManager sharedInstance] delegateThisBookDigestAndNotes:digest];
                
                NSLog(@"isDelete ======  %d",isDelete);
                
            }
            
            if (isSave) {
                
                //成功后让公用数据中的书摘更新成最新的数据
                [[JRBookDigestManager sharedInstance] loadThisBookDigestsAndNotes:[MyBooksManager sharedInstance].currentReadBook];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LYBOOK_BOOKMARK_CHANGED object:nil];
                
            }
            
            //获取所有的书摘
            NSMutableArray *digests = [[JRBookDigestManager sharedInstance] loadThisBookDigestsAndNotes:[MyBooksManager sharedInstance].currentReadBook];
            
            NSMutableArray *currentDigest = [self screeningDigests:digests];
            
            NSMutableArray *tmpNew = [[NSMutableArray alloc]init];
            
            for (BookDigest *obj in currentDigest) {
                
                [tmpNew addObject:[ModelTransformationTool coreDataTransformationUseModel:obj]];
                
            }
            
            //如果有数据走筛选方法并return
            if (tmpNew.count > 0) {
                
                return tmpNew;
                
            }
            
            
        }else{
        
            
            BOOL isSave = [[JRBookDigestManager sharedInstance] saveBookDigestsendRange:range DigestString:digestString PageInfo:info Catalogue:catelogueLB.text CatIndex:[currentLayouter navIndex] NumbersArray:numbersArray Note:nil];
            
            if (isSave) {
                
                //上传服务器
                [[NetworkSynchronizationForBook manager] saveBookDigestToSever:[JRBookDigestManager sharedInstance].currentNeedSaveBookDigest];
                
                //成功后让公用数据中的书摘更新成最新的数据
                [[JRBookDigestManager sharedInstance] loadThisBookDigestsAndNotes:[MyBooksManager sharedInstance].currentReadBook];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LYBOOK_BOOKMARK_CHANGED object:nil];
                
            }else {
                
                
            }
            
            
            //获取所有的书摘
            NSMutableArray *digests = [JRBookDigestManager sharedInstance].currentBookDigest;
            
            NSMutableArray *currentDigest = [self screeningDigests:digests];
            
            NSMutableArray *tmp = [[NSMutableArray alloc]init];
            
            for (BookDigest *obj in currentDigest) {
                
                [tmp addObject:[ModelTransformationTool coreDataTransformationUseModel:obj]];
                
            }
            
            //如果有数据走筛选方法并return
            if (tmp.count > 0) {
                
                return tmp;
                
            }
            
        }
        
    }
    
    return nil;
}



-(NSString *)getStringFromPageInfo:(GLCTPageInfo *)pageInfo andNumbers:(NSArray *)numbersArray withSames:(NSMutableArray *)sames
{
    
    if (numbersArray.count > 0) {
        
        NSNumber *firstNumber = numbersArray.firstObject;
        NSNumber *lastNumber = numbersArray.lastObject;
        
        NSInteger length = [pageInfo.description length];
        
        NSInteger cha = [lastNumber integerValue] - (pageInfo.location + length);
        
        NSString *b;
        
        if (cha <= 0) {
            
            if ([firstNumber integerValue] < pageInfo.location) {
                
                NSString *tmp = [pageInfo.description substringWithRange:NSMakeRange(0, [lastNumber integerValue] - pageInfo.location)];
                
                BookDigest *needAddModel;//超出的model
                NSInteger number = 0;//位置
                NSNumber *lastPageWord = [NSNumber numberWithInteger:pageInfo.location];
                
                for (BookDigest *model in sames) {
                    
                    NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:model.numbers];
                    
                    BOOL isHave = [arr containsObject:lastPageWord];
                    
                    if (isHave) {
                        
                        needAddModel = model;
                        
                        number = [arr indexOfObject:lastPageWord];
                        break;
                    }
                    
                }
                
                if (needAddModel) {
                    
                    NSString *tmp1 = [needAddModel.summary substringWithRange:NSMakeRange(0, number+1)];
                    
                    b = [NSString stringWithFormat:@"%@%@",tmp1,tmp];
                    
                    NSLog(@"b === %@",b);
                    
                }

            }else{
                
                b = [pageInfo.description substringWithRange:NSMakeRange([firstNumber integerValue] - pageInfo.location, [lastNumber integerValue] - [firstNumber integerValue])];
            }
            
            
        }else{
            
            NSString *tmp = [pageInfo.description substringWithRange:NSMakeRange([firstNumber integerValue] - pageInfo.location, pageInfo.location + length - [firstNumber integerValue])];
            
            BookDigest *needAddModel;//超出的model
            NSInteger number = 0;//位置
            NSNumber *lastPageWord = [NSNumber numberWithInteger:(pageInfo.location + length+1)];
            
            for (BookDigest *model in sames) {
                
                NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithData:model.numbers];
                
                BOOL isHave = [arr containsObject:lastPageWord];
                
                if (isHave) {
                    
                    needAddModel = model;
                    
                    number = [arr indexOfObject:lastPageWord];
                    break;
                }
                
            }
            
            if (needAddModel) {
                
                NSString *tmp1 = [needAddModel.summary substringFromIndex:number];
                
                b = [NSString stringWithFormat:@"%@%@",tmp,tmp1];
            }
            

        }
        
        return b;
        
    }
    
    return nil;
}

//筛选摘要是否属于本页
-(NSMutableArray *)screeningDigests:(NSMutableArray *)array
{
    if (array.count > 0) {
        
        NSMutableArray *tmp = [[NSMutableArray alloc]init];
        
        for (JRDigestModel *obj in array) {
            
            if ([obj.catName isEqualToString:catelogueLB.text]) {
                [tmp addObject:obj];
            }
        }
        
        return tmp;
    }
    
    return nil;
}

#pragma mark 批注代理方法

-(void)callNoteEditCtrlWithStr:(NSString *)digestString withRange:(NSRange)range withPageInfo:(GLCTPageInfo *)info AndNumberArray:(NSMutableArray *)numbersArray
{
    
    //先获取判断是否有重叠的书摘
    NSMutableArray *digests1 = [JRBookDigestManager sharedInstance].currentBookDigest;
    
    //筛选本章中已存在的书摘
    NSMutableArray *currentDigest1 = [self screeningDigests:digests1];
    
    //创建存放含有重叠字符的书摘
    NSMutableArray *sames = [[NSMutableArray alloc]init];
    
    //注释内容
    NSMutableString *baseString = [[NSMutableString alloc]init];
    
    for (BookDigest *obj in currentDigest1) {
        
        NSArray *newArray = [NSKeyedUnarchiver unarchiveObjectWithData:obj.numbers];
        
        if ([self isHaveSameObjArray:newArray withBaseArray:numbersArray withPageInfo:info]) {
            
            [sames addObject:obj];
            
        }
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollNo" object:nil];

    //存在相同的
    if (sames > 0) {
        
        NSMutableString *shareStr = [[NSMutableString alloc]init];
        
        [shareStr appendString:digestString];
        
        for (BookDigest *obj in sames) {
            
            NSArray *newArray = [NSKeyedUnarchiver unarchiveObjectWithData:obj.numbers];
            
            //字符的拼接
            [numbersArray addObjectsFromArray:newArray];
            
            if (obj.digestNote != nil) {
                
                //注释内容的拼接
                if ([baseString isEqualToString:@""]) {
                    [baseString appendString:obj.digestNote];
                }else{
                    [baseString appendString:@"\n"];
                    [baseString appendString:obj.digestNote];
                }
                
            }
        }
        
        NSSet *set = [NSSet setWithArray:numbersArray];
        
        //--------------------
        //处理后所含的位置model number属性
        NSArray *tmpArray = [set allObjects];
        NSArray *numbers = [tmpArray sortedArrayUsingSelector:@selector(compare:)];
        NSMutableArray *tmp = [[NSMutableArray alloc]initWithArray:numbers];
        
        //处理后model用的range
        NSRange range1 = NSMakeRange([[tmp objectAtIndex:0] intValue], tmp.count+1);
        //合并字摘要
        NSString *summer = [self getStringFromPageInfo:info andNumbers:tmp withSames:sames];
        
        notsArray = numbersArray;
        
        tmpSharedStr = summer;
        tmpRange = range1;
        tmpPageInfo = info;
        tmpNumbers = tmp;
        
        NotesViewController *notes = [[NotesViewController alloc]initWithNibName:nil bundle:nil];
        notes.delegate = self;
        [self presentViewController:notes animated:YES completion:^{
            [notes setSubViewContent:tmpSharedStr Range:range1 PageInfo:info Numbers:tmp isMore:YES andBaseNoteString:baseString andSames:sames];
            [notes updateStatusBarStyle];
        }];
        
    }
    else{
        
        notsArray = numbersArray;
        
        tmpSharedStr = digestString;
        tmpRange = range;
        tmpPageInfo = info;
        tmpNumbers = numbersArray;
        
        NotesViewController *notes = [[NotesViewController alloc]initWithNibName:nil bundle:nil];
        notes.delegate = self;
        [self presentViewController:notes animated:YES completion:^{
            
            [notes setSubViewContent:tmpSharedStr Range:range PageInfo:info Numbers:numbersArray isMore:NO andBaseNoteString:baseString andSames:nil];
            [notes updateStatusBarStyle];
            
        }];

        
    }
    
}

#pragma mark noteDelegate 笔记代理方法
-(void)completeEditor:(NSString *)string withSharedString:(NSString *)shareString
{
    
    
    BOOL isSave = [[JRBookDigestManager sharedInstance] saveBookDigestsendRange:tmpRange DigestString:tmpSharedStr PageInfo:tmpPageInfo Catalogue:catelogueLB.text CatIndex:[currentLayouter navIndex] NumbersArray:tmpNumbers Note:string];
    
    if (isSave) {
        
        [[NetworkSynchronizationForBook manager] saveBookDigestToSever:[JRBookDigestManager sharedInstance].currentNeedSaveBookDigest];
        
        //成功后让公用数据中的书摘更新成最新的数据
        [[JRBookDigestManager sharedInstance] loadThisBookDigestsAndNotes:[MyBooksManager sharedInstance].currentReadBook];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LYBOOK_BOOKMARK_CHANGED object:nil];
        
    }else {
        
        
    }
    
    
    //获取所有的书摘
    NSMutableArray *digests = [JRBookDigestManager sharedInstance].currentBookDigest;
    
    NSMutableArray *currentDigest = [self screeningDigests:digests];
    
    NSMutableArray *tmp = [[NSMutableArray alloc]init];
    
    for (BookDigest *obj in currentDigest) {
        
        [tmp addObject:[ModelTransformationTool coreDataTransformationUseModel:obj]];
        
    }
    
    //如果有数据走筛选方法并return
    if (tmp.count > 0) {
        
        [pageContentView clearDigestArray:tmp];
        
    }
}

-(void)completeEditor:(NSString *)string withSharedString:(NSString *)shareString withSames:(NSMutableArray *)array
{
    
    BOOL isSave = [[JRBookDigestManager sharedInstance] saveBookDigestsendRange:tmpRange DigestString:tmpSharedStr PageInfo:tmpPageInfo Catalogue:catelogueLB.text CatIndex:[currentLayouter navIndex] NumbersArray:tmpNumbers Note:string];
    
    if (isSave) {
        
        [[NetworkSynchronizationForBook manager] saveBookDigestToSever:[JRBookDigestManager sharedInstance].currentNeedSaveBookDigest];
        
        //成功后让公用数据中的书摘更新成最新的数据
        [[JRBookDigestManager sharedInstance] loadThisBookDigestsAndNotes:[MyBooksManager sharedInstance].currentReadBook];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:LYBOOK_BOOKMARK_CHANGED object:nil];
        
    }
    
    for (BookDigest *digest in array) {
        
        BOOL isDelete = [[JRBookDigestManager sharedInstance] delegateThisBookDigestAndNotes:digest];
        
        NSLog(@"isDelete ======  %d",isDelete);
        
    }
    
    [[JRBookDigestManager sharedInstance] loadThisBookDigestsAndNotes:[MyBooksManager sharedInstance].currentReadBook];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LYBOOK_BOOKMARK_CHANGED object:nil];
    
    
    //获取所有的书摘
    NSMutableArray *digests = [JRBookDigestManager sharedInstance].currentBookDigest;
    
    NSMutableArray *currentDigest = [self screeningDigests:digests];
    
    NSMutableArray *tmp = [[NSMutableArray alloc]init];
    
    for (BookDigest *obj in currentDigest) {
        
        [tmp addObject:[ModelTransformationTool coreDataTransformationUseModel:obj]];
        
    }
    
    //如果有数据走筛选方法并return
    if (tmp.count > 0) {
        
        [pageContentView clearDigestArray:tmp];
        
    }
}

#pragma mark 调用注释界面
-(void)addNoteToBookDigest:(BookDigest *)model
{
    NotesViewController *notes = [[NotesViewController alloc]initWithNibName:nil bundle:nil];
    notes.delegate = self;
    [self presentViewController:notes animated:YES completion:^{
        [notes setSubViewContentWithBookDigestModel:model];
        [notes updateStatusBarStyle];

    }];

}

-(void)completeEditorIsModelType
{
    [self changeColorComplete];
}



-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
//    NSLog(@"%@",NSStringFromClass([gestureRecognizer.view class]));
    
    return NO;
}

-(void)setVideoPlayerShow
{
//    [pageContentView drawVideoPlayer];
}

-(void)btnActionIntoVideo:(VideoBtn *)btn
{
//    NSLog(@"btn.attachment.contents ====== %@",btn.attachment.contents);
    
    NSString *sendStr = [NSString stringWithFormat:@"%@",btn.attachment.contents];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"intoVideo" object:sendStr];
    
}



#pragma mark 弹框代理方法
-(void)changeColorComplete
{
    
    [[JRBookDigestManager sharedInstance] loadThisBookDigestsAndNotes:[MyBooksManager sharedInstance].currentReadBook];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:LYBOOK_BOOKMARK_CHANGED object:nil];
    
    NSMutableArray *digests = [JRBookDigestManager sharedInstance].currentBookDigest;
    
    NSMutableArray *currentDigest = [self screeningDigests:digests];
    
    NSMutableArray *tmp = [[NSMutableArray alloc]init];
    
    for (BookDigest *obj in currentDigest) {
        
        [tmp addObject:[ModelTransformationTool coreDataTransformationUseModel:obj]];
        
    }
    
    //如果有数据走筛选方法并return
        
    [pageContentView clearDigestArray:tmp];
    
}


#pragma mark 音乐代理
-(void)addAideoToPlay:(VideoBtn *)btn
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddAudio" object:nil];
}


#pragma mark 停止本页音乐按钮旋转
-(void)stopAudioBtnAnimation
{
    [pageContentView stopBtnAnimation];
}



-(GLCTPageInfo *)getGLCTPageInfo
{
    return baseInfo;
}




-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)swipeDown
{
    
}

#pragma mark 更换字体或者字号后重新加载页面
-(void)updatePageNumber:(NSString *)info
{
    
    if (pageNumberLB.text != nil) {
        
        pageNumberLB.text = info;
    }
}


#pragma mark 获取页码 （只在重新计算完成后调用）
-(NSString *)getPageNumber
{
    
    if (pageNumberLB.text != nil) {
        NSString *str = [NSString stringWithFormat:@"%@",pageNumberLB.text];
        return str;
    }
    
    return nil;
}



#pragma mark 将现有页码变成百分比（此方法为改变字体自豪需要重新计算时调用的方法）
-(void)changePageCountToFloat
{
    if (pageNumberLB.text != nil) {
        
//        pageNumberLB.text = @"我在改变中";
        
        NSString *tmpString = [NSString stringWithFormat:@"%@",pageNumberLB.text];
        
        NSArray *array = [tmpString componentsSeparatedByString:@"/"];
        
        if (array.count > 1) {
            
        }
        else{
            
            return;
        }
        
        NSString *tmp1 = [array objectAtIndex:0];
        NSString *tmp2 = [array objectAtIndex:1];
        
        CGFloat t1 = [tmp1 floatValue];
        CGFloat t2 = [tmp2 floatValue];
        
        CGFloat k = t1 / t2;
        
        k = k * 100;
        
        NSString *str = [NSString stringWithFormat:@"%f",k];
        NSString *newPageNumber;
        
        if (str.length >= 5) {
            NSString *tmp = [str substringWithRange:NSMakeRange(0,5)];
            newPageNumber = [NSString stringWithFormat:@"%@%%",tmp];
        }
        
        pageNumberLB.text = newPageNumber;
    }
}


#pragma mark 分享
- (void)shareSelectedText:(NSString *)str
{
    NSArray *activityItems = @[str];
    
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                      applicationActivities:nil];
    activityController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard,UIActivityTypeAddToReadingList, UIActivityTypePrint];
    [self presentViewController:activityController animated:YES completion:nil];

    if (isPad) {
        if ([activityController respondsToSelector:@selector(popoverPresentationController)]) {
            UIPopoverPresentationController *presentationController = [activityController popoverPresentationController];
            presentationController.sourceView = self.view;
            presentationController.sourceRect = CGRectMake(0, appHeight-50, appWidth, 50);

        }
    }
   
}

#pragma mark 搜索
- (void)searchSelectedText:(NSString *)str
{
    NSString *urlStr = [NSString stringWithFormat:@"http://www.baidu.com/s?ie=utf-8&wd=%@", (__bridge NSString *)[self encode:str]];
    NSURL *url = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication] openURL:url];
}

- (CFStringRef)encode:(NSString *)string
{
    return  CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                    (__bridge CFStringRef)string, nil,
                                                    CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), kCFStringEncodingUTF8);
}
@end
