//
//  EnvironmentLayer.h
//  FootGame
//
//  Created by Owyn Richen on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCAutoScalingSprite.h"

@interface EnvironmentLayer : CCLayer<CCTargetedTouchDelegate>

@property (nonatomic, retain) CCAutoScalingSprite *background;
@property (nonatomic, retain) NSString *key;

+(id) initWithDictionary: (NSDictionary *) setupData;

@end
