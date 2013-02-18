//
//  FlagCircleButton.m
//  FootGame
//
//  Created by Owyn Richen on 2/17/13.
//
//

#import "FlagCircleButton.h"
#import "FlagLayer.h"

@implementation FlagCircleButton

+(FlagCircleButton *) buttonWithLanguageCode: (NSString *) lang {
    return [[[FlagCircleButton alloc] initWithLanguageCode:lang] autorelease];
}

-(id) initWithLanguageCode: (NSString *) lang {
    FlagLayer *layer = [FlagLayer flagLayerWithLanguage:lang];
    
    self = [super initWithNode:layer];
    
    return self;
}

@end
