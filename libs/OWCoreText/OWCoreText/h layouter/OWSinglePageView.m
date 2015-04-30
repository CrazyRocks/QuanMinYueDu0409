
//
//  Created by  oowwww on 11-9-3.
//  Copyright (c) 2011年 OOWWWW. All rights reserved.

#define STARLINE @"StarLine"
#define STARNUMBER @"StarNumber"

#define ENDLINE @"EndLine"
#define ENDNUMBER @"EndNumber"



#import "OWSinglePageView.h"
#import "OWCoreTextLayoutFrame.h"
#import "OWTextAttachment.h"
#import <QuartzCore/QuartzCore.h>
#import "PageImage.h"
#import "GLCTPageInfo.h"
#import "OWAnnotationButton.h"
#import "OWCoreTextGlyphRun.h"


#import "AudioCommon.h"



//检测是否开启ARC模式
#if !__has_feature(objc_arc)
#error THIS CODE MUST BE COMPILED WITH ARC ENABLED!
#endif

@interface OWSinglePageView ()<UIGestureRecognizerDelegate>
{
    __weak OWCoreTextLayouter *_layouter;
    GLCTPageInfo *pageInfo;
    
    NSMutableArray *annotations;
    
    UIMenuController *menu;
    
    //是否有需要显示的文本
    bool needsDisplay;
}

@end

@implementation OWSinglePageView

@synthesize  delegate;

- (void)setup
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeShowAnimation) name:@"changeShowAnimation_YES" object:nil];
    
    
    _digestArray = [[NSMutableArray alloc]init];
    needDraws = [[NSMutableArray alloc]init];
    noteBtns = [[NSMutableArray alloc]init];
    digestNoteBtns = [[NSMutableArray alloc]init];
    
    self.contentMode = UIViewContentModeTopLeft; // to avoid bitmap scaling effect on resize
    
    
    _rectView = [[WordRectView alloc]initWithFrame:self.bounds];
    [self addSubview:_rectView];
    
    //添加遮罩 主要为了取消文字选择
    _mask = [[OWChooseMask alloc] initWithFrame:self.bounds];
//    _mask.backgroundColor = [UIColor blueColor];
    _mask.maskDelegate = self;
    _mask.hidden = YES;
    [self addSubview:_mask];
    
    
    //大头针
    _starSlider = [[BookPin alloc]initWithFrame:CGRectMake(0, 0, 12, 20)];
//    _starSlider.image = [UIImage imageNamed:@"slider_Choose"];
    [_starSlider setContentMode:UIViewContentModeScaleAspectFill];
    _starSlider.userInteractionEnabled = YES;
    //    _starSlider.backgroundColor = [UIColor yellowColor];
    _starSlider.hidden = YES;
    [self insertSubview:_starSlider aboveSubview:_mask];
    
    _endSlider = [[BookPin alloc]initWithFrame:CGRectMake(0, 0, 12, 20)];
//    _endSlider.image = [UIImage imageNamed:@"slider_Choose"];
    [_endSlider setContentMode:UIViewContentModeScaleAspectFill];
    _endSlider.hidden = YES;
    _endSlider.transform=CGAffineTransformMakeRotation(M_PI);
    _endSlider.userInteractionEnabled = YES;
    [self insertSubview:_endSlider aboveSubview:_mask];
    
    
    UIPanGestureRecognizer *pan1 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(changeSliderCenter:)];
    pan1.delegate = self;
    [_endSlider addGestureRecognizer:pan1];
    
    UIPanGestureRecognizer *pan2 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(changeSliderCenter:)];
    pan1.delegate = self;
    [_starSlider addGestureRecognizer:pan2];
    
    menu = [UIMenuController sharedMenuController];

}


-(void)changeShowAnimation
{
    _isNeedDrawAnimation = YES;
}


#pragma mark 弹窗
- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
//    [super canPerformAction:action withSender:sender];
    
    if ( action == @selector(copyQ:) ||
        action == @selector(digest:) ||
        action == @selector(notes:) ||
        action == @selector(share:) ||
        action == @selector(searchAction:)) {
        return YES;
    }
    else {
        return NO;
    }
}

