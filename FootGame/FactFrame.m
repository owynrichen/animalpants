//
//  FactFrame.m
//  FootGame
//
//  Created by Owyn Richen on 2/11/13.
//
//

#import "FactFrame.h"

#define FRAME_BORDER_SCALE 0.75

@implementation FactFrame

+(FactFrame *) factFrameWithAnimal: (Animal *) anml frameType: (FactFrameType) ft {
    return [[[FactFrame alloc] initFrameWithAnimal:anml frameType:ft] autorelease];
}

-(id) initFrameWithAnimal: (Animal *) anml frameType: (FactFrameType) ft {
    self = [super init];
    
    animal = [anml retain];
    type = ft;
    
    CCAutoScalingSprite *frame;
    CCAutoScalingSprite *photo;
    
    switch(type) {
        case kEarthFactFrame:
            frame = [CCAutoScalingSprite spriteWithFile:@"earth-frame.png"];
            photo = [CCAutoScalingSprite spriteWithFile:@"earth.png"];
            break;
        case kFaceFactFrame:
            frame = [CCAutoScalingSprite spriteWithFile:@"face-frame.png"];
            NSString *face = [NSString stringWithFormat:@"%@.png", [animal.key lowercaseString]];
            photo = [CCAutoScalingSprite spriteWithFile:face];
            break;
        case kFoodFactFrame:
            frame = [CCAutoScalingSprite spriteWithFile:@"smallbottom-frame.png"];
            photo = [CCAutoScalingSprite spriteWithFile:@"carrot.png"];
            break;
        case kSpeedFactFrame:
            frame = [CCAutoScalingSprite spriteWithFile:@"smallbottom-frame.png"];
            photo = [CCAutoScalingSprite spriteWithFile:@"stopwatch.png"];
            break;
        case kWeightFactFrame:
            frame = [CCAutoScalingSprite spriteWithFile:@"weight-frame.png"];
            NSString *weight = [NSString stringWithFormat:@"%@_weight.png", [animal.key lowercaseString]];
            photo = [CCAutoScalingSprite spriteWithFile:weight];
            break;
        case kHeightFactFrame:
            frame = [CCAutoScalingSprite spriteWithFile:@"height-frame.png"];
            NSString *height = [NSString stringWithFormat:@"%@_height.png", [animal.key lowercaseString]];
            photo = [CCAutoScalingSprite spriteWithFile:height];

            break;
    }
    frame.anchorPoint = ccp(0,0);
    photo.anchorPoint = ccp(0,0);
    float scale = 1.0;
    if (photo.contentSize.width > frame.contentSize.width * FRAME_BORDER_SCALE) {
        float s = frame.contentSize.width * FRAME_BORDER_SCALE / photo.contentSize.width;
        if (s < scale) {
            scale = s;
        }
    }
    
    if (photo.contentSize.height > frame.contentSize.height * FRAME_BORDER_SCALE) {
        float s = frame.contentSize.height * FRAME_BORDER_SCALE / photo.contentSize.height;
        if (s < scale) {
            scale = s;
        }
    }
    
    photo.scale = scale;
    
    photo.position = ccp((frame.contentSize.width - photo.contentSize.width * scale) / 2, (frame.contentSize.height - photo.contentSize.height * scale) / 2);
    [self addChild:frame];
    [self addChild:photo];
    
    return self;
}

-(void) dealloc {
    if (animal != nil)
        [animal release];
    
    [super dealloc];
}

@end
