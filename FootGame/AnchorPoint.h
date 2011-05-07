//
//  AnchorPoint.h
//  FootGame
//
//  Created by Owyn Richen on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AnchorPoint : NSObject {
    CGPoint point;
    float orientation;
    NSString *name;
}

@property (nonatomic) CGPoint point;
@property (nonatomic) float orientation;
@property (nonatomic, retain) NSString *name;

@end

@interface AnchorPointPair : NSObject {
    AnchorPoint *first;
    AnchorPoint *second;
    CGFloat distance;
}

@property (readonly, nonatomic) AnchorPoint *first;
@property (readonly, nonatomic) AnchorPoint *second;
@property (readonly) float distance;

-(id) initWithFirst: (AnchorPoint *) f second: (AnchorPoint *) s distance: (CGFloat) dist;

@end
