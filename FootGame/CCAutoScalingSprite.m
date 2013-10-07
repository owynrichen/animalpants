//
//  CCAutoScalingSprite.m
//  FootGame
//
//  Created by Owyn Richen on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCAutoScalingSprite.h"
#import "CCAutoScaling.h"
#import "CPWrappers.h"
#import "chipmunk.h"

@interface CCAutoScalingSprite()

-(void) setupPhysics: (cpBody *) body shape: (cpShape *) shape;
-(void) teardownPhysics;
//-(void) drawPhysics;
-(void) drawHitSpace;

@end

@implementation CCAutoScalingSprite

@synthesize autoScaleFactor;
@synthesize behaviorManager=behaviorManager_;
@synthesize bitMask;
@synthesize name;

+(id) spriteWithFile:(NSString *)filename space:(cpSpace *)physicsSpace {
    return [[[self alloc] initWithFile:filename space:physicsSpace] autorelease];
}

+(id) spriteWithAnimationFile: (NSString *) filename frame: (NSString *) frameName space: (cpSpace *) physicsSpace {
    return [[[self alloc] initWithAnimationFile:filename frame:frameName space:physicsSpace] autorelease];
}

-(id) initWithFile:(NSString *)filename space:(cpSpace *)physicsSpace {
    self = [super initWithFile:filename];
    
    name = filename;
    
    return self;
}

-(id) initWithAnimationFile: (NSString *) filename frame: (NSString *) frameName space: (cpSpace *) physicsSpace {
    
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:filename];
    
    name = filename;
    
    self = [super initWithSpriteFrameName:frameName];
    return self;
}

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated {
    self = [super initWithTexture:texture rect:rect rotated:rotated];
    
    bitMask = [[BitVector alloc] initWithSprite: self];

    autoScaleFactor = autoScaleForCurrentDevice();
    // self.scale = autoScaleFactor;
    behaviorManager_ = [[BehaviorManager alloc] init];
     
    return self;
}

-(void) addToSpace:(cpSpace *)space {
    cpBody *bdy = cpBodyNew(6, cpMomentForBox(6, self.contentSize.width, self.contentSize.height));
    bdy->data = self;
    bdy->p = CGPointApplyAffineTransform(self.position, [self nodeToWorldTransform]);
    bdy->a = self.rotation;
    
    cpShape *shp = cpBoxShapeNew(bdy, self.contentSize.width, self.contentSize.height);
    shp->e = 0.0f;
    shp->u = 0.8f;
    shp->collision_type = 0;
    
    [self addToSpace:space withBody:bdy andShape:shp];
}

-(void) addToSpace: (cpSpace *) space withBody:(cpBody *)body andShape:(cpShape *)shape {
    if (_physicsSpace != NULL) {
        [self removeFromSpace:_physicsSpace];
    }
    
    _physicsSpace = space;
    [self setupPhysics: body shape:shape];
}

