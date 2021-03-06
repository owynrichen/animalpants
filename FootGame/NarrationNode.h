//
//  NarrationLayer.h
//  FootGame
//
//  Created by Owyn Richen on 5/17/13.
//
//

#import <UIKit/UIKit.h>
#import "AudioCues.h"

@interface NarrationNode : CCNode<CCRGBAProtocol, AudioCuesDelegate> {
    CCLabelBMFont *label;
    NSString *storyText;
    AudioCues *audioCues;
    void (^finishBlock)(CCNode *node);
    CGSize tSize;
}

-(id) initWithSize: (CGSize) talkSize;

-(void) clear;
-(void) startWithCues: (AudioCues *) cues finishBlock: (void (^)(CCNode *node)) callback;
-(void) startForLanguage: (NSString *) lang cues: (AudioCues *) cues finishBlock: (void (^)(CCNode *node)) callback;

-(void) stop;

-(void) cuedAudioStarted: (AudioCues *) cues;
-(void) cuedAudioComplete: (AudioCues *) cues;
-(void) cueHit: (AudioCues *) cues forCueKey: (NSString *) key atTime: (ccTime) time;
-(void) cuedAudioStopped: (AudioCues *) cues;

@end
