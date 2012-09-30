//
//  PartRepository.m
//  FootGame
//
//  Created by Owyn Richen on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimalPartRepository.h"

@interface NSMutableArray (ArchUtils_Shuffle)
- (void)shuffle;
@end

// Unbiased random rounding thingy.
static NSUInteger random_below(NSUInteger n) {
    NSUInteger m = 1;
    
    do {
        m <<= 1;
    } while(m < n);
    
    NSUInteger ret;
    
    do {
        ret = random() % m;
    } while(ret >= n);
    
    return ret;
}

@implementation NSMutableArray (ArchUtils_Shuffle)

- (void)shuffle {
    // http://en.wikipedia.org/wiki/Knuth_shuffle
    
    for(NSUInteger i = [self count]; i > 1; i--) {
        NSUInteger j = random_below(i);
        [self exchangeObjectAtIndex:i-1 withObjectAtIndex:j];
    }
}
@end

@interface AnimalPartRepository()

-(void) loadAnimal: (Animal *) animal;
@end

@implementation AnimalPartRepository

static AnimalPartRepository * _instance;
static NSString *_sync = @"";

@synthesize allAnimals;

+(AnimalPartRepository *) sharedRepository {
    if (_instance == nil) {
        @synchronized(_sync) {
            if (_instance == nil) {
                _instance = [[AnimalPartRepository alloc] init];
            }
        }
    }
    
    return _instance;
}

-(id) init {
    self = [super init];
    
    parts = [[NSMutableArray alloc] init];
    feet = [[NSMutableArray alloc] init];
    animals = [[NSMutableDictionary alloc] init];
    partsByType = [[NSMutableDictionary alloc] init];
    usedAnimalNames = [[NSMutableDictionary alloc] init];
    
    [partsByType setValue:[[[NSMutableArray alloc] init] autorelease] forKey:@"body"];
    [partsByType setValue:[[[NSMutableArray alloc] init] autorelease] forKey:@"foot"];

    [self loadDataWithFilterBlock:^BOOL(NSString *filename) {
        return [filename hasPrefix:@"Animal-"] && [filename.pathExtension isEqualToString:@"plist"];
    } resultBlock:^(NSDictionary *data) {
        Animal *animal = [Animal initWithDictionary: data];
        
        [self loadAnimal:animal];
    }];
    
    allAnimals = animals;
        
    return self;
}

-(void) loadAnimal:(Animal *)animal {
    [animals setValue:animal forKey:animal.key];
    [((NSMutableArray *) [partsByType objectForKey:@"body"]) addObject:animal.body];
    [((NSMutableArray *) [partsByType objectForKey:@"foot"]) addObject:animal.foot];
    [feet addObject:animal.foot];
    [parts addObject:animal.body];
    [parts addObject:animal.foot];
}

-(void) resetAnimals {
    [usedAnimalNames removeAllObjects];
}

-(Animal *) getRandomAnimal {
    srand(time(nil));
    if ([usedAnimalNames count] == [animals count])
        [self resetAnimals];
    
    NSString *nextAnimal = [[animals allKeys] objectAtIndex: rand() % [[animals allKeys] count]];
    
    while([usedAnimalNames objectForKey:nextAnimal] != nil) {
        nextAnimal = [[animals allKeys] objectAtIndex: rand() % [[animals allKeys] count]];
    }
    
    [usedAnimalNames setValue:@"USED" forKey: nextAnimal];
    
    return [animals objectForKey: nextAnimal];
}

-(Animal *) getAnimalByKey: (NSString *) key {
    return [animals objectForKey:key];
}

-(NSArray *) getRandomFeet: (int) count includingAnimalFeet:(Animal *)animal {
    srand(time(nil));
    
    NSMutableArray *feetToReturn = [[[NSMutableArray alloc] init] autorelease];
    
    if (animal != nil) {
        [feetToReturn addObject:[[animal.foot copyWithZone:nil] autorelease]];
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
            // NSLog(@"%@ == %@ or %@", foot.imageName, animal.frontFoot.imageName, animal.backFoot.imageName);
            if ([foot.imageName isEqualToString: animal.foot.imageName]) {
                NSLog(@"true");
                continue;
            }
            NSLog(@"false");
        }
        
        // loop through existing feet to be sure we're not duping
        for(int i = 0; i < [feetToReturn count]; i++) {
            NSString *name = ((AnimalPart *) [feetToReturn objectAtIndex:i]).imageName;
            // NSLog(@"%@ == %@", foot.imageName, name);
            if ([foot.imageName isEqualToString: name]) {
                // NSLog(@"true");
                add = NO;
                break;
            }
            // NSLog(@"false");
        }
        
        if (add) {
            // [feetToReturn addObject:foot];
            [feetToReturn addObject:[[foot copyWithZone:nil] autorelease]];
        }
    }
    [feetToReturn shuffle];
    
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
