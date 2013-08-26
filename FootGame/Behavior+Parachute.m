//
//  Behavior+Parachute.m
//  FootGame
//
//  Created by Owyn Richen on 8/25/13.
//
//

#import "Behavior+Parachute.h"

@implementation Behavior(Parachute)

-(CCAction *) chute: (NSDictionary *) params {
    CCSprite *n = (CCSprite *) [params objectForKey:@"node"];
    CGPoint bottom = [self parseCoordinate:[params objectForKey:@"bottomPosition"]];
    
    CCSprite *chute = [CCSprite spriteWithFile:@"avery-parachute.png"];
    
    CCCallBlockN *spawn = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        chute.scaleX = node.scaleX;
        chute.scaleY = node.scaleY;
        
        if ([params objectForKey:@"position"] == nil) {
            chute.position = n.position;
        }
        
        [node.parent addChild:chute];
        chute.zOrder = node.zOrder;
        
        chute.anchorPoint = ccp(0.5, 1.0);
        
        CCRotateTo *rotate = [CCRotateTo actionWithDuration:0.6 angle:-30];
        CCRotateTo *rev = [CCRotateTo actionWithDuration:0.6 angle:30];
        CCRepeat *repeat = [CCRepeat actionWithAction:[CCSequence actions:rotate, rev, nil] times:12];
        
        ccBezierConfig bez;
        bez.endPosition = ccp(chute.position.x, bottom.y);
        bez.controlPoint_1 = ccp(chute.position.x - (chute.position.x / 5), (chute.position.y - bottom.y) / 3);
        bez.controlPoint_2 = ccp(chute.position.x + (chute.position.x / 5), (chute.position.y - bottom.y) / 3 * 2);
        // CCBezierTo *move = [CCBezierTo actionWithDuration:7 bezier: bez];
        CCMoveTo *move = [CCMoveTo actionWithDuration:7 position:ccp(chute.position.x, bottom.y)];
        
        CCFadeOut *fade = [CCFadeOut actionWithDuration:8];
        CCSequence *seq = [CCSequence actions:fade, [CCCallBlockN actionWithBlock:^(CCNode *node) {
            [node removeFromParentAndCleanup:YES];
        }], nil];
        
        [chute runAction:repeat];
        [chute runAction:move];
        [chute runAction:seq];
    }];
    
    return spawn;
}

@end
