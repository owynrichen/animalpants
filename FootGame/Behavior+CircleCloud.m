//
//  Behavior+CircleCloud.m
//  FootGame
//
//  Created by Owyn Richen on 9/8/13.
//
//

#import "Behavior+CircleCloud.h"
#import "Behavior+ParticleSystem.h"

@implementation Behavior(CircleCloud)

-(CCAction *) circleClouds: (NSDictionary *) params {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    
    CCAction *def = [self particleSystemActionWithDef:@"CircleClouds.plist" params:dict];
    
    return def;
}

@end
