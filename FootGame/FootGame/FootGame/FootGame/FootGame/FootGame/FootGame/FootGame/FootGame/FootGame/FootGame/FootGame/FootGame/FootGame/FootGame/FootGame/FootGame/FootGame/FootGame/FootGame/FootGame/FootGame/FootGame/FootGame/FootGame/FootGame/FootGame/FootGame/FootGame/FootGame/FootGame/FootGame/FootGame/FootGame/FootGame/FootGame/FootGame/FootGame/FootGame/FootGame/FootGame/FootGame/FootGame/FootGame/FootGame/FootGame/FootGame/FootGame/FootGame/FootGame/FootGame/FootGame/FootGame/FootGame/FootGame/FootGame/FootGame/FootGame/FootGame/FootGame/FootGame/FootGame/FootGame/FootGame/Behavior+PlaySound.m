//
//  Behavior+PlaySound.m
//  FootGame
//
//  Created by Owyn Richen on 9/3/12.
//
//

#import "Behavior+PlaySound.h"
#import "SoundManager.h"

@implementation Behavior(PlaySound)

-(CCAction *) playSound: (NSDictionary *) params {
    //CCNode *node = (CCNode *) [params objectForKey:@"node"];
    NSString *fx = (NSString *) [params objectForKey:@"sound"];
    [[SoundManager sharedManager] preloadSound:fx];
    
    CCCallBlockN *playSound = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [[SoundManager sharedManager] playSound:fx];
    }];
    
    return playSound;
}

@end
