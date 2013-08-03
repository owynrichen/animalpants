//
//  Environment.m
//  FootGame
//
//  Created by Owyn Richen on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Environment.h"
#import "CCAutoScaling.h"
#import "Water.h"
#import "Vine.h"
#import "RopeNode.h"

@interface Environment(Layers)

// TODO: make this dynamic instead of stupid
-(CCAutoScalingSprite *) getAutoScalingSprite: (NSDictionary *) data withSpace: (cpSpace *) space;
-(Water *) getWater: (NSDictionary *) data withSpace: (cpSpace *) space;
-(RopeNode *) getVine: (NSDictionary *) data withSpace: (cpSpace *) space;
// END TODO
-(void) applyCommonParameters: (NSDictionary *) parameters toNode: (CCNode *) node;
-(void) applyBehaviors: (NSDictionary *) parameters toNode: (CCNode<BehaviorManagerDelegate> *) node;

-(CGPoint) parsePosition: (NSDictionary *) position;

-(void) enumerateLayersWithBlock: (void (^)(NSDictionary * obj)) blk;

@end

@implementation Environment

@synthesize key;
@synthesize layers;
@synthesize animalPosition;
@synthesize textPosition;
@synthesize kidPosition;
@synthesize storyKey;
@synthesize bgMusic;
@synthesize ambientFx;

-(id) initWithDictionary: (NSDictionary *) setupData {
    self = [super init];
    
    mfest = [[ContentManifest alloc] init];
    
    self.key = (NSString *) [setupData objectForKey:@"Key"];
    self.layers = [setupData retain];
    self.animalPosition = [self parsePosition:(NSDictionary *) [self.layers objectForKey:@"AnimalPosition"]];
    self.textPosition = [self parsePosition:(NSDictionary *) [self.layers objectForKey:@"TextPosition"]];
    self.kidPosition = [self parsePosition:(NSDictionary *) [self.layers objectForKey:@"KidPosition"]];
    self.storyKey = (NSString *) [self.layers objectForKey:@"StoryKey"];
    self.bgMusic = (NSString *) [setupData objectForKey:@"Music"];
    self.ambientFx = (NSString *) [setupData objectForKey:@"Ambient"];
    
    [mfest addAudioFile:self.bgMusic];
    [mfest addAudioFile:self.ambientFx];
    [self enumerateLayersWithBlock:^(NSDictionary *obj) {
        [mfest addImageFile:[obj objectForKey:@"imageName"]];
        if ([obj objectForKey:@"reflectImageName"]) {
            [mfest addImageFile:[obj objectForKey:@"reflectImageName"]];
        }
    }];

    return self;
}

-(void) dealloc {
    [mfest release];
    
    [super dealloc];
}

+(Environment *) initWithDictionary:(NSDictionary *)setupData {
    Environment *env = [[Environment alloc] initWithDictionary:setupData];
    
    return [env autorelease];
}

-(ContentManifest *) manifest {
    return [[mfest copy] autorelease];
}

-(CCAutoScalingSprite *) getAutoScalingSprite: (NSDictionary *) data withSpace:(cpSpace *)space {
    NSString *img = (NSString *) [data objectForKey:@"imageName"];
    CCAutoScalingSprite *sprite = [CCAutoScalingSprite spriteWithFile:img space:space];
    [self applyCommonParameters:data toNode:sprite];
    return sprite;
}

-(Water *) getWater: (NSDictionary *) data withSpace:(cpSpace *)space {
    NSString *img = (NSString *) [data objectForKey:@"imageName"];
    Water *sprite = [Water spriteWithFile:img space:space];
    [sprite addReflectTexture:[data objectForKey:@"reflectImageName"]];
    [self applyCommonParameters:data toNode:sprite];
    return sprite;
}

-(RopeNode *) getVine: (NSDictionary *) data withSpace: (cpSpace *) space {
    CGPoint pos = [self parsePosition:[data objectForKey:@"position"]];
    
    cpBody *b1 = cpSpaceGetStaticBody(space);
    b1->p = cpv(pos.x, pos.y);
    
    cpShape *rootShape = cpBoxShapeNew(b1, 1.0, 1.0);
    rootShape->e = 1.0f;
    rootShape->u = 1.0f;
    cpSpaceAddShape(space, rootShape);
    
    cpBody *b2 = cpBodyNew(1, INFINITY);
    b2->p = ccp(420,50);
    b2->a = 0;
    cpSpaceAddBody(space, b2);
    cpShape *s2 = cpBoxShapeNew(b2, 10, 10);
    cpSpaceAddShape(space, s2);
    
    CPBody *bod1 = [CPBody create:b1];
    CPBody *bod2 = [CPBody create:b2];

    RopeNode *vine = [[[RopeNode alloc] initWithLength:20.0f segments:5 body1:bod1 body2:bod2 offset1:ccp(0,0) offset2:ccp(0,0)] autorelease];
    // Vine *vine = [Vine vineWithSpace:space];
    [self applyCommonParameters:data toNode:vine];
    return vine;
}

-(CGPoint) parsePosition: (NSDictionary *) position {
    CGPoint coord = [self parseCoordinate:position];
    return ccpToRatio(coord.x, coord.y);
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
    
    if ([parameters objectForKey:@"scale"] != nil) {
        CGPoint scale = [self parseCoordinate:[parameters objectForKey:@"scale"]];
        
        node.scaleX = scale.x;
        node.scaleY = scale.y;
    }
    
    // TODO: make this around a different anchor?
    if ([parameters objectForKey:@"rotate"] != nil) {
        NSNumber *rot = (NSNumber *) [parameters objectForKey:@"rotate"];
        node.rotation = [rot floatValue];
    }
    
    node.userData = parameters;
    
    if ([node.class conformsToProtocol:@protocol(BehaviorManagerDelegate)]) {
        [self applyBehaviors:parameters toNode:(CCNode<BehaviorManagerDelegate> *) node];
    } else {
        NSLog(@"node %@ doesn't conform to BehaviorManagerDelegate protocol, skipping applying behaviors", [node description]);
    }
}

-(void) enumerateLayersWithBlock: (void (^)(NSDictionary * o)) blk {
    [self.layers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            blk((NSDictionary *) obj);
        }
    }];
}

-(EnvironmentLayer *) getLayerwithSpace: (cpSpace *) physicsSpace {
    __block EnvironmentLayer *env = [EnvironmentLayer node];
    
    env.animalPosition = self.animalPosition;
    env.textPosition = self.textPosition;
    env.kidPosition = self.kidPosition;
    env.storyKey = self.storyKey;
    env.key = self.key;
 
    [self enumerateLayersWithBlock:^(NSDictionary *obj) {
        NSString *type = (NSString *) [obj objectForKey:@"type"];
        if ([type isEqualToString:@"CCAutoScalingSprite"]) {
            [env addChild:[self getAutoScalingSprite:obj withSpace:physicsSpace]];
        } else if ([type isEqualToString:@"Water"]) {
            [env addChild:[self getWater:obj withSpace:physicsSpace]];
        } else if ([type isEqualToString:@"Vine"]) {
            [env addChild:[self getVine: obj withSpace: physicsSpace]];
        } else {
            NSLog(@"Unexpected type %@ in set %@", type, [obj description]);
        }
    }];

    return env;
}

@end
