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
@synthesize behaviorManager=behaviorManager_;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated {
    self = [super initWithTexture:texture rect:rect rotated:rotated];
    
    // TODO: this is a pretty naive approach to scaling, we really should scale it before we cache the
    // actual texture to be more conservative about memory
    
    autoScaleFactor = autoScaleForCurrentDevice();
    self.scale = autoScaleFactor;
    behaviorManager_ = [[BehaviorManager alloc] init];
    
    
    return self;
}

-(void) onEnter {
    [super onEnter];
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:2 swallowsTouches:NO];
}

-(void) onExit {
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}

-(void) dealloc {
    [behaviorManager_ release];
    [super dealloc];
}

-(BehaviorManager *) behaviorManager {
    return behaviorManager_;
}

-(void) setAnchorPoint:(CGPoint)anchorPoint {
    [super setAnchorPoint:anchorPoint];
    //anchorPoint_ = CGPointMake(anchorPoint.x / self.autoScaleFactor, anchorPoint.y / self.autoScaleFactor);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    
    if (self.visible && CGRectContainsPoint([self boundingBox], pnt)) {
        Behavior *b = [behaviorManager_ getBehavior:@"touch"];
    
        if (b != nil) {
            [self runAction:[b getAction]];
            return YES;
        }
    }
    
    return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {

}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {

}

@end
