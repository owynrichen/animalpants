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
