//
//  SyncManager.h
//  LongYuanYueDu
//
//  Created by  iMac001 on 12-12-20.
//  Copyright (c) 2012年 LONGYUAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OWBasicHTTPRequest.h"

@interface LYSyncManager : OWBasicHTTPRequest
{
    dispatch_queue_t          queue;
    NSMutableString          *titleIDs;
    
    //是否已经同步
    BOOL                      alreadySync;
}
+(LYSyncManager *)sharedInstance;
-(void)startSync;

@end
