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
    srand(time(nil));
    return [animals objectForKey:@"Dog"];
    // return [animals objectForKey:[[animals allKeys] objectAtIndex: rand() % [[animals allKeys] count]]];
}

-(Animal *) getAnimalByKey: (NSString *) key {
    return [animals objectForKey:key];
}

-(NSArray *) getRandomFeet: (int) count includingAnimalFeet:(Animal *)animal {
    srand(time(nil));
    
    NSMutableArray *feetToReturn = [[NSMutableArray alloc] init];
    
    if (animal != nil) {
        [feetToReturn addObject:animal.frontFoot];
        [feetToReturn addObject:animal.backFoot];
    }
    
    int footCount = [feet count];
    if (count > footCount) {
        count = footCount;
    }
    
    while([feetToReturn count] < count) {
        // get random foot
        AnimalPart *foot = [feet objectAtIndex: rand() % footCount];
        BOOL add = YES;
        
        // if an animal is passed, ensure that it's not an existing animal foot
        if (animal != nil) {
            NSLog(@"%@ == %@ or %@", foot.imageName, animal.frontFoot.imageName, animal.backFoot.imageName);
            if ([foot.imageName isEqualToString: animal.frontFoot.imageName] || [foot.imageName isEqualToString: animal.backFoot.imageName]) {
                NSLog(@"true");
                continue;
            }
            NSLog(@"false");
        }
        
        // loop through existing feet to be sure we're not duping
        for(int i = 0; i < [feetToReturn count]; i++) {
            NSString *name = ((AnimalPart *) [feetToReturn objectAtIndex:i]).imageName;
            NSLog(@"%@ == %@", foot.imageName, name);
            if ([foot.imageName isEqualToString: name]) {
                NSLog(@"true");
                add = NO;
                break;
            }
            NSLog(@"false");
        }
        
        if (add) {
            [feetToReturn addObject:foot];
        }
    }
    return feetToReturn;
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
