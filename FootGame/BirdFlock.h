//
//  BirdFlock.h
//  FootGame
//
//  Created by Owyn Richen on 9/2/13.
//
//

#import "CCNode.h"
#import "Boid.h"

@interface BirdFlock : CCNode <CCStandardTouchDelegate> {
    Boid * _flockPointer;
    
    CGPoint direction;
    NSSet *touchSet;
}

+(id) birdsWithBirds: (int) count position: (CGPoint) pos direction: (CGPoint) dir scale: (float) scale color: (ccColor3B) color;

-(id) initWithBirds: (int) count position: (CGPoint) pos direction: (CGPoint) dir scale: (float) scale color: (ccColor3B) color;

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(void) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
