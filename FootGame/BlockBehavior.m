//
//  BlockBehavior.m
//  FootGame
//
//  Created by Owyn Richen on 1/10/13.
//
//

#import "BlockBehavior.h"

@implementation BlockBehavior

+(BlockBehavior *) behaviorFromKey: (NSString *) key dictionary: (NSDictionary *) data block: (void (^)(id sender)) blk {
    BlockBehavior *b = [[(BlockBehavior *) [BlockBehavior alloc] initWithKey:key data:data block: blk] autorelease];
    
    return b;
}

-(id) initWithKey:(NSString *)k data:(NSDictionary *)d block: (void (^)(id sender)) blk {
    self = [super initWithKey:k data:d];
    block = blk;
    
    return self;
}

-(void) dealloc {
    block = nil;
    [super dealloc];
}

-(CCAction *) getAction:(CCNode *)node withParams:(NSDictionary *)p {
    return [CCCallBlockN actionWithBlock:block];
}

@end
