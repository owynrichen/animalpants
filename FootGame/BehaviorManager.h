//
//  BehaviorManager.h
//  FootGame
//
//  Created by Owyn Richen on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Behavior : NSObject

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSDictionary *data;

+(Behavior *) behaviorFromKey: (NSString *) key dictionary: (NSDictionary *) data;

-(id) initWithKey: (NSString *) k data: (NSDictionary *) d;
-(CCAction *) getAction;
@end

@interface BehaviorManager : NSObject {
    NSMutableDictionary *behaviors;
}

-(void) addBehavior: (Behavior *) behavior;
-(Behavior *) getBehavior: (NSString *) key;
-(void) removeBehavior: (NSString *) key;
@end

@protocol BehaviorManagerDelegate<CCTargetedTouchDelegate>

-(BehaviorManager *) behaviorManager;

@end