//
//  BlockBehavior.h
//  FootGame
//
//  Created by Owyn Richen on 1/10/13.
//
//

#import "Behavior.h"

@interface BlockBehavior : Behavior {
    void (^block)(CCNode * sender);
}

+(BlockBehavior *) behaviorFromKey: (NSString *) key dictionary: (NSDictionary *) data block: (void (^)(CCNode * sender)) blk;

-(id) initWithKey:(NSString *)k data:(NSDictionary *)d block: (void (^)(CCNode * sender)) blk;

@end
