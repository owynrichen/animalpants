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
-(NSString *) htmlForProduct: (SKProduct *) product;
- (void)showKeyboard:(NSNotification*)notification;
- (void)hideKeyboard:(NSNotification*)notification;
@end


@implementation PurchaseViewController

@synthesize buyActivity;
@synthesize buyButton;
@synthesize buyAllButton;
@synthesize productName;
@synthesize productContent;
@synthesize promoCodeField;
@synthesize cancelButton;

-(id) initWithProduct: (SKProduct *) prod upsellProduct: (SKProduct *) upsell delegate:(id<PurchaseViewDelegate>)del {
    self = [self initWithNibName:@"PurchaseViewController" bundle:nil];
    
    delegate = del;
    
    product = [prod retain];
    if (upsell != nil) {
        upsellProduct = [upsell retain];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard:) name:UIKeyboardDidHideNotification object:nil];
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    if (delegate != nil)
        delegate = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.buyButton setTitle:locstr(@"buy", @"strings", "") forState:UIControlStateNormal];;
    
    if (upsellProduct != nil) {
        NSString * buyText = [NSString stringWithFormat:locstr(@"buy_upsell", @"strings", @""), upsellProduct.priceAsString];
        [self.buyAllButton setTitle:buyText forState:UIControlStateNormal];
        self.buyAllButton.hidden = NO;
    } else {
        self.buyAllButton.hidden = YES;
    }
    
    self.productName.text = product.localizedTitle;
    self.promoCodeField.placeholder = locstr(@"promocode", @"strings", "");
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    [self.productContent loadHTMLString:[self htmlForProduct:product] baseURL:baseURL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *) htmlForProduct: (SKProduct *) pduct {
    NSString *html = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" href=\"products.css\" /></head><body><p>%@</p><br /><div class=\"cost\">%@</div></body></html>", pduct.localizedDescription, [pduct priceAsString]];
    
    return html;
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
            [[InAppPurchaseManager instance] purchaseProduct:product delegate: self];
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
        NSString *promoText = self.promoCodeField.text;
        
        if ([promoText isEqualToString:@""]) {
            apEvent(@"buy", @"upsell click", @"start for product");
            [[InAppPurchaseManager instance] purchaseProduct:upsellProduct delegate: self];
        } else {
            apEvent(@"buy", @"upsell click", @"start with promo");
            [[PromotionCodeManager instance] usePromotionCode:promoText withDelegate:self];
        }
    } else {
        apEvent(@"buy", @"upsell click", @"still in progress");
    }
}

- (void)showKeyboard:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - keyboardFrameBeginRect.size.width);
}

- (void)hideKeyboard:(NSNotification*)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + keyboardFrameBeginRect.size.width);
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