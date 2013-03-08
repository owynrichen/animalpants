//
//  FactDetailPopup.m
//  FootGame
//
//  Created by Owyn Richen on 2/14/13.
//
//

#import "FactDetailPopup.h"
#import "LocalizationManager.h"
#import "LocationManager.h"
#import "WorldMapNode.h"
#import "AnalyticsPublisher.h"

#define BORDER_SCALE 1.0

@implementation FactDetailPopup

+(FactDetailPopup *) popup {
    return [[[FactDetailPopup alloc] init] autorelease];
}

-(id) init {
    self = [super init];
    
    background = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 0)];
    background.contentSize = CGSizeMake(950, 600);
    background.blendFunc = (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };
    [self addChild:background];
    
    close = [CircleButton buttonWithFile:@"close-x.png"];
    close.scale = 0.6;
    close.position = ccp(900, 550);
    [self addChild:close z:100];
    [close addEvent:@"touch" withBlock:^(CCNode * sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.8]];
    }];
    
    [close addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.6]];
    }];
    
    [close addEvent:@"touchup" withBlock:^(CCNode *sender) {
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.6]];
        FactDetailPopup *p = (FactDetailPopup *) sender.parent.parent;
        [p hide];
    }];
    
    self.contentSize = background.contentSize;
    self.opacity = 0;
    self.scale = 0.8;
    self.anchorPoint = ccp(0.5,0.5);
    
    return self;
}

-(void) showFact: (FactFrameType) fact forAnimal: (Animal *) animal withOpenBlock:(PopupBlock) openBlock closeBlock:(PopupBlock) closeBlock {
    if (factData) {
        [self removeChild:factData cleanup:YES];
        factData = nil;
    }
    
    if (factText) {
        [self removeChild:factText cleanup:YES];
        factText = nil;
    }
    
    NSString *key;
    CGPoint textPos = ccp(background.contentSize.width / 2, background.contentSize.height / 4);
    CGPoint imagePos = ccp(background.contentSize.width / 2, background.contentSize.height / 2);
    NSString *imgFile;
    
    switch(fact) {
        case kHeightFactFrame:
            key = @"height";
            imgFile = [NSString stringWithFormat:@"%@_%@_large.png", [animal.key lowercaseString], key];
            break;
        case kWeightFactFrame:
            key = @"weight";
            imgFile = [NSString stringWithFormat:@"%@_%@_large.png", [animal.key lowercaseString], key];
            break;
        case kEarthFactFrame:
            key = @"location";
            WorldMapNode *wmn = [WorldMapNode worldMapWithMap:@"world-map.png" projectionType:kRobinsonProjection];
            
            NSString *pinimg = [NSString stringWithFormat:@"mappin-%@.png", [animal.key lowercaseString]];
            [animal enumerateHabitiatLocationsWithBlock:^(LatitudeLongitude ll) {
                [wmn addMapPin:[WorldMapPin worldMapPinWithImage:pinimg ll:ll]];
            }];
            
            [[LocationManager sharedManager] getLocation:^(LatitudeLongitude ll) {
                NSString *unit = [[LocationManager sharedManager] currentLocaleUsesMetric] ? locstr(@"kilometers", @"strings",@"") : locstr(@"miles", @"string",@"");
                __block CGFloat shortestDistance = MAX_INT;
                [animal enumerateHabitiatLocationsWithBlock:^(LatitudeLongitude all) {
                    CGFloat d = hdist(ll, all);
                    if (d < shortestDistance) {
                        shortestDistance = d;
                    }
                }];
                
                NSString *distanceStr = [NSString stringWithFormat:
                                         locstr(@"distance_from_you_string",@"strings",@""),
                                         shortestDistance,
                                         unit,
                                         [animal localizedName]];
                factText.string = [distanceStr stringByAppendingString:factText.string];
                
                [wmn addMapPin:[WorldMapPin worldMapPinWithImage:@"mappin-kids.png" ll:ll]];
            }];
            
            factData = wmn;
            break;
        case kFoodFactFrame:
            key = @"food";
            imgFile = [NSString stringWithFormat:@"%@-%@.png", [animal.key lowercaseString], key];
            break;
        case kSpeedFactFrame:
            key = @"speed";
            imgFile = [NSString stringWithFormat:@"%@_%@.png", [animal.key lowercaseString], key];
            break;
        case kFaceFactFrame:
            key = @"photo";
            // TODO: wire this up when we have a photo
            factData = [CCAutoScalingSprite spriteWithFile:@"girl1_head.png"];
            break;
    }
    
    if (factData == nil && imgFile != nil) {
        factData = [CCAutoScalingSprite spriteWithFile:imgFile];
    }
    factData.position = imagePos;
    
    NSString *txtstr = [NSString stringWithFormat:@"%@_fact_%@", [animal.key lowercaseString], key];

    factText = [CCLabelTTF labelWithString:@" " fontName:@"Rather Loud" fontSize:48 * fontScaleForCurrentDevice() dimensions:CGSizeMake(500, 200) hAlignment:kCCTextAlignmentLeft];
    factText.string = [factText.string stringByAppendingString:locstr(txtstr,@"strings",@"")];
    factText.position = textPos;
    factText.color = ccBLACK;
    
    float scale = 1.0;
    if (factData.contentSize.width > background.contentSize.width * BORDER_SCALE) {
        float s = background.contentSize.width * BORDER_SCALE / factData.contentSize.width;
        if (s < scale) {
            scale = s;
        }
    }
    
    if (factData.contentSize.height > background.contentSize.height * BORDER_SCALE) {
        float s = background.contentSize.height * BORDER_SCALE / factData.contentSize.height;
        if (s < scale) {
            scale = s;
        }
    }
    
    factData.scale = scale;
    
    //factData.position = ccp((background.contentSize.width - factData.contentSize.width * scale) / 2, (background.contentSize.height - factData.contentSize.height * scale) / 2);
    
    [self addChild:factData];
    [self addChild:factText];
    
    if (openBlock != nil)
        openBlock(self);
    
    cBlock = [[closeBlock copy] retain];
    
    [self runAction:[CCFadeIn actionWithDuration:0.3]];
    [self runAction:[CCScaleTo actionWithDuration:0.3 scale:1.0]];
    NSString *alog = [NSString stringWithFormat: @"Fact Detail %@ %@", animal.key, key];
    apView(alog);
}

-(void) hide {
    if (cBlock != nil) {
        cBlock(self);
        [cBlock release];
        cBlock = nil;
    }
    [self runAction:[CCFadeOut actionWithDuration:0.3]];
    [self runAction:[CCScaleTo actionWithDuration:0.3 scale:0.8]];
}

-(void) setColor:(ccColor3B)color {
    background.color = color;
    close.color = color;
    factData.color = color;
    factText.color = color;
}

-(ccColor3B) color {
    return background.color;
}

-(GLubyte) opacity {
    return background.opacity;
}

-(void) setOpacity: (GLubyte) opacity {
    background.opacity = opacity;
    close.opacity = opacity;
    factData.opacity = opacity;
    factText.opacity = opacity;
}

@end
