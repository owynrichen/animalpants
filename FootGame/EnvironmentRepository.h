//
//  Environment.h
//  FootGame
//
//  Created by Owyn Richen on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnvironmentLayer.h"
#import "BaseRepository.h"

@interface EnvironmentRepository : BaseRepository

@property (nonatomic, readonly) NSMutableDictionary *environments;


+(EnvironmentRepository *) sharedRepository;

-(EnvironmentLayer *) getEnvironment: (NSString *) key;

@end
