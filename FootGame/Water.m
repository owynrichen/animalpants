//
//  Water.m
//  FootGame
//
//  Created by Owyn Richen on 9/10/12.
//
//

#import "Water.h"
#import "ccGLStateCache.h"

#define TOUCH_AMP_START 8.0;

@implementation Water

-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated {
    self = [super initWithTexture:texture rect:rect rotated:rotated];
    
    CCGLProgram *shader = [[[CCGLProgram alloc] initWithVertexShaderFilename:@"water.vs" fragmentShaderFilename:@"water.fs"] autorelease];
    
    [shader addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[shader addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
	[shader addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
    
    [shader link];
    
	[shader updateUniforms];
    
    uniformReflectTexture = glGetUniformLocation(shader->program_, "u_reflect_texture");
    uniformTime = glGetUniformLocation( shader->program_, "u_time");
    uniformTouchPos = glGetUniformLocation(shader->program_, "u_touchPos");
    uniformTouchAmp = glGetUniformLocation(shader->program_, "u_touchAmp");
    
    [[CCShaderCache sharedShaderCache] addProgram:shader forKey:@"water"];
    self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:@"water"];
    
    [self scheduleUpdate];
    touchDown = NO;
    touchAmp = 0.0;
    touchPos = ccp(0.5,0.5);
    
    return self;
}

-(void) dealloc {
    if (reflectTexture)
        [reflectTexture release];
    
    [super dealloc];
}

-(void) update: (ccTime) dt {
    time_ += dt;
    
    // cycle time with sin wave to keep
    // floating point percision high
    
    if (time_ > 2 * M_PI) {
        time_ -= 4 * M_PI;
    }
    
    if (touchAmp > 0) {
        touchAmp -= dt;
        if (touchAmp < 0) {
            touchAmp = 0;
        }
    }
}

-(void) afterDrawInit {
    [self.shaderProgram setUniformLocation:uniformTouchPos withF1:touchPos.x f2:touchPos.y];
    glUniform1f(uniformTime, time_);
    glUniform1f(uniformTouchAmp, touchAmp);
    
    if (reflectTexture != nil) {
      ccGLBindTexture2DN(1, [reflectTexture name]);
      [self.shaderProgram setUniformLocation:uniformReflectTexture withI1:1];
    }
}



- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [super ccTouchBegan:touch withEvent:event];
    
    CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
    
    if (self.visible && CGRectContainsPoint([self boundingBox], pnt)) {
        pnt = CGPointApplyAffineTransform(pnt, [self parentToNodeTransform]);
        touchAmp = TOUCH_AMP_START;
        touchDown = YES;
        touchPos = ccp(pnt.x / self.texture.contentSize.width, 1 - (pnt.y / self.texture.contentSize.height));
    }
   
    return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {

}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    touchDown = NO;
}

-(void) addReflectTexture:(NSString *)fileName {
    if (reflectTexture != nil) {
        [reflectTexture release];
        reflectTexture = nil;
    }
    
    reflectTexture = [[[CCTextureCache sharedTextureCache] addImage:fileName] retain];
}

@end
