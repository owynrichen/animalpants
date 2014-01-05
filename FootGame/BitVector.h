//
//  BitVector.h
//  FootGame
//
//  Created by Owyn Richen on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: precache/precompute this to speed up scene loading

@interface BitVector : NSObject {
    signed char *byteArray;
    UInt32 vectorLength;
    size_t width;
    size_t height;
    float percentCoverage;
}

-(id) initWithImage:(CGImageRef) img upsideDown: (BOOL) upsideDown;
-(id) initWithSprite: (CCSprite *) sprite;
-(id) initWithData: (const UInt32 *) data width: (size_t) width height: (size_t) height upsideDown: (BOOL) upsideDown;
-(float) getPercentCoverage;

-(BOOL) hitx:(int) x  y: (int) y;
-(BOOL) hitx:(int) x y: (int) y radius: (int) radius;

@end
