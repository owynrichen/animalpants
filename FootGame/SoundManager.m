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

-(void) setMusicVolume: (float) vol {
    [audioEngine setBackgroundMusicVolume:vol];
    [[NSUserDefaults standardUserDefaults] setFloat:vol forKey:MUSIC_VOLUME_KEY];
}

-(void) setSoundVolume: (float) vol {
    [audioEngine setEffectsVolume:vol];
    [[NSUserDefaults standardUserDefaults] setFloat:vol forKey:SOUND_VOLUME_KEY];
}

-(void) preloadSound:(NSString *)name {
    [audioEngine preloadEffect:name];
}

-(void) playSound: (NSString *) name {
    [self playSound:name withVol:1.0f];
}

-(void) playSound: (NSString *) name withVol: (float) vol {
    [audioEngine playEffect:name pitch:1.0f pan:0.0 gain:vol];
}

-(void) playBackground:(NSString *)name {
    [audioEngine playBackgroundMusic:name loop:YES];
}

-(void) playSoundWithCues: (AudioCues *) cues withDelegate: (id<AudioCuesDelegate>) delegate; {
    if (runningCue != nil && ![runningCue isStopped]) {
        NSLog(@"Can only run 1 AudioCue audio entry at a time");
        return;
    }
    
    runningCue = cues;
    [audioEngine playEffect:cues.audioFilename];
    [cues startWithDelegate:delegate];
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

@end
