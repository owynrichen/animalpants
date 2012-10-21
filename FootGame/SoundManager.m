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
    am = [CDAudioManager sharedManager];
    soundEngine = am.soundEngine;
    bufferManager = [[CDBufferManager alloc] initWithEngine:soundEngine];
    
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
