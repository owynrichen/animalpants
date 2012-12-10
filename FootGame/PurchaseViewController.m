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

@interface PurchaseViewController ()
-(NSString *) htmlForProduct: (SKProduct *) product;
- (void)showKeyboard:(NSNotification*)notification;
- (void)hideKeyboard:(NSNotification*)notification;
@end


@implementation PurchaseViewController

@synthesize buyActivity;
@synthesize buyButton;
@synthesize productName;
@synthesize productContent;
@synthesize promoCodeField;
@synthesize cancelButton;

-(id) initWithProduct: (SKProduct *) prod delegate:(id<PurchaseViewDelegate>)del {
    self = [self initWithNibName:@"PurchaseViewController" bundle:nil];
    
    delegate = del;
    
    product = [prod retain];

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
    
    if (delegate != nil)
        delegate = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.buyButton setTitle:locstr(@"buy", @"strings", "") forState:UIControlStateNormal];;
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
    NSString *html = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" href=\"product.css\" /></head><body>%@<br /><div class=\"cost\">%@</div></body></html>", pduct.localizedDescription, [pduct priceAsString]];
    
    return html;
}

-(void) purchaseStarted {
    buying = YES;
    [self.buyActivity startAnimating];
    NSLog(@"starting purchase");
}

-(void) purchaseSucceeded: (NSString *) productId {
    buying = NO;
    [self.buyActivity stopAnimating];
    NSLog(@"purchase succeeded");
    
    if (delegate != nil && [delegate respondsToSelector:@selector(purchaseFinished:)]) {
        [delegate purchaseFinished: YES];
    }
    
    [self.view removeFromSuperview];
}

-(void) purchaseFailed: (NSString *) productId {
    buying = NO;
    [self.buyActivity stopAnimating];
     NSLog(@"purchase failed");
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
}

-(void) usePromotionCodeSuccess: (Promotion *) promo success: (BOOL) successful {
    buying = NO;
    [self.buyActivity stopAnimating];
    if (successful) {
        NSLog(@"promotion code succeeded");
    } else {
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
    NSLog(@"promotion code failed");
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
            [[InAppPurchaseManager instance] purchaseProduct:product];
        } else {
            [[PromotionCodeManager instance] usePromotionCode:promoText withDelegate:self];
        }
    }
}

-(IBAction) cancelClick: (id) sender {
    if (delegate != nil && [delegate respondsToSelector:@selector(cancelClicked:)]) {
        [delegate cancelClicked: buying];
    }
    
    if (!buying) {
        [self.view removeFromSuperview];
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

-(IBAction) editingDidBegin: (id) sender {

}

-(IBAction) editingDidEnd: (id) sender {
    
}


@end
