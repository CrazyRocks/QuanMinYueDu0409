//
//  ModelTransformationTool.h
//  LYBookStore
//
//  Created by grenlight on 14-10-15.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookDigest.h"
#import <OWCoreText/JRDigestModel.h>
#import "BookDigestNetModel.h"
#import "BookMarkNetModel.h"
#import "MyBooksManager.h"

@interface ModelTransformationTool : NSObject

//转换成OWCoreText使用的对象
+(JRDigestModel *)coreDataTransformationUseModel:(BookDigest *)bookDigest;


+(BookDigestNetModel *)changeInfoToBookDigestNetModel:(NSDictionary *)info;


+(BookMarkNetModel *)changeInfoToBookMarkNetModel:(NSDictionary *)info;

@end
