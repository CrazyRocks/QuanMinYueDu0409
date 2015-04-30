//
//  SendingProgressController.h
//  KWFBooks
//
//  Created by 龙源 on 13-6-9.
//
//

#import <UIKit/UIKit.h>

@interface SendingProgressController : UIViewController
{
    IBOutlet UILabel     *titleLB;
    IBOutlet UIImageView *thumbView;
}
@property (nonatomic, assign) BOOL sended;

- (void)progressing;
- (void)completed;

@end
