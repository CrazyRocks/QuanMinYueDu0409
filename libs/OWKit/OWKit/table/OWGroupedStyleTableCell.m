//
//  OWGroupedStyleTableCell.m
//  KWFBooks
//
//  Created by gren light on 13-3-25.
//
//

#import "OWGroupedStyleTableCell.h"

@implementation OWGroupedStyleTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initBackgroundView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initBackgroundView];
}

- (void)initBackgroundView
{
    OWCellBackgroundView *bg = [[OWCellBackgroundView alloc] init];
    OWCellBackgroundView *selectedBg = [[OWCellBackgroundView alloc] init];

    bg.borderColor = bg.splitColor =
    selectedBg.splitColor = selectedBg.borderColor = @"#E9E9E3";
    bg.fillColor = @"#ffffff";
    bg.cornerRadius = selectedBg.cornerRadius = 0;
    bg.paddingLeft = selectedBg.paddingLeft = 12;
    bg.glowRadius = selectedBg.glowRadius = 0;
    
    selectedBg.fillColor = @"#11000000";
    selectedBg.isSelectedBackgroundView = YES;
    
    self.backgroundView = bg;
    self.selectedBackgroundView = selectedBg;
}

- (void)renderStyleByTable:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    NSInteger numRows = [tableView numberOfRowsInSection:indexPath.section];
    OWCellBackgroundView *bgView = (OWCellBackgroundView *)self.backgroundView;
    OWCellBackgroundView *selectedBgView = (OWCellBackgroundView *)self.selectedBackgroundView;

    if (indexPath.row == 0 && indexPath.row == numRows - 1) {
        bgView.position = selectedBgView.position = OWCellBackgroundViewPositionSingle;
    }
    else if (indexPath.row == 0) {
        bgView.position = selectedBgView.position = OWCellBackgroundViewPositionTop;
    }
    else if (indexPath.row != numRows - 1) {
        bgView.position = selectedBgView.position = OWCellBackgroundViewPositionMiddle;
    }
    else {
        bgView.position = selectedBgView.position = OWCellBackgroundViewPositionBottom;
    }
    
    [bgView setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
