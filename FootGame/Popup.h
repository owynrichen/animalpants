//
//  Popup.h
//  FootGame
//
//  Created by Owyn Richen on 5/14/13.
//
//

#import <UIKit/UIKit.h>
#import "CCLayer.h"
#import "CircleButton.h"

typedef void (^PopupBlock)(CCNode<CCRGBAProtocol> *popup);

@interface Popup : CCNode<CCRGBAProtocol> {
    CircleButton *close;
    CCLayerColor *background;
    
    PopupBlock cBlock;
}

+(Popup *) popup;
+(Popup *) popupWithSize: (CGSize) size;

-(id) initWithSize: (CGSize) size;

-(void) showWithOpenBlock:(PopupBlock) openBlock closeBlock:(PopupBlock) closeBlock analyticsKey: (NSString *) key;
-(void) hide;

-(void) setColor:(ccColor3B)color;
-(ccColor3B) color;

-(GLubyte) opacity;
-(void) setOpacity: (GLubyte) opacity;

@end
