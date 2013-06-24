//
//  CCButtonMenuItem.h
//  FootGame
//
//  Created by Owyn Richen on 6/10/13.
//
//

#import "CCButtonMenuItem.h"
#import "CCControlPotentiometer.h"

typedef enum VolumeType {
    kMusicVolume,
    kSoundVolume
} VolumeType;


@interface CCVolumeMenuItem : CCButtonMenuItem {
    VolumeType t;
    CCControlPotentiometer *potentiometer;
}

+(id) buttonWithVolumeType: (VolumeType) type button: (CCNode<CCRGBAProtocol> *) btn text: (NSString *) text;

-(id) initWithVolumeType: (VolumeType) type button: (CCNode<CCRGBAProtocol> *) btn text: (NSString *) text;

@end
