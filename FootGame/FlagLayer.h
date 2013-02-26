//
//  FlagLayer.h
//  FootGame
//
//  Created by Owyn Richen on 2/17/13.
//
//

#import "CCLayer.h"

@interface FlagLayer : CCLayer<CCRGBAProtocol> {
    int currentFlagIndex;
    ccColor3B color_;
    GLubyte opacity_;
}

+(FlagLayer *) flagLayerWithLanguage: (NSString *) lang;

-(id) initWithLanguage: (NSString *) lang;

-(void) setColor:(ccColor3B)color;
-(ccColor3B) color;

-(GLubyte) opacity;
-(void) setOpacity: (GLubyte) opacity;

@end
