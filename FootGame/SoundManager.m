//
//  SoundManager.m
//  FootGame
//
//  Created by Owyn Richen on 5/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SoundManager.h"

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
    
    return self;
}

-(void) preloadSound:(NSString *)name {
    [audioEngine preloadEffect:name];
}

-(void) playSound: (NSString *) name {
    [audioEngine playEffect:name];
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
