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
@synthesize frontFoot;
@synthesize backFoot;
@synthesize successSound;
@synthesize failSound;

+(Animal *) initWithDictionary: (NSDictionary *) dict {
    Animal *anml = [[Animal alloc] init];
    anml.name = [dict objectForKey:@"Name"];
    anml.body = [AnimalPart initWithDictionary:[dict objectForKey:@"Body"] partType:kAnimalPartTypeBody];
    anml.frontFoot = [AnimalPart initWithDictionary:[dict objectForKey: @"FrontFoot"] partType:kAnimalPartTypeFrontFoot];
    anml.backFoot = [AnimalPart initWithDictionary:[dict objectForKey:@"BackFoot"] partType:kAnimalPartTypeBackFoot];
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
        
        NSRange range = [pnt.name rangeOfString: @"FrontFoot"];
        if (range.location != NSNotFound) {
            AnchorPoint *ffpnt = (AnchorPoint *) [frontFoot.fixPoints objectAtIndex:0];
            CGPoint ffpntWS = [frontFoot convertToWorldSpace:ffpnt.point];
            
            if (ccpDistance(pntWS, ffpntWS) != 0)
                return NO;
        }
        
        range = [pnt.name rangeOfString: @"BackFoot"];
        if (range.location != NSNotFound) {
            AnchorPoint *bfpnt = (AnchorPoint *) [backFoot.fixPoints objectAtIndex:0];
            CGPoint bfpntWS = [backFoot convertToWorldSpace:bfpnt.point];
            
            if (ccpDistance(pntWS, bfpntWS) != 0)
                return NO;
        }
    }
    return YES;
}

@end
