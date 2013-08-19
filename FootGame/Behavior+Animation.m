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
    CCAnimation *animation = [CCAnimation animation];
    
    if ([params objectForKey:@"delay"] != nil) {
        animation.delayPerUnit = [((NSNumber *)[params objectForKey:@"delay"]) floatValue];
    }
    
    [frames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *frame = obj;

        [animation addSpriteFrameWithFilename:[frame objectForKey:@"file"]];
    }];
    
    return [CCAnimate actionWithAnimation:animation];
}

@end
