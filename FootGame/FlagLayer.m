//
//  FlagLayer.m
//  FootGame
//
//  Created by Owyn Richen on 2/17/13.
//
//

#import "FlagLayer.h"

#define CROSSFADE_TIME 2.0
#define DELAY_TIME 1.0

@interface FlagLayer()

-(void) setupCrossfade: (CCNode *) node;

@end

@implementation FlagLayer

+(FlagLayer *) flagLayerWithLanguage: (NSString *) lang {
    return [[FlagLayer alloc] initWithLanguage:lang];
}

-(id) initWithLanguage: (NSString *) lang {
    self = [super init];
    
    currentFlagIndex = 0;
    
    NSMutableArray* paths = [NSMutableArray arrayWithArray:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                                               NSUserDomainMask, YES)];
    [paths addObject:[[NSBundle mainBundle] bundlePath]];
    
    // [self loadFromOldFile];
    [paths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSEnumerator *enumerator = [[NSFileManager defaultManager]
                                    enumeratorAtPath:(NSString *) obj];
        
        NSString *path = nil;
        NSString *dotLang = [NSString stringWithFormat:@".%@", lang];
        
        while (path = (NSString *) [enumerator nextObject]) {
            NSArray *components = [path pathComponents];
            NSString *filename = [components objectAtIndex:[components count] - 1];
            
            if ([filename hasPrefix:@"flag-"] &&
                [filename rangeOfString:dotLang options:NSCaseInsensitiveSearch].location != NSNotFound &&
                [filename rangeOfString:@"-ipadhd" options:NSCaseInsensitiveSearch].location == NSNotFound &&
                [filename rangeOfString:@"-ipad" options:NSCaseInsensitiveSearch].location == NSNotFound &&
                [filename rangeOfString:@"-hd" options:NSCaseInsensitiveSearch].location == NSNotFound) {
                
                CCSprite *sprite = [CCSprite spriteWithFile:filename];
                sprite.opacity = 0;
                [self addChild:sprite];
            }
        }

    }];
    
    return self;
}

-(void) onEnter {
    [super onEnter];
    
    CCSprite *curNode = (CCSprite *) [self.children objectAtIndex:currentFlagIndex];
    curNode.opacity = 255;
    [self setupCrossfade:curNode];
}

-(void) setupCrossfade: (CCNode *) cfNode {
    CCDelayTime *delay = [CCDelayTime actionWithDuration:DELAY_TIME];
    CCCallBlockN *action = [CCCallBlockN actionWithBlock:^(CCNode *anode) {
        [anode runAction:[CCFadeOut actionWithDuration:CROSSFADE_TIME]];
        currentFlagIndex += 1;
        if (currentFlagIndex >= [self.children count]) {
             currentFlagIndex = 0;
        }
         
        CCSprite *nextNode = (CCSprite *) [self.children objectAtIndex:currentFlagIndex];
        CCSequence *seq = [CCSequence actions:[CCFadeIn actionWithDuration:CROSSFADE_TIME], [CCCallBlockN actionWithBlock:^(CCNode *bnode) {
            [self setupCrossfade:bnode];
        }],nil];
        [nextNode runAction:seq];
    }];
    
    [cfNode runAction:[CCSequence actions:delay, action, nil]];
}

@end
