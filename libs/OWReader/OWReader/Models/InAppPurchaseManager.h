//
//  InAppPurchaseManager.h
//  GeneralTester
//
//  Created by huoju on 7/15/13.
//  Copyright (c) 2013 TBA Digital. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@protocol PurchaseManagerDelegate;

@interface InAppPurchaseManager : NSObject  <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
  SKProduct *proUpgradeProduct;
  SKProductsRequest *productsRequest;
}
@property (nonatomic, assign) id<PurchaseManagerDelegate> delegate;

+ (InAppPurchaseManager *)sharedInstance;

- (void)requestProUpgradeProductData:(NSString*)identifier;
- (void)loadStore:(NSString*)identifier;
- (BOOL)canMakePurchases;
@end

@protocol PurchaseManagerDelegate <NSObject>

@required
- (void)purchaseCompleted;

@end
