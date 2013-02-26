//
//  WorldMapNode.h
//  FootGame
//
//  Created by Owyn Richen on 2/20/13.
//
//

#import <UIKit/UIKit.h>
#import "CCAutoScalingSprite.h"
#import "LocationManager.h"

@interface WorldMapPin : CCNode<CCRGBAProtocol> {
    CCAutoScalingSprite *pinImage;
}

@property (nonatomic) LatitudeLongitude latlng;

+(WorldMapPin *) worldMapPinWithImage: (NSString *) img ll: (LatitudeLongitude) ll;

-(id) initWorldMapPinWithImage: (NSString *) img ll: (LatitudeLongitude) ll;

-(void) setColor:(ccColor3B)color;
-(ccColor3B) color;

-(GLubyte) opacity;
-(void) setOpacity: (GLubyte) opacity;

@end

typedef enum {
    kRobinsonProjection
} WorldMapProjectionType;

@interface WorldMapNode : CCNode<CCRGBAProtocol> {
    CCAutoScalingSprite *map;
    WorldMapProjectionType projType;
}

+(WorldMapNode *) worldMapWithMap: (NSString *) mapFile projectionType: (WorldMapProjectionType) proj;

-(id) initWithMap: (NSString *) mapFile projectionType: (WorldMapProjectionType) proj;

-(void) addMapPin: (WorldMapPin *) pin;

-(void) setColor:(ccColor3B)color;
-(ccColor3B) color;

-(GLubyte) opacity;
-(void) setOpacity: (GLubyte) opacity;

@end
