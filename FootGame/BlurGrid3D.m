//
//  BlurGrid3D.m
//  FootGame
//
//  Created by Owyn Richen on 9/18/12.
//
//

#import "BlurGrid3D.h"

@implementation BlurGrid3D

-(id) initWithSize:(ccGridSize)gridSize duration:(ccTime)d {
    self = [super initWithSize:gridSize duration:d];
    
    return self;
}

-(void)startWithTarget:(id)target {
    [super startWithTarget:target];
    
    CCGLProgram *shader = [[[CCGLProgram alloc] initWithVertexShaderFilename:@"blur.vs" fragmentShaderFilename:@"blur.fs"] autorelease];
    
    [shader addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[shader addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
	[shader addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
    
    [shader link];
    
    CHECK_GL_ERROR_DEBUG();
    
	[shader updateUniforms];
    
    uniformBlurSize = glGetUniformLocation(shader->program_, "u_blurSize");
    uniformSubstract = glGetUniformLocation( shader->program_, "u_substract");
    uniformDesaturate = glGetUniformLocation(shader->program_, "u_desaturate");
    
    [[CCShaderCache sharedShaderCache] addProgram:shader forKey:@"blur"];
    ((CCNode *) self.target).grid.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:@"blur"];
    
    CGSize winSize = [[CCDirector sharedDirector] winSizeInPixels];
    blurSize = ccp(1.0/winSize.width,1.0/winSize.height);
    substract[0] = substract[1] = substract[2] = substract[3] = 0.0;
    desaturate = 0.7;
    
    [shader setUniformLocation:uniformBlurSize withF1:blurSize.x f2:blurSize.y];
    [shader setUniformLocation:uniformSubstract with4fv:substract count:1];
    [shader setUniformLocation:uniformDesaturate withF1:desaturate];
}

-(void) update:(ccTime)time {

}

@end
