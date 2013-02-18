//
//  FactFrame.h
//  FootGame
//
//  Created by Owyn Richen on 2/11/13.
//
//

#import "CCLayer.h"
#import "Animal.h"

typedef enum {
    kFaceFactFrame,
    kHeightFactFrame,
    kWeightFactFrame,
    kEarthFactFrame,
    kSpeedFactFrame,
    kFoodFactFrame,
} FactFrameType;

@interface FactFrame : CCLayer {
    FactFrameType type;
    Animal *animal;
}

+(FactFrame *) factFrameWithAnimal: (Animal *) anml frameType: (FactFrameType) ft;

-(id) initFrameWithAnimal: (Animal *) anml frameType: (FactFrameType) ft;

@end
