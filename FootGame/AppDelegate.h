//
//  AppDelegate.h
//  FootGame
//
//  Created by Owyn Richen on 3/23/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedbackPrompt.h"

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate> {
    CCDirector          *director_;
	UIWindow			*window_;
    UINavigationController *navController_;
    FeedbackPrompt *prompt;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
