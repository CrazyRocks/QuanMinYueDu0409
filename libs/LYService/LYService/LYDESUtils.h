//
//  LYDESUtils.h
//  LYService
//
//  Created by grenlight on 12/3/14.
//  Copyright (c) 2014 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYDESUtils : NSObject

+ (LYDESUtils *)sharedInstance;

- (NSString *)encryptString:(NSString *)inputStr;

- (void)encryptFile:(NSString *)inputPath;

@end
