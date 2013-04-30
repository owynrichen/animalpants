//
//  Animal.h
//  FootGame
//
//  Created by Owyn Richen on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnimalPart.h"
#import "LocationManager.h"
#import "ContentManifest.h"

typedef enum {
    kFaceFact = 0,
    kHeightFact = 1,
    kWeightFact = 2,
    kEarthFact = 3,
    kSpeedFact = 4,
    kFoodFact = 5,
} FactType;

@interface Animal : NSObject {
    NSString *key;
    NSString *name;
    AnimalPart *body;
    AnimalPart *foot;
    
    NSString *environment;
    NSString *successSound;
    NSString *failSound;
    NSString *word;
    NSString *productId;
    
    NSArray *habitatLocations;
}

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) AnimalPart *body;
@property (nonatomic, retain) AnimalPart *foot;
@property (nonatomic, retain) NSString *successSound;
@property (nonatomic, retain) NSString *failSound;
@property (nonatomic, retain) NSString *environment;
@property (nonatomic, retain) NSString *word;
@property (nonatomic, retain) NSString *productId;
@property (nonatomic, retain) NSArray *habitatLocations;
@property (nonatomic, retain, getter = getManifest, setter = setManifest:) ContentManifest *manifest;

+(Animal *) initWithDictionary: (NSDictionary *) dict;

-(void) enumerateHabitiatLocationsWithBlock: (void (^)(LatitudeLongitude ll)) block;
-(NSString *) localizedName;

-(NSString *) factTitle: (FactType) ftype;
-(NSString *) factText: (FactType) ftype;

@end
