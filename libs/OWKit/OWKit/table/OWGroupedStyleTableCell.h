//
//  OWGroupedStyleTableCell.h
//  KWFBooks
//
//  Created by gren light on 13-3-25.
//
//

#import <UIKit/UIKit.h>
#import "OWCellBackgroundView.h"

@interface OWGroupedStyleTableCell : UITableViewCell

- (void)initBackgroundView;
- (void)renderStyleByTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end
