//
//  InAppPurchaseManager.m
//  CatOfTheDay
//
//  Created by Owyn Richen on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "InAppPurchaseManager.h"
#import "MBProgressHUD.h"
#import "LocalizationManager.h"
#import "AnalyticsPublisher.h"

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

-(void) getProducts: (id<ProductRetrievalDelegate>)del {
    [self getProducts: del withData:nil];
}

-(void) getProducts: (id<ProductRetrievalDelegate>)del withData:(NSObject *)obj {
    if (prodDelegate)
        prodDelegate = nil;
    
    if (del == nil)
        prodDelegate = self;
    else
        prodDelegate = del;
    
    if (prodDelegate) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
        hud.labelText = locstr(@"get_products", @"strings", @"");
        
        [prodDelegate productRetrievalStarted];
    }
    
    if (cachedProducts) {
        if (prodDelegate) {
            [prodDelegate productsRetrieved:cachedProducts withData:obj];
        }
    } else {
        state = [obj retain];
        NSArray *productIds = [[PremiumContentStore instance] products];
        
        NSSet *products = [NSSet setWithArray:productIds];
        SKProductsRequest *req = [[SKProductsRequest alloc] initWithProductIdentifiers:products];
        req.delegate = self;
        
        [req start];
    }
}

-(void) productRetrievalStarted {
    
}

-(void) productsRetrieved: (NSArray *) products withData:(NSObject *)data {
    [cachedProducts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKProduct *prod = (SKProduct *) obj;
        
        if ([prod.productIdentifier isEqualToString:(NSString *) data]) {
            [self purchaseProduct:prod delegate:delegate];
            return;
        }
    }];
    
    if (delegate)
        [delegate purchaseFailed:(NSString *)data];
}

-(void) productsRetrievedFailed: (NSError *) error withData:(NSObject *)data {
    apErr(error);
    
    if (delegate)
        [delegate purchaseFailed:(NSString *)data];
}

-(void) purchaseProductById: (NSString *) productId delegate: (id<PurchaseDelegate>) del {
    if (delegate)
        delegate = nil;
    
    delegate = del;
    
    if (delegate)
        [delegate purchaseStarted];
    
    [self getProducts:self withData:productId];
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
        if (prodDelegate) {
            [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
            
            [prodDelegate productsRetrieved: products withData:state];
        }
    } else {
        if (prodDelegate) {
            [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
            
            [prodDelegate productsRetrievedFailed:nil withData:state];
        }
    }
    
    if (state != nil)
        [state release];
}

-(void) purchaseProduct: (SKProduct *) product delegate: (id<PurchaseDelegate>) del {
    if (delegate != nil)
        delegate = nil;
    
    delegate = del;
    
    if (delegate)
        [delegate purchaseStarted];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

-(void) restorePurchases: (id<PurchaseDelegate>) del {
    if (delegate != nil)
        delegate = nil;
    
    delegate = del;
    
    if (delegate)
        [delegate purchaseStarted];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
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
        
        if (cachedProducts) {
            [cachedProducts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SKProduct *product = (SKProduct *) obj;
                if ([product.productIdentifier isEqualToString:transaction.payment.productIdentifier]) {
                    apPurchase(product, transaction);
                }
            }];
        } else {
            NSLog(@"No cached products to check");
            apPurchase(nil, transaction);
        }
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
        apErrMsg([transaction.error debugDescription])
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        [self finishTransaction:transaction wasSuccessful:NO];
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

@implementation SKProduct (priceAsString)

- (NSString *) priceAsString
{
    return [SKProduct localeFormattedPrice:[self price] locale:[self priceLocale]];
}

+(NSString *) localeFormattedPrice: (NSNumber *) price locale: (NSLocale *) locale {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:locale];
    
    NSString *str = [formatter stringFromNumber:price];
    [formatter release];
    return str;
}

@end
