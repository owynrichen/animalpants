//
//  Behavior+Popup.m
//  FootGame
//
//  Created by Owyn Richen on 8/16/13.
//
//

#import "Behavior+Popup.h"

@implementation Behavior (Popup)

-(CCAction *) popup: (NSDictionary *) params {
    NSNumber *durNum = (NSNumber *) [params objectForKey:@"duration"];
    NSNumber *holdDurNum = (NSNumber *) [params objectForKey:@"holdDuration"];
    CGPoint moveby = [self parseCoordinate:[params objectForKey:@"position"]];
    
    CCMoveBy *move = [CCMoveBy actionWithDuration:[durNum floatValue] position:moveby];
    CCMoveTo *reverse = [CCMoveTo actionWithDuration:[durNum floatValue] position:[self getOriginalPosition:params]];
    
    return [CCSequence actions: [self resetNodeAction:params], move, [CCDelayTime actionWithDuration:[holdDurNum floatValue]], reverse, nil];
}

@end
