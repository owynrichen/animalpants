//
//  PartRepository.h
//  FootGame
//
//  Created by Owyn Richen on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnimalPart.h"
#import "Animal.h"

@interface PartRepository : NSObject {
    NSDictionary *animals;
    NSDictionary *partsByType;
    NSMutableArray *feet;
    NSMutableArray *parts;
    
    NSMutableDictionary *aplist;
}

+(PartRepository *) sharedRepository;

-(Animal *) getRandomAnimal;
-(Animal *) getAnimalByKey: (NSString *) key;
-(NSArray *) getRandomParts: (int) partFlags count: (int) count;

@end
