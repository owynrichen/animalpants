//
//  FlagLayer.m
//  FootGame
//
//  Created by Owyn Richen on 2/17/13.
//
//

#import "FlagNode.h"
#import "CCSpriteFrameCache+Enumerable.h"

#define CROSSFADE_TIME 2.0
#define DELAY_TIME 1.0

@interface FlagNode()

-(void) setupCrossfade: (CCNode *) node;

@end

@implementation FlagNode

+(FlagNode *) flagNodeWithLanguage: (NSString *) lang {
    return [[FlagNode alloc] initWithLanguage:lang];
}

-(id) initWithLanguage: (NSString *) lang {
    self = [super init];
    
    currentFlagIndex = 0;
    
    NSString *dotLang = [NSString stringWithFormat:@".%@", lang];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"flags2.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] eachFrameWithBlock:^(NSString *key, CCSpriteFrame *frame) {
        if ([key hasPrefix:@"flag-"] && [key rangeOfString:dotLang options:NSCaseInsensitiveSearch].location != NSNotFound) {
            CCSprite *sprite = [CCSprite spriteWithSpriteFrame:frame];
            sprite.opacity = 0;
            [self addChild:sprite];
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

-(void) setColor:(ccColor3B)color {
    color_ = color;
    for (int i = 0; i < [self.children count]; i++) {
        CCSprite *sprite = (CCSprite *) [self.children objectAtIndex:i];
        sprite.color = color;
    }
}

-(ccColor3B) color {
    return color_;
}

-(GLubyte) opacity {
    return opacity_;
}

-(void) setOpacity: (GLubyte) opacity {
    opacity_ = opacity;
    for (int i = 0; i < [self.children count]; i++) {
        CCSprite *sprite = (CCSprite *) [self.children objectAtIndex:i];
        sprite.opacity = opacity;
    }
}

@end
