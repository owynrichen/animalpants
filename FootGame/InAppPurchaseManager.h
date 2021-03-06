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

@protocol ProductRetrievalDelegate <NSObject>

-(void) productRetrievalStarted;
-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data;
-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data;

@end

@protocol PurchaseDelegate <NSObject>

-(void) purchaseStarted;
-(void) purchaseSucceeded: (NSString *) productId;
-(void) purchaseFailed: (NSString *) productId;

@end

@interface InAppPurchaseManager : NSObject<SKProductsRequestDelegate, SKPaymentTransactionObserver, ProductRetrievalDelegate> {
    id<ProductRetrievalDelegate> prodDelegate;
    id<PurchaseDelegate> delegate;
    NSArray *cachedProducts;
    
    NSDate *lastProductIdFetch;
    NSUserDefaults *defaults;
    NSObject *state;
}

+(InAppPurchaseManager *) instance;

-(void) getProducts: (id<ProductRetrievalDelegate>) del;
-(void) getProducts: (id<ProductRetrievalDelegate>) del withData: (NSObject *) obj;
-(void) purchaseProductById: (NSString *) productId delegate: (id<PurchaseDelegate>) del;
-(BOOL) canMakePayments;
-(void) purchaseProduct: (SKProduct *) product delegate: (id<PurchaseDelegate>) del;
-(void) restorePurchases: (id<PurchaseDelegate>) del;

-(void) productRetrievalStarted;
-(void) productsRetrieved: (NSArray *) products withData:(NSObject *)data;
-(void) productsRetrievedFailed: (NSError *) error withData:(NSObject *)data;
-(void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response;
-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;

@end

@interface SKProduct (priceAsString)
@property (nonatomic, readonly) NSString *priceAsString;
+(NSString *) localeFormattedPrice: (NSNumber *) price locale: (NSLocale *) locale;
@end
