//
//  CPBody.m
//  FootGame
//
//  Created by Owyn Richen on 5/27/13.
//
//

#import "CPWrappers.h"
#import "chipmunk.h"

@implementation CPBody

+(id) create: (cpBody *) b {
    return [[[self alloc] initWithBody:b] autorelease];
}

-(id) initWithBody: (cpBody *) b {
    self = [super init];
    _body = b;
    return self;
}

@end

@implementation CPConstraint

+(id) create: (cpConstraint *) b {
    return [[[self alloc] initWithConstraint:b] autorelease];
}

-(id) initWithConstraint: (cpConstraint *) b {
    self = [super init];
    _constraint = b;
    return self;
}

@end