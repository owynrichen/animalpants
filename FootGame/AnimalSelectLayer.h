//
//  AnimalSelectLayer.h
//  FootGame
//
//  Created by Owyn Richen on 9/30/12.
//
//

#import "CCLayer.h"
#import "CCAutoScalingSprite.h"

@interface AnimalSelectLayer : CCLayer<UIWebViewDelegate>

@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCAutoScalingSprite *background;
@property (nonatomic, retain) UIWebView *facts;

+(CCScene *) scene;

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(UIWebView *)webView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error;

@end
