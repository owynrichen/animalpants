//
//  CPBody.h
//  FootGame
//
//  Created by Owyn Richen on 5/27/13.
//
//

#import <Foundation/Foundation.h>
#import "chipmunk.h"

@interface CPBody : NSObject

@property (nonatomic, readonly) cpBody *body;

+(id) create: (cpBody *) b;

-(id) initWithBody: (cpBody *) b;

@end

@interface CPConstraint : NSObject

@property (nonatomic, readonly) cpConstraint *constraint;

+(id) create: (cpConstraint *) b;

-(id) initWithConstraint: (cpConstraint *) b;

@end