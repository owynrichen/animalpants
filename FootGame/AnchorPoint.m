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
@synthesize name;


-(void) dealloc {
    [name release];
    [super dealloc];
}
@end

@implementation AnchorPointPair

@synthesize first;
@synthesize second;

-(id) initWithFirst: (AnchorPoint *) f second: (AnchorPoint *) s {
    self = [super init];
    first = f;
    second = s;
    return self;
}

@end