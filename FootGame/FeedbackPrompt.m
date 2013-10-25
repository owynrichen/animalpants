//
//  FeedbackPrompt.m
//  FootGame
//
//  Created by Owyn Richen on 7/31/13.
//
//

#import "FeedbackPrompt.h"
#import "AnalyticsPublisher.h"
#import "LocalizationManager.h"
#import "PremiumContentStore.h"
#import "PromotionCodeManager.h"
#import "NSString+NSHash.h"

// count after which Rate this app alert shown
#define STARTUP_COUNT_SHOW_DIALOG 3
#define FEEDBACK_DIALOG_SHOWN_KEY @"FeedbackShown"
#define FEEDBACK_COUNT_KEY @"FeedbackShowCount"

@implementation FeedbackPrompt

#pragma mark -
#pragma mark Public Methods

-(void)showRateThisAppAlert {
    apEvent(@"rating", @"show dialog", @"");
    
    // Set dialog shown for this version
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:FEEDBACK_DIALOG_SHOWN_KEY];
    [userDefaults synchronize];
    
    apView(@"Rate This App Dialog");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:locstr(@"like_animal_pants?",@"strings",@"")
        message:locstr(@"like_animal_pants_details",@"strings",@"")
        delegate:self
        cancelButtonTitle:locstr(@"later", @"strings", @"")
        otherButtonTitles:locstr(@"yes",@"strings",@""),locstr(@"no",@"strings",@""),
        nil];
    
    [alert show];
    [alert release];
}

+(BOOL)shouldShowRateDialog {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSInteger launchCountForRateAlert = [userDefaults integerForKey:FEEDBACK_COUNT_KEY];
    
    BOOL dialogShown = [userDefaults boolForKey:FEEDBACK_DIALOG_SHOWN_KEY];
    
    if (!dialogShown && launchCountForRateAlert >= STARTUP_COUNT_SHOW_DIALOG){
        return YES;
    } else {
        return NO;
    }
}

+(void)updateCountForPromptByOne:(BOOL)increase {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger launchCountForRateAlert = [userDefaults integerForKey:FEEDBACK_COUNT_KEY];
    
    increase ? launchCountForRateAlert++ : launchCountForRateAlert--;
    if(launchCountForRateAlert < 0){
        launchCountForRateAlert = 0;
    }
    [userDefaults setInteger:launchCountForRateAlert forKey:FEEDBACK_COUNT_KEY];
    [userDefaults synchronize];
}

#pragma mark -
#pragma mark Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch(buttonIndex) {
        case 0:
            apEvent(@"rating",@"later",@"");
            break;
        case 1:
            apEvent(@"rating",@"yes",@"");
        
            [[UIApplication sharedApplication]
             openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=581827653"]];
            break;
        case 2:
            apEvent(@"rating",@"no",@"");
        
            [self showFeedbakDialog];
            
            break;
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        apEvent(@"rating",@"feedback_email",@"sent");
        apView(@"Feedback Success View");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:locstr(@"thanks_for_feedback_title",@"strings",@"")
                                                        message:locstr(@"thanks_for_feedback_details",@"strings",@"")
                                                       delegate:nil
                                              cancelButtonTitle:locstr(@"okay",@"strings",@"")
                                              otherButtonTitles: nil];
        
        [alert show];
        [alert release];
    } else if (result == MFMailComposeResultCancelled) {
        apEvent(@"rating",@"feedback_email",@"cancelled");
    }else {
        NSString *resultString = [NSString stringWithFormat:@"%u",result];
        apEvent(@"rating",@"feedback_email",resultString);
        NSString *viewString = [NSString stringWithFormat:@"Feedback Error View (%@)", resultString];
        apView(viewString);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:locstr(@"feedback_submit_error_title",@"strings",@"")
                                                        message:locstr(@"feedback_submit_error_details",@"strings",@"")
                                                       delegate:nil
                                              cancelButtonTitle:locstr(@"okay",@"strings",@"")
                                              otherButtonTitles: nil];
        
        [alert show];
        [alert release];
    }
    
    [[CCDirector sharedDirector] dismissModalViewControllerAnimated:YES];
}

-(void) showFeedbackDialog {
    if (![MFMailComposeViewController canSendMail]) {
        apEvent(@"rating",@"feedback_email",@"cannot send");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:locstr(@"feedback_mail_unavailable_title",@"strings",@"")
                                                        message:locstr(@"feedback_mail_unavailable_details",@"strings",@"")
                                                       delegate:self
                                              cancelButtonTitle:locstr(@"okay",@"strings",@"")
                                              otherButtonTitles: nil];
        
        [alert show];
        [alert release];
        
        return;
    }
    
    apView(@"Feedback Email Dialog");
    
    UIDevice *device = [UIDevice currentDevice];
    NSDictionary *b = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [NSString stringWithFormat:@"%@ (%@)", [b objectForKey:@"CFBundleShortVersionString"], [b objectForKey:@"CFBundleVersion"]];
    
    NSString *systemData = [NSString stringWithFormat:@"App Version: %@<br />"
                            "System Locale: %@<br />"
                            "App Locale: %@<br />"
                            "OS: %@<br />"
                            "Version: %@<br />"
                            "Model: %@<br />", appVersion, [[LocalizationManager sharedManager] getSystemLocale], [[LocalizationManager sharedManager] getAppPreferredLocale], [device systemName], [device systemVersion], [device name]];
    
    NSString *privateData = [[NSString stringWithFormat:@"%@<br />%@<br />%@<br />s33kr3tk33y0d00d", systemData, [[PremiumContentStore instance] ownedProducts], [[PromotionCodeManager instance] attemptedCodes]] encryptWithKey:@"Sweet man!"];
    
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:locstr(@"feedback_email_subject",@"strings",@"")];
    [controller setToRecipients:[NSArray arrayWithObject: @"feedback@alchemistinteractive.com"]];
    [controller setMessageBody:[NSString stringWithFormat: @""
                                "<html>"
                                "  <head><title>Feedback Email</title>"
                                "  <body>"
                                "    <br /><br />"
                                "    <hr />"
                                "    <h4>%@</h4>"
                                "    <p>"
                                "%@"
                                "    </p>"
                                "    <hr />"
                                "    <h4>%@</h4>"
                                "    <pre>%@</pre>"
                                "    <hr />"
                                "    <br /><br />"
                                "  </body>"
                                "</html>", locstr(@"technical_details", @"strings", @""), systemData, locstr(@"encrypted_technical_details", @"strings", @""), privateData] isHTML:YES];
    
    if (controller) [[CCDirector sharedDirector] presentModalViewController:controller animated:YES];
    [controller release];
}

@end