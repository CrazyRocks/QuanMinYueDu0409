//
//  BookShelfController.h
//  LogicBook
//
//  Created by 龙源 on 13-10-8.
//
//

#import <UIKit/UIKit.h>
#import <OWKit/OWKit.h>
#import <LYService/LYService.h>
#import "OWBookButton.h"

typedef enum {
    lyBook,
    lyMagazine,
}LYBookType;//书的类型，图书 or 杂志

@class BSCollectionCell;

@interface LYBookShelfController : XibAdaptToScreenController<UICollectionViewDataSource,
UICollectionViewDelegate,
UIAlertViewDelegate> {
    
    __weak IBOutlet UICollectionView   *collectionView;
    __weak IBOutlet UIButton   *messageBT;
    
    BSCollectionCell    *selectedCell, *lastReadCell;
    float           itemHeight;
    
    NSMutableArray *dataSource;
    
    NSString    *filterString;
    NSString    *keyString;
    
    BOOL isEditMode;
    
    UITapGestureRecognizer *tap;
   
}
@property (nonatomic, copy) ReturnMethod returnToPreController;
@property (nonatomic, assign) LYBookType    bookType;

//定制返回动作
- (void)setReturnToPreControllerBlock:(ReturnMethod)returnToPreController;

//隐藏返回按钮
- (void)hideBackButton;

//隐藏顶部导航（在外部controller已包含导航时）
- (void)hideNavigationBar;

- (void)beginEdit;
- (void)endEdit;

- (void)deleteSelectedItem:(BSCollectionCell *)cell;

- (IBAction)completeEdit:(id)sender;

//
- (IBAction)verticalLayout:(id)sender;
- (IBAction)horizontalLayout:(id)sender;
@end
