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

@interface Environment(Layers)

// TODO: make this dynamic instead of stupid
-(CCAutoScalingSprite *) getAutoScalingSprite: (NSDictionary *) data;
-(Water *) getWater: (NSDictionary *) data;
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

-(CCAutoScalingSprite *) getAutoScalingSprite: (NSDictionary *) data {
    NSString *img = (NSString *) [data objectForKey:@"imageName"];
    CCAutoScalingSprite *sprite = [CCAutoScalingSprite spriteWithFile:img];
    [self applyCommonParameters:data toNode:sprite];
    return sprite;
}

-(Water *) getWater: (NSDictionary *) data {
    NSString *img = (NSString *) [data objectForKey:@"imageName"];
    Water *sprite = [Water spriteWithFile:img];
    [sprite addReflectTexture:[data objectForKey:@"reflectImageName"]];
    [self applyCommonParameters:data toNode:sprite];
    return sprite;
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

-(EnvironmentLayer *) getLayer {
    __block EnvironmentLayer *env = [EnvironmentLayer node];
    
    env.animalPosition = self.animalPosition;
    env.textPosition = self.textPosition;
    env.kidPosition = self.kidPosition;
    env.storyKey = self.storyKey;
    env.key = self.key;
 
    [self enumerateLayersWithBlock:^(NSDictionary *obj) {
        NSString *type = (NSString *) [obj objectForKey:@"type"];
        if ([type isEqualToString:@"CCAutoScalingSprite"]) {
            [env addChild:[self getAutoScalingSprite:obj]];
        } else if ([type isEqualToString:@"Water"]) {
            [env addChild:[self getWater:obj]];
        } else {
            NSLog(@"Unexpected type %@ in set %@", type, [obj description]);
        }
    }];

    return env;
}

@end
