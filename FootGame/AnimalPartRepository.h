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
#import "ContentManifest.h"

@interface AnimalPartRepository : BaseRepository {
    NSDictionary *animals;
    NSDictionary *partsByType;
    NSMutableArray *feet;
    NSMutableArray *parts;
    
    NSMutableDictionary *aplist;
    NSMutableArray *animalList;
    int curAnimalIndex;
}

+(AnimalPartRepository *) sharedRepository;

@property (readonly) NSDictionary *allAnimals;

-(Animal *) getRandomAnimal;
-(Animal *) getFirstAnimal;
-(Animal *) getNextAnimal;
-(Animal *) getPreviousAnimal;
-(Animal *) peekNextAnimal;
-(void) resetAnimals: (BOOL) rand;
-(Animal *) getAnimalByKey: (NSString *) key;
-(NSArray *) getRandomFeet: (int) count includingAnimalFeet: (Animal *) animal;
-(ContentManifest *) manifest;

@end
