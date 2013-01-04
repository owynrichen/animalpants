//
//  Behavior+Bugs.m
//  FootGame
//
//  Created by Owyn Richen on 1/3/13.
//
//

#import "Behavior+Bugs.h"
#import "Behavior+ParticleSystem.h"

@implementation Behavior(Bugs)

-(CCAction *) bugSwarm: (NSDictionary *) params {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    CCNode *node = (CCNode *) [params objectForKey:@"node"];
    
    
    CCAction *def = [self particleSystemActionWithDef:@"BugSwarm.plist" params:dict];
    
    return def;
}

@end
