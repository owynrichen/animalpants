//
//  Behavior+AirplaneTracer.m
//  FootGame
//
//  Created by Owyn Richen on 12/26/12.
//
//

#import "Behavior+AirplaneTracer.h"
#import "Behavior+ParticleSystem.h"

@implementation Behavior(AirplaneTracer)

-(CCAction *) tracer: (NSDictionary *) params {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    
    CCAction *def = [self particleSystemActionWithDef:@"AirplaneTracer.plist" params:dict];
    
    return def;
}

@end
