//
//  PremiumContentManager.m
//  FootGame
//
//  Created by Owyn Richen on 11/27/12.
//
//

#import "PremiumContentStore.h"

static PremiumContentStore *_instance;
static NSString *_sync = @"sync";

@interface Product : NSObject

@property (nonatomic, retain) NSString *productId;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, readonly) NSMutableArray *parents;

@end

@implementation Product
@synthesize productId;
@synthesize status;
@synthesize parents;

-(id) init {
    self = [super init];
    
    parents = [[NSMutableArray alloc] init];
    
    return self;
}



-(void) dealloc {
    if (parents != nil) {
        [parents release];
    }
    
    [super dealloc];
}

@end

@interface PremiumContentStore()

-(void) addToMap: (id) key data: (id) data;

@end

@implementation PremiumContentStore

+(PremiumContentStore *) instance {
    if (_instance == NULL) {
        @synchronized(_sync) {
            if (_instance == NULL) {
                _instance = [[PremiumContentStore alloc] init];
            }
        }
    }
    
    return _instance;
}

-(void) addToMap: (id) key data: (id) data {
    if ([data isKindOfClass:[NSArray class]]) {
        Product *parent = (Product *) [productMap objectForKey:(NSString *) key];
        if (parent == nil) {
            parent = [[[Product alloc] init] autorelease];
        }
        
        parent.productId = key;
        parent.status = @"parent";
        [productMap setObject:parent forKey:key];
        
        [((NSArray *) data) enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Product *prod = (Product *) [productMap objectForKey:(NSString *) obj];
            if (prod == nil) {
                prod = [[[Product alloc] init] autorelease];
            }
            
            [prod.parents addObject:(NSString *) key];
            
            [productMap setObject:prod forKey:(NSString *) obj];
        }];
    } else if ([data isKindOfClass:[NSString class]]) {
        Product *prod = (Product *) [productMap objectForKey:key];
        if (prod == nil) {
            prod = [[[Product alloc] init] autorelease];
        }
        
        prod.productId = (NSString *) key;
        prod.status = (NSString *) data;
        
        [productMap setObject:prod forKey:(NSString *) key];
    } else {
        NSLog(@"Unknown data type in product map '%@' for key '%@'", [[data class] description], [key description]);
        return;
    }
}

-(id) init {
    self = [super init];
    
    productMap = [[NSMutableDictionary alloc] init];
    
    NSObject *path = [[NSBundle mainBundle] pathForResource:@"Products" ofType:@"plist"];
    
    NSString *fullPath = (NSString *) path;
    
    NSPropertyListFormat format;
    NSString *errorDesc = nil;
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:fullPath];
    
    NSDictionary *data = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format
                                          errorDescription:&errorDesc];

    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSLog(@"Product %@ - %@", (NSString *) key, [obj description]);
        [self addToMap:key data:obj];
    }];
    
    return self;
}

-(NSArray *) products {
    return [productMap allKeys];
}

-(void) dealloc {
    if (productMap != nil)
        [productMap release];
    
    [super dealloc];
}

-(BOOL) ownsProductId: (NSString *) productId {
    if ([productId isEqualToString:FREE_PRODUCT_ID])
        return YES;
    
    Product *prod = (Product *) [productMap objectForKey:productId];
    
    if (prod == nil) {
        NSLog(@"nil Product for %@ when unexpected", productId);
    } else {
        if ([prod.status isEqualToString:FREE_PRODUCT_ID]) {
            return YES;
        }
        
        NSData *purchased = [[NSUserDefaults standardUserDefaults] objectForKey:productId];
        
        if (purchased != NULL) {
            return YES;
        }
        
        __block BOOL bought = NO;
        
        [prod.parents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([self ownsProductId:(NSString *) obj]) {
                bought = YES;
                *stop = YES;
            }
        }];
        
        return bought;
    }
    
    return NO;
}

-(NSString *) ownedProducts {
    NSMutableArray *products = [NSMutableArray array];
    [productMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([self ownsProductId:key]) {
            [products addObject:[key stringByReplacingOccurrencesOfString:@"com.alchemistinteractive.footgame." withString:@""]];
        }
    }];
    
    return [products componentsJoinedByString:@", "];
}

-(void) boughtProductId: (NSString *) productId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"bought" forKey:productId];
    [defaults synchronize];
}

-(void) returnedProductId: (NSString *) productId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:productId];
    [defaults synchronize];
}

-(void) returnAllProducts {
    [productMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        Product *product = (Product *) obj;
        
        if (![product.status isEqualToString:FREE_PRODUCT_ID]) {
            [self returnedProductId:(NSString *) key];
        }
    }];
}

@end
