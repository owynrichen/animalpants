//
//  SpeechBubble.h
//  FootGame
//
//  Created by Owyn Richen on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCLabelTTFWIthStroke.h"

@interface SpeechBubble : CCLayer {
    CCLabelTTFWithStroke *label;
    NSString *storyText;
    ccTime interval;
    CGRect talkRect;
    CGPoint bubblePoint;
    
    CCRenderTexture *bubbleSprite;
}

-(id) initWithStoryKey: (NSString *) storyKey typingInterval: (ccTime) ival rect: (CGRect) talkRect point: (CGPoint) bubblePoint;
-(void) startWithBlock: (void (^)(CCNode *node)) callback;

@end
