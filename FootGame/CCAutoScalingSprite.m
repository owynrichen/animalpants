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
    
    bitMask = [[BitVector alloc] initWithSprite: self];
    
    autoScaleFactor = autoScaleForCurrentDevice();
    // self.scale = autoScaleFactor;
    behaviorManager_ = [[BehaviorManager alloc] init];
     
    return self;
}

-(void) onEnter {
    [super onEnter];
    [self enableTouches:YES];
    
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    
    [behaviorManager_ runBehaviors:@"start" onNode: self withParams:params];
}

-(void) onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
}

-(void) onExit {
    [self enableTouches:NO];
    [super onExit];
}

-(void) dealloc {
    CCLOG(@"dealloc: %@", self);
    [behaviorManager_ release];
    behaviorManager_ = nil;
    [bitMask release];
    bitMask = nil;
    
    [super dealloc];
}

-(BehaviorManager *) behaviorManager {
    return behaviorManager_;
}

-(void) setAnchorPoint:(CGPoint)anchorPoint {
    [super setAnchorPoint:anchorPoint];
}

-(void) addEvent: (NSString *) event withBlock: (void (^)(CCNode * sender)) blk {
    [[self behaviorManager] addBehavior:[BlockBehavior behaviorFromKey:event dictionary:[NSDictionary dictionaryWithObject:event forKey:@"event"] block:blk]];
}

-(void) draw {
    CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"CCSprite - draw");
    
	NSAssert(!batchNode_, @"If CCSprite is being rendered by CCSpriteBatchNode, CCSprite#draw SHOULD NOT be called");
    
	CC_NODE_DRAW_SETUP();
    
	ccGLBlendFunc( blendFunc_.src, blendFunc_.dst );
    
	ccGLBindTexture2D( [texture_ name] );
    [self.shaderProgram updateUniforms];
    
    // OFFER CHILD CLASSES AN OPPORTUNITY TO INJECT GL COMMANDS
    [self afterDrawInit];
    
    CHECK_GL_ERROR_DEBUG();
    
	//
	// Attributes
	//
    
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );
    
#define kQuadSize sizeof(quad_.bl)
	long offset = (long)&quad_;
    
	// vertex
	NSInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));
    
	// texCoods
	diff = offsetof( ccV3F_C4B_T2F, texCoords);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
    
	// color
	diff = offsetof( ccV3F_C4B_T2F, colors);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
	CHECK_GL_ERROR_DEBUG();
    
#if CC_SPRITE_DEBUG_DRAW == 1
	// draw bounding box
	CGPoint vertices[4]={
		ccp(quad_.tl.vertices.x,quad_.tl.vertices.y),
		ccp(quad_.bl.vertices.x,quad_.bl.vertices.y),
		ccp(quad_.br.vertices.x,quad_.br.vertices.y),
		ccp(quad_.tr.vertices.x,quad_.tr.vertices.y),
	};
	ccDrawPoly(vertices, 4, YES);
#elif CC_SPRITE_DEBUG_DRAW == 2
	// draw texture box
	CGSize s = self.textureRect.size;
	CGPoint offsetPix = self.offsetPosition;
	CGPoint vertices[4] = {
		ccp(offsetPix.x,offsetPix.y), ccp(offsetPix.x+s.width,offsetPix.y),
		ccp(offsetPix.x+s.width,offsetPix.y+s.height), ccp(offsetPix.x,offsetPix.y+s.height)
	};
	ccDrawPoly(vertices, 4, YES);
