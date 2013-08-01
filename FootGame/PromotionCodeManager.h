//
//  PromotionCodeManager.h
//  FootGame
//
//  Created by Owyn Richen on 11/27/12.
//
//

#import <Foundation/Foundation.h>

@interface Promotion : NSObject<NSCopying>

@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSString *productId;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;

-(BOOL) isValid;
-(id) initWithDictionary: (NSDictionary *) data;
-(NSDictionary *) toDict;

@end

@protocol PromotionCodeDelegate <NSObject>

@optional
-(void) usePromotionCodeStarted: (Promotion *) promo;
-(void) usePromotionCodeSuccess: (Promotion *) promo success: (BOOL) successful;
-(void) usePromotionCodeError: (Promotion *) promo error: (NSError *) error;

@end

@interface PromotionCodeManager : NSObject

+(PromotionCodeManager *) instance;

-(void) usePromotionCode: (NSString *) code withDelegate: (id<PromotionCodeDelegate>) del;
-(NSDictionary *) attemptedCodes;


@end
