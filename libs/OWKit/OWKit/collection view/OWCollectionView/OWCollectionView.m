//
//  OWCollectionView.m
//  PageableAndDraggableCollectionView
//
//  Created by grenlight on 13-11-28.
//  Copyright (c) 2013年 oowwww. All rights reserved.
//

#import "OWCollectionView.h"
#import "OWPagingLayout.h"
#import "OWShakeableCVCell.h"

CGPoint CGPointAdd(CGPoint point1, CGPoint point2)
{
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

@implementation OWCollectionView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    currentPage = 0;
    isPaging = NO;
    isInLongPress = NO;
    
    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handleLongPressGesture:)];
    longPressGestureRecognizer.delegate = self;

    [self addGestureRecognizer:longPressGestureRecognizer];
    
    panPressGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                  initWithTarget:self action:@selector(handlePanGesture:)];
    panPressGestureRecognizer.delegate = self;
    
    [self addGestureRecognizer:panPressGestureRecognizer];
    
    for (UIGestureRecognizer *gestureRecognizer in self.gestureRecognizers) {
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [gestureRecognizer requireGestureRecognizerToFail:longPressGestureRecognizer];
            break;
        }
    }
    [self setDraggable:NO];
}

- (void)setCollectionViewLayout:(UICollectionViewLayout *)collectionViewLayout
{
    [super setCollectionViewLayout:collectionViewLayout];
    layouter = (OWPagingLayout *)collectionViewLayout;
}

- (BOOL)draggable
{
    return _draggable;
}

- (void)setDraggable:(BOOL)draggable
{
    _draggable = draggable;
    longPressGestureRecognizer.enabled = draggable;
    panPressGestureRecognizer.enabled = draggable;
}

#pragma mark gesture action
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateChanged) {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [self indexPathForItemClosestToPoint:[sender locationInView:self]];
        if (!indexPath) {
            return;
        }
        currentPage = self.contentOffset.x/CGRectGetWidth(self.bounds);
        isInLongPress = YES;
        
        layouter.fromIndexPath = indexPath;

        self.scrollEnabled = NO;
        self.pagingEnabled = NO;
        
        UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
        cell.highlighted = NO;
        [mockCell removeFromSuperview];
        mockCell = [[UIImageView alloc] initWithFrame:cell.frame];
        mockCell.image = [self imageFromCell:cell];
        mockCenter = mockCell.center;
        [self addSubview:mockCell];
        [UIView animateWithDuration:0.3
                         animations:^{
                             mockCell.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
                         }
                         completion:nil];
        
        [layouter setHiddenIndexPath:indexPath];
        [layouter invalidateLayout];
        
        [self startShake];
    }
    else {
        isInLongPress = NO;
        if (!layouter.fromIndexPath || !layouter.toIndexPath) {
            [self animateMockCellToCorrectPosition:nil];
            return;
        }
        
        //switch dataSource's item, then move cell.
        [self.owDelegate collectionView:self moveItemAtIndexPath:layouter.fromIndexPath toIndexPath:layouter.toIndexPath];
        [self performBatchUpdates:^{
            [self moveItemAtIndexPath:layouter.fromIndexPath toIndexPath:layouter.toIndexPath];
            layouter.fromIndexPath = nil;
            layouter.toIndexPath = nil;
        } completion:nil];
        
        [self animateMockCellToCorrectPosition:nil];
    }
}

- (void)animateMockCellToCorrectPosition:(void(^)())completionBlock
{
    UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:layouter.hiddenIndexPath];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         mockCell.center = layoutAttributes.center;
                         mockCell.transform = CGAffineTransformMakeScale(1.f, 1.f);
                     }
                     completion:^(BOOL finished) {
                         self.scrollEnabled = YES;
                         self.pagingEnabled = YES;

                         [layouter setHiddenIndexPath:Nil];
                         [layouter invalidateLayout];

                         [self performSelector:@selector(removeMockCell) withObject:Nil afterDelay:0.1];

                         if (completionBlock)
                             completionBlock();
                     }];

}

