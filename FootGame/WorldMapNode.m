//
//  WorldMapNode.m
//  FootGame
//
//  Created by Owyn Richen on 2/20/13.
//
//

#import "WorldMapNode.h"

@implementation WorldMapPin

@synthesize latlng;

+(WorldMapPin *) worldMapPinWithImage: (NSString *) img ll: (LatitudeLongitude) ll {
    return [[[WorldMapPin alloc] initWorldMapPinWithImage:img ll:ll] autorelease];
}

-(id) initWorldMapPinWithImage: (NSString *) img ll: (LatitudeLongitude) ll {
    self = [super init];
    
    pinImage = [CCAutoScalingSprite spriteWithFile:img];
    pinImage.anchorPoint = ccp(0.5,0);
    [self addChild:pinImage];
    latlng = ll;
    self.contentSize = pinImage.contentSize;
    
    self.anchorPoint = ccp(0.5,0);
    
    return self;
}

-(void) setColor:(ccColor3B)color {
    pinImage.color = color;
}

-(ccColor3B) color {
    return pinImage.color;
}

-(GLubyte) opacity {
    return pinImage.opacity;
}

-(void) setOpacity: (GLubyte) opacity {
    pinImage.opacity = opacity;
}

@end

@interface WorldMapNode()

-(CGPoint) calculatePoint: (LatitudeLongitude) latlng;
-(CGPoint) calculatePinPoint: (WorldMapPin *) pin;

@end

@interface WorldMapNode(RobinsonProjection)

-(CGPoint) getinterpolatedConstant: (CGFloat) latitude;

@end

@implementation WorldMapNode

+(WorldMapNode *) worldMapWithMap: (NSString *) mapFile projectionType: (WorldMapProjectionType) proj {
    return [[[WorldMapNode alloc] initWithMap:mapFile projectionType:proj] autorelease];
}

-(id) initWithMap: (NSString *) mapFile projectionType: (WorldMapProjectionType) proj {
    self = [super init];
    
    map = [CCAutoScalingSprite spriteWithFile:mapFile];
    projType = proj;
    [self addChild:map];
    
    self.contentSize = map.contentSize;
    
    return self;
}

-(void) addMapPin: (WorldMapPin *) pin {
    pin.position = [self calculatePinPoint:pin];
    [map addChild:pin];
}

-(void) setColor:(ccColor3B)color {
    for(int i = 0; i < [children_ count]; i++) {
        ((CCNode<CCRGBAProtocol> *) [children_ objectAtIndex:i]).color = color;
    }
}

-(ccColor3B) color {
    return map.color;
}

-(GLubyte) opacity {
    return map.opacity;
}

-(void) setOpacity: (GLubyte) opacity {
    for(int i = 0; i < [children_ count]; i++) {
        ((CCNode<CCRGBAProtocol> *) [children_ objectAtIndex:i]).opacity = opacity;
    }
    for(int i = 0; i < [map.children count]; i++) {
        ((CCNode<CCRGBAProtocol> *) [map.children objectAtIndex:i]).opacity = opacity;
    }
}

-(CGPoint) calculatePoint: (LatitudeLongitude) latlng {
    CGFloat h = map.contentSize.height;
    CGFloat w = map.contentSize.width;
    
    CGPoint constants = [self getinterpolatedConstant:latlng.latitude];
    
    CGFloat mul = latlng.latitude >= 0 ? 1.0 : -1.0;
    CGFloat latlen = w * constants.x;
    
    CGFloat y = (h * 0.5) + (h * 0.5 * constants.y * mul);
    CGFloat x = ((w - latlen) / 2) + (180 + latlng.longitude) * (latlen/360);
    
    return ccp(x,y);
}

-(CGPoint) calculatePinPoint: (WorldMapPin *) pin {
    return [self calculatePoint:pin.latlng];
}

// this table was pulled from here:
// http://en.wikipedia.org/wiki/Robinson_projection

