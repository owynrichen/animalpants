//
//  Water.h
//  FootGame
//
//  Created by Owyn Richen on 9/10/12.
//
//

#import "CCAutoScalingSprite.h"

@interface Water : CCAutoScalingSprite {
    CCTexture2D *reflectTexture;
    float		time_;
    CGPoint     touchPos;
    float       touchAmp;
    BOOL        touchDown;
	GLuint		uniformReflectTexture, uniformTime, uniformTouchPos, uniformTouchAmp;
}

-(void) addReflectTexture: (NSString *) fileName;

@end
