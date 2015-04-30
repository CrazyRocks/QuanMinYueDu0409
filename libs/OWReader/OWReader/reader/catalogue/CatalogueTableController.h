//
//  CatelogueTableController.h
//  LogicBook
//
//  Created by iMac001 on 12-2-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CatalogueTableCell.h"
#import "GLLoading.h"
#import <OWKit/OWKit.h> 





@interface CatalogueTableController : OWCommonTableViewController<GLTableCellDelegate>
{
   @private    
    
    CatalogueTableCell *currentCell;
    CGPoint loadingCenter;


}
@property (nonatomic, weak) IBOutlet UIView  *tableFooter;
@property (nonatomic, weak) IBOutlet UIView  *tableHeader;

@property(copy)CatalogueSelectedBlock selectedItemChangedCallBack;
@property(copy)GLBasicBlock scrollCallBack;

-(void)setContentOffset:(CGPoint)offset;





@end
