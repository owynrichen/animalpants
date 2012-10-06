//
//  LanguageSelectLayer.h
//  FootGame
//
//  Created by Owyn Richen on 10/6/12.
//
//

#import "CCLayer.h"
#import "CCAutoScalingSprite.h"

@interface LanguageSelectLayer : CCLayer

@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCAutoScalingSprite *background;

+(CCScene *) scene;

@end
