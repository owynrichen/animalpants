//
//  Environment.m
//  FootGame
//
//  Created by Owyn Richen on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Environment.h"
#import "CCAutoScaling.h"

@interface Environment(Layers)

-(CCAutoScalingSprite *) getAutoScalingSprite: (NSDictionary *) data;
-(void) applyCommonParameters: (NSDictionary *) parameters toNode: (CCNode *) node;
-(void) applyBehaviors: (NSDictionary *) parameters toNode: (CCNode<BehaviorManagerDelegate> *) node;
-(CGPoint) parsePosition: (NSDictionary *) position;
@end

@implementation Environment

@synthesize key;
@synthesize layers;
@synthesize animalPosition;
@synthesize textPosition;
@synthesize kidPosition;
@synthesize storyKey;

-(id) initWithDictionary: (NSDictionary *) setupData {
    self = [super init];
    
    self.key = (NSString *) [setupData objectForKey:@"Key"];
    self.layers = [setupData retain];
    self.animalPosition = [self parsePosition:(NSDictionary *) [self.layers objectForKey:@"AnimalPosition"]];
    self.textPosition = [self parsePosition:(NSDictionary *) [self.layers objectForKey:@"TextPosition"]];
    self.kidPosition = [self parsePosition:(NSDictionary *) [self.layers objectForKey:@"KidPosition"]];
    self.storyKey = (NSString *) [self.layers objectForKey:@"StoryKey"];

    return self;
}

+(Environment *) initWithDictionary:(NSDictionary *)setupData {
    Environment *env = [[Environment alloc] initWithDictionary:setupData];
    
    return env;
}

-(CCAutoScalingSprite *) getAutoScalingSprite: (NSDictionary *) data {
    NSString *img = (NSString *) [data objectForKey:@"imageName"];
    CCAutoScalingSprite *sprite = [CCAutoScalingSprite spriteWithFile:img];
    [self applyCommonParameters:data toNode:sprite];
    return sprite;
}

-(CGPoint) parsePosition: (NSDictionary *) position {
    NSNumber *x = (NSNumber *) [position objectForKey:@"x"];
    NSNumber *y = (NSNumber *) [position objectForKey:@"y"];
    return ccpToRatio([x intValue],[y intValue]);
}

-(void) applyBehaviors: (NSDictionary *) parameters toNode: (CCNode<BehaviorManagerDelegate> *) node {
    NSDictionary *behaviors = (NSDictionary *) [parameters objectForKey:@"Behaviors"];
    
    if (behaviors == nil) {
        NSLog(@"No behaviors found in %@ for node %@", [parameters description], [node description]);
        return;
    }
    
    [behaviors enumerateKeysAndObjectsUsingBlock:^(id k, id obj, BOOL *stop) {
        Behavior *b = [Behavior behaviorFromKey:(NSString *) k dictionary:obj];
        [node.behaviorManager addBehavior: b];
    }];
}

-(void) applyCommonParameters: (NSDictionary *) parameters toNode: (CCNode *) node {
    CGPoint position = [self parsePosition:(NSDictionary *) [parameters objectForKey:@"position"]];
    
    NSNumber *z = (NSNumber *) [parameters objectForKey:@"z"];

    node.anchorPoint = ccp(0,0);
    node.position = position;
    node.zOrder = [z intValue];
    
    if ([node.class conformsToProtocol:@protocol(BehaviorManagerDelegate)]) {
        [self applyBehaviors:parameters toNode:(CCNode<BehaviorManagerDelegate> *) node];
    } else {
        NSLog(@"node %@ doesn't conform to BehaviorManagerDelegate protocol, skipping applying behaviors", [node description]);
    }
}


-(EnvironmentLayer *) getLayer {
    __block EnvironmentLayer *env = [EnvironmentLayer node];
    
    env.animalPosition = self.animalPosition;
    env.textPosition = self.textPosition;
    env.kidPosition = self.kidPosition;
    env.storyKey = self.storyKey;
    env.key = self.key;
 
    [self.layers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *data = (NSDictionary *) obj;
            NSString *type = (NSString *) [data objectForKey:@"type"];
            if (type != nil) {
                if ([type isEqualToString:@"CCAutoScalingSprite"]) {
                    [env addChild:[self getAutoScalingSprite:data]];
                } else {
                    NSLog(@"Unexpected type %@ in set %@", type, [data description]);
                }
            } else {
                
            }
        }
    }];

    return env;
}

@end
