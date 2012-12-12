//
//  PromotionCodeManager.m
//  FootGame
//
//  Created by Owyn Richen on 11/27/12.
//
//

#import "PromotionCodeManager.h"
#import "SBJsonParser.h"
#import "PremiumContentStore.h"

#define PROMO_LIST_URL @"http://www.alchemistkids.com/index.php/apantspcodes/1cbd27a7c9c01a865a13386b3fb27db7/list/json"

@interface PromotionCodeManager()

-(NSArray *) getDataFromServer: (id<PromotionCodeDelegate>) del withError: (NSError **) error;

@end

@implementation PromotionCodeManager

static PromotionCodeManager *_instance;
static NSString *_sync = @"sync";

+(PromotionCodeManager *) instance {
    if (_instance == NULL) {
        @synchronized(_sync) {
            if (_instance == NULL) {
                _instance = [[PromotionCodeManager alloc] init];
            }
        }
    }
    
    return _instance;
}

-(void) usePromotionCode: (NSString *) code withDelegate: (id<PromotionCodeDelegate>) del {
    if (del != nil && [del respondsToSelector:@selector(usePromotionCodeStarted:)]) {
        [del usePromotionCodeStarted: nil];
    }
    
    NSError *error = nil;
    
    // Test code to clear products
    if ([code isEqualToString:@"!clear"]) {
        [[PremiumContentStore instance] returnAllProducts];
        
        if (del != nil && [del respondsToSelector:@selector(usePromotionCodeSuccess:success:)]) {
            [del usePromotionCodeSuccess: nil success:YES];
        }
        return;
    }
    
    NSArray *codes = [self getDataFromServer:del withError:&error];
    
    if (error != nil) {
        if (del != nil && [del respondsToSelector:@selector(usePromotionCodeError:error:)]) {
            [del usePromotionCodeError:nil error:error];
        }
    }
    
    __block BOOL codeSuccess = NO;
    
    [codes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Promotion *promoCode = (Promotion *) obj;
        
        NSLog(@"checking code '%@' against promo '%@' - %@", code, promoCode.code, promoCode.productId);
        
        if ([promoCode isValid]) {
            if ([[promoCode.code lowercaseString] isEqualToString:[code lowercaseString]]) {
                
                [[PremiumContentStore instance] boughtProductId:promoCode.productId];
                
                if (del != nil && [del respondsToSelector:@selector(usePromotionCodeSuccess:success:)]) {
                    [del usePromotionCodeSuccess: nil success:YES];
                }
                
                codeSuccess = YES;
                *stop = YES;
            }
        } else {
            NSLog(@"Promo code %@ isn't valid %@ - %@-%@", promoCode.code, [[NSDate date] description], [promoCode.startDate description], [promoCode.endDate description]);
            
            codeSuccess = NO;
            *stop = YES;
        }
    }];
    
    if (!codeSuccess && del != nil && [del respondsToSelector:@selector(usePromotionCodeSuccess:success:)]) {
        [del usePromotionCodeSuccess: nil success:NO];
        return;
    }
}

-(NSArray *) getDataFromServer: (id<PromotionCodeDelegate>) del withError: (NSError **) error {
    NSURL *metaUrl = [NSURL URLWithString:PROMO_LIST_URL];
    
    NSLog(@"Requesting update from %@", [metaUrl description]);
    
    NSString *response = [NSString stringWithContentsOfURL:metaUrl encoding:NSUTF8StringEncoding error:error];
    
    if (*error) {
        apErr(*error);
        NSLog(@"Error getting data: %@", [*error localizedDescription]);
        return nil;
    }
    
    NSLog(@"Response: %@", response);
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *dataSet = [parser objectWithString:response error:error];
    [parser release];
    
    NSLog(@"Data From Server: %@", [dataSet description]);
    
    if (*error) {
        NSLog(@"Error parsing data: %@", [*error localizedDescription]);
        return nil;
    }
    
    NSArray *entries = (NSArray *) [dataSet objectForKey:@"entries"];
    
    [dataSet release];
    
    NSMutableArray *possibleCodes = [[NSMutableArray alloc] init];
    
    [entries enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *promo = (NSDictionary *) obj;
        
        Promotion *code = [[Promotion alloc] initWithDictionary:promo];
        
        [possibleCodes addObject:code];
    }];
    
    return possibleCodes;
}

@end

@implementation Promotion

@synthesize code;
@synthesize productId;
@synthesize startDate;
@synthesize endDate;

-(BOOL) isValid {
    NSDate *now = [NSDate date];
    
    return ([now compare:self.startDate] >= NSOrderedSame && [now compare:self.endDate] <= NSOrderedSame);
}

-(id) initWithDictionary: (NSDictionary *) data {
    self = [super init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    self.startDate = [formatter dateFromString:(NSString *) [data objectForKey:@"start_date"]];
    self.endDate = [formatter dateFromString:(NSString *) [data objectForKey:@"end_date"]];
    
    [formatter release];
    
    self.code = (NSString *) [data objectForKey:@"code"];
    self.productId = (NSString *) [data objectForKey:@"product_id"];
    
    return self;
}

@end