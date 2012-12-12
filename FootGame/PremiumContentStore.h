//
//  PremiumContentManager.h
//  FootGame
//
//  Created by Owyn Richen on 11/27/12.
//
//

#import <Foundation/Foundation.h>
#import "BaseRepository.h"
#import "AnalyticsPublisher.h"

#define FREE_PRODUCT_ID @"free"
#define PREMIUM_PRODUCT_ID @"com.alchemistinteractive.footgame.premo"

@interface PremiumContentStore : BaseRepository {
    NSMutableDictionary *productMap;
}

+(PremiumContentStore *) instance;

-(NSArray *) products;
-(BOOL) ownsProductId: (NSString *) productId;
-(void) boughtProductId: (NSString *) productId;
-(void) returnedProductId: (NSString *) productId;
-(void) returnAllProducts;

@end
