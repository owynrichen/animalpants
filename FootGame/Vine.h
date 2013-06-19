//
//  Vine.h
//  FootGame
//
//  Created by Owyn Richen on 5/30/13.
//
//

#import <UIKit/UIKit.h>
#import "chipmunk.h"

@interface Vine : CCNode {
    NSMutableArray *constraints;
    cpSpace *_physicsSpace;
    cpShape *rootShape;
}

+(id) vineWithSpace: (cpSpace *) space;

-(id) initWithSpace: (cpSpace *) space;

@end
