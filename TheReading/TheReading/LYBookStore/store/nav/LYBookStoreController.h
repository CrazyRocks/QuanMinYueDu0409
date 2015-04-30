//
//  LYBookStoreController.h
//  LYBookStore
//
//  Created by grenlight on 14-5-6.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import <OWKit/OWKit.h>
#import <LYService/LYMenuData.h>

@interface LYBookStoreController : XibAdaptToScreenController
{
    NSArray *bookCategories;
    IBOutlet OWBundleButton   *backButton;
    
}
@property (nonatomic, copy) ReturnMethod returnToPreController;
@property (nonatomic, strong) LYMenuData *menu;

- (void)setBackButtonImage:(UIImage *)img;


@end
