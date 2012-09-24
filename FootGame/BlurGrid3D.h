//
//  BlurGrid3D.h
//  FootGame
//
//  Created by Owyn Richen on 9/18/12.
//
//

#import "CCGrid.h"

@interface BlurGrid3D : CCGrid3DAction  {
    GLint uniformBlurSize, uniformSubstract, uniformDesaturate;
    CGPoint blurSize;
    GLfloat substract[4];
    GLfloat desaturate;
}

@end
