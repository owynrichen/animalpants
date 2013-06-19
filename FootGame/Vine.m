//
//  Vine.m
//  FootGame
//
//  Created by Owyn Richen on 5/30/13.
//
//

#import "Vine.h"
#import "CCAutoScalingSprite.h"
#import "CPWrappers.h"

@implementation Vine

+(id) vineWithSpace: (cpSpace *) space {
    return [[[Vine alloc] initWithSpace:space] autorelease];
}

-(id) initWithSpace: (cpSpace *) space {
    self = [super init];
    _physicsSpace = space;
    constraints = [[NSMutableArray alloc] init];
    
    return self;
}

-(void) onEnter {
    [super onEnter];
    
    cpBody *sBody = cpSpaceGetStaticBody(_physicsSpace);
    sBody->p = cpv(self.position.x, self.position.y);
    
    rootShape = cpBoxShapeNew(sBody, 1.0, 1.0);
    rootShape->e = 1.0f;
    rootShape->u = 1.0f;
    cpSpaceAddShape(_physicsSpace, rootShape);
    
    CCAutoScalingSprite *oldVine = nil;
    
    int group = rand();
    
    for(int i = 0; i < 50; i++) {
        CCAutoScalingSprite *vine = [CCAutoScalingSprite spriteWithFile:@"piece_of_vine.png" space:_physicsSpace];
        vine.position = ccp(self.position.x, self.position.y + (-1 * i * (vine.contentSize.height / 2)));
        [self.parent addChild:vine z:self.zOrder];
        
        cpBody *bdy = cpBodyNew(0.3, cpMomentForBox(1, vine.contentSize.width / 2, vine.contentSize.height / 2));
        bdy->data = vine;
        bdy->p = vine.position;
        bdy->a = self.rotation;
        
        cpShape *shp = cpBoxShapeNew(bdy, vine.contentSize.width / 2, vine.contentSize.height / 2);
        shp->e = 0.0f;
        shp->u = 0.8f;
        shp->collision_type = 0;
        //shp->group = group;
        
        [vine addToSpace:_physicsSpace withBody:bdy andShape:shp];
        
        cpBody *a;
        cpBody *b;
        if (i > 0) {
            a = oldVine.physicsBody;
            b = vine.physicsBody;
        } else {
            a = sBody;
            b = vine.physicsBody;
        }
        
        cpConstraint *joint = cpPinJointNew(a, b, ccp(0, 0), ccp(0,0)); //, 1, 2);
        cpPinJointSetDist(joint, 0);
        joint->maxForce = 1000.0f;
        joint->errorBias = 0.0f;
        cpSpaceAddConstraint(_physicsSpace, joint);
        [constraints addObject:[CPConstraint create:joint]];
        oldVine = vine;
    }
}

-(void) onExit {
    [constraints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        cpSpaceRemoveConstraint(_physicsSpace, ((CPConstraint *) obj).constraint);
        cpConstraintFree(((CPConstraint *) obj).constraint);
    }];
    
    cpSpaceRemoveShape(_physicsSpace, rootShape);
    cpShapeFree(rootShape);
    [super onExit];
}


-(void) dealloc {
    [constraints release];
    constraints = nil;
    [super dealloc];
}

@end
