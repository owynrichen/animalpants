//
//  FlagCircleButton.h
//  FootGame
//
//  Created by Owyn Richen on 2/17/13.
//
//

#import "CircleButton.h"

@interface FlagCircleButton : CircleButton

+(id) buttonWithLanguageCode: (NSString *) lang;

-(id) initWithLanguageCode: (NSString *) lang;

@end
