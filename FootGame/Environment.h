//
//  Environment.h
//  FootGame
//
//  Created by Owyn Richen on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnvironmentLayer.h"

@interface Environment : NSObject

@property (nonatomic, retain) NSString *key;
@property (nonatomic) CGPoint animalPosition;
@property (nonatomic) CGPoint textPosition;
@property (nonatomic, retain) NSDictionary *layers;
@property (nonatomic) CGPoint kidPosition;
@property (nonatomic, retain) NSString *storyKey;

+(Environment *) initWithDictionary: (NSDictionary *) setupData;

-(id) initWithDictionary: (NSDictionary *) setupData;
-(EnvironmentLayer *) getLayer;

@end
