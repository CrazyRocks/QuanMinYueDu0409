//
//  NextChapterIndicator.h
//  KWFBooks
//
//  Created by gren light on 13-3-24.
//
//

#import <UIKit/UIKit.h>

@interface NextChapterIndicator : UIView
{
    @private
    CGPoint homeCenter, schoolCenter;
    
}
@property (nonatomic, weak) IBOutlet UILabel *label;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)goHome;
- (void)goToSchool;

@end