- (void)removeMockCell
{
    [self stopShake];
    [UIView animateWithDuration:0.3 animations:^{
        [mockCell setAlpha:0.9];
    } completion:^(BOOL finished) {
        [mockCell removeFromSuperview];
        mockCell = nil;
    }];
}

- (NSIndexPath *)indexPathForItemClosestToPoint:(CGPoint)point
{
    NSIndexPath *indexPath;
    
    for (UICollectionViewCell *cell in self.visibleCells) {
        if (CGRectContainsPoint(cell.frame, point)) {
            indexPath = [self indexPathForCell:cell];
            break;
        }
    }
    return indexPath;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateChanged &&
       layouter.fromIndexPath && isInLongPress) {
        CGPoint movePoint = [sender locationInView:self];
        mockCell.center = movePoint;
        
        [self ifNeedsPaging:movePoint];
        
        if (isPaging) return;
        
        NSIndexPath *indexPath = [self indexPathForItemClosestToPoint:movePoint];
        if (indexPath && ![indexPath isEqual:layouter.fromIndexPath]) {
            if (self.owDelegate) {
                [self performBatchUpdates:^{
                    layouter.hiddenIndexPath = indexPath;
                    layouter.toIndexPath = indexPath;
                } completion:^(BOOL finished) {
                    [self startShake];
                }];
            }
        }
    }
}

- (void)ifNeedsPaging:(CGPoint)movePoint
{
    if (isPaging) return;
    
    float distance = self.contentOffset.x-appWidth*currentPage;
    if (distance < 0.1 && distance > (-0.1)) {
        BOOL canPageToNext = (currentPage + 1) < layouter.pageCount;
        BOOL canPageToPre = currentPage > 0;
        
        CGRect bounds = CGRectMake(appWidth*(currentPage + 1) - layouter.itemSize.width/2.0f, 0, layouter.itemSize.width, appHeight);
        if (CGRectContainsPoint(bounds, movePoint) && canPageToNext) {
            [self pagingAnimation:1];

        }
        else if (canPageToPre) {
            bounds.origin.x -= appWidth;
            if (CGRectContainsPoint(bounds, movePoint)) {
                [self pagingAnimation:-1];
            }
        }
    }
}

- (void)pagingAnimation:(int)pageParam
{
    currentPage += pageParam;
    isPaging = YES;
    
    CGRect nextPageRect = CGRectMake(appWidth*currentPage, CGRectGetMinY(self.frame), appWidth, CGRectGetHeight(self.frame));
    [self scrollRectToVisible:nextPageRect animated:YES];
    [self performSelector:@selector(resetPagingParameter) withObject:Nil afterDelay:0.5];
    [self performSelector:@selector(startShake) withObject:Nil afterDelay:0.4];

}

- (void)resetPagingParameter
{
    isPaging = NO;
}

- (UIImage *)imageFromCell:(UICollectionViewCell *)cell
{
    UIGraphicsBeginImageContextWithOptions(cell.bounds.size, cell.isOpaque, 0.0f);
    [cell.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)collectionViewPaged
{
    if (isInLongPress)
        [self startShake];
    else
        [self stopShake];
}

#pragma mark shake
- (void)startShake
{
    for (OWShakeableCVCell *cell in self.visibleCells) {
        [cell startShake];
    }
}

- (void)stopShake
{
    for (OWShakeableCVCell *cell in self.visibleCells) {
        [cell stopShake];
    }
}

#pragma mark gesture delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
//    if ((gestureRecognizer == longPressGestureRecognizer &&
//        otherGestureRecognizer == panPressGestureRecognizer) ||
//        (gestureRecognizer == panPressGestureRecognizer &&
//         otherGestureRecognizer==longPressGestureRecognizer))
//    return YES;
//    
    return YES;
}

@end
