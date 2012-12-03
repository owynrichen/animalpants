//
//  InAppPurchaseManager.m
//  CatOfTheDay
//
//  Created by Owyn Richen on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "InAppPurchaseManager.h"

static InAppPurchaseManager *_instance;
static NSString *_sync = @"sync";

@implementation InAppPurchaseManager

+(InAppPurchaseManager *) instance {
    if (_instance == NULL) {
        @synchronized(_sync) {
            if (_instance == NULL) {
                _instance = [[InAppPurchaseManager alloc] init];
            }
        }
    }
    
    return _instance;
}

-(void) getProducts: (id<PurchaseDelegate>)del {
    // TODO: block and unload
    if (delegate)
        delegate = nil;
    
    delegate = del;
    
    if (cachedProducts) {
        if (delegate) {
            [delegate productsRetrieved:cachedProducts];
        }
    } else {
        NSArray *productIds = [[PremiumContentStore instance] products];
        
        NSSet *products = [NSSet setWithArray:productIds];
        SKProductsRequest *req = [[SKProductsRequest alloc] initWithProductIdentifiers:products];
        req.delegate = self;
        
        [req start];
    }
}

-(BOOL) canMakePayments {
    return [SKPaymentQueue canMakePayments];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *products = response.products;
    [response.invalidProductIdentifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"invalid identifier %@", obj);
    }];
    
    SKProduct *product = products.count > 1 ? [products objectAtIndex:0] : nil;
    
    if (product) {
        cachedProducts = [products retain];
        NSLog(@"Name: %@", product.localizedTitle);
        NSLog(@"Price: %@", product.price);
        if (delegate) {
            [delegate productsRetrieved: products];
        }
    } else {
        if (delegate) {
            [delegate purchaseFailed:nil];
        }
        return;
    }
}

-(void) purchaseProduct: (SKProduct *) product {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    [defaults setObject:transaction.payment.requestData forKey:transaction.payment.productIdentifier];
    NSLog(@"Transaction recorded...");
}

//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    NSLog(@"Transaction finished...");
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    if (wasSuccessful)
    {
        [[PremiumContentStore instance] boughtProductId:transaction.payment.productIdentifier];
        if (delegate) {
            [delegate purchaseSucceeded:transaction.payment.productIdentifier];
        }
    }
    else
    {
        // TODO: this blanket approach is probably wrong, we need a better decision mechanism
        // before we "unpurchase" an item in this case
        [[PremiumContentStore instance] returnedProductId:transaction.payment.productIdentifier];
        if (delegate) {
            [delegate purchaseFailed:transaction.payment.productIdentifier];
        }
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction complete...");
    [self recordTransaction:transaction];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction restored...");
    [self recordTransaction:transaction.originalTransaction];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction failed...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

@end
