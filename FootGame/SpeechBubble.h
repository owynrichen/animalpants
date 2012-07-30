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
}

-(id) initWithStoryKey: (NSString *) storyKey typingInterval: (ccTime) ival;
-(void) start;

@end
