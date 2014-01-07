//
//  CCBaseLayer.h
//  FootGame
//
//  Created by Richen, Owyn on 1/4/14.
//
//

#import "CCLayer.h"

@interface CCBaseScene :CCScene {
    
}

-(void) enableTouches: (BOOL) on;

@end

@interface CCBaseLayer : CCLayer<CCRGBAProtocol> {
    BOOL paused;
}

-(void) enableTouches: (BOOL) on;

-(void) setColor:(ccColor3B)color;
-(ccColor3B) color;

-(GLubyte) opacity;
-(void) setOpacity: (GLubyte) opacity;

@end
