//
//  GLPhotoController.m
//  DragonSourceEPUB
//
//  Created by iMac001 on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GLPhotoController.h"

@interface GLPhotoView : UIView {
@private
    UIView *bg;
    UIView *pageView;
    CGPoint homeCenter, schoolCenter;
    CGRect  schoolFrame; 
}
@property(nonatomic,assign)CGRect homeFrame;
@property(nonatomic,retain)UIView *image;
@property(nonatomic,retain)id delegate;
@end

@implementation GLPhotoView

@synthesize delegate, image, homeFrame;

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
    }
    return self;
}

-(void)initContent
{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    self.hidden = YES;
    bg = [[UIView alloc]initWithFrame:self.frame];
    bg.backgroundColor =  [UIColor colorWithWhite:0 alpha:1];
    bg.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self addSubview:bg];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"PageImageToFullScreen" object:Nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        
        self.hidden = NO;
        image = [note.userInfo objectForKey:@"image"];
        pageView = [note.userInfo objectForKey:@"pageView"];
        bg.alpha = 0;
        homeCenter = image.center;
        homeFrame = image.frame;
        schoolCenter = [pageView convertPoint:homeCenter toView:self];
        [image setCenter:schoolCenter];
        image.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        [self addSubview:image];
        schoolFrame = image.frame;

        [UIView commitAnimations];
        [UIView animateWithDuration:0.4f animations:^{
            [image setFrame:[UIScreen mainScreen].bounds];
            [bg setAlpha:1];
        } completion:^(BOOL finished) {
            [delegate performSelector:@selector(beginObserverOrientationChange)];

        }];
    } ];
}

-(void)onFullScreen{
    [delegate performSelector:@selector(beginObserverOrientationChange)];

}

-(void)onTap:(id)sender{
    [delegate performSelector:@selector(removeObserverOrientationChange)];
    image.autoresizingMask = UIViewAutoresizingNone;
    [UIView animateWithDuration:0.4f animations:^{
        [bg setAlpha:0];
        [image setFrame:schoolFrame];
    } completion:^(BOOL finished) {
        [image setFrame:homeFrame];
        [pageView addSubview:image];
        [image performSelector:@selector(addTapGesture)];
        self.hidden = YES;
        self.transform = CGAffineTransformIdentity;
    }];
}

@end


@implementation GLPhotoController

- (id)init
{
    self = [super init];
    if (self) {
        rootView = [[GLPhotoView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        [rootView setDelegate:self];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]init];
        singleTap.numberOfTapsRequired = 1;
        [singleTap addTarget:rootView action:@selector(onTap:)];
        [rootView addGestureRecognizer:singleTap];

        self.view = rootView;
        currentFrame = [UIScreen mainScreen].bounds;
        portraitFrame = CGRectZero;
        portraitFrame.size = currentFrame.size;
        landscapeFrame = CGRectZero;
        landscapeFrame.size = currentFrame.size;
//        landscapeFrame.size = CGSizeMake(currentFrame.size.height, currentFrame.size.width) ;
    }
    return self;
}

-(void)beginObserverOrientationChange{
    
    UIDevice *device = [UIDevice currentDevice];
    //将视图初始化到当前方位
    [self performSelector:@selector(initOrientation)];
    
	[[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(orientationChanged:)
												 name: UIDeviceOrientationDidChangeNotification
											   object: device];
}

-(void)removeObserverOrientationChange{
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object: nil];
    //当关闭大图查看模式时,如果设备不是正向方位,需要将视图旋转到正向方位
    closingFullScreen = YES;
    [self executeOrientationChange:UIDeviceOrientationPortrait];
}

- (void) viewWillDisappear: (BOOL) animated
{
    [super viewWillDisappear: animated];
    [self removeObserverOrientationChange];
}
//当用户不是正向拿着设备点击看大图片时将视图初始化到当前方位
-(void)initOrientation{
    closingFullScreen = NO;
    currentOrientation = UIDeviceOrientationPortrait;
    [self executeOrientationChange:[UIDevice currentDevice].orientation];
}

- (void) orientationChanged: (NSNotification *) note
{	
	UIDeviceOrientation orientation = [[note object] integerValue];
	[self executeOrientationChange:orientation];
    
}

-(void)executeOrientationChange:(UIDeviceOrientation)orientation{
    if ( currentOrientation == orientation )	return;
	
	CGFloat angle = 0.0;
	switch (currentOrientation)
	{
		case UIDeviceOrientationPortrait:
		{
			switch ( orientation )
			{
				case UIDeviceOrientationPortraitUpsideDown:
                    currentFrame = portraitFrame;
					angle = (CGFloat)M_PI;	// 180.0*M_PI/180.0 == M_PI
					break;
				case UIDeviceOrientationLandscapeLeft:
                    currentFrame = landscapeFrame;
					angle = (CGFloat)M_PI/2.0;
					break;
				case UIDeviceOrientationLandscapeRight:
                    currentFrame = landscapeFrame;
					angle = (CGFloat)-M_PI/2.0;
					break;
				default:
					return;
			}
			break;
		}
		case UIDeviceOrientationPortraitUpsideDown:
		{
			switch ( orientation )
			{
				case UIDeviceOrientationPortrait:
                    currentFrame = portraitFrame;                    
                    angle = (CGFloat)M_PI;	// 180.0*M_PI/180.0 == M_PI
					break;
				case UIDeviceOrientationLandscapeLeft:
                    currentFrame = landscapeFrame;
					angle = (CGFloat)-M_PI/2.0;
					break;
				case UIDeviceOrientationLandscapeRight:
					currentFrame = landscapeFrame;
					angle = (CGFloat)M_PI/2.0;
					break;
				default:
					return;
			}
			break;
		}
		case UIDeviceOrientationLandscapeLeft:
		{
			switch ( orientation )
			{
				case UIDeviceOrientationLandscapeRight:
					currentFrame = landscapeFrame;
					angle = (CGFloat)M_PI;	// 180.0*M_PI/180.0 == M_PI
					break;
				case UIDeviceOrientationPortraitUpsideDown:
                    currentFrame = portraitFrame;
                    angle = (CGFloat)M_PI/2.0;
					break;
				case UIDeviceOrientationPortrait:
					currentFrame = portraitFrame;
                    angle = (CGFloat)-M_PI/2.0;
					break;
				default:
					return;
			}
			break;
		}
		case UIDeviceOrientationLandscapeRight:
		{
			switch ( orientation )
			{
				case UIDeviceOrientationLandscapeLeft:
                    currentFrame = landscapeFrame;
                    angle = (CGFloat)-M_PI;	// 180.0*M_PI/180.0 == M_PI
					break;
				case UIDeviceOrientationPortrait:
					currentFrame = portraitFrame;
                    angle = (CGFloat)M_PI/2.0;
					break;
				case UIDeviceOrientationPortraitUpsideDown:
					currentFrame = portraitFrame;
                    angle = (CGFloat)-M_PI/2.0;
					break;
				default:
					return;
			}
			break;
		}
        default:
            return;
	}
    
    if(closingFullScreen){
        currentFrame = rootView.homeFrame;
        closingFullScreen = NO;
    }

	CGAffineTransform rotation = CGAffineTransformMakeRotation( angle );
	
    [UIView animateWithDuration:0.4 animations:^{
        rootView.image.transform = CGAffineTransformConcat(rotation, rootView.image.transform);
        [rootView.image.layer setFrame:currentFrame]; 
    } completion:^(BOOL finished) {
        currentOrientation = orientation; 
    }];

}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end
