//
//  Behavior+Notes.m
//  FootGame
//
//  Created by Owyn Richen on 8/18/13.
//
//

#import "Behavior+Notes.h"
#import "Behavior+ParticleSystem.h"

@implementation Behavior(Notes)

-(CCAction *) notes: (NSDictionary *) params {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    
    CCAction *def = [self particleSystemActionWithDef:@"Notes.plist" params:dict];
    
    return def;
}

@end
