//
//  PurchaseViewController.m
//  FootGame
//
//  Created by Owyn Richen on 12/5/12.
//
//

#import "PurchaseViewController.h"
#import "LocalizationManager.h"
#import "PremiumContentStore.h"
#import "CCAutoScaling.h"
#import "AnalyticsPublisher.h"
#import "MBProgressHUD.h"

@interface PurchaseViewController ()
- (void)showKeyboard:(NSNotification*)notification;
- (void)hideKeyboard:(NSNotification*)notification;
@end

@implementation PurchaseViewController

@synthesize buyActivity;
@synthesize buyButton;
@synthesize buyAllButton;
@synthesize titleLabel;
@synthesize productName;
@synthesize productCost;
@synthesize upsellProductName;
@synthesize promoCodeField;
@synthesize cancelButton;

-(id) initWithProduct: (SKProduct *) prod upsellProduct: (SKProduct *) upsell delegate:(id<PurchaseViewDelegate>)del {
    self = [self initWithNibName:@"PurchaseViewController" bundle:nil];
    
    if (del != nil)
        delegate = [del retain];
    
    product = [prod retain];
    if (upsell != nil) {
        upsellProduct = [upsell retain];
    }
    
    currentProduct = product;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardDidHideNotification object:nil];
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (product != nil)
        [product release];
    
    if (upsellProduct != nil) {
        [upsellProduct release];
    }
    
    if (delegate != nil) {
        [delegate release];
        delegate = nil;
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.font = [UIFont fontWithName:@"Rather Loud" size:48];
    self.productName.font = [UIFont fontWithName:@"Rather Loud" size:30];
    self.upsellProductName.font = [UIFont fontWithName:@"Rather Loud" size:30];
    self.productCost.font = [UIFont fontWithName:@"Rather Loud" size:30];
    self.buyButton.titleLabel.font = [UIFont fontWithName:@"Rather Loud" size:20];
    self.buyAllButton.titleLabel.font = [UIFont fontWithName:@"Rather Loud" size:20];
    self.promoCodeField.font = [UIFont fontWithName:@"Rather Loud" size:20];
    
    self.titleLabel.text = locstr(@"confirm_title",@"strings", @"");
    self.productCost.text = product.priceAsString;
    [self.buyButton setTitle:locstr(@"confirm", @"strings", @"") forState:UIControlStateNormal];;
    
    if (upsellProduct != nil) {
        NSString * buyText = [NSString stringWithFormat:locstr(@"buy_upsell", @"strings", @""), [SKProduct localeFormattedPrice: [upsellProduct.price decimalNumberBySubtracting: product.price] locale:[upsellProduct priceLocale]]];
        [self.buyAllButton setTitle:buyText forState:UIControlStateNormal];
        self.upsellProductName.text = upsellProduct.localizedTitle;
        self.buyAllButton.hidden = NO;
        self.upsellProductName.hidden = NO;
    } else {
        self.buyAllButton.hidden = YES;
        self.upsellProductName.hidden = YES;
    }
    
    self.productName.text = product.localizedTitle;
    self.promoCodeField.placeholder = locstr(@"promocode", @"strings", "");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) purchaseStarted {
    buying = YES;
    [self.buyActivity startAnimating];
    self.buyActivity.hidden = NO;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
    hud.labelText = locstr(@"buying_product", @"strings", @"");
    
    NSLog(@"starting purchase");
    apEvent(@"purchase", @"start", @"");
}

-(void) purchaseSucceeded: (NSString *) productId {
    buying = NO;
    [self.buyActivity stopAnimating];
    self.buyActivity.hidden = YES;
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    NSLog(@"purchase succeeded");
    apEvent(@"purchase", @"success", productId);
    
    if (delegate != nil && [delegate respondsToSelector:@selector(purchaseFinished:)]) {
        [delegate purchaseFinished: YES];
    }
    
    [self.view removeFromSuperview];
}

-(void) purchaseFailed: (NSString *) productId {
    buying = NO;
    [self.buyActivity stopAnimating];
    self.buyActivity.hidden = YES;
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    NSLog(@"purchase failed");
    apEvent(@"purchase", @"fail", productId);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:locstr(@"product_buy_error_title", @"strings", @"")
                                                    message:locstr(@"product_buy_error_desc", @"strings", @"")
                                                   delegate:nil
                                          cancelButtonTitle:locstr(@"okay", @"strings", @"")
                                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
    
    if (delegate != nil && [delegate respondsToSelector:@selector(purchaseFinished:)]) {
        [delegate purchaseFinished: NO];
    }
    
    [self.view removeFromSuperview];
}

-(void) usePromotionCodeStarted: (Promotion *) promo {
    buying = YES;
    [self.buyActivity startAnimating];
    self.buyActivity.hidden = NO;
    apEvent(@"promo", @"start", @"");
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
    hud.labelText = locstr(@"checking_code", @"strings", @"");
}