-(void)copyQ:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if (shareStr) {
        [pasteboard setString:shareStr]; //将文字复制进粘帖版
    }
    
    [_mask hiddenMeQ];
}

//摘要功能需要
-(void)digest:(id)sender
{
    //设置需要传出去的range （在本章节的节点位置）
    NSRange range = NSMakeRange(pageInfo.location + star , end - star);
    
    //将每个文字在本章节中的位置进行添加
    NSMutableArray *sendArray = [[NSMutableArray alloc]init];
    
    for (long i = range.location; i < range.location + range.length; i++) {
        [sendArray addObject:[NSNumber numberWithLong:i]];
    }
    
    if ([self.delegate  respondsToSelector:@selector(saveBookDigest: withRange: withPageInfo: AndNumberArray:)]) {
        
        NSMutableArray *tmpDigests = [self.delegate saveBookDigest:shareStr withRange:range withPageInfo:pageInfo AndNumberArray:sendArray];
        
        [self clearDigestArray:tmpDigests];
    }
    
}

#pragma mark 笔记
-(void)notes:(id)sender
{
    //设置需要传出去的range （在本章节的节点位置）
    NSRange range = NSMakeRange(pageInfo.location + star , end - star+1);
    
    //将每个文字在本章节中的位置进行添加
    NSMutableArray *sendArray = [[NSMutableArray alloc]init];
    
    for (long i = range.location; i < range.location + range.length; i++) {
        [sendArray addObject:[NSNumber numberWithLong:i]];
    }
    
    if ([self.delegate respondsToSelector:@selector(callNoteEditCtrlWithStr:withRange:withPageInfo:AndNumberArray:)]) {
        [self.delegate callNoteEditCtrlWithStr:shareStr withRange:range withPageInfo:pageInfo AndNumberArray:sendArray];
    }
    
    [_mask hiddenMeQ];
    
    [self setNeedsDisplay];
}

#pragma mark 分享
-(void)share:(id)sender
{
    [self.delegate shareSelectedText:shareStr];
}

#pragma mark 搜索
- (void)searchAction:(id)sender
{
    [self.delegate searchSelectedText:shareStr];
}

#pragma mark 拖动大头针位置方法
-(void)changeSliderCenter:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        [menu setMenuVisible:NO animated:YES];
    }
    else if (pan.state == UIGestureRecognizerStateChanged) {
        
        if ((UIImageView *)pan.view == _endSlider) {
            
            CGPoint point = [pan locationInView:self];
            
            CGRect endRect = [self findEndPointX:point];
            
            CGPoint panPoint = endRect.origin;
            
            CGPoint pointNewSet = CGPointMake(panPoint.x + _edgeInsets.left, panPoint.y + _edgeInsets.top);
            
            //转换后的新起始点坐标
            CGPoint pointNewS = CGPointMake(starPoint.x + _edgeInsets.left, starPoint.y+_edgeInsets.top);
            
            if (pointNewSet.y > pointNewS.y) {
                
                [self drawNoteLineWithStartPoint:pointNewS EndPoint:pointNewSet isShowMask:NO];
                
            }else if (pointNewSet.y == pointNewS.y){
                
                if (pointNewSet.x >= pointNewS.y) {
                    
                    [self drawNoteLineWithStartPoint:pointNewS EndPoint:pointNewSet isShowMask:NO];
                    
                }
                
            }else{
                
                
                
            }
            
        }
        else if ((UIImageView *)pan.view == _starSlider){
            
            CGPoint point = [pan locationInView:self];
            
            CGRect endRect = [self findEndPointX:point];
            
            CGPoint panPoint = endRect.origin;
            
            CGPoint pointNewSet = CGPointMake(panPoint.x + _edgeInsets.left, panPoint.y + _edgeInsets.top);
            
            //转换后的新起始点坐标
            
            CGPoint pointNewE = CGPointMake(endPoint.x + _edgeInsets.left, endPoint.y+_edgeInsets.top);
            
            if (pointNewSet.y < pointNewE.y) {
                [self drawNoteLineWithStartPoint:pointNewSet EndPoint:pointNewE isShowMask:NO];
                
            }
            else if (pointNewSet.y == pointNewE.y){
                
                if (pointNewSet.x <= pointNewE.x) {
                    [self drawNoteLineWithStartPoint:pointNewSet EndPoint:pointNewE isShowMask:NO];
                }
                
            }else{
                
            }
        }
        
    }else if (pan.state == UIGestureRecognizerStateEnded){
        [self showMenu];
    }
    
}

