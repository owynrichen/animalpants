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
#import "AnimalViewLayer.h"
#import "SoundManager.h"
#import "TestFlight.h"
#import "MainMenuLayer.h"

@implementation AppDelegate

// @synthesize window;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"AlchemistKids.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [TestFlight takeOff:@"d3beeb5b8630b754a3ec1bf5620b131d_NTgxNzgyMDEyLTAzLTEzIDAyOjQ1OjMzLjA4MTE5OQ"];
    
#define TESTING 1
#ifdef TESTING
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
    /* 
    CGRect bounds = [[UIScreen mainScreen] bounds];
    float scale = [[UIScreen mainScreen] scale];
    bounds.size.width *= scale;
    bounds.size.height *= scale;
    
    // CGRect bounds = [window bounds];
    CCGLView *glView = [CCGLView viewWithFrame:bounds
								   pixelFormat:kEAGLColorFormatRGBA8
								   depthFormat:0 //GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    
    [glView setMultipleTouchEnabled:YES];
	
    // [director setProjection:CCDirectorProjection2D];
	// attach the openglView to the director
	director.view = glView;
    // Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES])
		CCLOG(@"Retina Display Not supported");
    
	[director setDelegate:self];

	[director setAnimationInterval:1.0/60];
	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    // make the View Controller a child of the main window
	[window addSubview: director.view];
    
    [[[CCDirector sharedDirector] runningScene] visit];
    [[[CCDirector sharedDirector] runningScene] draw];
    [glView swapBuffers];
    
    [window makeKeyAndVisible];
     */
    
    CC_DIRECTOR_INIT();
    [[CCDirector sharedDirector] runWithScene: [MainMenuLayer scene]];
	
	// Run the intro Scene
    [[SoundManager sharedManager] preloadSound:@"glock__c2.mp3"];
    [[SoundManager sharedManager] preloadSound:@"glock__g1.mp3"];
    [[SoundManager sharedManager] preloadSound:@"game_intro_bgmusic.mp3"];
    [[SoundManager sharedManager] preloadSound:@"level_complete.mp3"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)applicationWillResignActive:(UIApplication *)application {
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
//	CCDirector *director = [CCDirector sharedDirector];
//	
//	[director.view removeFromSuperview];
//	
//	[window release];
//	
//	[director end];
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
