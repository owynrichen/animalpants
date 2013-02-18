//
//  FactDetailPopup.m
//  FootGame
//
//  Created by Owyn Richen on 2/14/13.
//
//

#import "FactDetailPopup.h"

@implementation FactDetailPopup

-(id) init {
    self = [super init];
    
    background = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 180)];
    [self addChild:background];
    
    close = [CircleButton buttonWithFile:@"close-x.png"];
    [self addChild:close];
    
    return self;
}

@end
