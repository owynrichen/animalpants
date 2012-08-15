//
//  BitVector.h
//  FootGame
//
//  Created by Owyn Richen on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BitVector : NSObject {
    signed char *byteArray;
    size_t width;
    size_t height;
}

-(id) initWithImage:(CGImageRef) img upsideDown: (BOOL) upsideDown;
-(id) initWithSprite: (CCSprite *) sprite;
-(id) initWithData: (const UInt32 *) data width: (size_t) width height: (size_t) height upsideDown: (BOOL) upsideDown;

-(BOOL) hitx:(int) x  y: (int) y;

@end
