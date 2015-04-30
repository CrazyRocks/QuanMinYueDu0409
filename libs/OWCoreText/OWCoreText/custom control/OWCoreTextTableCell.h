//
//  OWCoreTextTableCell.h
//  OWUIKit
//
//  Created by  iMac001 on 13-2-1.
//  Copyright (c) 2013年 OOWWWW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OWCoreTextTableCellData.h"

@class OWTiledView;

@interface OWCoreTextTableCell : UITableViewCell
{
    OWTiledView                  *contentView ;
    
    OWCoreTextTableCellData      *_cellData;

}
@property(nonatomic,retain)OWCoreTextTableCellData *cellData;
@property(nonatomic,assign)CGPoint contentViewOffset;

-(void)renderContent;

@end
