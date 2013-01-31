//
//  BlurGrid3D.m
//  FootGame
//
//  Created by Owyn Richen on 9/18/12.
//
//

#import "FadeGrid3D.h"
#import "CCGLProgram.h"

@implementation FadeGridAction

@synthesize sigma;
@synthesize desaturate;


-(CCGridBase *)grid {
    return [FadeGrid3D gridWithSize:gridSize_];
}

+(FadeGridAction *) actionWithDuration:(ccTime)d sigmaStart: (GLfloat) sStart sigmaEnd: (GLfloat) sEnd desaturateStart: (GLfloat) dStart desaturateEnd: (GLfloat) dEnd {
    FadeGridAction *act = [[[FadeGridAction alloc] initWithDuration:d sigmaStart:sStart sigmaEnd:sEnd desaturateStart:dStart desaturateEnd:dEnd] autorelease];
    
    return act;
}

-(id) initWithDuration:(ccTime)d sigmaStart: (GLfloat) sStart sigmaEnd: (GLfloat) sEnd desaturateStart: (GLfloat) dStart desaturateEnd: (GLfloat) dEnd {
    self = [super initWithSize:ccg(1,1) duration:d];
    
    sigStart = sStart;
    sigEnd = sEnd;
    sig = fabsf(sEnd - sStart);
    desStart = dStart;
    desEnd = dEnd;
    des = fabsf(desEnd - desStart);
    
    self.sigma = sigStart;
    self.desaturate = desStart;
    
    return self;
}

-(void) update:(ccTime)time {
    FadeGrid3D *mygrid = (FadeGrid3D *) [target_ grid];
    
    if (desEnd >= desStart) {
        self.desaturate = des * time;
        self.sigma = sig * time;
    } else {
        self.desaturate = des * (1.0 - time);
        self.sigma = sig * (1.0 - time);
    }
    
    mygrid.desaturate = self.desaturate;
    mygrid.sigma = self.sigma;
    
    if ([self isDone]) {
        if (self.desaturate == 0 && self.sigma == 0) {
            [[target_ grid] setActive:NO];
            [target_ setGrid:nil];
        }
    }
}

@end

@implementation FadeGrid3D

@synthesize sigma = sigma_;
@synthesize desaturate;

-(id) initWithSize:(ccGridSize)gridSize texture:(CCTexture2D *)texture flippedTexture:(BOOL)flipped {
    self = [super initWithSize:gridSize texture:texture flippedTexture:flipped];
    
    CCGLProgram *shader = [[CCGLProgram alloc] initWithVertexShaderFilename:@"fade.vs" fragmentShaderFilename:@"fade.fs"];
    
    [shader addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[shader addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
	[shader addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
    
    [shader link];
    
    CHECK_GL_ERROR_DEBUG();
    
	[shader updateUniforms];
    
    uniformBlurSize = glGetUniformLocation(shader->program_, "u_blurSize");
    uniformDesaturate = glGetUniformLocation(shader->program_, "u_desaturate");
    
    [[CCShaderCache sharedShaderCache] addProgram:shader forKey:@"blur"];
    [shader release];
    
    shaderProgram_ = [[[CCShaderCache sharedShaderCache] programForKey:@"blur"] retain];
    
    [self setSigma:1.0];
    desaturate = 0.7;
    
    [shaderProgram_ setUniformLocation:uniformBlurSize withF1:blurSize.x f2:blurSize.y];
    [shaderProgram_ setUniformLocation:uniformDesaturate withF1:desaturate];
    
    return self;
}

-(void) setSigma:(GLfloat)sigma {
    sigma_ = sigma;
    CGSize winSize = [[CCDirector sharedDirector] winSizeInPixels];
    blurSize = ccp(1.0/winSize.width*sigma_,1.0/winSize.height*sigma_);
}

-(GLfloat) sigma {
    return sigma_;
}

-(void) dealloc {
    [shaderProgram_ release];
    [super dealloc];
}

-(void)blit
{
	NSInteger n = gridSize_.x * gridSize_.y;
    
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords );
	[shaderProgram_ use];
	[shaderProgram_ setUniformsForBuiltins];
    
    [shaderProgram_ setUniformLocation:uniformBlurSize withF1:blurSize.x f2:blurSize.y];
    [shaderProgram_ setUniformLocation:uniformDesaturate withF1:desaturate];
    
	//
	// Attributes
	//
    
	// position
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    
	// texCoods
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, texCoordinates);
    
	glDrawElements(GL_TRIANGLES, (GLsizei) n*6, GL_UNSIGNED_SHORT, indices);
	
	CC_INCREMENT_GL_DRAWS(1);
}

@end
