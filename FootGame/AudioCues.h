//
//  AudioCues.h
//  FootGame
//
//  Created by Owyn Richen on 11/12/12.
//
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>

@interface AudioCues : NSObject<NSCopying> {
    id delegate;
    NSMutableArray *cueSequence;
    BOOL stopped;
    ccTime totalTime;
    ALuint soundID;
}

@property (nonatomic, retain) NSString *storyKey;
@property (nonatomic, retain) NSString *audioFilename;
@property (nonatomic, retain) NSString *locale;
@property (nonatomic, retain) NSDictionary* cues;
@property (nonatomic, retain) NSDictionary* data;
@property (nonatomic, readonly) ccTime totalRuntime;

+(AudioCues *) initWithDictionary: (NSDictionary *) dict;

-(id) copyWithZone:(NSZone *)zone;
-(NSString *) key;

-(void) startWithDelegate: (id) del soundId: (ALuint) sid;
-(BOOL) isStopped;
-(void) stop;

@end


@protocol AudioCuesDelegate

@optional

-(void) cuedAudioStarted: (AudioCues *) cues;
-(void) cuedAudioComplete: (AudioCues *) cues;
-(void) cueHit: (AudioCues *) cues forCueKey: (NSString *) key atTime: (ccTime) time;
-(void) cuedAudioStopped: (AudioCues *) cues;
// TODO: should we fire if we need to skip a cue for some reason?

@end