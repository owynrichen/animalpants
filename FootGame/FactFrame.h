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

@interface FactFrame : CCNode<CCRGBAProtocol> {
    FactFrameType type;
    Animal *animal;
    CCAutoScalingSprite *frame;
    CCAutoScalingSprite *photo;
}

+(FactFrame *) factFrameWithAnimal: (Animal *) anml frameType: (FactFrameType) ft;

-(id) initFrameWithAnimal: (Animal *) anml frameType: (FactFrameType) ft;
-(void) addEvent: (NSString *) event withBlock: (void (^)(CCNode * sender)) blk;

-(void) setColor:(ccColor3B)color;
-(ccColor3B) color;

-(GLubyte) opacity;
-(void) setOpacity: (GLubyte) opacity;

@end
