//
//  InAppPurchaseManager.h
//  CatOfTheDay
//
//  Created by Owyn Richen on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>
#import "PremiumContentStore.h"

#define PURCHASE_SUCCESS @"purchase.succeeded"
#define PURCHASE_FAIL @"purchase.failed"

@protocol PurchaseDelegate <NSObject>

-(void) purchaseStarted;
-(void) productsRetrieved: (NSArray *) products;
-(void) purchaseSucceeded: (NSString *) productId;
-(void) purchaseFailed: (NSString *) productId;

@end

@interface InAppPurchaseManager : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver> {
    id<PurchaseDelegate> delegate;
    NSArray *cachedProducts;
    
    NSDate *lastProductIdFetch;
    NSUserDefaults *defaults;
}

+(InAppPurchaseManager *) instance;

-(void) getProducts: (id<PurchaseDelegate>) del;
-(BOOL) canMakePayments;
-(void) purchaseProduct: (SKProduct *) product;
-(void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;

@end
