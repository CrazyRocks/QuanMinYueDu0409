//
//  OWCoreTextTableCellData.h
//  OWUIKit
//
//  Created by  iMac001 on 13-2-1.
//  Copyright (c) 2013年 OOWWWW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OWCoreTextTableCellData : NSObject

@property(nonatomic,retain)NSAttributedString *attributedString;
@property(nonatomic,retain)NSArray            *textLines;

@property(nonatomic,assign)CGRect             itemFrame;
@property(nonatomic,assign)float              itemHeight;

@end
