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
#import "PremiumContentStore.h"

@implementation Animal

@synthesize key;
@synthesize name;
@synthesize body;
@synthesize foot;
@synthesize successSound;
@synthesize failSound;
@synthesize environment;
@synthesize word;
@synthesize productId;
@synthesize habitatLocations;

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
    
    NSString *productId = [dict objectForKey:@"productId"];
    if (productId == nil) {
        productId = FREE_PRODUCT_ID;
    }
    anml.productId = productId;
    
    NSArray *habitats = (NSArray *) [dict objectForKey:@"habitatLocations"];
    if (habitats != nil) {
        anml.habitatLocations = habitats;
    } else {
        anml.habitatLocations = [[[NSArray alloc] init] autorelease];
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

-(void) enumerateHabitiatLocationsWithBlock: (void (^)(LatitudeLongitude ll)) block {
    [habitatLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(llFromDict((NSDictionary *) obj));
    }];
}

-(NSString *) localizedName {
    NSString *k = [NSString stringWithFormat:@"%@_name", [key lowercaseString]];
    return locstr(k, @"strings", @"");
}

@end
