//
//  BitVector.m
//  FootGame
//
//  Created by Owyn Richen on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BitVector.h"

#define BITMASK 1

@implementation BitVector

-(id) initWithImage:(CGImageRef) img upsideDown:(BOOL)upsideDown {
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(img));
    const UInt32* imagePixels = (const UInt32*)CFDataGetBytePtr(data);
    
    self = [self initWithData:imagePixels width:CGImageGetWidth(img) height: CGImageGetHeight(img) upsideDown:upsideDown];
    
    CFRelease(data);
    return self;
}

-(id) initWithSprite: (CCSprite *) sprite {
    CCRenderTexture *rt = [[CCRenderTexture alloc] initWithWidth:sprite.contentSize.width height:sprite.contentSize.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
    CGPoint aPoint = sprite.anchorPoint;
    sprite.anchorPoint = ccp(0,0);
    
    [rt begin];
    [sprite visit];
    [rt end];
    
    sprite.anchorPoint = aPoint;
    
    CGImageRef img = [rt newCGImage];
    
    self = [self initWithImage:img upsideDown:NO];
    
    CGImageRelease(img);
    img = nil;
    [rt release];
    rt = nil;
    
    return self;
}

-(id) initWithData: (const UInt32 *) imagePixels width: (size_t) w height: (size_t) h upsideDown:(BOOL)upsideDown {
    self = [super init];
    
    width = w;
    height = h;
    
    UInt32 pixelMask = width * height;
    UInt32 hitPixels = 0;
    
    UInt32 alphaValue = 0, x = 0, y = height - 1;
    if (!upsideDown) {
        y = 0;
    }
    
#ifndef BITMASK
    byteArray = malloc(pixelMask * sizeof(char));
    memset(byteArray, 0, pixelMask * sizeof(char));
#else
    byteArray = malloc(pixelMask / 8);
    memset(byteArray, 0, pixelMask / 8);
#endif
    
    for(int i = 0; i < pixelMask; i++) {
        NSUInteger index = y * width + x;
        x++;
        if (x >= width) {
            x = 0;
            if (upsideDown) {
                y--;
            } else {
                y++;
            }
        }
        
        alphaValue = imagePixels[index] & 0xff000000;
        if (alphaValue > 0)
        {
            // get the alpha value, then compare alpha with the alpha threshold
            UInt8 alpha = (UInt8)(alphaValue >> 24);
            if (alpha > 128)
            {
                hitPixels++;
#ifndef BITMASK
                byteArray[index] = YES;
#else
                byteArray[index / 8] |= (0x80 >> (index % 8));
#endif
            }
        }
    }
    
    percentCoverage = ((float) hitPixels / (float) pixelMask) * 100;
    
    return self;
}
                         
-(void) dealloc {
//    CFRelease(bitVector);
    free(byteArray);
    [super dealloc];
}

-(float) getPercentCoverage {
    return percentCoverage;
}

-(BOOL) hitx:(int) x  y: (int) y {
    x = x * CC_CONTENT_SCALE_FACTOR();
    y = y * CC_CONTENT_SCALE_FACTOR();
    if (x > width || x < 0 || y > height || y < 0)
        return NO;
    // because sprites are upside down on draw, invert the y
#ifndef BITMASK
    BOOL val = byteArray[((height - y) * width + x) * sizeof(BOOL)];
    return val;
#else
    int index = ((height - y) * width + x);
    signed char offset = (0x80 >> (index % 8));
    
    return (byteArray[index / 8] & offset) == offset;
#endif
}

-(BOOL) hitx:(int) x y: (int) y radius: (int) radius {
    // TODO: switch how we test to fan out from the center
    // to improve short-circuit chances
    for(int xt = x - radius; xt <= x + radius; xt++) {
        for(int yt = y - radius; yt <= y + radius; yt++) {
            BOOL hit = [self hitx:xt y:yt];
            if (hit) {
                return hit;
            }
        }
    }
    
    return NO;
}

@end
