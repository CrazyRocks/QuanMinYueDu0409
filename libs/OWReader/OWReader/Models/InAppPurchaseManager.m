//
//  InAppPurchaseManager.m
//  GeneralTester
//
//  Created by huoju on 7/15/13.
//  Copyright (c) 2013 TBA Digital. All rights reserved.
//

#import "InAppPurchaseManager.h"
#import <OWKit/OWMessageView.h>
#import <LYService/LYService.h> 

@implementation InAppPurchaseManager
@synthesize delegate;

+ (InAppPurchaseManager *)sharedInstance
{
    static InAppPurchaseManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[InAppPurchaseManager alloc] init];
    });
    return instance;
}

- (void)requestProUpgradeProductData:(NSString*)identifier
{
  NSSet *productIdentifiers = [NSSet setWithObject:identifier ];
  productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
  productsRequest.delegate = self;
  [productsRequest start];
  
  // we will release the request object in the delegate callback
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
  
    if (products.count == 0) {
        for (NSString *invalidProductId in response.invalidProductIdentifiers) {
            [[OWMessageView sharedInstance] showMessage:@"获取购买信息出错" autoClose:YES];

        }
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    else {
        proUpgradeProduct = products[0];
        if (proUpgradeProduct) {
            [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

            [[OWMessageView sharedInstance] showMessage:@"连接到 iTunes Store ..." autoClose:NO];

            SKPayment * payment = [SKPayment paymentWithProduct:proUpgradeProduct];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
    }
  
}

- (void)loadStore:(NSString*)identifier
{
    if ([CommonNetworkingManager sharedInstance].isReachable) {
        [[OWMessageView sharedInstance] showMessage:@"获取书的购买信息…..." autoClose:NO];
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [self requestProUpgradeProductData:identifier];
    }
}

- (BOOL)canMakePurchases
{
  return [SKPaymentQueue canMakePayments];
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
//  if ([transaction.payment.productIdentifier isEqualToString:kInAppPurchaseProUpgradeProductId])
//  {
    // save the transaction receipt to disk
    [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey: [transaction.payment.productIdentifier stringByAppendingString:@"_TransactionReceipt" ]];
    [[NSUserDefaults standardUserDefaults] synchronize];
//  }
}

- (void)provideContent:(NSString *)productId
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productId ];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerRedrawTeamViewNotification object:self userInfo:nil];
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
  [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

}


- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
    [[OWMessageView sharedInstance] showMessage:@"购买成功" autoClose:YES];

    if (delegate && [delegate respondsToSelector:@selector(purchaseCompleted)])
        [delegate purchaseCompleted];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];

}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [[OWMessageView sharedInstance] showMessage:@"你已经购买这本书了，可以直接下载." autoClose:YES];
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];

}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
  if (transaction.error.code != SKErrorPaymentCancelled) {
//      NSLog(@"transaction error:%@",transaction.error.description);
      [[OWMessageView sharedInstance] showMessage:@"无法连接到 iTunes Store" autoClose:YES];

    [self finishTransaction:transaction wasSuccessful:NO];
  }
  else {
      [[OWMessageView sharedInstance] showMessage:@"已取消购买" autoClose:YES];

    // this is fine, the user just cancelled, so don’t notify
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
  }
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
  for (SKPaymentTransaction *transaction in transactions) {
    switch (transaction.transactionState){
      case SKPaymentTransactionStatePurchased:
        [self completeTransaction:transaction];
        break;
            
      case SKPaymentTransactionStateFailed:
        [self failedTransaction:transaction];
        break;
            
      case SKPaymentTransactionStateRestored://已经购买过该商品
        [self restoreTransaction:transaction];
        break;
            
    case SKPaymentTransactionStatePurchasing:
            [[OWMessageView sharedInstance] showMessage:@"购买中..." autoClose:NO];
            break;
            
      default:
        break;
    }
  }
}
@end
