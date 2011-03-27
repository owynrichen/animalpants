//
//  Animal.m
//  FootGame
//
//  Created by Owyn Richen on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Animal.h"


@implementation Animal

@synthesize body;
@synthesize frontFoot;
@synthesize backFoot;

+(Animal *) initWithDictionary: (NSDictionary *) dict {
    Animal *anml = [[Animal alloc] init];
    anml.body = [AnimalPart initWithDictionary:[dict objectForKey:@"Body"] partType:kAnimalPartTypeBody];
    anml.frontFoot = [AnimalPart initWithDictionary:[dict objectForKey: @"FrontFoot"] partType:kAnimalPartTypeFrontFoot];
    anml.backFoot = [AnimalPart initWithDictionary:[dict objectForKey:@"BackFoot"] partType:kAnimalPartTypeBackFoot];
    
    return anml;
}

@end
