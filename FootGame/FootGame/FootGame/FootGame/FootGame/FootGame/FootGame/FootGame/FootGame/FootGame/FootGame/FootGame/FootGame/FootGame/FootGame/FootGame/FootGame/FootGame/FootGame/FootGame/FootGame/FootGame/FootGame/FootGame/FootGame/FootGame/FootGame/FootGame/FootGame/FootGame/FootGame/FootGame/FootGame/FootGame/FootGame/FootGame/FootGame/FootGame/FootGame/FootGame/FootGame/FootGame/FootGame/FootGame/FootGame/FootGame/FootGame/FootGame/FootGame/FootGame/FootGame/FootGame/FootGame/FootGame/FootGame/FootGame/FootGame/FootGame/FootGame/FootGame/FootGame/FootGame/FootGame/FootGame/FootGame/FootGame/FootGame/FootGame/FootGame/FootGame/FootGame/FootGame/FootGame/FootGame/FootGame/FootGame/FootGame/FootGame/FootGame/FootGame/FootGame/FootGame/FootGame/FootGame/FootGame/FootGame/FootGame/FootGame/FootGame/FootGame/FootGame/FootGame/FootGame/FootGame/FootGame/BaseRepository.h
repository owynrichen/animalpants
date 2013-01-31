//
//  BaseRepository.h
//  FootGame
//
//  Created by Owyn Richen on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseRepository : NSObject

-(void) loadDataWithFilterBlock: (BOOL (^)(NSString *fileName)) filterBlock resultBlock: (void (^)(NSDictionary *data)) resultBlock;
-(void) loadFromFilesAtPath: (NSString *) rootPath withFilterBlock: (BOOL (^)(NSString *fileName)) filterBlock resultBlock: (void (^)(NSDictionary *data)) resultBlock;

@end
