//
//  CCSpriteFrameCache+Enumerable.h
//  FootGame
//
//  Created by Owyn Richen on 10/5/13.
//
//

#import "CCSpriteFrameCache.h"

@interface CCSpriteFrameCache(Enumerable)

-(void) eachFrameWithBlock: (void (^)(NSString * key, CCSpriteFrame * frame)) block;

@end
