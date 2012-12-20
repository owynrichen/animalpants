//
//  AnimalSelectLayer.h
//  FootGame
//
//  Created by Owyn Richen on 9/30/12.
//
//

#import "CCLayer.h"
#import "CCAutoScalingSprite.h"
#import "PurchaseViewController.h"

@interface AnimalSelectLayer : CCLayer<UIWebViewDelegate, ProductRetrievalDelegate, PurchaseViewDelegate>

@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCAutoScalingSprite *background;
@property (nonatomic, retain) UIWebView *facts;
@property (nonatomic, retain) PurchaseViewController *purchase;

+(CCScene *) scene;

-(void) redrawMenu;

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(UIWebView *)webView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;

-(void) productRetrievalStarted;
-(void) productsRetrieved: (NSArray *) products withData: (NSObject *) data;
-(void) productsRetrievedFailed: (NSError *) error withData: (NSObject *) data;
-(void) purchaseFinished: (BOOL) success;

@end
