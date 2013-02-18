//
//  CircleButton.m
//  FootGame
//
//  Created by Owyn Richen on 2/14/13.
//
//

#import "CircleButton.h"

@implementation CircleButton

+(CircleButton *) buttonWithFile: (NSString *) img {
    return [[[CircleButton alloc] initWithFile:img] autorelease];
}

+(CircleButton *) buttonWithNode: (CCNode *) node {
    return [[[CircleButton alloc] initWithNode:node] autorelease];
}

-(id) initWithFile: (NSString *) img {
    self = [self initWithNode:[CCAutoScalingSprite spriteWithFile:img]];
    
    return self;
}

-(id) initWithNode: (CCNode *) node {
    self = [super init];
    
    back = [CCAutoScalingSprite spriteWithFile:@"circle-button-back.png"];
    middle = node;
    sheen = [CCAutoScalingSprite spriteWithFile:@"circle-button-front.png"];
    
    [self addChild:back];
    [self addChild:middle];
    [self addChild:sheen];
    
    return self;
}

-(void) dealloc {
    if (back != nil)
        [back release];
    
    if (middle != nil)
        [middle release];
    
    if (sheen != nil)
        [sheen release];
    
    [super dealloc];
}


@end
