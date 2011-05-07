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

+(SoundManager *) sharedManager {
    if (_instance == nil) {
        @synchronized(_instance) {
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

@end
