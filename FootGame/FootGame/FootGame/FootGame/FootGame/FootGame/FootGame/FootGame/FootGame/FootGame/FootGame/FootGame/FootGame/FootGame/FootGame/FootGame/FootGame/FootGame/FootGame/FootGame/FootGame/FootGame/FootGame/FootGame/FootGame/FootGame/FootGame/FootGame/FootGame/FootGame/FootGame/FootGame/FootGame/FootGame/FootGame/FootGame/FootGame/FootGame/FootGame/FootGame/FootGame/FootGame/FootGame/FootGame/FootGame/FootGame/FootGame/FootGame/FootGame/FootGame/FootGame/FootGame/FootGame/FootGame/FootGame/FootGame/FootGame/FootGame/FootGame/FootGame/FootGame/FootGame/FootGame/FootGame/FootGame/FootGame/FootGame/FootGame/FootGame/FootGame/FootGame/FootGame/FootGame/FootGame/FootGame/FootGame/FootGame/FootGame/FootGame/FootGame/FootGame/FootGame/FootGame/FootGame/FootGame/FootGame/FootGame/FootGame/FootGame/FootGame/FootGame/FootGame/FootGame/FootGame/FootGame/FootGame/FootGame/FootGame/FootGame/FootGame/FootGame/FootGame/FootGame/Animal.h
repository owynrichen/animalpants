//
//  Animal.h
//  FootGame
//
//  Created by Owyn Richen on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnimalPart.h"

@interface Animal : NSObject {
    NSString *key;
    NSString *name;
    AnimalPart *body;
    AnimalPart *foot;
    
    NSString *environment;
    NSString *successSound;
    NSString *failSound;
    NSString *word;
    NSString *productId;
    
    NSString *factsHtml;
}

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) AnimalPart *body;
@property (nonatomic, retain) AnimalPart *foot;
@property (nonatomic, retain) NSString *successSound;
@property (nonatomic, retain) NSString *failSound;
@property (nonatomic, retain) NSString *environment;
@property (nonatomic, retain) NSString *word;
@property (nonatomic, retain) NSString *productId;

@property (nonatomic, retain) NSString *factsHtml;

+(Animal *) initWithDictionary: (NSDictionary *) dict;

@end
