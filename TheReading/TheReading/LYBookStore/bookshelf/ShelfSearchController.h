//
//  ShelfSearchController.h
//  LYBookStore
//
//  Created by grenlight on 14/8/25.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShelfSearchDelegate <NSObject>

@optional
- (void)shelfFilterButtonTapped;
- (void)shelfSearchedByKey:(NSString *)key;

@end

@interface ShelfSearchController : UIViewController<UITextFieldDelegate>
{
    __weak IBOutlet UITextField *searchField;
    
    CADisplayLink *displayLink;
}

@property (nonatomic, assign) id<ShelfSearchDelegate> delegate;

- (IBAction)filterButtonTapped:(id)sender;

- (void)quitSearch;

@end


