//
//  InGameSettingsMenuPopup.h
//  FootGame
//
//  Created by Owyn Richen on 6/14/13.
//
//

#import "Popup.h"

typedef void (^GoHomeBlock)(void);

@interface InGameSettingsMenuPopup : Popup {
    CCMenu *menu;
}

@property (nonatomic) GoHomeBlock goHome;

+(id) inGameSettingsMenuPopupWithGoHomeBlock: (GoHomeBlock) ghBlock;
-(id) initwithGoHomeBlock: (GoHomeBlock) ghBlock;

@end
