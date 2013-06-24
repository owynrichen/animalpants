//
//  BaseRepository.m
//  FootGame
//
//  Created by Owyn Richen on 7/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseRepository.h"

@implementation BaseRepository

-(void) loadDataWithFilterBlock: (BOOL (^)(NSString *fileName)) filterBlock resultBlock: (void (^)(NSDictionary *data)) resultBlock {
    NSMutableArray* paths = [NSMutableArray arrayWithArray:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                                               NSUserDomainMask, YES)];
    [paths addObject:[[NSBundle mainBundle] bundlePath]];
    
    // [self loadFromOldFile];
    [paths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self loadFromFilesAtPath:(NSString *) obj withFilterBlock:filterBlock resultBlock:resultBlock];  
    }];
    
}

-(void) loadFromFilesAtPath: (NSString *) rootPath withFilterBlock: (BOOL (^)(NSString *fileName)) filterBlock resultBlock: (void (^)(NSDictionary *data)) resultBlock {
    NSEnumerator *enumerator = [[NSFileManager defaultManager]
                                enumeratorAtPath:rootPath];
    
    NSString *path = nil;
    
    while (path = (NSString *) [enumerator nextObject]) {
        NSArray *components = [path pathComponents];
        NSString *filename = [components objectAtIndex:[components count] - 1];
        
        if (filterBlock(filename)) {
            NSString *fullPath = [rootPath stringByAppendingPathComponent:filename];
            
            NSPropertyListFormat format;
            NSString *errorDesc = nil;
            NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:fullPath];
            
            NSDictionary *dict = (NSDictionary *)[NSPropertyListSerialization
                                                    propertyListFromData:plistXML
                                                    mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                    format:&format
                                                    errorDescription:&errorDesc];
            
            resultBlock(dict);
        }
    }

}

@end
