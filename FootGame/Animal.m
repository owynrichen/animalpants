//
//  Animal.m
//  FootGame
//
//  Created by Owyn Richen on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Animal.h"
#import "SoundManager.h"
#import "LocalizationManager.h"

@implementation Animal

@synthesize key;
@synthesize name;
@synthesize body;
@synthesize foot;
@synthesize successSound;
@synthesize failSound;
@synthesize environment;
@synthesize word;
@synthesize factsHtml;

+(Animal *) initWithDictionary: (NSDictionary *) dict {
    Animal *anml = [[Animal alloc] init];
    anml.key = [dict objectForKey:@"Key"];
    anml.name = [dict objectForKey:@"Name"];
    anml.body = [AnimalPart initWithDictionary:[dict objectForKey:@"Body"] partType:kAnimalPartTypeBody];
    anml.foot = [AnimalPart initWithDictionary:[dict objectForKey:@"Foot"] partType:kAnimalPartTypeFoot];
    anml.successSound = [dict objectForKey:@"SuccessSound"];
    anml.failSound = [dict objectForKey:@"FailSound"];
    anml.environment = [dict objectForKey:@"Environment"];
    anml.word = [dict objectForKey:@"Word"];
    
    NSString *menuKey = [NSString stringWithFormat:@"menu_%@", [anml.key lowercaseString]];
    NSString *name = locstr(menuKey, @"strings", @"");
    
    NSString *facts = [NSString stringWithContentsOfFile:[[LocalizationManager sharedManager] getLocalizedFilename:[NSString stringWithFormat:@"Facts-%@.html", anml.key]]
                              encoding:NSUTF8StringEncoding
                                                   error:NULL];
    
    if (facts == nil) {
        anml.factsHtml = [NSString stringWithFormat:@"<html><head></head><body style='background: transparent'><h1>%@</h1><p>%@ wears pants</p><a href='animalpants://scene/%@'>Go to scene>></a></body></html>", name, name, anml.key];
    } else {
        anml.factsHtml = facts;
    }
    
    [[SoundManager sharedManager] preloadSound:anml.successSound];
    //[[SoundManager sharedManager] preloadSound:anml.failSound];
    
    return [anml autorelease];
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
