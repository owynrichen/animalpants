//
//  CCAutoScalingSprite.m
//  FootGame
//
//  Created by Owyn Richen on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCAutoScalingSprite.h"
#import "CCAutoScaling.h"

@implementation CCAutoScalingSprite

@synthesize autoScaleFactor;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated {
    self = [super initWithTexture:texture rect:rect rotated:rotated];
    
    // TODO: this is a pretty naive approach to scaling, we really should scale it before we cache the
    // actual texture to be more conservative about memory
    
    autoScaleFactor = autoScaleForCurrentDevice();
    self.scale = autoScaleFactor;
    
    return self;
}

-(void) setAnchorPoint:(CGPoint)anchorPoint {
    [super setAnchorPoint:anchorPoint];
    //anchorPoint_ = CGPointMake(anchorPoint.x / self.autoScaleFactor, anchorPoint.y / self.autoScaleFactor);
}

@end
