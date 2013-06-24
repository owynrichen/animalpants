//
//  EarFlagCircleButton.m
//  FootGame
//
//  Created by Owyn Richen on 6/9/13.
//
//

#import "EarFlagCircleButton.h"
#import "FlagNode.h"

@implementation EarFlagCircleButton

+(id) buttonWithLanguageCode: (NSString *) lang {
    return [[[EarFlagCircleButton alloc] initWithLanguageCode:lang] autorelease];
}

-(id) initWithLanguageCode: (NSString *) lang {
    CCSprite *ear = [CCSprite spriteWithFile:@"ear.png"];
    ear.position = ccp(0,0);
    self = [super initWithNode:ear];
    
    FlagNode *layer = [FlagNode flagNodeWithLanguage:lang];
    layer.scale = 0.4;
    layer.anchorPoint = ccp(0.5,0.5);
    layer.position = ccp(65,35);
    [self addChild:layer];
    
    return self;
}

@end
