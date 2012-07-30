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

@property (nonatomic, retain) NSString *key;
@property (nonatomic) CGPoint animalPosition;
@property (nonatomic) CGPoint textPosition;
@property (nonatomic) CGPoint kidPosition;

@end
