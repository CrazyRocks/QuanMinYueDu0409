//
//  ZYBasicHTTPRequest.h
//  YuanYang
//
//  Created by grenlight on 14/6/21.
//  Copyright (c) 2014年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonNetworkingManager.h"
#import "LYCoreDataDelegate.h"
#import "LYUserEvent.h"

typedef NS_ENUM(NSInteger, OWHTTPRequestStatus){
    owHTTPRequestCompletionState,//请求已完成
    owHTTPRequestRequestingState,//请求进行中
    owHTTPRequestFaultState//请求出错了
};

@interface OWBasicHTTPRequest : NSObject
{
    LYCoreDataDelegate *cdd;
    
    OWHTTPRequestStatus requestStatus;
    
    AFHTTPRequestOperation  *httpRequest;
    GLHttpRequstResult completionBlock;
    GLHttpRequstFault  faultBlock;
}

- (void)cancelRequest;

@end
