//
//  SpeechBubble.h
//  FootGame
//
//  Created by Owyn Richen on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCLabelTTFWIthStroke.h"
#import "AudioCues.h"

@interface SpeechBubble : CCLayer<CCRGBAProtocol, CCTargetedTouchDelegate, AudioCuesDelegate> {
    CCLabelTTFWithStroke *label;
    NSString *storyText;
    ccTime interval;
    CGRect talkDrawRect;
    CGRect talkPositionRect;
    CGPoint bubblePoint;
    AudioCues *audioCues;
    
    CCRenderTexture *bubbleSprite;
    void (^touchBlock)(CCNode *node, BOOL finished);
    void (^finishBlock)(CCNode *node);
}

-(id) initWithStoryKey: (NSString *) storyKey typingInterval: (ccTime) ival rect: (CGRect) talkRect point: (CGPoint) bubblePoint;

-(void) startWithCues: (AudioCues *) cues finishBlock: (void (^)(CCNode *node)) callback touchBlock: (void(^)(CCNode *node, BOOL finished)) touchCallback;

-(void) startWithFinishBlock: (void (^)(CCNode *node)) callback touchBlock: (void(^)(CCNode *node, BOOL finished)) touchCallback;

-(void) cuedAudioStarted: (AudioCues *) cues;
-(void) cuedAudioComplete: (AudioCues *) cues;
-(void) cueHit: (AudioCues *) cues forCueKey: (NSString *) key atTime: (ccTime) time;

@end
