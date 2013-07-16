//
//  PurchaseViewController.h
//  FootGame
//
//  Created by Owyn Richen on 12/5/12.
//
//

#import <UIKit/UIKit.h>
#import "PromotionCodeManager.h"
#import "InAppPurchaseManager.h"

@protocol PurchaseViewDelegate <NSObject>

@optional

-(BOOL) cancelClicked: (BOOL) buying;
-(BOOL) purchaseFinished: (BOOL) success;

@end

@interface PurchaseViewController : UIViewController<PurchaseDelegate, PromotionCodeDelegate> {
    BOOL buying;
    SKProduct *product;
    SKProduct *upsellProduct;
    id<PurchaseViewDelegate> delegate;
    SKProduct *currentProduct;
    CGRect originalFrame;
}

@property (nonatomic, readonly) IBOutlet UILabel *titleLabel;
@property (nonatomic, readonly) IBOutlet UILabel *productName;
@property (nonatomic, readonly) IBOutlet UILabel *productCost;
@property (nonatomic, readonly) IBOutlet UILabel *upsellProductName;
@property (nonatomic, readonly) IBOutlet UITextField *promoCodeField;
@property (nonatomic, readonly) IBOutlet UIButton *buyButton;
@property (nonatomic, readonly) IBOutlet UIButton *buyAllButton;
@property (nonatomic, readonly) IBOutlet UIButton *cancelButton;
@property (nonatomic, readonly) IBOutlet UIActivityIndicatorView *buyActivity;

-(id) initWithProduct: (SKProduct *) product upsellProduct: (SKProduct *) upsell delegate: (id<PurchaseViewDelegate>) del;

-(void) purchaseStarted;
-(void) purchaseSucceeded: (NSString *) productId;
-(void) purchaseFailed: (NSString *) productId;

-(void) usePromotionCodeStarted: (Promotion *) promo;
-(void) usePromotionCodeSuccess: (Promotion *) promo success: (BOOL) successful;
-(void) usePromotionCodeError: (Promotion *) promo error: (NSError *) error;

-(IBAction) buyClick: (id) sender;
-(IBAction) buyAllClick:(id)sender;
-(IBAction) cancelClick: (id) sender;

+(PurchaseViewController *) handleProductsRetrievedWithDelegate: (id<PurchaseViewDelegate>) del products: (NSArray *) products withProductId: (NSString *) productId upsell: (NSString *) upsellId;
+(void) handleProductsRetrievedFail;

@end
