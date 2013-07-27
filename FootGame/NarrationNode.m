//
//  NarrationLayer.m
//  FootGame
//
//  Created by Owyn Richen on 5/17/13.
//
//

#import "NarrationNode.h"
#import "SoundManager.h"
#import "LocalizationManager.h"
#import "CCAutoScaling.h"

@implementation NarrationNode

-(id) initWithSize: (CGSize) talkSize {
    self = [super init];
    
    tSize = talkSize;
    
    return self;
}

-(void) startWithCues: (AudioCues *) cues finishBlock: (void (^)(CCNode *node)) callback {
    [self startForLanguage:[[LocalizationManager sharedManager] getAppPreferredLocale] cues:cues finishBlock:callback];
}

-(void) startForLanguage: (NSString *) lang cues: (AudioCues *) cues finishBlock: (void (^)(CCNode *node)) callback {
    audioCues = cues;
    
    if (finishBlock != nil) {
        [finishBlock release];
        finishBlock = nil;
    }
    
    finishBlock = [callback copy];
    storyText = [[LocalizationManager sharedManager] getLocalizedStringForKey:cues.storyKey fromTable:@"strings" forLanguage:lang];
    
    [self removeAllChildrenWithCleanup:YES];
    label = [[CCLabelBMFont alloc] initWithString:@"" fntFile:@"CooperBlack.fnt" width:tSize.width alignment:kCCTextAlignmentLeft];

    label.anchorPoint = ccp(0,0);
    label.position = ccp(0,0);
    
    [self addChild:label];

    [[SoundManager sharedManager] playSoundWithCues:audioCues withDelegate:self];
}

-(void) clear {
    label.string = @"";
}

-(void) stop {
    if (audioCues)
        [audioCues stop];
}

-(void) cuedAudioStarted: (AudioCues *) cues {
    // NSLog(@"CUES: cue started");
}
-(void) cuedAudioComplete: (AudioCues *) cues {
    // NSLog(@"CUES: cue complete");
    
    if (finishBlock != nil) {
        finishBlock(label);
    }
}

-(void) cuedAudioStopped:(AudioCues *)cues {
    
}

-(void) cueHit: (AudioCues *) cues forCueKey: (NSString *) key atTime: (ccTime) time {
    NSDictionary *currentCue = (NSDictionary *) [cues.cues objectForKey:key];
    // NSNumber *startIndex = (NSNumber *) [currentCue objectForKey:@"startIndex"];
    NSNumber *endIndex = (NSNumber *) [currentCue objectForKey:@"end_index"];
    int e = [endIndex intValue];
    
    if (e == 0) {
        // NSLog(@"CUES: cue '%@' hit at %f - finishing...", key, time);
        return;
    }
    
    if (e > storyText.length) {
        e = storyText.length;
    }
    
    // NSLog(@"CUES: cue '%@' hit at %f", key, time);
    
    [label setString:[storyText substringToIndex:e]];
    [label visit];
}

-(void) setColor:(ccColor3B)color {
    label.color = color;
}

-(ccColor3B) color {
    return label.color;
}

-(GLubyte) opacity {
    return label.opacity;
}

-(void) setOpacity: (GLubyte) opacity {
    label.opacity = opacity;
}

@end
