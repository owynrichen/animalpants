//
//  FactDetailPopup.h
//  FootGame
//
//  Created by Owyn Richen on 2/14/13.
//
//

#import "Animal.h"
#import "FactFrame.h"
#import "Popup.h"

@interface FactDetailPopup : Popup {
    CCLabelTTF *factTitle;
    // CCLabelTTF *factText;
    CCLabelBMFont *factText;
    CCNode<CCRGBAProtocol> *factData;
}

+(FactDetailPopup *) popup;
+(ContentManifest *) manifestWithFrameType: (FactFrameType) fact animal: (Animal *) anml;

-(void) showFact: (FactFrameType) fact forAnimal: (Animal *) animal withOpenBlock:(PopupBlock) openBlock closeBlock:(PopupCloseBlock) closeBlock;

@end
