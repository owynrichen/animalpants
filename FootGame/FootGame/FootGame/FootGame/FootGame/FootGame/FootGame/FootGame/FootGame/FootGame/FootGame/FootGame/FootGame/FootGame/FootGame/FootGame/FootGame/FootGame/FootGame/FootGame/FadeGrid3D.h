//
//  BlurGrid3D.h
//  FootGame
//
//  Created by Owyn Richen on 9/18/12.
//
//

#import "CCGrid.h"

@interface FadeGrid3D : CCGrid3D {
    GLint uniformBlurSize, uniformDesaturate;
    CGPoint blurSize;    
}

@property GLfloat sigma;
@property GLfloat desaturate;

@end

@interface FadeGridAction : CCGrid3DAction {
    GLfloat sigStart;
    GLfloat sigEnd;
    GLfloat desStart;
    GLfloat desEnd;
    GLfloat sig;
    GLfloat des;
}

@property GLfloat sigma;
@property GLfloat desaturate;

+(FadeGridAction *) actionWithDuration:(ccTime)d sigmaStart: (GLfloat) sStart sigmaEnd: (GLfloat) sEnd desaturateStart: (GLfloat) dStart desaturateEnd: (GLfloat) dEnd;

-(id) initWithDuration:(ccTime)d sigmaStart: (GLfloat) sStart sigmaEnd: (GLfloat) sEnd desaturateStart: (GLfloat) dStart desaturateEnd: (GLfloat) dEnd;


@end
