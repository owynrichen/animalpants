//
//  CCButtonMenuItem.h
//  FootGame
//
//  Created by Owyn Richen on 6/10/13.
//
//

#import "CCMenuItem.h"
#import "CCLabelTTFWithStroke.h"

@interface CCButtonMenuItem : CCMenuItem<CCRGBAProtocol> {
    CCNode<CCRGBAProtocol> *button;
    CCLabelTTFWithStroke *label;
    void (^downBlock)(id sender);
    float originalScale;
}

+(id) itemWithButton: (CCNode<CCRGBAProtocol> *) btn text: (NSString *) text block: (void (^)(id))block;
-(id) initWithButton: (CCNode<CCRGBAProtocol> *) btn text: (NSString *) text block: (void (^)(id))block;

-(void) addDownEvent: (void (^)(id sender)) block;

-(void) setColor:(ccColor3B)color;
-(ccColor3B) color;
-(GLubyte) opacity;
-(void) setOpacity: (GLubyte) opacity;

@end
