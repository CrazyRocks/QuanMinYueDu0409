//
//  WYMainMenuController.h
//  PublicLibrary
//
//  Created by grenlight on 14-1-24.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GlobalManager.h"
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import "WYContentCanvasController.h"

@interface WYMainMenuController : OWCommonTableViewController
{
    BOOL    needShowHomePage;
    __weak IBOutlet UIImageView *bgView;
    __weak IBOutlet UIButton    *accountButton;
    
}
@property (nonatomic, weak) WYContentCanvasController *contentCanvasController;

- (void)intoLeft;
- (void)outLeft;

- (IBAction)intoAccount:(id)sender;

@end
