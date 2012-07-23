//
//  Environment.m
//  FootGame
//
//  Created by Owyn Richen on 7/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EnvironmentRepository.h"
#import "Environment.h"

@implementation EnvironmentRepository

static EnvironmentRepository * _instance;
static NSString *_sync = @"";

+(EnvironmentRepository *) sharedRepository {
    if (_instance == nil) {
        @synchronized(_sync) {
            if (_instance == nil) {
                _instance = [[EnvironmentRepository alloc] init];
            }
        }
    }
    
    return _instance;
}

@synthesize environments;

-(id) init {
    self = [super init];
    
    environments = [[NSMutableDictionary alloc] init];

    [self loadDataWithFilterBlock:^BOOL(NSString *filename) {
        return [filename hasPrefix:@"Environment-"] && [filename.pathExtension isEqualToString:@"plist"];
    } resultBlock:^(NSDictionary *data) {
        Environment *env = [Environment initWithDictionary: data];
        
        [self.environments setObject:env forKey:env.key];
    }];
    
    return self;
}

-(void) dealloc {
    if (environments != nil)
        [environments release];
    
    [super dealloc];
}

-(EnvironmentLayer *) getEnvironment: (NSString *) key {
    return [((Environment *) [self.environments objectForKey:key]) getLayer];
}

@end
