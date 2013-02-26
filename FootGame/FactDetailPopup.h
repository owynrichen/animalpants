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

@interface FactDetailPopup : CCNode<CCRGBAProtocol> {
    CircleButton *close;
    CCLayerColor *background;
    CCLabelTTF *factText;
    CCNode<CCRGBAProtocol> *factData;
}

+(FactDetailPopup *) popup;

-(void) showFact: (FactFrameType) fact forAnimal: (Animal *) animal;
-(void) hide;

-(void) setColor:(ccColor3B)color;
-(ccColor3B) color;

-(GLubyte) opacity;
-(void) setOpacity: (GLubyte) opacity;

@end
