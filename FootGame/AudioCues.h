//
//  AudioCues.h
//  FootGame
//
//  Created by Owyn Richen on 11/12/12.
//
//

#import <Foundation/Foundation.h>

@interface AudioCues : NSObject<NSCopying> {
    id delegate;
    NSMutableArray *cueSequence;
    BOOL stopped;
    ccTime totalTime;
}

@property (nonatomic, retain) NSString *audioFilename;
@property (nonatomic, retain) NSString *locale;
@property (nonatomic, retain) NSDictionary* cues;
@property (nonatomic, retain) NSDictionary* data;

+(AudioCues *) initWithDictionary: (NSDictionary *) dict;

-(id) copyWithZone:(NSZone *)zone;
-(NSString *) key;

-(void) startWithDelegate: (id) del;
-(BOOL) isStopped;

@end


@protocol AudioCuesDelegate

@optional

-(void) cuedAudioStarted: (AudioCues *) cues;
-(void) cuedAudioComplete: (AudioCues *) cues;
-(void) cueHit: (AudioCues *) cues forCueKey: (NSString *) key atTime: (ccTime) time;
// TODO: should we fire if we need to skip a cue for some reason?

@end