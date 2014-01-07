//
//  CCBaseLayer.m
//  FootGame
//
//  Created by Richen, Owyn on 1/4/14.
//
//

#import "CCBaseLayer.h"

@implementation CCBaseScene

-(void) enableTouches: (BOOL) on {
    for (int i = 0; i < [children_ count]; i++) {
        if ([[children_ objectAtIndex:i] respondsToSelector:@selector(enableTouches:)]) {
            [[children_ objectAtIndex:i] enableTouches:on];
        }
    }
}

@end


@implementation CCBaseLayer

-(id) init {
    self = [super init];
    paused = YES;
    
    return self;
}

- (void) enableTouches: (BOOL) on {
    for (int i = 0; i < [children_ count]; i++) {
        if ([[children_ objectAtIndex:i] respondsToSelector:@selector(enableTouches:)]) {
            [[children_ objectAtIndex:i] enableTouches:on];
            continue;
        }
        
        if ([[children_ objectAtIndex:i] respondsToSelector:@selector(setEnabled:)]) {
            [[children_ objectAtIndex:i] setEnabled:on];
        }
    }
}

-(void) setColor:(ccColor3B)color {

}

-(ccColor3B) color {
    return ccWHITE;
}

-(GLubyte) opacity {
    return 255;
}

-(void) setOpacity: (GLubyte) opacity {
    
}

@end
