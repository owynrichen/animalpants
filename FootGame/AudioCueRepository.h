//
//  AudioCueRepository.h
//  FootGame
//
//  Created by Owyn Richen on 11/12/12.
//
//

#import "BaseRepository.h"
#import "AudioCues.h"

@interface AudioCueRepository : BaseRepository {
    NSDictionary *audioCuesByFilename;
    NSDictionary *audioCuesByLocale;
    NSDictionary *audioCues;
}

+(AudioCueRepository *) sharedRepository;

-(AudioCues *) getCues: (NSString *) audioFilename;

@end
