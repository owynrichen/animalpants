//
//  FeedbackPrompt.h
//  FootGame
//
//  Created by Owyn Richen on 7/31/13.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface FeedbackPrompt : NSObject<UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

+ (void)updateCountForPromptByOne:(BOOL)increase;
+ (BOOL)shouldShowRateDialog;

- (void)showRateThisAppAlert;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;

-(void) showFeedbackDialog;

@end