-(void)showMenu
{
    [self becomeFirstResponder];
    if (!menu.menuItems) {
        //菜单栏
        UIMenuItem *copyTest = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyQ:)];
        UIMenuItem *digest = [[UIMenuItem alloc] initWithTitle:@"书摘" action:@selector(digest:)];
        UIMenuItem *notes = [[UIMenuItem alloc] initWithTitle:@"批注" action:@selector(notes:)];
        UIMenuItem *share = [[UIMenuItem alloc] initWithTitle:@"分享" action:@selector(share:)];
        UIMenuItem *searchItem = [[UIMenuItem alloc] initWithTitle:@"查询" action:@selector(searchAction:)];

        [menu setMenuItems:@[copyTest,digest, notes, share, searchItem]];
    }
    if (_starSlider.frame.origin.y > self.frame.size.height - _endSlider.frame.origin.y) {
        [menu setTargetRect:_starSlider.frame inView:self];
    }
    else{
        [menu setTargetRect:_endSlider.frame inView:self];
    }
    
    [menu setMenuVisible:YES animated:YES];
}


- (id)initWithFrame:(CGRect)frame layouter:(OWCoreTextLayouter *)layouter
{
    if ((self = [super initWithFrame:frame])) {
        _layouter = layouter;
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 原来重载的方法
- (void)resetLayouter:(OWCoreTextLayouter *)layouter
{
    _layouter = layouter;
    
    //移除注释
    if (annotations) {
        for (UIView *annotation in annotations) {
            [annotation removeFromSuperview];
        }
        [annotations removeAllObjects];
        annotations = nil;
    }
    
    //移除视频
    if (videos.count > 0) {
        for (VideoBtn *btn in videos) {
            [btn removeFromSuperview];
        }
        [videos removeAllObjects];
        videos = nil;
    }
    
    //移除音频
    if (audios.count > 0) {
        for (VideoBtn *btn in audios) {
            [btn removeFromSuperview];
        }
        [audios removeAllObjects];
        audios = nil;
    }
    
}

- (void)drawPage:(NSInteger)pageNum
{
    _layoutFrame = nil;
    
    if (_isNeedDrawAnimation == NO) {
        [self setAlpha:0];
    }
    else{
        [self setAlpha:1];
        _isNeedDrawAnimation = NO;
    }
    
    if (_layouter == nil) {
        needsDisplay = NO;
    }
    else {
        needsDisplay = YES;
        CGRect frame = CGRectZero;
        frame.size = self.frame.size;
        pageInfo = [_layouter getPageInfo:pageNum];
        
        //这里传出pageInfo给CTRL
        [delegate pageContentLoadComplete:pageInfo];
        
        _layoutFrame = [[OWCoreTextLayoutFrame alloc] initWithFrame:frame andPageInfo:pageInfo];
        _layoutFrame.edgeInsets = self.edgeInsets;
        _layoutFrame.pageView = self;
        
        //先计算一页内含有多少个文字的Rect并设置全局变量 每次更新后重新计算赋值
        
        if (allRunRect) {
            
            [allRunRect removeAllObjects];
            
        }else{
            
            allRunRect = [[NSMutableArray alloc]init];
            
        }
        
        for (OWCoreTextLayoutLine *line in pageInfo.lines) {
            
            NSArray *runs = [line glyphRunsWithRange:[line stringRange]];
            
            for (OWCoreTextGlyphRun *run in runs) {
                
                for (NSInteger i = 0 ; i < run.numberOfGlyphs ; i++) {
                    
                    CGRect oneRect = [run frameOfGlyphAtIndex:i];
                    
                    [allRunRect addObject:[NSValue valueWithCGRect:oneRect]];
                }
            }
        }
        
        //把所有文字Rect 以及边距传给绘制层
        [_rectView setAllRunRect:allRunRect withEdgeInsets:_edgeInsets];
        
    }
    
    [self setNeedsDisplay];
    
    if(needsDisplay){
        
        [UIView animateWithDuration:0.25 animations:^{
            [self setAlpha:1];
        }];
        
    }
    
}

//绘制注释标记
-(void)drawAnnotation
{
    if (![NSThread isMainThread]) {
        [NSThread mainThread];
    }
    
    annotations = [[NSMutableArray alloc]init];
    videos = [[NSMutableArray alloc]init];
    audios = [[NSMutableArray alloc]init];
    
    for (OWTextAttachment *attachment in _layoutFrame.textAttachments) {
        
        //注释
        if (attachment.contentType == OWTextAttachmentTypeAnnotation) {
            
            CGRect frame = CGRectMake(0, 0, 44, 34);
            OWAnnotationButton *annotationBT = [[OWAnnotationButton alloc]initWithFrame:frame content:attachment.contents];
            annotationBT.layouter = _layouter;
            [annotationBT setCenter:CGPointMake(attachment.positionCenter.x + self.edgeInsets.left, attachment.positionCenter.y + self.edgeInsets.top)];
            [self addSubview:annotationBT];
            [annotations addObject:annotationBT];
        };
        
//        //视频   attachment.contents 路径
        if (attachment.contentType == OWTextAttachmentTypeVideoURL) {
            
            CGFloat w = self.frame.size.width - self.edgeInsets.left - self.edgeInsets.right;
            
            VideoBtn *btn;
            
            if (isPad) {
                btn = [[VideoBtn alloc]initWithFrame:CGRectMake(0, 0, w/2, w*3/4/2) withOWTextAttachment:attachment];
            }else{
                btn = [[VideoBtn alloc]initWithFrame:CGRectMake(0, 0, w, w*3/4) withOWTextAttachment:attachment];
            }
            
            btn.delegate = self;
            btn.center = CGPointMake(appWidth/2, attachment.positionCenter.y+_edgeInsets.top);
            
            [self addSubview:btn];
            
            [videos addObject:btn];
            
        }
        
        if (attachment.contentType == OWTextAttachmentTypeAudioURL) {
            
            CGFloat w = self.frame.size.width - self.edgeInsets.left - self.edgeInsets.right;
            
            VideoBtn *btn;
            
            if (isPad) {
                btn = [[VideoBtn alloc]initWithFrame:CGRectMake(0, 0, w/2, w*3/4/2) withOWTextAttachmentAudio:attachment];
            }else{
                btn = [[VideoBtn alloc]initWithFrame:CGRectMake(0, 0, w, w*3/4) withOWTextAttachmentAudio:attachment];
            }
            
            btn.delegate = self;
            btn.center = CGPointMake(appWidth/2, attachment.positionCenter.y+_edgeInsets.top);
            
            if ([[AudioCommon sharedInstance].currentURL isEqual:[NSURL URLWithString:attachment.contents]]) {
                [btn autoPlay];
            }
            
            [self addSubview:btn];
            
            [audios addObject:btn];
        }
        
        
        
    }
    
}



-(void)drawVideoPlayer
{
    
//    if (![NSThread isMainThread]) {
//        [NSThread mainThread];
//    }
//    
//    videos = [[NSMutableArray alloc]init];
//
//    for (OWTextAttachment *attachment in _layoutFrame.textAttachments) {
//        
//        //视频   attachment.contents 路径
//        if (attachment.contentType == OWTextAttachmentTypeVideoURL) {
//            
//            CGFloat w = self.frame.size.width - self.edgeInsets.left - self.edgeInsets.right;
//            
//            ALMoviePlayerController *player = [[ALMoviePlayerController alloc]initWithFrame:CGRectMake(0, 0, w, w*3/4)];
//            player.delegate = self;
//            [player setMySamllTypeCenter:player.view.center];
//            player.view.center = CGPointMake(self.frame.size.width/2, attachment.positionCenter.y + self.edgeInsets.top);
//            
//            
//            ALMoviePlayerControls *movieControls = [[ALMoviePlayerControls alloc] initWithMoviePlayer:player style:ALMoviePlayerControlsStyleDefault];
//            [movieControls setBarColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4]];
//            
//            [player setControls:movieControls];
//            
//            [player setContentURL:[NSURL fileURLWithPath:attachment.contents]];
//            
//            [self addSubview:player.view];
//            
//            [videos addObject:player];
//            
//        }
//        
//    }
    
}




#pragma mark 协议方法
- (void)movieTimedOut {
    NSLog(@"MOVIE TIMED OUT");
}

- (void)moviePlayerWillMoveFromWindow {
    
    for (ALMoviePlayerController *obj in videos) {
        
        [self addSubview:obj.view];
        [obj changeSamllType];
    }
    
}





#pragma mark 单击文字方法
-(RunObject *)findPointIsInDigestRect:(CGPoint)point
{
    
    CGRect rect = [self findEndPointX:point];
    
    BOOL isHaveLine = NO;
    
    
    RunObject *runObj;
    
    if (needDraws.count > 0) {
        
        for (RunObject *obj in needDraws) {
            
            CGRect objRect = [obj.rectValue CGRectValue];
            
            if (objRect.origin.x == rect.origin.x && objRect.origin.y == rect.origin.y) {
                
                isHaveLine = YES;
                
                runObj = obj;
                
                break;
            }
            
        }
    }
    
    return runObj;
}

#pragma mark 单机文字后寻找model的所有位置
-(NSMutableDictionary *)findTouchPointRunObjc:(JRDigestModel *)model
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    NSArray *numbers = model.numbers;
    
    for (RunObject *run in needDraws) {
        
        if (run.number == [[numbers firstObject] longLongValue]) {
            [dic setObject:run forKey:@"starRect"];
        }else if (run.number == [[numbers lastObject] longLongValue]){
            [dic setObject:run forKey:@"endRect"];
        }
    }
    
    return dic;
}



#pragma mark 文字选择前置方法
-(void)drawNoteLineWithStartPoint:(CGPoint)startP EndPoint:(CGPoint)endP isShowMask:(BOOL)isShowMask
{
    //查找第一个字符与结束字符的Rect
    CGRect starRect = [self findStarPointX:startP];
    CGRect endRect = [self findEndPointX:endP];
    
    if (endRect.origin.y > starRect.origin.y) {
        starPoint = starRect.origin;
        endPoint = endRect.origin;
    }
    else if (endRect.origin.y == starRect.origin.y){
        
        if (endRect.origin.x >= endRect.origin.x) {
            starPoint = starRect.origin;
            endPoint = endRect.origin;
        }
        else{
            starPoint = endRect.origin;
            endPoint = starRect.origin;
        }

    }
    else{
        starPoint = endRect.origin;
        endPoint = starRect.origin;
    }
    
        shareStr = [self findSharedStringWithPointA:starRect AndPointB:endRect];
        
        if (isShowMask) {
            
            [_mask showMask];
            
        }
        else{
            
            
        }
    
    [_rectView drawRectChooseWordWithStart:star End:end];
    
    [self showSlider];
//        [self setNeedsDisplay];
}

-(NSString *)findSharedStringWithPointA:(CGRect)startRect AndPointB:(CGRect )endRect
{
    
    NSInteger startP = 0;
    NSInteger endP = 0;
    
    //找寻开始结束在所有文字Rect集合中的位置
    for (NSInteger i = 0 ; i < allRunRect.count; i++) {
        
        NSValue *value = [allRunRect objectAtIndex:i];
        
        CGRect oneRect = [value CGRectValue];
        
        if (startRect.origin.x == oneRect.origin.x && oneRect.origin.y == startRect.origin.y) {
            
            startP = i;
            
            if (startRect.origin.x == endRect.origin.x && startRect.origin.y == endRect.origin.y) {
                endP = i;
            }
            
        }else if (endRect.origin.x == oneRect.origin.x && endRect.origin.y == oneRect.origin.y){
            endP = i;
        }
        
    }
    
    NSInteger differenceNumber = 0;
    
    if (endP > startP) {
        
        star = startP;
        end = endP;
        
    }
    else if (startP == endP)
    {
        
        if (startP != allRunRect.count-1) {
            star = startP;
            end = endP + 1;
        }
        else
        {
            star = end = startP;
        }
    }
    
    differenceNumber = end - star;
    
    if (differenceNumber <= 0) {
        differenceNumber = 1;
    }
    
//    NSLog(@"differenceNumber == %d",differenceNumber);
    
    //提取文字
    NSString *str = [pageInfo.description substringWithRange:NSMakeRange(star,differenceNumber)];
    
//    NSLog(@"baseStr = %@",str);
    
    return str;
}

//找起始点的X坐标
-(CGRect)findStarPointX:(CGPoint)point
{
    
    CGRect startRect = CGRectMake(0, 0, 0, 0);
    
    CGPoint pointNewSet = CGPointMake(point.x - _edgeInsets.left, point.y - _edgeInsets.top);
    
    for (NSValue *value in allRunRect) {
        
        CGRect rect = [value CGRectValue];
        
        BOOL isIn = CGRectContainsPoint(rect, pointNewSet);
        
        if (isIn) {
            
            startRect = rect;
            
        }
        
    }
    
    //如果起始点点为空（比如点到了间距上）
    if (startRect.size.height == 0 && startRect.size.width == 0) {
        
        startRect = [self minSpacingRect:pointNewSet];
    }
    
//    NSLog(@"startRect == %@",NSStringFromCGRect(startRect));

    return startRect;
}

//寻找点击的点最近的Rect
-(CGRect)minSpacingRect:(CGPoint)point
{
    if (!allRunRect || allRunRect.count == 0) {
        return CGRectZero;
    }
    NSMutableArray *lineList = [[NSMutableArray alloc]init];
    
    for (NSValue *value in allRunRect) {
        
        CGRect rect = [value CGRectValue];
        
        double a = (rect.origin.x - point.x);
        double b = (rect.origin.y - point.y);
        
        if (a < 0) {
            a = a*(-1);
        }
        if (b < 0) {
            b = b*(-1);
        }
        
        double result = hypot(a, b);
        
        [lineList addObject:[NSNumber numberWithDouble:result]];
    }
    
    NSNumber * min = [lineList valueForKeyPath:@"@min.doubleValue"];
    
    NSInteger k = 0;
    
    for (NSInteger i = 0; i < lineList.count; i ++) {
        
        NSNumber *number = [lineList objectAtIndex:i];
        
        if ([number doubleValue] == [min doubleValue]) {
            k = i;
            break;
        }
        
    }
    
    NSValue *value = [allRunRect objectAtIndex:k];
    
    return [value CGRectValue];
}


//找结束点的X坐标
-(CGRect)findEndPointX:(CGPoint)point
{
    CGRect endRect = CGRectMake(0, 0, 0, 0);
    
    CGPoint pointNewSet = CGPointMake(point.x - _edgeInsets.left, point.y - _edgeInsets.top);
    
    for (NSValue *value in allRunRect) {
        
        CGRect rect = [value CGRectValue];
        
        BOOL isIn = CGRectContainsPoint(rect, pointNewSet);
        
        if (isIn) {
            
            endRect = rect;
            
        }
        
    }
    
    if (endRect.size.height == 0 && endRect.size.width == 0) {
        
        endRect = [self minSpacingRect:pointNewSet];
        
    }
    
    return endRect;
}

#pragma mark drawRect最后一步绘制完成线条后调用移动拖拽点
-(void)showSlider
{
    
    if (star == 0 && end == 0) {
        return;
    }
    if (!allRunRect || allRunRect.count == 0) {
        return;
    }
    NSValue *startValue = [allRunRect objectAtIndex:star];
    
    CGRect startRect = [startValue CGRectValue];
    
    NSValue *endValue = [allRunRect objectAtIndex:end];
    
    CGRect endRect = [endValue CGRectValue];
    
    _starSlider.frame = CGRectMake(startRect.origin.x + _edgeInsets.left - startRect.size.height/2/2*1.5f,
                                   startRect.origin.y + _edgeInsets.top -startRect.size.height/2,
                                   startRect.size.height/2*1.5f,
                                   startRect.size.height*1.5f);
    _starSlider.hidden = NO;
    
    _endSlider.frame = CGRectMake(endRect.origin.x + _edgeInsets.left - startRect.size.height/2/2*1.5f, endRect.origin.y + _edgeInsets.top , endRect.size.height/2*1.5f,endRect.size.height*1.5f);
    _endSlider.hidden = NO;
    
}

//清理文字选择
-(void)clearMaskAndChooseArray
{
    [menu setMenuVisible:NO animated:YES];
    _starSlider.hidden = YES;
    _endSlider.hidden = YES;
    [self clearChooseLine];
//    [self setNeedsDisplay];
}

//清理选中线段
-(void)clearChooseLine
{
    star = 0;
    end = 0;
    [_rectView clearChooseLine];
}

//页面重载后调用该方法重设摘要
-(void)clearDigestArray:(NSMutableArray *)array
{
    
    if (needDraws.count > 0) {
        [needDraws removeAllObjects];
    }
    
    
    //查找本页内的书摘
    
    NSMutableArray *tmpDigest = [[NSMutableArray alloc]init];
    
    if (array.count > 0 && pageInfo.location >= 0)
    {
        
        for (JRDigestModel *model in array)
        {
            
            for (NSNumber *number in model.numbers)
            {
                
                if ([number longValue] - pageInfo.location >= 0 && [number longValue] - pageInfo.location <= allRunRect.count-1)
                {
                    
                    RunObject *runObj = [[RunObject alloc]init];
                    
                    runObj.color = model.lineColor;
                    
                    runObj.rectValue = [allRunRect objectAtIndex:[number longValue] - pageInfo.location];
                    
                    runObj.number = [number longValue];
                    
                    runObj.sharedString = model.summary;
                    
                    [needDraws addObject:runObj];
                    
                    
                    BOOL isHave = [tmpDigest containsObject:model];
                    
                    if (!isHave) {
                        [tmpDigest addObject:model];
                    }
                    
                }
            }
        }
    }
    
    [self setAnimationBtn:tmpDigest];
    
    [_mask hiddenMeQ];
    
    if (needDraws > 0) {
//        [self setNeedsDisplay];
        [_rectView drawBookDigest:needDraws];
        
    }else{
        return;
    }
}

#pragma mark 添加含有注释的书摘按钮
-(void)setAnimationBtn:(NSMutableArray *)array
{
    
    if (digestNoteBtns.count > 0) {
        
        for (OWAnnotationButton *obj in digestNoteBtns) {
            [obj removeFromSuperview];
        }
        
        [digestNoteBtns removeAllObjects];
    }
    
    if (array.count == 0) {
        return;
    }
    
    for (JRDigestModel *model in array) {
        
        if (model.digestNote != nil) {
            
            NSArray *tmp = model.numbers;
            
            if (([[tmp firstObject] integerValue] >= pageInfo.location && [[tmp lastObject] integerValue] <= pageInfo.location + allRunRect.count-1 ) || ([[tmp firstObject] integerValue] < pageInfo.location && [[tmp lastObject] integerValue] <= pageInfo.location + allRunRect.count-1)) {
                
                NSInteger index = [[tmp lastObject] integerValue] - pageInfo.location;
                
                NSValue *value = [allRunRect objectAtIndex:index];
                
                CGRect tmpRect = [value CGRectValue];
                
                CGRect rect = CGRectMake(tmpRect.origin.x + tmpRect.size.width + _edgeInsets.left, tmpRect.origin.y + tmpRect.size.height + _edgeInsets.top, 43, 44);
                
                OWAnnotationButton *annotationBT = [[OWAnnotationButton alloc]initWithFrame:rect withDigestNoteContent:model.digestNote];
                
                annotationBT.center = CGPointMake(tmpRect.origin.x + tmpRect.size.width + _edgeInsets.left, tmpRect.origin.y + tmpRect.size.height + _edgeInsets.top+3);
                
                annotationBT.layouter = _layouter;
                [self addSubview:annotationBT];
                [digestNoteBtns addObject:annotationBT];
                
            }
            else if ([[tmp firstObject] integerValue] > pageInfo.location && [[tmp firstObject] integerValue] < pageInfo.location + allRunRect.count -1 && [[tmp lastObject] integerValue] > pageInfo.location + allRunRect.count-1)
            {
                
                NSValue *value = [allRunRect lastObject];
                
                CGRect tmpRect = [value CGRectValue];
                
                CGRect rect = CGRectMake(tmpRect.origin.x + tmpRect.size.width + _edgeInsets.left, tmpRect.origin.y + tmpRect.size.height + _edgeInsets.top, 40, 40);
                
                OWAnnotationButton *annotationBT = [[OWAnnotationButton alloc]initWithFrame:rect withDigestNoteContent:model.digestNote];
                
                annotationBT.center = CGPointMake(tmpRect.origin.x + tmpRect.size.width + _edgeInsets.left, tmpRect.origin.y + tmpRect.size.height + _edgeInsets.top+3);
                
                annotationBT.layouter = _layouter;
                [self addSubview:annotationBT];
                [digestNoteBtns addObject:annotationBT];
            }
            
        }
        
    }
    
}



#pragma mark 绘制方法重写的drawRect方法
- (void)drawRect:(CGRect)rect
{
    if(needsDisplay){
       	CGContextRef context = UIGraphicsGetCurrentContext();
        [_layoutFrame drawInContext:context drawImages:YES];
    }
}

#pragma mark 视频按钮点击代理方法
-(void)goToVideoCtrl:(VideoBtn *)btn
{
    
    if ([self.delegate respondsToSelector:@selector(btnActionIntoVideo:)]) {
        [self.delegate btnActionIntoVideo:btn];
    }
    
}

#pragma mark 音频播放代理
-(void)audioBeginPlayAction:(VideoBtn *)btn
{
    NSURL *url = [NSURL URLWithString:btn.attachment.contents];
    
    [AudioCommon sharedInstance].currentURL = url;
    
     [[NSNotificationCenter defaultCenter] postNotificationName:@"AddAudio" object:nil];
    
//    if ([self.delegate respondsToSelector:@selector(addAideoToPlay:)]) {
//        [self.delegate addAideoToPlay:btn];
//    }
    
}

-(void)audioEndPlayAction:(VideoBtn *)btn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeAudio" object:nil];
}

-(void)stopBtnAnimation
{
    if (audios && audios.count > 0) {
        for (VideoBtn *btn in audios) {
            [btn stopAnimation];
        }
    }
}


//-(void)recoveryOfAnimation:(NSNotification *)notification
//{
//    
//    NSArray *arr = self.subviews;
//    
//    for (UIView *view in arr) {
//        
//        if ([[view class] isSubclassOfClass:[VideoBtn class]]) {
//            
//            VideoBtn *btn = (VideoBtn *)view;
//            
//            if ([[AudioCommon sharedInstance].currentURL isEqual:[NSURL URLWithString:btn.attachment.contents]]) {
//                [btn autoPlay];
//            }
//
//        }
//        
//    }
//
//}



@end
