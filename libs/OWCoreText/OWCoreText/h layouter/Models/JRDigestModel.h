//
//  JRDigestModel.h
//  OWCoreText
//
//  Created by grenlight on 14-10-15.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JRDigestModel : NSObject

@property (nonatomic, retain) NSString * range;
@property (nonatomic, retain) NSDate * addDate;
@property (nonatomic, retain) NSString * bookID;
@property (nonatomic, retain) NSNumber * catIndex;
@property (nonatomic, retain) NSString * catName;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * digestNote;
@property (nonatomic, retain) NSNumber * pos;
@property (nonatomic, retain) NSString * lineColor;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSArray *numbers;
@property (nonatomic, retain) NSNumber *noteID;

@end
