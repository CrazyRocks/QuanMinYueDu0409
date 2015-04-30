//
//  UnitSelectionController.h
//  TheReading
//
//  Created by grenlight on 15/1/6.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnitSelectionController : OWCommonTableViewController
{
    IBOutlet UIView *sectionHeader;
}
@property (nonatomic, strong) NSArray *units;
@property (nonatomic, copy) GLNoneParamBlock loginCompleteBlock;

@end
