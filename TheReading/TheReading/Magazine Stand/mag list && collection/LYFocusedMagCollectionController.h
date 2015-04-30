//
//  LYFocusedMagCollectionController.h
//  LYMagazinesStand
//
//  Created by grenlight on 13-12-26.
//  Copyright (c) 2013年 OOWWWW. All rights reserved.
//

#import "MagazineCollectionController.h"

@interface LYFocusedMagCollectionController : MagazineCollectionController<OWShakeableCVCellDelegate>
{
    UIGestureRecognizer *longPressGestureRecognizer;
    
}

- (void)startShake;
- (void)stopShake;

@end
