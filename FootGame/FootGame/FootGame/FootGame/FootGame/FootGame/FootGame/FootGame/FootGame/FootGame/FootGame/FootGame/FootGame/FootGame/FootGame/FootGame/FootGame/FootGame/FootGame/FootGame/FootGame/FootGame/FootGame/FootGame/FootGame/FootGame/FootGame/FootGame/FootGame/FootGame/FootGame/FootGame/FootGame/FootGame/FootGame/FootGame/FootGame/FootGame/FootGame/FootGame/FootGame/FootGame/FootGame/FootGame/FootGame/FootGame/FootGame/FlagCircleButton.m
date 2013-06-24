//
//  FlagCircleButton.m
//  FootGame
//
//  Created by Owyn Richen on 2/17/13.
//
//

#import "FlagCircleButton.h"
#import "FlagNode.h"

@implementation FlagCircleButton

+(id) buttonWithLanguageCode: (NSString *) lang {
    return [[[FlagCircleButton alloc] initWithLanguageCode:lang] autorelease];
}

-(id) initWithLanguageCode: (NSString *) lang {
    FlagNode *layer = [FlagNode flagNodeWithLanguage:lang];
    
    self = [super initWithNode:layer];
    
    return self;
}

@end
