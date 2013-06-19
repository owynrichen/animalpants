/////// RopeNode.h

#import "cocos2d.h"
#import "chipmunk.h"
#import "CPWrappers.h"

struct RopeNodeParticle;

@interface RopeNode : CCNode {
	CPBody *_body1, *_body2;
	cpVect _offset1, _offset2;
	
	int _count;
	cpFloat _segLength;
	int _iterations;
	
	cpFloat _width;
	ccColor4B _color;
	
	cpFloat _damping;
	cpVect _gravity;
	struct RopeNodeParticle *_particles;
}

@property(assign) cpFloat length;
@property(assign) cpFloat width;
@property(assign) ccColor4B color;

@property(assign) cpFloat damping;
@property(assign) cpVect gravity;
@property(assign) int iterations;

+(id) ropeWithLength: (cpFloat) length segments: (int) count;

- (id)initWithLength:(cpFloat)length segments:(int)count
               body1:(CPBody *)body1 body2:(CPBody *)body2
             offset1:(cpVect)offset1 offset2:(cpVect)offset2;

- (void)step;

@end