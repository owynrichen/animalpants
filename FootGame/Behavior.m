//
//  Behavior.m
//  FootGame
//
//  Created by Owyn Richen on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Behavior.h"

@implementation Behavior

@synthesize key;
@synthesize event;
@synthesize data;

+(Behavior *) behaviorFromKey: (NSString *) key dictionary: (NSDictionary *) data {
    Behavior *b = [[(Behavior *) [Behavior alloc] initWithKey:key data:data] autorelease];
    
    return b;
}

-(id) initWithKey: (NSString *) k data: (NSDictionary *) d {
    self = [super init];
    
    srand(time(nil));
    
    self.key = k;
    self.data = d;
    self.event = [self.data objectForKey:@"event"];
    
    return self;
}

-(CCAction *) getAction: (CCNode *) node withParams: (NSDictionary *) p {
    NSString *action = (NSString *) [data objectForKey:@"action"];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *) [data objectForKey:@"params"]];
    [params setObject:node forKey:@"node"];
    
    [params setValuesForKeysWithDictionary:p];
    
    NSDictionary *origParams = (NSDictionary *) node.userData;
    NSDictionary *origPos = [origParams objectForKey:@"position"];
    [params setObject:[origPos objectForKey:@"x"] forKey:@"original_x"];
    [params setObject:[origPos objectForKey:@"y"] forKey:@"original_y"];
    
    NSNumber *origRotation = [origParams objectForKey:@"rotate"];
    if (origRotation == nil) {
        origRotation = [NSNumber numberWithFloat:0.0];
    }
    [params setObject:origRotation forKey:@"original_rotate"];
    
    NSDictionary *origScale = [origParams objectForKey:@"scale"];
    
    if (origScale == nil) {
        [params setObject:[NSNumber numberWithFloat:1.0] forKey:@"original_scaleX"];
        [params setObject:[NSNumber numberWithFloat:1.0] forKey:@"original_scaleY"];
    } else {
        [params setObject:[origScale objectForKey:@"x"] forKey:@"original_scaleX"];
        [params setObject:[origScale objectForKey:@"y"] forKey:@"original_scaleY"];
    }

    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", action]);
    CCAction *act = nil;
        
    if (sel != nil) {
        act = [self performSelector:sel withObject:params];
    }
        
    if (action != nil) {
        return act;
    } else {
        NSLog(@"Unknown action %@ in set %@", action, [data description]);
    }
    
    return nil;
}

-(float) randWithBase: (float) base deviation: (float) dev {
    int halfDev = dev * 0.5 * 1000;
    int newDev = dev * 1000;
    
    float r = base + ((float)((rand() % halfDev) - (rand() % newDev)) / 1000.0);
    
    return r;
}

-(CGPoint) randXYWithBase: (CGPoint) base deviation: (CGPoint) dev {
    return CGPointMake([self randWithBase:base.x deviation:dev.x], [self randWithBase:base.y deviation:dev.y]);
}


-(CGPoint) getOriginalPosition: (NSDictionary *) params {
    return CGPointMake([((NSNumber *)[params objectForKey:@"original_x"]) floatValue], [((NSNumber *)[params objectForKey:@"original_y"]) floatValue]);
}

-(float) getOriginalRotation: (NSDictionary *) params {
    return [((NSNumber *) [params objectForKey:@"original_rotate"]) floatValue];
}

-(CCFiniteTimeAction *) resetPositionAction: (NSDictionary *) params {
    return [CCMoveTo actionWithDuration:0.1 position: [self getOriginalPosition:params]];
}

-(CCFiniteTimeAction *) resetRotationAction: (NSDictionary *) params {
    return [CCRotateTo actionWithDuration:0.1 angle:[self getOriginalRotation:params]];
}

-(CCFiniteTimeAction *) resetScaleAction: (NSDictionary *) params {
    return [CCScaleTo actionWithDuration:0.1 scaleX:[((NSNumber *) [params objectForKey:@"original_scaleX"]) floatValue] scaleY:[((NSNumber *) [params objectForKey:@"original_scaleY"]) floatValue]];
}

-(CCFiniteTimeAction *) resetNodeAction:(NSDictionary *)params {
    return [CCSpawn actions:[self resetPositionAction:params], [self resetRotationAction:params], [self resetScaleAction:params], nil];
}

-(CCAction *) move: (NSDictionary *) params {
    float duration = [(NSNumber *) [params objectForKey:@"duration"] floatValue];
    NSDictionary *pos = [params objectForKey:@"position"];
    float x = [(NSNumber *) [pos objectForKey:@"x"] floatValue];
    float y = [(NSNumber *) [pos objectForKey:@"y"] floatValue];
    
    return [CCMoveBy actionWithDuration:duration position:ccpToRatio(x, y)];
}

-(CCAction *) rotate: (NSDictionary *) params {
    float duration = [(NSNumber *) [params objectForKey:@"duration"] floatValue];
    float angle = [(NSNumber *) [params objectForKey:@"rotation"] floatValue];
    
    return [CCRotateBy actionWithDuration:duration angle:angle];
}

-(CCAction *) tint: (NSDictionary *) params {
    float duration = [(NSNumber *) [params objectForKey:@"duration"] floatValue];
    NSDictionary *color = [params objectForKey:@"color"];
    GLubyte r = [(NSNumber *) [color objectForKey:@"r"] intValue];
    GLubyte g = [(NSNumber *) [color objectForKey:@"g"] intValue];
    GLubyte b = [(NSNumber *) [color objectForKey:@"b"] intValue];

    return [CCTintTo actionWithDuration:duration red:r green:g blue:b];
}

@end
