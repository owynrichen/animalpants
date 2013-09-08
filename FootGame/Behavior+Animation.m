//
//  Behavior+Animation.m
//  FootGame
//
//  Created by Owyn Richen on 8/17/13.
//
//

#import "Behavior+Animation.h"

@implementation Behavior(Animation)

-(CCAction *) animate: (NSDictionary *) params {    
    NSArray *frames = [params objectForKey:@"frames"];
    CCAnimation *animation;
    
    if ([params objectForKey:@"animationName"] != nil) {
        NSString *ani = (NSString *) [params objectForKey:@"animationName"];
        animation = [[CCAnimationCache sharedAnimationCache] animationByName:ani];
    } else {
        animation = [CCAnimation animation];
        if ([params objectForKey:@"delay"] != nil) {
            animation.delayPerUnit = [((NSNumber *)[params objectForKey:@"delay"]) floatValue];
        }
    
        if ([params objectForKey:@"loops"] != nil) {
            animation.loops = [((NSNumber *)[params objectForKey:@"loops"]) intValue];
        }
    
        [frames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *frame = obj;

            if ([frame objectForKey:@"file"] != nil) {
                [animation addSpriteFrameWithFilename:[frame objectForKey:@"file"]];
            } else {
                [animation addSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[frame objectForKey:@"spriteFrame"]]];
            }
        }];
    }
    
    return [CCAnimate actionWithAnimation:animation];
}

@end
