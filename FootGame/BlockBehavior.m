//
//  BlockBehavior.m
//  FootGame
//
//  Created by Owyn Richen on 1/10/13.
//
//

#import "BlockBehavior.h"

@implementation BlockBehavior

+(BlockBehavior *) behaviorFromKey: (NSString *) key dictionary: (NSDictionary *) data block: (void (^)(CCNode * sender)) blk {
    BlockBehavior *b = [[(BlockBehavior *) [BlockBehavior alloc] initWithKey:key data:data block: blk] autorelease];
    
    return b;
}

-(id) initWithKey:(NSString *)k data:(NSDictionary *)d block: (void (^)(CCNode * sender)) blk {
    self = [super initWithKey:k data:d];
    block = [blk retain];
    
    return self;
}

-(void) dealloc {
    if (block != nil) {
        [block release];
    }
    block = nil;
    [super dealloc];
}

-(CCAction *) getAction:(CCNode *)node withParams:(NSDictionary *)p {
    NSLog(@"Calling block for %@ with params %@", [node description], [p description]);
    return [CCCallBlockN actionWithBlock:block];
}

@end
