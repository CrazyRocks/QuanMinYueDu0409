//
//  OWBlockDefine.h
//  OWUIKit
//
//  Created by gren light on 12-7-11.
//  Copyright (c) 2012年 OOWWWW. All rights reserved.
//


typedef void(^CatalogueSelectedBlock)(float,float) ;
typedef void(^GLBasicBlock)(float);
typedef void(^GLNoneParamBlock) ();
typedef void(^GLTableCellBlock)(id) ;
typedef void(^GLParamBlock)(id);

typedef void(^GLHttpRequstResult)(id);
typedef void(^GLHttpRequstMultiResults)(NSArray *, NSInteger);
typedef void(^GLHttpRequstFault)(NSString *) ;

typedef NSString *(^RefreshKey)() ;

typedef void(^ReturnMethod)() ;

typedef void(^DrawLayerBlock)(CGContextRef);


@interface OWBlockDefine : NSObject

@end
