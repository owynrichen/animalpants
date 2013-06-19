/////// RopeNode.m

#import "RopeNode.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGL.h>

typedef struct RopeNodeParticle {
	cpVect pos, prev;
} Particle;

@implementation RopeNode

@synthesize gravity = _gravity, iterations = _iterations, damping = _damping, width = _width, color = _color;

- (id)initWithLength:(cpFloat)length segments:(int)count
               body1:(CPBody *)body1 body2:(CPBody *)body2
             offset1:(cpVect)offset1 offset2:(cpVect)offset2;
{
	if((self = [super init])){
		_body1 = [body1 retain];
		_body2 = [body2 retain];
		_offset1 = offset1;
		_offset2 = offset2;
		
		_count = count;
		_iterations = 5;
		self.length = length;
		
		_width = 5.0f;
		_color = ccc4(255, 255, 255, 255);
		
		cpVect start = cpBodyLocal2World(_body1.body, offset1);
		cpVect end = cpBodyLocal2World(_body2.body, offset2);
		
		_particles = calloc(count + 1, sizeof(Particle));
		for(int i=0; i<=count; i++){
			cpVect p = cpvlerp(start, end, (cpFloat)i/(cpFloat)count);
			_particles[i] = (Particle){p, p};
		}
        
        self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
	}
    
    [self scheduleUpdate];
	
	return self;
}

- (void)dealloc {
    [self unscheduleUpdate];
	[_body1 release];
	[_body2 release];
	
	free(_particles);
	
	[super dealloc];
}

-(void)setLength:(cpFloat)length {
	_segLength = length/_count;
}

-(cpFloat)length {
	return _segLength;
}

-(void) update:(ccTime)delta {
    [self step];
}

static inline Particle
stepParticle(Particle p, cpVect g, cpFloat damping)
{
	cpVect pos = p.pos;
	cpVect vel = cpvmult(cpvsub(pos, p.prev), damping);
	return (Particle){cpvadd(cpvadd(pos, vel), g), pos};
}

static inline void
contract(Particle *particles, int i, int j, cpFloat dSQ, cpFloat ratio)
{
	cpVect v1 = particles[i].pos;
	cpVect v2 = particles[j].pos;
	
	cpVect delta = cpvsub(v2, v1);
	if(cpvlengthsq(delta) < dSQ) return;
	cpFloat diff = 0.5f - dSQ/(cpvlengthsq(delta) + dSQ);
	
	particles[i].pos = cpvadd(v1, cpvmult(delta, diff*ratio));
	particles[j].pos = cpvadd(v2, cpvmult(delta, diff*(ratio - 1.0)));
}

- (void)step;
{
	int count = _count;
	Particle *particles = _particles;
	
	cpVect g = _gravity;
	cpFloat damping = _damping;
	for(int i=1; i<count; i++) particles[i] = stepParticle(particles[i], g, damping);
	
	particles[0].pos = cpBodyLocal2World(_body1.body, _offset1);
	particles[count].pos = cpBodyLocal2World(_body2.body, _offset2);
	
	cpFloat dSQ = _segLength*_segLength;
	for(int iteration=0; iteration<_iterations; iteration++){
		contract(particles, 0, 1, dSQ, 0.0f);
		for(int i=2; i<count; i++) contract(particles, i-1, i, dSQ, 0.5f);
		contract(particles, count-1, count, dSQ, 1.0f);
	}
}

static void
generateVertexes(Particle *particles, cpVect *verts, int count, cpFloat width)
{
	cpVect v0 = particles[0].pos;
	cpVect t0 = cpvperp(cpvnormalize_safe(cpvsub(particles[1].pos, v0)));
	verts[0] = cpvadd(v0, cpvmult(t0, width));
	verts[1] = cpvadd(v0, cpvmult(t0, -width));
	
	for(int i=1; i<count-1; i++){
		cpVect v1 = particles[i].pos;
		cpVect t1 = cpvperp(cpvnormalize_safe(cpvsub(v1, v0)));
		
		cpVect t = cpvmult(cpvnormalize_safe(cpvlerp(t0, t1, 0.5f)), width);
		verts[2*i+0] = cpvadd(v1, t);
		verts[2*i+1] = cpvadd(v1, cpvneg(t));
		
		v0 = v1, t0 = t1;
	}
	
	cpVect v1 = particles[count-1].pos;
	cpVect t1 = cpvperp(cpvnormalize_safe(cpvsub(v1, particles[count-2].pos)));
	verts[2*count-2] = cpvadd(v1, cpvmult(t1, width));
	verts[2*count-1] = cpvadd(v1, cpvmult(t1, -width));
}

static void
generateColors(ccColor4F* col, int count) {
    for(int i = 0; i < count; i++) {
        col[i] = ccc4f(1.0,1.0,1.0,0.8);
    }
}

- (void)draw {
    CC_NODE_DRAW_SETUP();
    
	int count = _count + 1;
	
	cpVect verts[count*2];
    ccColor4F color[count * 2];
	generateVertexes(_particles, verts, count, _width);
    generateColors(color ,count * 2);
	
    CHECK_GL_ERROR_DEBUG();
    
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );
    
    CHECK_GL_ERROR_DEBUG();
    
	//
	// Attributes
	//
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, verts);

    CHECK_GL_ERROR_DEBUG();
	
    glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, 0, color);
	
    CHECK_GL_ERROR_DEBUG();
    
    ccGLBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    
    CHECK_GL_ERROR_DEBUG();
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, count*2);
    
    CHECK_GL_ERROR_DEBUG();

    CC_INCREMENT_GL_DRAWS(1);
}

@end