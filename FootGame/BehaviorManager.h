//
//  BehaviorManager.h
//  FootGame
//
//  Created by Owyn Richen on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Behavior.h"

@interface BehaviorManager : NSObject {
    NSMutableDictionary *behaviors;
}

-(void) addBehavior: (Behavior *) behavior;
-(Behavior *) getBehavior: (NSString *) key;
-(void) removeBehavior: (NSString *) key;
-(BOOL) hasBehaviors;
@end

@protocol BehaviorManagerDelegate<CCTargetedTouchDelegate>

-(BehaviorManager *) behaviorManager;

@end