//
//  AnimalPart.m
//  FootGame
//
//  Created by Owyn Richen on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AnimalPart.h"
#import "SoundManager.h"
#import "CCAutoScaling.h"

@implementation AnimalPart

@synthesize partType;
@synthesize fixPoints;
@synthesize imageName;
@synthesize happyImageName;
@synthesize touch;
@synthesize data;
@synthesize textureState;

+(id) initWithDictionary:(NSDictionary *)dict partType: (AnimalPartType) pt {
    NSString *imgName = (NSString *) [dict objectForKey:@"Image"];
    NSString *himgName = (NSString *) [dict objectForKey:@"HappyImage"];
    
    if (!himgName) {
        himgName = imgName;
    }
    
    AnimalPart *p = [AnimalPart spriteWithFile:imgName];
    p.imageName = imgName;
    p.happyImageName = himgName;
    p.fixPoints = [[[NSMutableArray alloc] init] autorelease];
    p.data = dict;
    p.partType = pt;
    p.textureState = [[[NSMutableDictionary alloc] init] autorelease];
    CCTexture2D *happyTexture = [[CCTextureCache sharedTextureCache] addImage:p.happyImageName];
    
    [p.textureState setObject:p.texture forKey:[NSNumber numberWithInt: (int) kAnimalStateNormal]];
    [p.textureState setObject:happyTexture forKey:[NSNumber numberWithInt: (int) kAnimalStateHappy]];
    
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
            CGPoint pnt = CGPointMake(x * (positionScaleForCurrentDevice(kDimensionY) / autoScaleForCurrentDevice()), p.contentSize.height - (y * (positionScaleForCurrentDevice(kDimensionY) / autoScaleForCurrentDevice())));
            
            ap.point = pnt;
            ap.orientation = [((NSNumber *) [pntDict objectForKey:@"orientation"]) floatValue];
            ap.name = key;
            [p.fixPoints addObject: ap];
            [ap release];
        }
    }
    
    if (p.partType != kAnimalPartTypeBody) {
        // convert the pixel anchor to a percentage and set
        CGPoint newAnchorPx = ((AnchorPoint *) [p.fixPoints objectAtIndex:0]).point;
        // invert the scale factor of all points to compensate for any downscaling
        CGPoint newAnchor = CGPointMake(newAnchorPx.x / p.contentSize.width, newAnchorPx.y / p.contentSize.height);
        // NSLog
        p.anchorPoint = newAnchor;
    }

    return p;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[AnimalPart initWithDictionary:self.data partType:self.partType] retain];
}

-(id) init {
    self = [super init];
    
    return self;
}

-(void) dealloc {
    [super dealloc];
}

-(void) draw {
    [super draw];
/*    int count = [fixPoints count];
    for (int i = 0; i < count; i++) {
        AnchorPoint *pnt = (AnchorPoint *) [fixPoints objectAtIndex:i];
        ccDrawColor4B(0, 0, 255, 255);
        ccPointSize(8 * CC_CONTENT_SCALE_FACTOR());
        // NSLog(@"%f,%f -> %f, %f", pnt.point.x, pnt.point.y, glpnt.x, glpnt.y);
        ccDrawPoint(pnt.point);
    }
    
    ccDrawColor4B(0,255,0,180);
    ccPointSize(8);
    ccDrawPoint(self.anchorPointInPoints);*/
}

-(void) setState: (AnimalStateType) state {
    [self setTexture: [self.textureState objectForKey:[NSNumber numberWithInt: (int) state]]];
}

-(void) getAttention {
    id rotate = [CCRotateBy actionWithDuration:0.05 angle:18];
    id reverseRotate = [CCRotateBy actionWithDuration:0.1 angle:-36];
    id rotate2 = [CCRotateBy actionWithDuration:0.05 angle:18];
    
    id seq = [CCRepeat actionWithAction:[CCSequence actions:rotate, reverseRotate, rotate2, nil] times: 3];

    [self runAction:seq];
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
    CGFloat distance;
    
    int count = [part.fixPoints count];
    int selfCount = [self.fixPoints count];
    for(int i = 0; i < selfCount; i++) {
        for(int j = 0; j < count; j++) {
            CGPoint footPoint = [self convertToWorldSpace:((AnchorPoint *) [self.fixPoints objectAtIndex:i]).point];
            CGPoint bodyPoint = [part convertToWorldSpace:((AnchorPoint *) [part.fixPoints objectAtIndex:j]).point];
            distance = ccpDistance(footPoint, bodyPoint);
            // NSLog(@"%@: %f,%f - %@: %f,%f - D: %f Max: %f", ((AnchorPoint *) [self.fixPoints objectAtIndex:i]).name, footPoint.x, footPoint.y, ((AnchorPoint *) [part.fixPoints objectAtIndex:j]).name, bodyPoint.x, bodyPoint.y, distance, mindistance);
            
            if (distance < mindistance) {
                f = [self.fixPoints objectAtIndex:i];
                s = [part.fixPoints objectAtIndex:j];
                mindistance = distance;
            }
        }
    }
    
    if (f == nil || s == nil) {
        // NSLog(@"returning nil");
        return  nil;
    }
    
    return [[[AnchorPointPair alloc] initWithFirst:f second:s distance: mindistance] autorelease];
}

@end
