//
//  InGameSettingsMenuPopup.h
//  FootGame
//
//  Created by Owyn Richen on 6/14/13.
//
//

#import "Popup.h"
#import "CCVolumeMenuItem.h"

typedef void (^GoHomeBlock)(void);
typedef void (^FactPageBlock)(NSString *animalKey);

@interface InGameSettingsMenuPopup : Popup {
    CCMenu *menu;
    CCVolumeMenuItem *music;
    CCVolumeMenuItem *narration;
}

@property (nonatomic) GoHomeBlock goHome;
@property (nonatomic) FactPageBlock facts;
@property (nonatomic, retain) NSString *animalKey;

+(id) inGameSettingsMenuPopupWithGoHomeBlock: (GoHomeBlock) ghBlock factPageBlock: (FactPageBlock) fpBlock forAnimalKey: (NSString *) key;
-(id) initwithGoHomeBlock: (GoHomeBlock) ghBlock factPageBlock: (FactPageBlock) fpBlock  forAnimalKey: (NSString *) key;

@end
