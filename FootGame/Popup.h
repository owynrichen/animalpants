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

typedef enum {
    kPopupCloseStateManual,
    kPopupCloseStateSuccess,
    kPopupCloseStateFailure
} PopupCloseState;

typedef void (^PopupBlock)(CCNode<CCRGBAProtocol> *popup);
typedef void (^PopupCloseBlock)(CCNode<CCRGBAProtocol> *popup, PopupCloseState state);

@interface Popup : CCNode<CCRGBAProtocol> {
    CircleButton *close;
    CCLayerColor *background;
    CCLayerColor *background2;
    GLubyte op_;
    PopupCloseBlock cBlock;
}

+(Popup *) popup;
+(Popup *) popupWithSize: (CGSize) size;

-(id) initWithSize: (CGSize) size;

-(void) showWithOpenBlock:(PopupBlock) openBlock closeBlock:(PopupCloseBlock) closeBlock analyticsKey: (NSString *) key;
-(void) hide: (PopupCloseState) state;

-(void) setColor:(ccColor3B)color;
-(ccColor3B) color;

-(GLubyte) opacity;
-(void) setOpacity: (GLubyte) opacity;

@end
