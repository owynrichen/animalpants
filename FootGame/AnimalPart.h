//
//  AnimalPart.h
//  FootGame
//
//  Created by Owyn Richen on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnchorPoint.h"

typedef enum {
    kAnimalPartTypeBody = 0,
    kAnimalPartTypeFrontFoot = 1,
    kAnimalPartTypeBackFoot = 2
    } AnimalPartType;

@interface AnimalPart : CCSprite {
    AnimalPartType partType;
    NSMutableArray *fixPoints;
    NSString *imageName;
    UITouch *touch;
}

@property (nonatomic) AnimalPartType partType;
@property (nonatomic, retain) NSMutableArray *fixPoints;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) UITouch *touch;

+(id) initWithDictionary: (NSDictionary *) dict partType: (AnimalPartType) pt;

-(BOOL) hitTest: (CGPoint) point;
-(AnchorPointPair *) getClosestAnchorWithinDistance: (float) maxDistance withAnimalPart: (AnimalPart *) part;

@end