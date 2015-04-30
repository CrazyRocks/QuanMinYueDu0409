//
//  TouchReader.m
//  SimplerMaskTest
//

#import "TouchReader.h"
#import "MagnifierView.h"

@implementation TouchReader

@synthesize touchTimer;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        [self setup];
        
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
    }
    
    return self;
}

-(void)awakeFromNib
{
    [self setup];
}

-(void)setup
{
    self.userInteractionEnabled = YES;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addLoop:) name:@"add" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveLoop:) name:@"move" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLoop:) name:@"remove" object:nil];
}

-(void)addLoop:(CGPoint )point
{
        
        if(loop == nil){
            loop = [[MagnifierView alloc] init];
            loop.viewToMagnify = self;
        }
        
        [self.superview addSubview:loop];
        
        loop.hidden = NO;
        loop.touchPoint = point;
        NSLog(@"%@",NSStringFromCGPoint(point));
        [loop setNeedsDisplay];
}

-(void)moveLoop:(CGPoint )point
{
    loop.touchPoint = point;
    [loop setNeedsDisplay];
}

-(void)removeLoop:(CGPoint )point
{
    [loop removeFromSuperview];
}

@end
