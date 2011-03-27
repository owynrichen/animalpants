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
    NSString *name;
}

@property (nonatomic) CGPoint point;
@property (nonatomic, retain) NSString *name;

@end
