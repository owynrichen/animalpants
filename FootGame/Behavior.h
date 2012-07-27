//
//  Behavior.h
//  FootGame
//
//  Created by Owyn Richen on 7/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Behavior : NSObject

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSDictionary *data;

+(Behavior *) behaviorFromKey: (NSString *) key dictionary: (NSDictionary *) data;

-(id) initWithKey: (NSString *) k data: (NSDictionary *) d;
-(CCAction *) getAction;
@end