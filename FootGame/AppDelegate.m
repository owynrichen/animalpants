//
//  AppDelegate.m
//  FootGame
//
//  Created by Owyn Richen on 3/23/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "AnimalFactsLayer.h"
#import "AnimalViewLayer.h"
#import "AnimalSelectLayer.h"
#import "SoundManager.h"
#import "TestFlight.h"
#import "MainMenuLayer.h"
#import "AnalyticsPublisher.h"
#import "GoodbyeLayer.h"
#import "SettingsLayer.h"
#import <FacebookSDK/FacebookSDK.h>

#import "chipmunk.h"

#define USE_PHYSICS_ENGINE 0

@implementation AppDelegate

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
    [TestFlight takeOff:@"54c4595d-90ef-4840-9b99-de15225b2d50"];
    
#ifdef TESTING
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
	
    CC_DIRECTOR_INIT();
    
    [window_ setRootViewController:navController_];
    [[CCDirector sharedDirector] setDelegate:self];
    [window_ setMultipleTouchEnabled:YES];
    [[CCDirector sharedDirector].view setMultipleTouchEnabled:YES];

    // warm up the analytis publisher
    [AnalyticsPublisher instance];
    
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    NSString *vb = [NSString stringWithFormat:@"%@ (%@)", version, build];
    
    NSString *installedVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"installed_version"];
    
    // record a fresh install
    if (installedVersion == nil) {
        apEvent(@"application", @"install", vb);
        [[NSUserDefaults standardUserDefaults] setObject:vb forKey:@"installed_version"];
    } else if (![vb isEqualToString:installedVersion]) {
        NSString *up = [NSString stringWithFormat: @"%@ -> %@", installedVersion, vb];
        apEvent(@"application", @"upgrade", up);
        [[NSUserDefaults standardUserDefaults] setObject:vb forKey:@"installed_version"];
    }
    
    cpInitChipmunk();
    
	// Run the intro Scene
    [[SoundManager sharedManager] preloadSound:@"glock__c2.mp3"];
    [[SoundManager sharedManager] preloadSound:@"glock__g1.mp3"];
    [[SoundManager sharedManager] preloadSound:@"game_intro_bgmusic.mp3"];
    [[SoundManager sharedManager] preloadSound:@"level_complete.mp3"];
    
    // TODO: delete this when we launch
    // [[PremiumContentStore instance] boughtProductId:@"com.alchemistinteractive.footgame.premo"];

    [[CCDirector sharedDirector] runWithScene: [MainMenuLayer scene]];
    // [[CCDirector sharedDirector] runWithScene: [GoodbyeLayer scene]];
    // [[CCDirector sharedDirector] runWithScene: [AnimalSelectLayer scene]];
    // [[CCDirector sharedDirector] runWithScene:[AnimalViewLayer sceneWithAnimalKey: @"Giraffe"]];
    // [[CCDirector sharedDirector] runWithScene:[AnimalFactsLayer sceneWithAnimalKey: @"Crocodile"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [AnalyticsPublisher dispatch];
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
    [FBAppCall handleDidBecomeActive];
    [FBAppEvents activateApp];
    
    if ([FeedbackPrompt shouldShowRateDialog]) {
        prompt = [[FeedbackPrompt alloc] init];
        [prompt showRateThisAppAlert];
    } else {
        [FeedbackPrompt updateCountForPromptByOne:YES];
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [AnalyticsPublisher dispatch];
    [FBSession.activeSession close];
    CC_DIRECTOR_END();
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[window_ release];
    if (prompt != nil)
        [prompt release];
    
	[super dealloc];
}

@end
