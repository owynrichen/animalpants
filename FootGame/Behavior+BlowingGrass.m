//
//  Behavior+BlowingGrass.m
//  FootGame
//
//  Created by Owyn Richen on 12/26/12.
//
//

#import "Behavior+BlowingGrass.h"

@implementation Behavior(BlowingGrass)

-(CCAction *) windyGrass: (NSDictionary *) params {
    CCSprite *node = (CCSprite *) [params objectForKey:@"node"];
    NSNumber *durNum = (NSNumber *) [params objectForKey:@"duration"];
    NSNumber *durDevNum = (NSNumber *) [params objectForKey:@"durationDeviation"];
    NSNumber *skewBaseNum = (NSNumber *) [params objectForKey:@"skew"];
    NSNumber *skewDevNum = (NSNumber *) [params objectForKey:@"skewDeviation"];
    
    float duration, durationDeviation, skew, skewDev;
    
    if (durNum != nil) {
        duration = [durNum floatValue];
    } else {
        duration = 3.5;
    }
    
    if (durDevNum != nil) {
        durationDeviation = [durDevNum floatValue];
    } else {
        durationDeviation = 1.0;
    }
    
    if (skewBaseNum != nil) {
        skew = [skewBaseNum floatValue];
    } else {
        skew = 4.25;
    }
    
    if (skewDevNum != nil) {
        skewDev = [skewDevNum floatValue];
    } else {
        skewDev = 2.5;
    }
    
    float dur = [self randWithBase:duration deviation:durationDeviation];
    float revDur = [self randWithBase:duration deviation:durationDeviation];
    float x = [self randWithBase:skew deviation:skewDev];
    float revX = -[self randWithBase:skew deviation:skewDev];
    
    double side = node.contentSize.height;
    double skewPix2 = (pow(side, 2.0) + pow(side, 2.0)) - (2.0 * side * side * cos(x * M_PI/180));
    double skewPix = sqrt(skewPix2);
    double scaleX = (skewPix * 2.0 + node.contentSize.width) / (double) node.contentSize.width;
    node.scaleX = scaleX;
    node.position = ccp(node.position.x - skewPix, node.position.y);
    
    CCSkewTo *skewTo = [CCSkewTo actionWithDuration:dur skewX:x skewY:0];
    CCSkewTo *revSkewTo = [CCSkewTo actionWithDuration:revDur skewX:revX skewY:0];
    
    return [CCRepeatForever actionWithAction:[CCSequence actions:skewTo, revSkewTo, nil]];
}

@end