const float ROBINSON_PROJECTION_TABLE[][2]  = {
    {1.0000, 0.0000}, // 0 latitude
    {0.9986, 0.0620}, // 5 latitude
    {0.9954, 0.1240}, // 10 latitude
    {0.9900, 0.1860}, // 15 latitude
    {0.9822, 0.2480}, // 20 latitude
    {0.9730, 0.3100}, // 25 latitude
    {0.9600, 0.3720}, // 30 latitude
    {0.9427, 0.4340}, // 35 latitude
    {0.9216, 0.4958}, // 40 latitude
    {0.8962, 0.5571}, // 45 latitude
    {0.8679, 0.6176}, // 50 latitude
    {0.8350, 0.6769}, // 55 latitude
    {0.7986, 0.7346}, // 60 latitude
    {0.7597, 0.7903}, // 65 latitude
    {0.7186, 0.8435}, // 70 latitude
    {0.6732, 0.8936}, // 75 latitude
    {0.6213, 0.9394}, // 80 latitude
    {0.5722, 0.9761}, // 85 latitude
    {0.5322, 1.0000}, // 90 latitude
};

-(CGPoint) getinterpolatedConstant: (CGFloat) latitude {
    int tblIdx = abs(floor(latitude)) / 5;
    
    // if the latitude is exactly divisible by 5
    // return the exact table record
    
    if (fmod(latitude, 5.0) == 0.0) {
        return ccp(ROBINSON_PROJECTION_TABLE[tblIdx][0],
                   ROBINSON_PROJECTION_TABLE[tblIdx][1]);
    }
    
    // if it's not divisible by 5 exactly, interpolation
    // needs to happen
    float diff = (fabs(latitude) - ((float) tblIdx) * 5.0) / 5.0;
    
    float plen0 = ROBINSON_PROJECTION_TABLE[tblIdx][0];
    float pdfe0 = ROBINSON_PROJECTION_TABLE[tblIdx][1];
    float plen1 = ROBINSON_PROJECTION_TABLE[tblIdx + 1][0];
    float pdfe1 = ROBINSON_PROJECTION_TABLE[tblIdx + 1][1];
    
    float plen = plen1 + (plen0 - plen1) * diff;
    float pdfe = pdfe0 + (pdfe1 - pdfe0) * diff;
    
    return ccp(plen, pdfe);
}

//-(void) draw {
//    map.opacity = 100;
//    [super draw];
//    
//    if (self.opacity > 0 && self.visible) {
//        CGAffineTransform t = [map nodeToParentTransform];
//        float llinc = 7.5;
//        for(float lat = -90.0; lat <= 90.0; lat += llinc) {
//            
//            ccDrawColor4B(0, 0, 255, self.opacity);
//            CGPoint o = CGPointApplyAffineTransform([self calculatePoint:llmk(lat, -180)], t);
//            CGPoint d = CGPointApplyAffineTransform([self calculatePoint:llmk(lat, 180)], t);
////            CGPoint o = [self calculatePoint:llmk(lat, -180)];
////            CGPoint d = [self calculatePoint:llmk(lat, 180)];
//            
//            ccDrawLine(o, d);
//            
//            if (lat < 90) {
//                for(float lng = -180.0; lng <= 180.0; lng += llinc) {
//                    ccDrawColor4B(255, 0, 0, self.opacity);
//                    CGPoint lls = CGPointApplyAffineTransform([self calculatePoint:llmk(lat, lng)], t);
//                    CGPoint lle = CGPointApplyAffineTransform([self calculatePoint:llmk(lat + llinc, lng)], t);
////                    CGPoint lls = [self calculatePoint:llmk(lat, lng)];
////                    CGPoint lle = [self calculatePoint:llmk(lat + llinc, lng)];
//                    ccDrawLine(lls, lle);
//                }
//            }
//        }
//    }
//}

@end
