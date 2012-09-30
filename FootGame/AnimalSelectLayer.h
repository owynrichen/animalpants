//
//  AnimalSelectLayer.h
//  FootGame
//
//  Created by Owyn Richen on 9/30/12.
//
//

#import "CCLayer.h"
#import "CCAutoScalingSprite.h"

@interface AnimalSelectLayer : CCLayer

@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCAutoScalingSprite *background;

+(CCScene *) scene;

@end
