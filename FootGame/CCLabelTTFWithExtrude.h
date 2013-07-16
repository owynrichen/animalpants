//
//  CCLabelTTFWithExtrude.h
//  FootGame
//
//  Created by Owyn Richen on 7/14/13.
//
//

#import "CCLabelTTF.h"

@interface CCLabelTTFWithExtrude : CCLabelTTF {
    ccColor3B extrudeColor_;
    float extrudeDepth_;
    
    CCRenderTexture *extrudeTexture;
}

@property (nonatomic, readonly) ccColor3B extrudeColor;
@property (nonatomic, readonly) float extrudeDepth;

-(void) setExtrudeColor:(ccColor3B)extrudeColor;
-(void) setExtrudeDepth:(float)extrudeDepth;

-(void) drawExtrude;

+(CCRenderTexture*) createExtrude: (CCLabelTTF*) label size:(float)size color:(ccColor3B)cor;

@end
