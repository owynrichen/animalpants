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
#import "LocationManager.h"
#import "PremiumContentStore.h"

@interface Animal()

-(NSString *) factKey: (FactType) ftype;

@end

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
@synthesize manifest = mfest;

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
    
    ContentManifest *m = [[[ContentManifest alloc] init] autorelease];
    
    [m addImageFile:anml.foot.imageName];
    [m addImageFile:anml.body.imageName];
    [m addImageFile:anml.body.happyImageName];
    
    [m addAudioFile:anml.successSound];
    if (anml.failSound != nil && ![anml.failSound isEqualToString:@""]) {
        [m addAudioFile:anml.failSound];
    }
    
    anml.manifest = m;
    
    NSArray *habitats = (NSArray *) [dict objectForKey:@"habitatLocations"];
    if (habitats != nil) {
        anml.habitatLocations = habitats;
    } else {
        anml.habitatLocations = [[[NSArray alloc] init] autorelease];
    }
    
    
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

-(ContentManifest *) manifest {
    return [[mfest copy] autorelease];
}

-(void) setManifest:(ContentManifest *)manifest {
    if (mfest != nil)
        [mfest release];
    
    mfest = [manifest retain];
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

-(NSString *) factKey:(FactType)ftype {
    switch(ftype) {
        case kFaceFact:
            return @"photo";
        case kEarthFact:
            return @"location";
        case kFoodFact:
            return @"food";
        case kHeightFact:
            return @"height";
        case kWeightFact:
            return @"weight";
        case kSpeedFact:
            return @"speed";
    }
}

-(NSString *) factTitle: (FactType) ftype {
    NSString *strkey = [NSString stringWithFormat:@"%@_fact_%@", [key lowercaseString], [self factKey:ftype]];
    return locstr(strkey, @"strings", @"");
}

-(NSString *) factText: (FactType) ftype {
    NSString *format;
    
    if ([[LocationManager sharedManager] currentLocaleUsesMetric] &&
        (ftype == kHeightFact || ftype == kWeightFact || ftype == kSpeedFact)) {
        format = @"%@_fact_%@_details_metric";
    } else {
        format = @"%@_fact_%@_details";
    }
    
    NSString *strkey = [NSString stringWithFormat:format, [key lowercaseString], [self factKey:ftype]];
    
    return locstr(strkey, @"strings", @"");
}

@end
