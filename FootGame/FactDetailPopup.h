//
//  FactDetailPopup.h
//  FootGame
//
//  Created by Owyn Richen on 2/14/13.
//
//

#import "CCLayer.h"
#import "CircleButton.h"
#import "Animal.h"
#import "FactFrame.h"

typedef void (^PopupBlock)(CCNode<CCRGBAProtocol> *popup);

@interface FactDetailPopup : CCNode<CCRGBAProtocol> {
    CircleButton *close;
    CCLayerColor *background;
    CCLabelTTF *factTitle;
    CCLabelTTF *factText;
    CCNode<CCRGBAProtocol> *factData;
    
    PopupBlock cBlock;
}

+(FactDetailPopup *) popup;

-(void) showFact: (FactFrameType) fact forAnimal: (Animal *) animal withOpenBlock:(PopupBlock) openBlock closeBlock:(PopupBlock) closeBlock;
-(void) hide;

-(void) setColor:(ccColor3B)color;
-(ccColor3B) color;

-(GLubyte) opacity;
-(void) setOpacity: (GLubyte) opacity;

@end
