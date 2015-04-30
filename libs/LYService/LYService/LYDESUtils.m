//
//  LYDESUtils.m
//  LYService
//
//  Created by grenlight on 12/3/14.
//  Copyright (c) 2014 grenlight. All rights reserved.
//

#import "LYDESUtils.h"
#import <CommonCrypto/CommonCryptor.h>

const char key[] = {83, 90, 37, 105, 167, 94, 125, 19};
const char iv[] = {23, 7, 159, 173, 244, 22, 215, 76 };

@implementation LYDESUtils

+ (LYDESUtils *)sharedInstance
{
    static LYDESUtils *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [LYDESUtils new];
    });
    return instance;
}

- (NSString *)encryptString:(NSString *)inputStr
{
    NSData *textData = [inputStr dataUsingEncoding:NSUTF8StringEncoding];
    NSInteger d = [textData length]%8;
    NSMutableData* cipherData = [NSMutableData dataWithLength:[textData length] + (8-d)];
    
    size_t numBytesEncrypted = 0;
    NSString *encryptedStr;

    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding,
                                          key, kCCKeySizeDES,
                                          iv,
                                          [textData bytes]  , [textData length],
                                          cipherData.mutableBytes, [cipherData length],
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        encryptedStr = [cipherData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    else{
        NSLog(@"--%@--加密失败!", inputStr);
    }
    return encryptedStr;
}


@end
