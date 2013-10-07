//
//  CCSpriteFrameCache+Enumerable.m
//  FootGame
//
//  Created by Owyn Richen on 10/5/13.
//
//

#import "CCSpriteFrameCache+Enumerable.h"

@implementation CCSpriteFrameCache(Enumerable)

-(void) eachFrameWithBlock: (void (^)(NSString * key, CCSpriteFrame * frame)) block {
    [spriteFrames_ enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block((NSString *) key, (CCSpriteFrame *) obj);
    }];
}

@end
