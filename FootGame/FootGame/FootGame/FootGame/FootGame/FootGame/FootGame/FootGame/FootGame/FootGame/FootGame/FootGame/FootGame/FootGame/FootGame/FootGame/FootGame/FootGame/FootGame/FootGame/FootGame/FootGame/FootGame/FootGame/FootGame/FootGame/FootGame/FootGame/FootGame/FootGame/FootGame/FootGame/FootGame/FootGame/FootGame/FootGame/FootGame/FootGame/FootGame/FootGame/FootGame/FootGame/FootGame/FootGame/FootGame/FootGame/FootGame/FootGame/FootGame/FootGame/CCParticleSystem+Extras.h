//
//  CCParticleSystem+Extras.h
//  FootGame
//
//  Created by Owyn Richen on 12/26/12.
//
//

#import "CCParticleSystem.h"

@interface CCParticleSystem(Extras)

@property (nonatomic, readonly) float elapsed;

-(void) matchScale: (CCNode *) node;

+(id) particleWithFile:(NSString *)plistFile params: (NSDictionary *) params;
-(id) initWithFile:(NSString *)plistFile params: (NSDictionary *) params;
-(void) stopSystemAndCleanup;
-(void) cleanupWhenDone;
-(void) moveToParentsParent;

@end