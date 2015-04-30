//
//  LYUpdateManager.h
//  GoodSui
//
//  Created by grenlight on 13-12-17.
//  Copyright (c) 2013年 grenlight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LYUpdateManager : NSObject<UIAlertViewDelegate>
{
    NSString *updateURL;
}
+(LYUpdateManager *)sharedInstance;

-(void)checkUpdate:(NSString *)appID
          complete:(void(^)())completion
             fault:(void(^)())fault;

@end