-(void) removeFromSpace: (cpSpace *) space {
    [self teardownPhysics];
    _physicsSpace = NULL;
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

-(void) onExitTransitionDidStart {
    [self teardownPhysics];
    [self enableTouches:NO];
    [super onExitTransitionDidStart];
}

-(void) onExit {
    [super onExit];
}

-(void) dealloc {
    CCLOG(@"dealloc: %@", self);
    [behaviorManager_ release];
    behaviorManager_ = nil;
    [bitMask release];
    bitMask = nil;
    [self unscheduleUpdate];
    
    if (_physicsShape != NULL) {
        cpShapeFree(_physicsShape);
        _physicsShape = NULL;
    }
    
    if (_physicsBody != NULL) {
        cpBodyFree(_physicsBody);
        _physicsBody = NULL;
    }

    [super dealloc];
}

-(void) setupPhysics: (cpBody *) body shape: (cpShape *) shape {
    if (_physicsSpace == NULL) {
        return;
    }
    
    self.physicsEnabled = YES;
    
    _physicsBody = body;
    cpSpaceAddBody(_physicsSpace, _physicsBody);
    
    _physicsShape = shape;
    cpSpaceAddShape(_physicsSpace, _physicsShape);
    
    [self scheduleUpdate];
}

-(void) teardownPhysics {
    self.physicsEnabled = NO;
    
    if (_physicsSpace == NULL) {
        return;
    }
    [self unscheduleUpdate];
    cpSpaceRemoveBody(_physicsSpace, _physicsBody);
    cpBodyFree(_physicsBody);
    cpSpaceRemoveShape(_physicsSpace, _physicsShape);
    cpShapeFree(_physicsShape);
}

-(void) drawHitSpace {
    if ([behaviorManager_ hasBehaviors]) {
        ccDrawColor4B(0,0,255,180);
        ccDrawRect(self.boundingBox.origin, CGPointMake(self.boundingBox.origin.x + self.boundingBox.size.width, self.boundingBox.size.height));
        
        ccDrawColor4B(0,255,0,180);
        for (int y = 0; y < self.contentSize.height; y++) {
            for (int x = 0; x < self.contentSize.width; x++) {
                if ([self.bitMask hitx:x y:y]) {
                    ccDrawPoint(ccp(x,y));
                }
            }
        }
    }
}

-(BehaviorManager *) behaviorManager {
    return behaviorManager_;
}

-(void) setAnchorPoint:(CGPoint)anchorPoint {
    [super setAnchorPoint:anchorPoint];
}

-(void) addEvent: (NSString *) event withBlock: (void (^)(CCNode * sender)) blk {
    [[self behaviorManager] addBehavior:[BlockBehavior behaviorFromKey:event dictionary:[[NSDictionary dictionaryWithObject:event forKey:@"event"] autorelease] block:blk]];
}

-(void) update:(ccTime)delta {
    if (_physicsEnabled == YES && _physicsBody != NULL) {
//        CGPoint p = CGPointApplyAffineTransform(_physicsBody->p, [self worldToNodeTransform]);
        // CGPointApplyAffineTransform(parent, [self nodeToWorldTransform]);
        self.position = _physicsBody->p;
//        self.position = p;
        self.rotation = _physicsBody->a;
    }
    
    [super update:delta];
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
    
#ifdef DRAW_HITSPACE
    [self drawHitSpace];
#endif
    
	CC_INCREMENT_GL_DRAWS(1);
    
	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"CCSprite - draw");
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    
    CGRect bbox = CGRectApplyAffineTransform(CGRectApplyAffineTransform([self boundingBox], [self parentToNodeTransform]), [self nodeToWorldTransform]);
    
    if (self.visible && CGRectContainsPoint(bbox, pnt)) {
        CGPoint localpnt = CGPointApplyAffineTransform(pnt, [self worldToNodeTransform]);
        BOOL hit = NO;
        CCLOGINFO(@"Coverage: %f - %@", [self.bitMask getPercentCoverage], name);
        
        if ([self.bitMask getPercentCoverage] > 40) {
            hit = [self.bitMask hitx:localpnt.x y:localpnt.y];
        } else {
            hit = [self.bitMask hitx:localpnt.x y:localpnt.y radius:30 * autoScaleForCurrentDevice()];
        }
        
        if (hit) {
            NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
            NSMutableDictionary *touch = [[[NSMutableDictionary alloc] init] autorelease];
            
            [touch setObject:[NSNumber numberWithFloat: localpnt.x] forKey:@"x"];
            [touch setObject:[NSNumber numberWithFloat: localpnt.y] forKey:@"y"];
            [params setObject:touch forKey:@"touch"];
            
            
            if (_physicsSpace != NULL && _physicsEnabled == YES && _physicsBody != NULL) {
                [params setObject: [CPBody create: _physicsBody] forKey:@"physicsBody"];
            }
            
            return [behaviorManager_ runBehaviors:@"touch" onNode: self withParams: params] || [behaviorManager_ hasBehaviorsForEvent:@"move"] || [behaviorManager_ hasBehaviorsForEvent:@"touchup"] || [behaviorManager_ hasBehaviorsForEvent:@"touchupoutside"];
        }
    }
    
    return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    
    CGRect bbox = CGRectApplyAffineTransform(CGRectApplyAffineTransform([self boundingBox], [self parentToNodeTransform]), [self nodeToWorldTransform]);
    
    if (self.visible && CGRectContainsPoint(bbox, pnt)) {
        CGPoint localpnt = CGPointApplyAffineTransform(pnt, [self worldToNodeTransform]);
        BOOL hit = NO;
        CCLOGINFO(@"Coverage: %f", [self.bitMask getPercentCoverage]);
        
        if ([self.bitMask getPercentCoverage] > 40) {
            hit = [self.bitMask hitx:localpnt.x y:localpnt.y];
        } else {
            hit = [self.bitMask hitx:localpnt.x y:localpnt.y radius:30 * autoScaleForCurrentDevice()];
        }
        
        if (hit) {
            NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
            NSMutableDictionary *touch = [[[NSMutableDictionary alloc] init] autorelease];
            
            [touch setObject:[NSNumber numberWithFloat: localpnt.x] forKey:@"x"];
            [touch setObject:[NSNumber numberWithFloat: localpnt.y] forKey:@"y"];
            [params setObject:touch forKey:@"touch"];
            
            if (_physicsSpace != NULL && _physicsEnabled == YES && _physicsBody != NULL) {
                [params setObject: [CPBody create:_physicsBody] forKey:@"physicsBody"];
            }
            
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
            CGPoint localpnt = CGPointApplyAffineTransform(pnt, [self worldToNodeTransform]);
            BOOL hit = NO;
            CCLOGINFO(@"Coverage: %f", [self.bitMask getPercentCoverage]);
            
            if ([self.bitMask getPercentCoverage] > 40) {
                hit = [self.bitMask hitx:localpnt.x y:localpnt.y];
            } else {
                hit = [self.bitMask hitx:localpnt.x y:localpnt.y radius:30 * autoScaleForCurrentDevice()];
            }
            
            if (_physicsSpace != NULL && _physicsEnabled == YES && _physicsBody != NULL) {                
                [params setObject: [CPBody create: _physicsBody] forKey:@"physicsBody"];
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
