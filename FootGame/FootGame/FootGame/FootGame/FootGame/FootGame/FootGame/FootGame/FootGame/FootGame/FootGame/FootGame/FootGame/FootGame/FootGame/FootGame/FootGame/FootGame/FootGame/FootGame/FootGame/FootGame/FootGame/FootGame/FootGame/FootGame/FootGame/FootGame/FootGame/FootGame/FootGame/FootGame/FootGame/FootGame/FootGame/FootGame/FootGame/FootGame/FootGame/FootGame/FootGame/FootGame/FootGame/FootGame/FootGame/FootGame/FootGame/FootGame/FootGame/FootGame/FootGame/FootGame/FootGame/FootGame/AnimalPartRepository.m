//
//  PartRepository.m
//  FootGame
//
//  Created by Owyn Richen on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimalPartRepository.h"
#import "PremiumContentStore.h"

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

NSString* ANIMAL_ORDER[12] = { @"Giraffe", @"Penguin", @"Monkey", @"Panda", @"Hippo", @"Elephant", @"Lion", @"Crocodile", @"Kangaroo", @"Tiger", @"PolarBear", @"Zebra" };

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
    srand(time(nil));
    
    parts = [[NSMutableArray alloc] init];
    feet = [[NSMutableArray alloc] init];
    animals = [[NSMutableDictionary alloc] init];
    partsByType = [[NSMutableDictionary alloc] init];
    animalList = [[NSMutableArray alloc] init];
    
    [partsByType setValue:[[[NSMutableArray alloc] init] autorelease] forKey:@"body"];
    [partsByType setValue:[[[NSMutableArray alloc] init] autorelease] forKey:@"foot"];

    [self loadDataWithFilterBlock:^BOOL(NSString *filename) {
        return [filename hasPrefix:@"Animal-"] && [filename.pathExtension isEqualToString:@"plist"];
    } resultBlock:^(NSDictionary *data) {
        Animal *animal = [Animal initWithDictionary: data];
        
        [self loadAnimal:animal];
    }];
    
    allAnimals = animals;
    
    [self resetAnimals: NO];
        
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

-(ContentManifest *) manifest {
    ContentManifest *mfest = [[[ContentManifest alloc] init] autorelease];
    
    [animals enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [mfest addManifest:((Animal *) obj).manifest];
    }];
    
    return mfest;
}

-(void) resetAnimals: (BOOL) rand {
    [animalList removeAllObjects];
    // build list
    
    if (rand) {
        srand(time(nil));
    
        [animals enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [animalList addObject:obj];
        }];
    
        [animalList shuffle];
        
        [animalList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            Animal *first = (Animal *) obj1;
            Animal *second = (Animal *) obj2;
            
            BOOL ownsFirst = [[PremiumContentStore instance] ownsProductId:first.productId];
            BOOL ownsSecond = [[PremiumContentStore instance] ownsProductId:second.productId];
            
            if (!ownsFirst && ownsSecond) {
                return NSOrderedDescending;
            } else if (!ownsSecond && ownsFirst) {
                return NSOrderedAscending;
            }
            
            return NSOrderedSame;
        }];
    } else {
        for (int i = 0; i < 12; i++) {
            Animal *animal = (Animal *) [animals objectForKey:ANIMAL_ORDER[i]];
            [animalList addObject:animal];
        }
    }
}

-(Animal *) getRandomAnimal {
    if ([animalList count] == 0)
        [self resetAnimals: YES];
    
    Animal *first = [animalList objectAtIndex:0];
    [animalList removeObjectAtIndex:0];
    return first;
}

-(Animal *) getFirstAnimal {
    if ([animalList count] == 0)
        [self resetAnimals: NO];
    
    Animal *first = [self peekNextAnimal];
    [animalList removeObjectAtIndex:0];
    return first;
}

-(Animal *) getNextAnimal {
    Animal *first =[self peekNextAnimal];
    
    if (first == nil)
        return nil;
    
    [animalList removeObjectAtIndex:0];
    return first;
}

-(Animal *) peekNextAnimal {
    if ([animalList count] == 0) {
        return nil;
    }
    
    Animal *first = [animalList objectAtIndex:0];
    return first;
}

-(Animal *) getAnimalByKey: (NSString *) key {
    return [animals objectForKey:key];
}

-(NSArray *) getRandomFeet: (int) count includingAnimalFeet:(Animal *)animal {
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
