//
//  AnimalPart.h
//  FootGame
//
//  Created by Owyn Richen on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kAnimalPartTypeBody = 0,
    kAnimalPartTypeFrontFoot = 1,
    kAnimalPartTypeBackFoot = 2
    } AnimalPartType;

@interface AnimalPart : CCSprite {
    AnimalPartType partType;
    NSMutableArray *fixPoints;
    NSString *imageName;
}

@property (nonatomic) AnimalPartType partType;
@property (nonatomic, retain) NSMutableArray *fixPoints;
@property (nonatomic, retain) NSString *imageName;

+(id) initWithDictionary: (NSDictionary *) dict partType: (AnimalPartType) pt;

@end
