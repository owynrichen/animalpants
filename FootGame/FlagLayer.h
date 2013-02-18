//
//  FlagLayer.h
//  FootGame
//
//  Created by Owyn Richen on 2/17/13.
//
//

#import "CCLayer.h"

@interface FlagLayer : CCLayer {
    int currentFlagIndex;
}

+(FlagLayer *) flagLayerWithLanguage: (NSString *) lang;

-(id) initWithLanguage: (NSString *) lang;

@end
