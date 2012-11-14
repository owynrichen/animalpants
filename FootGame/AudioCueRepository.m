//
//  AudioCueRepository.m
//  FootGame
//
//  Created by Owyn Richen on 11/12/12.
//
//

#import "AudioCueRepository.h"

@interface AudioCueRepository()

-(void) loadAudioCues: (AudioCues *) cues;

@end

@implementation AudioCueRepository

static AudioCueRepository *_instance;
static NSString *_sync = @"";

+(AudioCueRepository *) sharedRepository {
    if (_instance == nil) {
        @synchronized(_sync) {
            if (_instance == nil) {
                _instance = [[AudioCueRepository alloc] init];
            }
        }
    }
    
    return _instance;
}

-(id) init {
    self = [super init];
    audioCues = [[NSMutableDictionary alloc] init];
    audioCuesByFilename = [[NSMutableDictionary alloc] init];
    audioCuesByLocale = [[NSMutableDictionary alloc] init];
    
    [self loadDataWithFilterBlock:^BOOL(NSString *filename) {
        return [filename hasPrefix:@"Cue-"] && [filename.pathExtension isEqualToString:@"plist"];
    } resultBlock:^(NSDictionary *data) {
        AudioCues *cues = [AudioCues initWithDictionary: data];
        
        [self loadAudioCues:cues];
    }];
    
    return self;
}

-(void) dealloc {
    [audioCues release];
    [audioCuesByFilename release];
    [audioCuesByLocale release];
    
    [super dealloc];
}

-(void) loadAudioCues: (AudioCues *) cues {
    [((NSMutableDictionary *)audioCues) setObject:cues forKey:[cues key]];
    [((NSMutableDictionary *) audioCuesByFilename) setObject:cues forKey:cues.audioFilename];
}

-(AudioCues *) getCues: (NSString *) audioFilename {
    return [((AudioCues *) [audioCuesByFilename objectForKey:[audioFilename lastPathComponent]]) copyWithZone:nil];
}

@end
