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
#import "BaseRepository.h"

@interface AnimalPartRepository : BaseRepository {
    NSDictionary *animals;
    NSDictionary *partsByType;
    NSMutableArray *feet;
    NSMutableArray *parts;
    
    NSMutableDictionary *aplist;
    NSMutableArray *animalList;
}

+(AnimalPartRepository *) sharedRepository;

@property (readonly) NSDictionary *allAnimals;

-(void) resetAnimals;
-(Animal *) getRandomAnimal;
-(Animal *) getAnimalByKey: (NSString *) key;
-(NSArray *) getRandomFeet: (int) count includingAnimalFeet: (Animal *) animal;

@end
