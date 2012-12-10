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

-(void) cancelClicked: (BOOL) buying;
-(void) purchaseFinished: (BOOL) success;

@end

@interface PurchaseViewController : UIViewController<PurchaseDelegate, PromotionCodeDelegate> {
    BOOL buying;
    SKProduct *product;
    id<PurchaseViewDelegate> delegate;
}

@property (nonatomic, readonly) IBOutlet UILabel* productName;
@property (nonatomic, readonly) IBOutlet UIWebView *productContent;
@property (nonatomic, readonly) IBOutlet UITextField *promoCodeField;
@property (nonatomic, readonly) IBOutlet UIButton *buyButton;
@property (nonatomic, readonly) IBOutlet UIButton *cancelButton;
@property (nonatomic, readonly) IBOutlet UIActivityIndicatorView *buyActivity;

-(id) initWithProduct: (SKProduct *) product delegate: (id<PurchaseViewDelegate>) del;

-(void) purchaseStarted;
-(void) purchaseSucceeded: (NSString *) productId;
-(void) purchaseFailed: (NSString *) productId;

-(void) usePromotionCodeStarted: (Promotion *) promo;
-(void) usePromotionCodeSuccess: (Promotion *) promo success: (BOOL) successful;
-(void) usePromotionCodeError: (Promotion *) promo error: (NSError *) error;

-(IBAction) buyClick: (id) sender;
-(IBAction) cancelClick: (id) sender;

@end
