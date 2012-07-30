//
//  SpeechBubble.m
//  FootGame
//
//  Created by Owyn Richen on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SpeechBubble.h"
#import "CCAutoScaling.h"

@implementation SpeechBubble

-(id) initWithStoryKey:(NSString *)storyKey typingInterval: (ccTime) ival {
    self = [super init];
    
    storyText = NSLocalizedStringFromTable(storyKey, @"strings", @"");
    
    label = [CCLabelTTFWithStroke labelWithString:@"" fontName:@"Marker Felt" fontSize:40 * fontScaleForCurrentDevice()];
    label.color = ccWHITE;
    label.strokeSize = 3 * fontScaleForCurrentDevice();
    label.strokeColor = ccBLACK;
    label.anchorPoint = ccp(0,0);
    label.position = ccpToRatio(50, 50);
    [label drawStroke];
    
    [self addChild:label];
    interval = ival;

    return self;
}

-(void) start {
    CCCallBlockN *updateTxt = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        int index = [label.string length] + 1;
        if (index > storyText.length) {
            index = storyText.length;
        }
        [label setString:[storyText substringToIndex:index]];
        [label drawStroke];
    }];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:interval];
    CCSequence *update = [CCSequence actions:updateTxt, delay, nil];
    
    CCRepeat *repeat = [CCRepeat actionWithAction:update times:[storyText length]];
    [label runAction:repeat];
}

@end
