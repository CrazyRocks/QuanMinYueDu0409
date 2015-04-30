//
//  CategoryItemView.h
//  DragonSourceReader
//
//  Created by iMac001 on 11-12-13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OWKit/OWKit.h>
#import <LYService/LYGlobalConfig.h>

@class Catalogue;

@protocol GLTableCellDelegate;

@interface CatalogueTableCell : UITableViewCell
{
     __weak IBOutlet OWSplitLineView *splitLine;

    @private
    Catalogue *cat;    
}
@property(nonatomic,assign) id<GLTableCellDelegate> delegate;

-(void)renderContent:(Catalogue *)aCat;

- (CGFloat)requiredRowHeightInTableView:(UITableView *)tableView;

@end

@protocol GLTableCellDelegate <NSObject>

@required
-(void)tableCellSelected:(CatalogueTableCell *)cell;

@end
