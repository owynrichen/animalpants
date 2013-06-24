//
//  CCMenuItemImageTouchDown.m
//  FootGame
//
//  Created by Owyn Richen on 2/4/13.
//
//

#import "CCMenuItemImageTouchDown.h"

@implementation CCMenuItemImageTouchDown

-(void) dealloc {
    if (downBlock != nil)
        [downBlock release];
    
    downBlock = nil;
    
    [super dealloc];
}

-(void) addDownEvent: (void (^)(id sender)) block {
    downBlock = [block retain];
}

-(void) selected {
    [super selected];
    if (downBlock != nil) {
        downBlock(self);
    }
}

@end
