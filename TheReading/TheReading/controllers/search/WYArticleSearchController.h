//
//  WYArticleSearchController.h
//  PublicLibrary
//
//  Created by grenlight on 14-3-8.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <OWKit/OWKit.h>

@interface WYArticleSearchController : OWViewController<UITextFieldDelegate>
{
    __weak IBOutlet UIButton       *searchBT;
    
    __weak IBOutlet UIView         *searchBar;
}
@property (nonatomic, weak) IBOutlet UITextField    *searchField;

- (IBAction)searchButtonTapped:(id)sender;
@end
