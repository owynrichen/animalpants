//
//  Animal.m
//  FootGame
//
//  Created by Owyn Richen on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Animal.h"
#import "SoundManager.h"

@implementation Animal

@synthesize name;
@synthesize body;
@synthesize foot;
@synthesize successSound;
@synthesize failSound;

+(Animal *) initWithDictionary: (NSDictionary *) dict {
    Animal *anml = [[Animal alloc] init];
    anml.name = [dict objectForKey:@"Name"];
    anml.body = [AnimalPart initWithDictionary:[dict objectForKey:@"Body"] partType:kAnimalPartTypeBody];
    anml.foot = [AnimalPart initWithDictionary:[dict objectForKey:@"Foot"] partType:kAnimalPartTypeFoot];
    anml.successSound = [dict objectForKey:@"SuccessSound"];
    anml.failSound = [dict objectForKey:@"FailSound"];
    
    [[SoundManager sharedManager] preloadSound:anml.successSound];
    //[[SoundManager sharedManager] preloadSound:anml.failSound];
    
    return anml;
}

-(BOOL) testVictory {
    for(int i = 0; i < [body.fixPoints count]; i++) {
        AnchorPoint* pnt = (AnchorPoint *) [body.fixPoints objectAtIndex: i];
        CGPoint pntWS = [body convertToWorldSpace:pnt.point];
        
        NSRange range = [pnt.name rangeOfString: @"Foot"];
        if (range.location != NSNotFound) {
            AnchorPoint *fpnt = (AnchorPoint *) [foot.fixPoints objectAtIndex:0];
            CGPoint fpntWS = [foot convertToWorldSpace:fpnt.point];
            
            if (ccpDistance(pntWS, fpntWS) != 0)
                return NO;
        }

    }
    return YES;
}

@end
