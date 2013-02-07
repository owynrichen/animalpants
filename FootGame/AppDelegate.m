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
#import "AnimalSelectLayer.h"
#import "AnimalViewLayer.h"
#import "SoundManager.h"
#import "TestFlight.h"
#import "MainMenuLayer.h"
#import "AnalyticsPublisher.h"

@implementation AppDelegate

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
    [TestFlight takeOff:@"d3beeb5b8630b754a3ec1bf5620b131d_NTgxNzgyMDEyLTAzLTEzIDAyOjQ1OjMzLjA4MTE5OQ"];
    
#define TESTING 1
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
    
    // record a fresh install
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"install_recorded?"]) {
        NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
        NSString *vb = [NSString stringWithFormat:@"%@ (%@)", version, build];
        
        apEvent(@"application", @"install", vb);
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"install_recorded?"];
    }
    
	// Run the intro Scene
    [[SoundManager sharedManager] preloadSound:@"glock__c2.mp3"];
    [[SoundManager sharedManager] preloadSound:@"glock__g1.mp3"];
    [[SoundManager sharedManager] preloadSound:@"game_intro_bgmusic.mp3"];
    [[SoundManager sharedManager] preloadSound:@"level_complete.mp3"];
    [[SoundManager sharedManager] setMusicVolume:0.6];
    
    [[CCDirector sharedDirector] runWithScene: [MainMenuLayer scene]];
    // [[CCDirector sharedDirector] runWithScene: [AnimalSelectLayer scene]];
    // [[CCDirector sharedDirector] runWithScene:[AnimalViewLayer sceneWithAnimalKey: @"Monkey"]];
    
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
    CC_DIRECTOR_END();
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[window_ release];
	[super dealloc];
}

@end
