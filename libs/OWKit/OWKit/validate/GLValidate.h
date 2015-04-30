//
//  GLValidate.h
//  LogicBook
//
//  Created by iMac001 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLValidate : NSObject

+ (BOOL)isValidateEmail:(NSString *)email;
+ (BOOL)isVAlidateString:(NSString *)str length:(uint)len;
+ (BOOL)isValidateCellPhone:(NSString *)cellPhone;

@end
