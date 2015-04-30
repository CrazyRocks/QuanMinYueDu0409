//
//  TouchReader.h
//  SimplerMaskTest
//

#import <UIKit/UIKit.h>
#import "MagnifierView.h"

#import "LineView.h"

@interface TouchReader : UIView <UIGestureRecognizerDelegate>{
    
	NSTimer *touchTimer;
	MagnifierView *loop;
    
}
@property BOOL isLine;
@property (nonatomic, retain) LineView *line;
@property (nonatomic ,retain) UILongPressGestureRecognizer *press;

@property (nonatomic, retain) NSTimer *touchTimer;
@property BOOL isDown;

@property BOOL isCurrent;

- (void)addLoop;
- (void)handleAction:(id)timerObj;

-(id)initWithFrame:(CGRect)frame;


-(void)addLoop:(CGPoint )point;

-(void)moveLoop:(CGPoint )point;

-(void)removeLoop:(CGPoint )point;

@end
