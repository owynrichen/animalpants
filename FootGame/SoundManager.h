//
//  SoundManager.h
//  FootGame
//
//  Created by Owyn Richen on 5/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"

@interface SoundManager : NSObject {
    SimpleAudioEngine *audioEngine;
}

+ (SoundManager *) sharedManager;

-(void) preloadSound: (NSString *) name;
-(void) playSound: (NSString *) name;
-(void) playBackground: (NSString *) name;

@end
