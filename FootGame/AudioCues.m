//
//  AudioCues.m
//  FootGame
//
//  Created by Owyn Richen on 11/12/12.
//
//

#import "AudioCues.h"

@interface AudioCues()

-(NSMutableArray *) buildCueSequence;
-(void) updateRunTime: (ccTime) time;

@end

@implementation AudioCues

@synthesize audioFilename;
@synthesize locale;
@synthesize cues;
@synthesize data;

+(AudioCues *) initWithDictionary: (NSDictionary *) dict {
    AudioCues *cues = [[AudioCues alloc] init];
    
    cues.data = dict;
    cues.audioFilename = (NSString *) [dict objectForKey:@"audioFile"];
    cues.locale = (NSString *) [dict objectForKey:@"locale"];
    
    // TODO: make this only the cues data
    cues.cues = dict;
    
    return cues;
}

-(NSString *) key {
    return [NSString stringWithFormat:@"%@:%@", audioFilename, locale];
}

-(id) copyWithZone:(NSZone *)zone {
    AudioCues *newCues = [AudioCues initWithDictionary:self.data];
    
    return newCues;
}

-(void) dealloc {
    NSLog(@"deallocating AudioCues %@", self.audioFilename);
    if (cueSequence != nil)
        [cueSequence release];
    
    [[CCDirector sharedDirector].scheduler unscheduleSelector:@selector(updateRunTime:) forTarget:self];
    
    delegate = nil;
    
    [super dealloc];
}

-(NSMutableArray *) buildCueSequence {
    NSMutableArray *seq = [[NSMutableArray alloc] init];
    
    [self.cues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [seq addObject:key];
        }
    }];
    
    [seq sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *key1 = (NSString *) obj1;
        NSString *key2 = (NSString *) obj2;
        
        NSDictionary *dict1 = (NSDictionary *) [self.cues objectForKey:key1];
        NSDictionary *dict2 = (NSDictionary *) [self.cues objectForKey:key2];
        
        NSNumber *start1 = (NSNumber *) [dict1 objectForKey:@"start"];
        NSNumber *start2 = (NSNumber *) [dict2 objectForKey:@"start"];
        
        return [start1 compare:start2];
    }];
    
    return seq;
}

-(BOOL) isStopped {
    return stopped;
}

-(void) startWithDelegate: (id) del {
    id<AudioCuesDelegate> cueDel = (id<AudioCuesDelegate>) del;
    NSAssert(cueDel != nil, @"argument del must be of type id<AudioCuesDelegate>");
    stopped = NO;
    totalTime = 0.0f;

    delegate = cueDel;
    if (cueSequence != nil)
        [cueSequence release];
    
    cueSequence = [[self buildCueSequence] retain];
    
    [cueDel cuedAudioStarted:self];
    
    [[CCDirector sharedDirector].scheduler scheduleSelector:@selector(updateRunTime:) forTarget:self interval:0.01 paused:NO];
}

-(void) updateRunTime: (ccTime) time {
    bool cueHit = NO;
    totalTime += time;
    
    if (cueSequence == nil || [cueSequence count] == 0) {
        return;
    }
    
    do {
        NSString *key = [cueSequence objectAtIndex:0];
        NSDictionary *dict = (NSDictionary *) [self.cues objectForKey:key];
        NSNumber *start = (NSNumber *) [dict objectForKey:@"start"];
        
        if (totalTime >= [start floatValue]) {
            cueHit = YES;
            [cueSequence removeObjectAtIndex:0];
            if (delegate) {
                [((id<AudioCuesDelegate>)delegate) cueHit:self forCueKey:key atTime:totalTime];
                
                if ([cueSequence count] == 0) {
                    [((id<AudioCuesDelegate>)delegate) cuedAudioComplete:self];
                    [[CCDirector sharedDirector].scheduler unscheduleSelector:@selector(updateRunTime:) forTarget:self];
                    stopped = YES;
                    totalTime = 0;
                    delegate = nil;
                }
            }
        } else {
            cueHit = NO;
        }
    } while(cueHit);
}

@end