#endif // CC_SPRITE_DEBUG_DRAW
    
    
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
    
	CC_INCREMENT_GL_DRAWS(1);
    
	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"CCSprite - draw");
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    
    CGRect bbox = CGRectApplyAffineTransform(CGRectApplyAffineTransform([self boundingBox], [self parentToNodeTransform]), [self nodeToWorldTransform]);
    
    if (self.visible && CGRectContainsPoint(bbox, pnt)) {
        pnt = CGPointApplyAffineTransform(pnt, [self worldToNodeTransform]);
        BOOL hit = NO;
        NSLog(@"Coverage: %f", [self.bitMask getPercentCoverage]);
        
        if ([self.bitMask getPercentCoverage] > 40) {
            hit = [self.bitMask hitx:pnt.x y:pnt.y];
        } else {
            hit = [self.bitMask hitx:pnt.x y:pnt.y radius:30 * autoScaleForCurrentDevice()];
        }
        
        if (hit) {
            NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
            NSMutableDictionary *touch = [[[NSMutableDictionary alloc] init] autorelease];
            
            [touch setObject:[NSNumber numberWithFloat: pnt.x] forKey:@"x"];
            [touch setObject:[NSNumber numberWithFloat: pnt.y] forKey:@"y"];
            [params setObject:touch forKey:@"touch"];
            
            return [behaviorManager_ runBehaviors:@"touch" onNode: self withParams: params] || [behaviorManager_ hasBehaviorsForEvent:@"move"] || [behaviorManager_ hasBehaviorsForEvent:@"touchup"] || [behaviorManager_ hasBehaviorsForEvent:@"touchupoutside"];
        }
    }
    
    return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    
    CGRect bbox = CGRectApplyAffineTransform(CGRectApplyAffineTransform([self boundingBox], [self parentToNodeTransform]), [self nodeToWorldTransform]);
    
    if (self.visible && CGRectContainsPoint(bbox, pnt)) {
        pnt = CGPointApplyAffineTransform(pnt, [self worldToNodeTransform]);
        BOOL hit = NO;
        NSLog(@"Coverage: %f", [self.bitMask getPercentCoverage]);
        
        if ([self.bitMask getPercentCoverage] > 40) {
            hit = [self.bitMask hitx:pnt.x y:pnt.y];
        } else {
            hit = [self.bitMask hitx:pnt.x y:pnt.y radius:30 * autoScaleForCurrentDevice()];
        }
        
        if (hit) {
            NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
            NSMutableDictionary *touch = [[[NSMutableDictionary alloc] init] autorelease];
            
            [touch setObject:[NSNumber numberWithFloat: pnt.x] forKey:@"x"];
            [touch setObject:[NSNumber numberWithFloat: pnt.y] forKey:@"y"];
            [params setObject:touch forKey:@"touch"];
            
            [behaviorManager_ runBehaviors:@"move" onNode: self withParams: params];
        }
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    
    if (self.visible) {
        NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
        NSMutableDictionary *touch = [[[NSMutableDictionary alloc] init] autorelease];
        
        [touch setObject:[NSNumber numberWithFloat: pnt.x] forKey:@"x"];
        [touch setObject:[NSNumber numberWithFloat: pnt.y] forKey:@"y"];
        [params setObject:touch forKey:@"touch"];
        
        CGRect bbox = CGRectApplyAffineTransform(CGRectApplyAffineTransform([self boundingBox], [self parentToNodeTransform]), [self nodeToWorldTransform]);
        
        if (CGRectContainsPoint(bbox, pnt)) {
            pnt = CGPointApplyAffineTransform(pnt, [self worldToNodeTransform]);
            BOOL hit = NO;
            NSLog(@"Coverage: %f", [self.bitMask getPercentCoverage]);
            
            if ([self.bitMask getPercentCoverage] > 40) {
                hit = [self.bitMask hitx:pnt.x y:pnt.y];
            } else {
                hit = [self.bitMask hitx:pnt.x y:pnt.y radius:30 * autoScaleForCurrentDevice()];
            }
            
            if (hit) {
                [behaviorManager_ runBehaviors:@"touchup" onNode: self withParams: params];
            } else {
                [behaviorManager_ runBehaviors:@"touchupoutside" onNode: self withParams: params];
            }
        } else {            
            [behaviorManager_ runBehaviors:@"touchupoutside" onNode: self withParams: params];
        }
    }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {

}

-(void) afterDrawInit {
    
}

-(void) enableTouches:(BOOL) on {
    if (on) {
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:2 swallowsTouches:NO];
    } else {
        [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    }
}

@end
