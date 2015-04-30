//
//  SearchCell.m
//  LYBookStore
//
//  Created by grenlight on 14/10/30.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import "SearchCell.h"
#import <OWKit/OWColor.h>

@implementation SearchCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    [self setup];
}

-(void)setup
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self setEditingAccessoryType:UITableViewCellAccessoryNone];
    
    self.backgroundColor = [UIColor clearColor];
    
    _line.backgroundColor = [OWColor colorWithHexString:@"#3A3C3A"];
    
}

-(void)setCellViewContent
{
    if (self.model == nil) {
        return;
    }
    
    _catLab.text = _model.cName;
    
    NSMutableAttributedString *attributedStr01 = [[NSMutableAttributedString alloc] initWithString: _model.baseString];
    
    [attributedStr01 addAttribute: NSForegroundColorAttributeName value:[OWColor colorWithHexString:@"A93523"] range: NSMakeRange(0, _model.searchString.length)];
    
    _contentLab.attributedText = attributedStr01;
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
