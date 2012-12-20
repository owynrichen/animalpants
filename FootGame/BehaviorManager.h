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
-(NSArray *) getBehaviors: (NSString *) event;
-(void) removeBehaviors: (NSString *) event;
-(BOOL) hasBehaviors;
// -(BOOL) runBehaviors: (NSString *) event onNode: (CCNode *) node;
-(BOOL) runBehaviors: (NSString *) event onNode: (CCNode *) node withParams: (NSDictionary *) params;

@end

@protocol BehaviorManagerDelegate<CCTargetedTouchDelegate>

-(BehaviorManager *) behaviorManager;

@end