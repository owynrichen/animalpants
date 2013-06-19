//
//  SoundManager.m
//  FootGame
//
//  Created by Owyn Richen on 5/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundManager.h"

#define MUSIC_VOLUME_KEY @"musicVolume"
#define SOUND_VOLUME_KEY @"soundVolume"

@interface SoundManager()
-(BOOL) fileExists: (NSString *) path;
@end

@implementation SoundManager
static SoundManager* _instance;
static NSString *_sync = @"";

+(SoundManager *) sharedManager {
    if (_instance == nil) {
        @synchronized(_sync) {
            if (_instance == nil) {
                _instance = [[SoundManager alloc] init];
            }
        }
    }
    
    return _instance;
}

-(id) init {
    self = [super init];
    audioEngine = [SimpleAudioEngine sharedEngine];
    soundQueue = dispatch_queue_create("com.alchemistinteractive.footgame.audioload", NULL);
    preloadedEffects = [[NSMutableDictionary alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:MUSIC_VOLUME_KEY] != nil) {
        // This wastes some cycles by re-saving to NSUserDefaults...
        [self setMusicVolume:[defaults floatForKey:MUSIC_VOLUME_KEY]];
    }
    
    if ([defaults objectForKey:SOUND_VOLUME_KEY] != nil) {
        // This wastes some cycles by re-saving to NSUserDefaults...
        [self setSoundVolume:[defaults floatForKey:SOUND_VOLUME_KEY]];
    }

    return self;
}

-(void) dealloc {
    [preloadedEffects release];
    [super dealloc];
}

-(void) setMusicVolume: (float) vol {
    [audioEngine setBackgroundMusicVolume:vol];
    [[NSUserDefaults standardUserDefaults] setFloat:vol forKey:MUSIC_VOLUME_KEY];
}

-(void) setSoundVolume: (float) vol {
    [audioEngine setEffectsVolume:vol];
    [[NSUserDefaults standardUserDefaults] setFloat:vol forKey:SOUND_VOLUME_KEY];
}

-(void) preloadSound:(NSString *)name {
    if (name == nil)
        return;
    
    // NSLog(@"preloading sound: %@", name);
    
    [preloadedEffects setObject:name forKey:name];
    [audioEngine preloadEffect:name];
}

-(void) preloadSoundAsync: (NSString *) name target: (id) target selector: (SEL) selector {
    NSAssert(name != nil, @"SoundManager: name MUST not be nil");
	NSAssert(target != nil, @"SoundManager: target can't be nil");
	NSAssert(selector != NULL, @"SoundManager: selector can't be NULL");
    
    dispatch_async(soundQueue, ^{
        [self preloadSound:name];
        
        [target performSelector:selector onThread:[[CCDirector sharedDirector] runningThread] withObject:name waitUntilDone:NO];
    });
}

-(void) unloadSound: (NSString *) name {
    [audioEngine unloadEffect:name];
    [preloadedEffects removeObjectForKey:name];
}

-(void) unloadAllSounds {
    [preloadedEffects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [audioEngine unloadEffect:key];
    }];
    [preloadedEffects removeAllObjects];
}

-(void) playSound: (NSString *) name {
    [self playSound:name withVol:1.0f];
}

-(void) playSound: (NSString *) name withVol: (float) vol {
    if (![self fileExists:name]) {
        return;
    }
    
    [audioEngine playEffect:name pitch:1.0f pan:0.0 gain:vol];
}

-(void) playBackground:(NSString *)name {
    if (![self fileExists:name]) {
        return;
    }
    
    [audioEngine playBackgroundMusic:name loop:YES];
}

-(void) playSoundWithCues: (AudioCues *) cues withDelegate: (id<AudioCuesDelegate>) delegate; {
    ALuint soundId = [audioEngine playEffect:cues.audioFilename];
    [cues startWithDelegate:delegate soundId:soundId];
}

-(void) stopSound:(ALuint)soundId {
    [audioEngine stopEffect:soundId];
}

-(void) fadeOutBackground {
    [audioEngine stopBackgroundMusic];
}

-(void) pauseBackground {
    [audioEngine pauseBackgroundMusic];
}

-(void) resumeBackground {
    [audioEngine resumeBackgroundMusic];
}

-(BOOL) fileExists: (NSString *) path {
    return [[NSFileManager defaultManager] fileExistsAtPath:[CDUtilities fullPathFromRelativePath:path]];
}
@end
