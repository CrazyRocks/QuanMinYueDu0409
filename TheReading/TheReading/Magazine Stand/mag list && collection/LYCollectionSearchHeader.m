//
//  LYMagCollectionHeader.m
//  LYMagazinesStand
//
//  Created by grenlight on 14-5-23.
//  Copyright (c) 2014年 OOWWWW. All rights reserved.
//

#import "LYCollectionSearchHeader.h"
#import "MagSearchResultController.h"

@implementation LYCollectionSearchHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)tapped:(id)sender
{
    searchButton.enabled = NO;
    MagSearchResultController *searchController = [[MagSearchResultController alloc] init];
    searchController.searchType = self.searchType;
    
    UINavigationController *searchNavController = [[UINavigationController alloc] initWithRootViewController:searchController];
    searchNavController.navigationBarHidden = YES;
    
    OWViewController *controller = [[OWViewController alloc] init];
    [controller addChildViewController:searchNavController];
    [controller.view addSubview:searchNavController.view];
    
    [[OWNavigationController sharedInstance]
     pushViewController:controller animationType:owNavAnimationTypeSlideFromBottom];
    [self performSelector:@selector(enableSearch) withObject:nil afterDelay:0.3];
}

- (void)enableSearch
{
    searchButton.enabled = YES;
}

@end
