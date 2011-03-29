//
//  PartRepository.m
//  FootGame
//
//  Created by Owyn Richen on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PartRepository.h"

@implementation PartRepository

static PartRepository * _instance;

+(PartRepository *) sharedRepository {
    if (_instance == nil) {
        @synchronized(_instance) {
            if (_instance == nil) {
                _instance = [[PartRepository alloc] init];
            }
        }
    }
    
    return _instance;
}

-(id) init {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Animals" ofType:@"plist"];
	aplist = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    parts = [[NSMutableArray alloc] init];
    feet = [[NSMutableArray alloc] init];
    animals = [[NSMutableDictionary alloc] init];
    partsByType = [[NSMutableDictionary alloc] init];
    
    [partsByType setValue:[[[NSMutableArray alloc] init] autorelease] forKey:@"body"];
    [partsByType setValue:[[[NSMutableArray alloc] init] autorelease] forKey:@"frontfoot"];
    [partsByType setValue:[[[NSMutableArray alloc] init] autorelease] forKey:@"backfoot"];
    
    
    [aplist enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stopblock) {
        NSString *strkey = (NSString *) key;
        Animal *animal = [Animal initWithDictionary: obj];
        
        [animals setValue:animal forKey:strkey];
        [((NSMutableArray *) [partsByType objectForKey:@"body"]) addObject:animal.body];
        [((NSMutableArray *) [partsByType objectForKey:@"frontfoot"]) addObject:animal.frontFoot];
        [((NSMutableArray *) [partsByType objectForKey:@"backfoot"]) addObject:animal.backFoot];
        [feet addObject:animal.frontFoot];
        [feet addObject:animal.backFoot];
        [parts addObject:animal.body];
        [parts addObject:animal.frontFoot];
        [parts addObject:animal.backFoot];
    }];

    return self;
}

-(Animal *) getRandomAnimal {
    return [animals objectForKey:[[animals allKeys] objectAtIndex: rand() % [[animals allKeys] count]]];
}

-(Animal *) getAnimalByKey: (NSString *) key {
    return [animals objectForKey:key];
}

-(NSArray *) getRandomFeet: (int) count {
    return [[NSArray alloc] init];
}

-(void) dealloc {
    [animals release];
    [partsByType release];
    [parts release];
    [feet release];
    [aplist release];
    [super dealloc];
}

@end
