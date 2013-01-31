//
//  AnchorPoint.m
//  FootGame
//
//  Created by Owyn Richen on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnchorPoint.h"


@implementation AnchorPoint

@synthesize point;
@synthesize orientation;
@synthesize name;

-(void) dealloc {
    [name release];
    [super dealloc];
}
@end

@implementation AnchorPointPair

@synthesize first;
@synthesize second;
@synthesize distance;

-(id) initWithFirst: (AnchorPoint *) f second: (AnchorPoint *) s distance: (CGFloat) dist {
    self = [super init];
    first = f;
    second = s;
    distance = dist;
    return self;
}

@end