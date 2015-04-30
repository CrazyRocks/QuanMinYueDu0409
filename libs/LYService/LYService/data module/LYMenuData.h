//
//  LYMenuData.h
//  LYService
//
//  Created by grenlight on 15/1/19.
//  Copyright (c) 2015年 grenlight. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface LYMenuData : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString  *menuName;
@property (nonatomic, copy, readonly) NSString  *menuType;
@property (nonatomic, copy, readonly) NSArray   *menuValue;

//@property (nonatomic, copy, readonly) NSArray   *MenuValue;
//
//@property (nonatomic, copy, readonly) NSString  *MenuCode;
//@property (nonatomic, copy, readonly) NSNumber  *Level;
//@property (nonatomic, copy, readonly) NSString  *ImageUrl;
//@property (nonatomic, copy, readonly) NSString  *ImageDisplayMode;
//@property (nonatomic, copy, readonly) NSNumber  *OpenMode;
//@property (nonatomic, copy, readonly) NSNumber  *OrderNumber;
//@property (nonatomic, copy, readonly) NSArray  *Childs;
//
//@property (nonatomic, copy, readonly) NSString  *ignored0;

@end
