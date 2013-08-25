//
//  Behavior+Lantern.m
//  FootGame
//
//  Created by Owyn Richen on 8/22/13.
//
//

#import "Behavior+Lantern.h"

@interface CCRandomFadeTo : CCFadeTo {
    CGFloat dmin_, dmax_;
    GLubyte omin_, omax_;
}

+(id) actionWithDurationMin: (CGFloat) dmin max: (CGFloat) dmax opacityMin: (GLubyte) min max: (GLubyte) max;

-(id) initWithDurationMin: (CGFloat) dmin max: (CGFloat) dmax opacityMin: (GLubyte) omin max: (GLubyte) omax;

@end

@implementation CCRandomFadeTo

+(id) actionWithDurationMin: (float) dmin max: (float) dmax opacityMin: (GLubyte) omin max: (GLubyte) omax {
    return [[[CCRandomFadeTo alloc] initWithDurationMin:dmin max:dmax opacityMin:omin max:omax] autorelease];
}

-(id) initWithDurationMin:(CGFloat)dmin max:(CGFloat)dmax opacityMin:(GLubyte)omin max:(GLubyte)omax {
    self = [super initWithDuration: arc4random() / UINT32_MAX * (dmax - dmin) + dmin];
    
    dmin_ = dmin;
    dmax_ = dmax;
    omin_ = omin;
    omax_ = omax;
    
    return self;
}

-(void) startWithTarget:(id)target {
    self.duration = (double) arc4random() / (double) UINT32_MAX * (dmax_ - dmin_) + dmin_;
    toOpacity_ = (double) arc4random() / (double) UINT32_MAX * (omax_ - omin_) + omin_;
    
    [super startWithTarget:target];
}

@end

@implementation Behavior(Lantern)

-(CCAction *) lantern: (NSDictionary *) params {
    CCRandomFadeTo *fadeOut = [CCRandomFadeTo actionWithDurationMin:0.1 max:0.2 opacityMin:160 max:200];
    CCRandomFadeTo *fadeIn = [CCRandomFadeTo actionWithDurationMin:0.1 max:0.2 opacityMin:190 max:255];
    
    return [CCRepeatForever actionWithAction:[CCSequence actions:fadeOut, fadeIn, nil]];
}

@end
