//
//  AnimalPart.m
//  FootGame
//
//  Created by Owyn Richen on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimalPart.h"
#import "AnchorPoint.h"

@implementation AnimalPart

@synthesize partType;
@synthesize fixPoints;
@synthesize imageName;

+(id) initWithDictionary:(NSDictionary *)dict partType: (AnimalPartType) pt {
    NSString *imgName = (NSString *) [dict objectForKey:@"Image"];
    
    AnimalPart *p = [AnimalPart spriteWithFile:imgName];
    p.imageName = imgName;
    p.fixPoints = [[NSMutableArray alloc] init];
    
    NSEnumerator *e = [dict keyEnumerator];
    NSString *key;
    while ((key = [e nextObject])) {
        if ([key rangeOfString:@"Anchor"].length != NSNotFound) {
            NSDictionary *pntDict = [dict objectForKey:key];
            CGFloat x = *((float *) [pntDict objectForKey:@"x"]);
            CGFloat y = *((float *) [pntDict objectForKey:@"y"]);
            
            AnchorPoint *ap = [[AnchorPoint alloc] init];
            CGPoint pnt = CGPointMake(x, y);
            ap.point = pnt;
            ap.name = key;
            [p.fixPoints addObject: ap];
        }
    }
    
    p.partType = pt;

    return p;
}

-(id) init {
    return [super init];
}

@end
