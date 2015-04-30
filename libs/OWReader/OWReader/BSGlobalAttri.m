

#import "BSGlobalAttri.h"
#import "Catalogue.h"
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>

@implementation BSGlobalAttri

static BSGlobalAttri *sharedInstance = nil;
@synthesize lyFont, cacheDirectory;
@synthesize catFont;
@synthesize imageEdgeY;
@synthesize fontScale, textRect, pageCount, currentPage, currentCatalogue, frameRange;

- (id)init
{
    self = [super init];
    
    if(self != nil){
        /* Do NOT allocate/initialize other objects here
         that might use the MyWorld's sharedInstance as
         that will create an infinite loop */ 
    }
    return(self);
}

- (void) initializeSharedInstance
{
    imageEdgeY = 10;
//    lyFont = @"SimSun";
//    lyFont = @"Hiragino Kaku Gothic ProN";
//    lyFont = @"Times New Roman";
//    lyFont = @"Hiragino Mincho ProN";
    lyFont = @"FZLTXHK--GBK1-0";
    
    catFont = [UIFont fontWithName:lyFont size:16];
    
    fontScale = gFontScale_Large;
    frameRange.startPoint = 0;
    frameRange.endPoint = 0;

    if (isPad) {
        self.textInsets = UIEdgeInsetsMake(55, 35, 40, 35);
    }
    else {
        self.textInsets = UIEdgeInsetsMake(45, 21, 30, 21);
    }
    textRect = CGRectMake(self.textInsets.left, self.textInsets.top, appWidth-(self.textInsets.left + self.textInsets.right), appHeight-(self.textInsets.top+self.textInsets.bottom));
        
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    cacheDirectory = [paths[0] stringByAppendingPathComponent:@"sinaHead"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&error];
        error = nil;
    }
    
}

+ (BSGlobalAttri *) sharedInstance
{
    @synchronized(self){
        if (sharedInstance == nil){
            sharedInstance = [[BSGlobalAttri alloc] init];
            [sharedInstance initializeSharedInstance];
        }
        return(sharedInstance);
    }
}


@end