-(void) usePromotionCodeSuccess: (Promotion *) promo success: (BOOL) successful {
    buying = NO;
    [self.buyActivity stopAnimating];
    self.buyActivity.hidden = YES;
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    if (successful) {
        NSLog(@"promotion code succeeded");
        apEvent(@"promo", @"success", promo.code);
    } else {
        apEvent(@"promo", @"fail", promo.code);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:locstr(@"invalid_promo_error_title", @"strings", @"")
                                                        message:locstr(@"invalid_promo_error_desc", @"strings", @"")
                                                       delegate:nil
                                              cancelButtonTitle:locstr(@"okay", @"strings", @"")
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    if (delegate != nil && [delegate respondsToSelector:@selector(purchaseFinished:)]) {
        [delegate purchaseFinished: successful];
    }
    
    [self.view removeFromSuperview];
}

-(void) usePromotionCodeError: (Promotion *) promo error: (NSError *) error {
    buying = NO;
    [self.buyActivity stopAnimating];
    self.buyActivity.hidden = YES;
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    NSLog(@"promotion code failed");
    apEvent(@"promo", @"fail", promo.code);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:locstr(@"promo_code_error_title", @"strings", @"")
                                                    message:locstr(@"promo_code_error_desc", @"strings", @"")
                                                   delegate:nil
                                          cancelButtonTitle:locstr(@"okay", @"strings", @"")
                                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
    
    if (delegate != nil && [delegate respondsToSelector:@selector(purchaseFinished:)]) {
        [delegate purchaseFinished: NO];
    }
    
    [self.view removeFromSuperview];
}

-(IBAction) buyClick: (id) sender {
    if (!buying) {
        NSString *promoText = self.promoCodeField.text;
        
        if ([promoText isEqualToString:@""]) {
            apEvent(@"buy", @"click", @"start for product");
            [[InAppPurchaseManager instance] purchaseProduct:currentProduct delegate: self];
        } else {
            apEvent(@"buy", @"click", @"start with promo");
            [[PromotionCodeManager instance] usePromotionCode:promoText withDelegate:self];
        }
    } else {
        apEvent(@"buy", @"click", @"still in progress");
    }
}

-(IBAction) cancelClick: (id) sender {
    BOOL cancelAllowed = YES;
    if (delegate != nil && [delegate respondsToSelector:@selector(cancelClicked:)]) {
        cancelAllowed = [delegate cancelClicked: buying];
    }
    
    if (!buying) {
        if (cancelAllowed) {
            apEvent(@"buy", @"cancel click", @"start");
            [self.view removeFromSuperview];
        } else {
            apEvent(@"buy", @"cancel click", @"not allowed");
        }
    } else {
        apEvent(@"buy", @"cancel click", @"still in progress");
    }
}

-(IBAction) buyAllClick:(id)sender {
    if (!buying) {
        apEvent(@"buy", @"upsell click", @"add upsell");
        currentProduct = upsellProduct;
        upsellProductName.hidden = YES;
        buyAllButton.hidden = YES;
        productCost.text = upsellProduct.priceAsString;
        productName.text = upsellProduct.localizedTitle;
    } else {
        apEvent(@"buy", @"upsell click", @"still in progress");
    }
}

- (void)showKeyboard:(NSNotification*)notification
{
//    NSDictionary* keyboardInfo = [notification userInfo];
//    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
//    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    titleLabel.hidden = YES;
    productName.hidden = YES;
    productCost.hidden = YES;
    
    if (upsellProduct != nil) {
        upsellProductName.hidden = YES;
        buyAllButton.hidden = YES;
    }
    
    [buyButton setTitle: locstr(@"use_code",@"strings",@"") forState:UIControlStateNormal];
    
    originalFrame = self.view.frame;
    
    // the width of the keyboard is it's height in landscape mode...
    CGFloat newHeight = self.view.frame.size.height / 3;
    
    self.view.frame = CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, newHeight);
}

- (void)hideKeyboard:(NSNotification*)notification {
    // NSDictionary* keyboardInfo = [notification userInfo];
    // NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    // CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    titleLabel.hidden = NO;
    productName.hidden = NO;
    productCost.hidden = NO;
    
    if (upsellProduct != nil && currentProduct != upsellProduct) {
        upsellProductName.hidden = NO;
        buyAllButton.hidden = NO;
    }
    
    [buyButton setTitle: locstr(@"confirm",@"strings",@"") forState:UIControlStateNormal];
    promoCodeField.text = @"";
    
    self.view.frame = originalFrame;
}

+(PurchaseViewController *) handleProductsRetrievedWithDelegate: (id<PurchaseViewDelegate>) del products: (NSArray *) products withProductId: (NSString *) productId upsell: (NSString *) upsellId {
    
    __block SKProduct *product = nil;
    __block SKProduct *upsell = nil;
    
    [products enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKProduct *p = (SKProduct *) obj;
        if ([productId isEqualToString:p.productIdentifier]) {
            product = p;
        }
        
        if (upsellId != nil && [upsellId isEqualToString:p.productIdentifier]) {
            upsell = p;
        }
    }];
    
    PurchaseViewController *purchase = [[PurchaseViewController alloc] initWithProduct:product upsellProduct: upsell delegate:del];
    [[CCDirector sharedDirector].view addSubview:purchase.view];
    
    DeviceResolutionType device = runningDevice();
    CGPoint pviewSize;
    CGPoint pViewOrigin;
    
    if (device == kiPad || device == kiPadRetina ) {
        pviewSize = ccpToRatio(512, 384);
        pViewOrigin = ccpToRatio(512/2, 384/2);
    } else {
        pviewSize = ccp(480, 320);
        pViewOrigin = ccp(0, 0);
    }
    purchase.view.frame = CGRectMake(pViewOrigin.x, pViewOrigin.y, pviewSize.x, pviewSize.y);
    
    return purchase;
}

+(void) handleProductsRetrievedFail {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:locstr(@"product_fetch_error_title", @"strings", @"")
                                                    message:locstr(@"product_fetch_error_desc", @"strings", @"")
                                                   delegate:nil
                                          cancelButtonTitle:locstr(@"okay", @"strings", @"")
                                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
}

@end
