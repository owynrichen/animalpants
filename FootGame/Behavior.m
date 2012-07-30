//
//  Behavior.m
//  FootGame
//
//  Created by Owyn Richen on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Behavior.h"
#import "CCAutoScaling.h"

@implementation Behavior

@synthesize key;
@synthesize data;

+(Behavior *) behaviorFromKey: (NSString *) key dictionary: (NSDictionary *) data {
    Behavior *b = [[(Behavior *) [Behavior alloc] initWithKey:key data:data] autorelease];
    
    return b;
}

-(id) initWithKey: (NSString *) k data: (NSDictionary *) d {
    self = [super init];
    
    self.key = k;
    self.data = d;
    
    return self;
}

-(CCAction *) getAction {
    NSString *action = (NSString *) [data objectForKey:@"action"];
    
    if ([action isEqualToString:@"shake"]) {
        CCMoveBy *shakeUp = [CCMoveBy actionWithDuration:0.1 position:ccpToRatio(0, -10)];
        CCMoveBy *shakeDown = (CCMoveBy *) [shakeUp reverse];
        CCSequence *shake = [CCSequence actions:shakeUp, shakeDown, shakeUp, shakeDown, nil];
        shake.tag = 1;
        return shake;
    } else if ([action isEqualToString:@"backflip"]) {
        __block CGPoint origAnchor;
        __block CGPoint origPosition;
        
        CCCallBlockN *centerAnchor = [CCCallBlockN actionWithBlock:^(CCNode *node) {
            origAnchor = node.anchorPoint;
            origPosition = node.position;
            node.anchorPoint = ccp(0.5,0.5);
            node.position = ccp((node.contentSize.width * node.scale / 2) + node.position.x, (node.contentSize.height * node.scale / 2) + node.position.y);
        }];
        
        CCCallBlockN *resetAnchor = [CCCallBlockN actionWithBlock:^(CCNode *node) {
            node.anchorPoint = origAnchor;
            node.position = origPosition;
        }];
        
        CGPoint jump = ccpToRatio(0, 100);
        CCJumpBy *jumpUp = [CCJumpBy actionWithDuration:0.5 position:ccpToRatio(0, 0) height:jump.y jumps:1];
        CCRotateBy *flip = [CCRotateBy actionWithDuration:0.5 angle:-360];

        CCSpawn *backflip = [CCSpawn actions:jumpUp, flip, nil];
        
        CCSequence *seq = [CCSequence actions:centerAnchor, backflip, resetAnchor, nil];
        
        return seq;
    } else {
        NSLog(@"Unknown action %@ in set %@", action, [data description]);
    }
    
    return nil;
}

@end
