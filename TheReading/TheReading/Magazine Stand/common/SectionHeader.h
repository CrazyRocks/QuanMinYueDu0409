//
//  SectionHeader.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-11-1.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OWKit/OWKit.h>

@interface SectionHeader : OWGradientBackgroundView
{
    __weak IBOutlet UILabel *titleLabel;
}
-(void)setTitle:(NSString *)title;
@end
