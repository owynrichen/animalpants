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
    kAnimalPartTypeFoot = 1
    } AnimalPartType;

@interface AnimalPart : CCSprite <NSCopying> {
    AnimalPartType partType;
    NSMutableArray *fixPoints;
    NSString *imageName;
    UITouch *touch;
    
    NSDictionary *data;
}

@property (nonatomic) AnimalPartType partType;
@property (nonatomic, retain) NSMutableArray *fixPoints;
@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) UITouch *touch;
@property (nonatomic, retain) NSDictionary *data;

+(id) initWithDictionary: (NSDictionary *) dict partType: (AnimalPartType) pt;

-(BOOL) hitTest: (CGPoint) point;
-(AnchorPointPair *) getClosestAnchorWithinDistance: (float) maxDistance withAnimalPart: (AnimalPart *) part;
- (id)copyWithZone:(NSZone *)zone;

@end