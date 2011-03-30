//
//  AnimalPart.m
//  FootGame
//
//  Created by Owyn Richen on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimalPart.h"

@implementation AnimalPart

@synthesize partType;
@synthesize fixPoints;
@synthesize imageName;
@synthesize touch;

+(id) initWithDictionary:(NSDictionary *)dict partType: (AnimalPartType) pt {
    NSString *imgName = (NSString *) [dict objectForKey:@"Image"];
    
    AnimalPart *p = [AnimalPart spriteWithFile:imgName];
    p.imageName = imgName;
    p.fixPoints = [[NSMutableArray alloc] init];
    
    NSEnumerator *e = [dict keyEnumerator];
    NSString *key;
    while ((key = [e nextObject])) {
        NSRange range = [key rangeOfString:@"Anchor"];
        if (range.location != NSNotFound) {
            NSDictionary *pntDict = [dict objectForKey:key];
            // NSLog(@"%@,%@", [pntDict objectForKey:@"x"], [pntDict objectForKey:@"y"]);
            CGFloat x = [((NSNumber *) [pntDict objectForKey:@"x"]) floatValue];
            CGFloat y = [((NSNumber *) [pntDict objectForKey:@"y"]) floatValue];
            
            AnchorPoint *ap = [[AnchorPoint alloc] init];
            CGPoint pnt = CGPointMake(x, p.contentSize.height - y);
            ap.point = pnt;
            ap.name = key;
            [p.fixPoints addObject: ap];
        }
    }
    
    if ([p.fixPoints count] == 1) {
        // convert the pixel anchor to a percentage and set
        CGPoint newAnchorPx = ((AnchorPoint *) [p.fixPoints objectAtIndex:0]).point;
        CGPoint newAnchor = CGPointMake(newAnchorPx.x / p.contentSizeInPixels.width, newAnchorPx.y / p.contentSizeInPixels.height);
        p.anchorPoint = newAnchor;
    }
    
    p.partType = pt;

    return p;
}

-(id) init {
    return [super init];
}

-(void) draw {
    int count = [fixPoints count];
    for (int i = 0; i < count; i++) {
        AnchorPoint *pnt = (AnchorPoint *) [fixPoints objectAtIndex:i];
        glColor4ub(255, 0, 0, 255);
        glPointSize(8);
        // NSLog(@"%f,%f -> %f, %f", pnt.point.x, pnt.point.y, glpnt.x, glpnt.y);
        ccDrawPoint(pnt.point);
    }
    
    glColor4ub(0,255,0,255);
    glPointSize(8);
    [super draw];
    ccDrawPoint(self.anchorPointInPixels);
}

-(BOOL) hitTest:(CGPoint)point {
    CGRect rect = [self boundingBox];
    if (CGRectContainsPoint(rect, point)) {
        // TODO: more detailed alpha-channel testing
        return YES;
    }
    return NO;
}

-(AnchorPointPair *) getClosestAnchorWithinDistance: (float) maxDistance withAnimalPart: (AnimalPart *) part {
    AnchorPoint *f = nil;
    AnchorPoint *s = nil;
    CGFloat mindistance = maxDistance;
    
    int count = [part.fixPoints count];
    int selfCount = [self.fixPoints count];
    for(int i = 0; i < selfCount; i++) {
        for(int j = 0; j < count; j++) {
            CGPoint footPoint = [self convertToWorldSpace:((AnchorPoint *) [self.fixPoints objectAtIndex:i]).point];
            CGPoint bodyPoint = [part convertToWorldSpace:((AnchorPoint *)[part.fixPoints objectAtIndex:j]).point];
            CGFloat distance = ccpDistance(footPoint, bodyPoint);
            //NSLog(@"FP: %f,%f - BP: %f,%f - D: %f Max: %f", footPoint.x, footPoint.y, bodyPoint.x, bodyPoint.y, distance, mindistance);
            
            if (distance < mindistance) {
                f = [self.fixPoints objectAtIndex:i];
                s = [part.fixPoints objectAtIndex:j];
            }
        }
    }
    
    if (f == nil || s == nil)
        return  nil;
    
    return [[AnchorPointPair alloc] initWithFirst:f second:s];
}

@end
