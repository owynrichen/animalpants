//
//  SpeechBubble.h
//  FootGame
//
//  Created by Owyn Richen on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCLabelTTFWIthStroke.h"

@interface SpeechBubble : CCLayer<CCRGBAProtocol, CCTargetedTouchDelegate> {
    CCLabelTTFWithStroke *label;
    NSString *storyText;
    ccTime interval;
    CGRect talkDrawRect;
    CGRect talkPositionRect;
    CGPoint bubblePoint;
    
    CCRenderTexture *bubbleSprite;
    void (^touchBlock)(CCNode *node, BOOL finished);
}

-(id) initWithStoryKey: (NSString *) storyKey typingInterval: (ccTime) ival rect: (CGRect) talkRect point: (CGPoint) bubblePoint;
-(void) startWithFinishBlock: (void (^)(CCNode *node)) callback touchBlock: (void(^)(CCNode *node, BOOL finished)) touchCallback;

@end
