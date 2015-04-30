//
//  MagCVCell.m
//  PublicLibrary
//
//  Created by grenlight on 13-12-4.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import "MagCVCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation MagCVCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setFrame:CGRectMake(-22, -22, 64, 64)];
    [deleteButton setImage:[UIImage imageNamed:@"deleteCollectionItem_bt_normal"] forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton setAlpha:0];
    [self addSubview:deleteButton];
    
    [self.superview.superview bringSubviewToFront:deleteButton];
    
    webImageView.layer.cornerRadius = 0;
    webImageView.layer.borderWidth = 0.5;
    webImageView.layer.borderColor = [OWColor colorWithHex:0xaaaaaa].CGColor;
    webImageView.contentMode = UIViewContentModeScaleAspectFill;
}


- (void)setContent:(LYMagazineTableCellData *)mag
{
    NSString *coverURL ;
    NSArray *coverArr = [mag.cover componentsSeparatedByString:@","];
    if (coverArr) {
        if (coverArr.count > 1 )
            coverURL = coverArr[1];
        else
            coverURL = coverArr[0];
    }
    titleLB.text = mag.magName;
    issueLB.text = [NSString stringWithFormat:@"%@年第%@期",mag.year, mag.issue];
    
    [webImageView setImageWithURL:coverURL];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.alpha = 0.5;
    }
    else {
        self.alpha = 1.f;
    }
}

- (void)startShake
{
    [super startShake];
    [UIView animateWithDuration:0.2 animations:^{
        [deleteButton setAlpha:1];
    }];
}

- (void)stopShake
{
    [super stopShake];
    [UIView animateWithDuration:0.15 animations:^{
        [deleteButton setAlpha:0];
    }];
}

- (void)deleteButtonTapped:(UIButton *)sender
{
    if (self.owDelegate)
        [self.owDelegate shakeView:self delete:sender];
}

- (CGRect)getCoverFrame
{
   return  webImageView.frame;
}

- (UIImage *)getCover
{
    return [OWImage CompositeImage:webImageView];
}
@end
