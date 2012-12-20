//
//  SoundManager.h
//  FootGame
//
//  Created by Owyn Richen on 5/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"
#import "AudioCues.h"

@interface SoundManager : NSObject {
    SimpleAudioEngine *audioEngine;
    AudioCues *runningCue;
}

+ (SoundManager *) sharedManager;

-(void) setMusicVolume: (float) vol;
-(void) setSoundVolume: (float) vol;

-(void) preloadSound: (NSString *) name;
-(void) playSound: (NSString *) name;
-(void) playSound: (NSString *) name withVol: (float) vol;
-(void) playBackground: (NSString *) name;
-(void) playSoundWithCues: (AudioCues *) cues withDelegate: (id<AudioCuesDelegate>) delegate;

-(void) fadeOutBackground;
-(void) pauseBackground;
-(void) resumeBackground;

@end
