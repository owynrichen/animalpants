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
@synthesize bitMask;

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated {
    self = [super initWithTexture:texture rect:rect rotated:rotated];
    
    // TODO: this is a pretty naive approach to scaling, we really should scale it before we cache the
    // actual texture to be more conservative about memory
    
    bitMask = [[BitVector alloc] initWithSprite: self];
    
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
}

-(void) draw {
    [super draw];
//    if ([behaviorManager_ hasBehaviors]) {
//        ccDrawColor4B(0,0,255,180);
//        ccDrawRect(self.boundingBox.origin, CGPointMake(self.boundingBox.origin.x + self.boundingBox.size.width, self.boundingBox.size.height));
//        
//        ccDrawColor4B(0,255,0,180);
//        for (int y = 0; y < self.contentSize.height; y++) {
//            for (int x = 0; x < self.contentSize.width; x++) {
//                if ([self.bitMask hitx:x y:y]) {
//                    ccDrawPoint(ccp(x,y));
//                }
//            }
//        }
//    }
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    
    if (self.visible && CGRectContainsPoint([self boundingBox], pnt)) {
        pnt = CGPointApplyAffineTransform(pnt, [self parentToNodeTransform]);
        BOOL hit = NO;
        NSLog(@"Coverage: %f", [self.bitMask getPercentCoverage]);
        
        if ([self.bitMask getPercentCoverage] > 30) {
            hit = [self.bitMask hitx:pnt.x y:pnt.y];
        } else {
            hit = [self.bitMask hitx:pnt.x y:pnt.y radius:30 * autoScaleForCurrentDevice()];
        }
        
        if (hit) {
            Behavior *b = [behaviorManager_ getBehavior:@"touch"];
    
            if (b != nil) {
                [self runAction:[b getAction]];
                return YES;
            }
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
