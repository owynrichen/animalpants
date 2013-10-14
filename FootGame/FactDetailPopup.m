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

#define BORDER_SCALE 1.0
#define TITLE_FONT @"Rather Loud"
#define TEXT_FONT @"Mill"
#define TITLE_FONT_SIZE 44
#define TEXT_FONT_SIZE 44

@interface FactDetailPopup()
-(CGSize) setFactDataScale: (CCNode<CCRGBAProtocol> *) fdata;
-(NSString *) imageForFactType: (FactFrameType) fact animal: (Animal *) anml;
-(NSString *) keyForFactType: (FactFrameType) fact;
@end

@implementation FactDetailPopup

+(FactDetailPopup *) popup {
    return [[[FactDetailPopup alloc] init] autorelease];
}

+(ContentManifest *) manifestWithFrameType: (FactFrameType) fact animal: (Animal *) anml {
    ContentManifest *mfest = [[[ContentManifest alloc] init] autorelease];
    
    
    
    return mfest;
}

-(void) showFact: (FactFrameType) fact forAnimal: (Animal *) animal withOpenBlock:(PopupBlock) openBlock closeBlock:(PopupBlock) closeBlock {
    if (factData) {
        [self removeChild:factData cleanup:YES];
        factData = nil;
    }
    
    if (factTitle) {
        [self removeChild:factTitle cleanup:YES];
        factTitle = nil;
    }
    
    if (factText) {
        [self removeChild:factText cleanup:YES];
        factText = nil;
    }
    
    NSString *key = [self keyForFactType: fact];
    CGPoint half = ccp(background.contentSize.width / 2, background.contentSize.height / 2);
//    CGPoint titlePos = ccp(background.contentSize.width / 2, background.contentSize.height / 4);
//    CGPoint textPos = ccp(0,0);
    CGPoint titlePos, textPos;
    CGSize titleSize, textSize;
    NSString *imgFile;
    CGSize cSize;
    
    NSString *titlestr = [animal factTitle:(FactType) fact];
    NSString *txtstr = [animal factText:(FactType) fact];
    
    factTitle = [CCLabelTTF labelWithString:titlestr fontName:TITLE_FONT fontSize:TITLE_FONT_SIZE * fontScaleForCurrentDevice() dimensions:CGSizeMake(0, 0) hAlignment:kCCTextAlignmentLeft];
    
    // factText = [CCLabelTTF labelWithString:txtstr fontName:TEXT_FONT fontSize:TEXT_FONT_SIZE * fontScaleForCurrentDevice() dimensions:CGSizeMake(0, 0) hAlignment:kCCTextAlignmentLeft vAlignment:kCCVerticalTextAlignmentTop];
    
    factText = [CCLabelBMFont labelWithString:txtstr fntFile:@"RobotoThin.fnt" width:0 alignment:kCCTextAlignmentLeft];
    
    float titleMult = 1.0;
    
    switch(fact) {
        case kHeightFactFrame:
            imgFile = [NSString stringWithFormat:@"%@_%@_large.png", [animal.key lowercaseString], key];
            factData = [CCAutoScalingSprite spriteWithFile:imgFile];
            cSize = [self setFactDataScale:factData];
            factData.position = ccpToRatio(half.x + (half.x - (cSize.width / 2)), half.y);
            
            titleSize = CGSizeMake(half.x, 500);
            textSize = CGSizeMake(half.x * 0.8, 500);
            titlePos = ccpToRatio(half.x * 0.05, half.y + (half.y * 0.75));
            textPos = ccpToRatio(half.x * 0.05, half.y + (half.y * 0.75));
            break;
        case kWeightFactFrame:
            imgFile = [NSString stringWithFormat:@"%@_%@_large.png", [animal.key lowercaseString], key];
            factData = [CCAutoScalingSprite spriteWithFile:imgFile];
            cSize = [self setFactDataScale:factData];
            factData.position = ccpToRatio(cSize.width / 2, half.y);
            
            titleSize = CGSizeMake(half.x * 0.75, 500);
            textSize = CGSizeMake(half.x * 0.75, 500);
            titlePos = ccpToRatio(half.x + (half.x * 0.2), half.y + (half.y / 2));
            textPos = ccpToRatio(half.x + (half.x * 0.2), half.y + (half.y / 2));
            break;
        case kEarthFactFrame:
            key = [self keyForFactType: fact];
            WorldMapNode *wmn = [WorldMapNode worldMapWithMap:@"world-map.png" projectionType:kRobinsonProjection];
            
            NSString *pinimg = [NSString stringWithFormat:@"mappin-%@.png", [animal.key lowercaseString]];
            [animal enumerateHabitiatLocationsWithBlock:^(LatitudeLongitude ll) {
                [wmn addMapPin:[WorldMapPin worldMapPinWithImage:pinimg ll:ll]];
            }];
            // This block could return immediately if the lat/lng is cached
            [[LocationManager sharedManager] getLocation:^(LatitudeLongitude ll) {
                NSString *unit = [[LocationManager sharedManager] currentLocaleUsesMetric] ? locstr(@"kilometers", @"strings",@"") : locstr(@"miles", @"string",@"");
                __block CGFloat shortestDistance = INT32_MAX;
                [animal enumerateHabitiatLocationsWithBlock:^(LatitudeLongitude all) {
                    CGFloat d = hdist(ll, all);
                    if (d < shortestDistance) {
                        shortestDistance = d;
                    }
                }];
                
                shortestDistance = [[LocationManager sharedManager] getLocalizedDistance:shortestDistance];
                
                NSString *distanceStr = [NSString stringWithFormat:
                                         locstr(@"distance_from_you_string",@"strings",@""),
                                         [animal localizedName],
                                         shortestDistance,
                                         unit];
                factText.string = distanceStr;
                
                [wmn addMapPin:[WorldMapPin worldMapPinWithImage:@"mappin-kids.png" ll:ll]];
            }];
            
            factData = wmn;
            cSize = [self setFactDataScale:factData];
            factData.position = ccpToRatio(half.x, half.y + (half.y - (cSize.height / 2)) - (half.x * 0.05));
            
            titleMult = 0.8;
            titleSize = CGSizeMake(cSize.width * 0.9, 500);
            textSize = CGSizeMake(cSize.width * 0.9, 500);
            titlePos = ccpToRatio(half.x * 0.1, factData.position.y - (cSize.height / 2)); 
            textPos = ccpToRatio(half.x * 0.1, factData.position.y - (cSize.height / 2));
            
            break;
        case kFoodFactFrame:
            imgFile = [NSString stringWithFormat:@"%@-%@.png", [animal.key lowercaseString], key];
            factData = [CCAutoScalingSprite spriteWithFile:imgFile];
            cSize = [self setFactDataScale:factData];
            factData.position = ccpToRatio(half.x, half.y - (half.y - (cSize.height / 2)));
            
            titleSize = CGSizeMake(half.x, 500);
            textSize = CGSizeMake(half.x, 500);
            titlePos = ccpToRatio(half.x * 0.85, half.y + (half.y * 0.75));
            textPos = ccpToRatio(half.x * 0.85, half.y + (half.y * 0.75));
            break;
        case kSpeedFactFrame:
            key = @"speed";
            imgFile = [NSString stringWithFormat:@"%@_%@.png", [animal.key lowercaseString], key];
            factData = [CCAutoScalingSprite spriteWithFile:imgFile];
            cSize = [self setFactDataScale:factData];
            factData.position = ccpToRatio(half.x, half.y - (half.y - (cSize.height / 2)));
            
            titleSize = CGSizeMake(half.x, 500);
            textSize = CGSizeMake(half.x, 500);
            titlePos = ccpToRatio(half.x * 0.05, half.y + (half.y * 0.75));
            textPos = ccpToRatio(half.x * 0.05, half.y + (half.y * 0.75));
            break;
        case kFaceFactFrame:
            key = @"photo";
            imgFile = [NSString stringWithFormat:@"%@_%@.jpg", [animal.key lowercaseString], key];
            factData = [CCAutoScalingSprite spriteWithFile:imgFile];
            cSize = [self setFactDataScale:factData];
            factData.position = ccpToRatio((cSize.width / 2) + (cSize.width * 0.05), half.y); // + (half.y - (cSize.height / 2))
            
            titleSize = CGSizeMake(half.x * 0.8, 500);
            textSize = CGSizeMake(half.x * 0.8, 500);
            titlePos = ccpToRatio(factData.position.x + (cSize.width / 2) + (half.x * 0.02), half.y + (cSize.height / 2));
            textPos = ccpToRatio(factData.position.x + (cSize.width / 2) + (half.x * 0.02), half.y + (cSize.height / 2));
            break;
    }
    
    float fontSize = TITLE_FONT_SIZE * titleMult * fontScaleForCurrentDevice();
    titleSize = [titlestr sizeWithFont:[UIFont fontWithName:TITLE_FONT size:fontSize] constrainedToSize:titleSize lineBreakMode:NSLineBreakByWordWrapping];
    textSize = [txtstr sizeWithFont:[UIFont fontWithName:TEXT_FONT size:TEXT_FONT_SIZE * fontScaleForCurrentDevice()] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    textPos = ccp(textPos.x, textPos.y - titleSize.height);
    
    factTitle.dimensions = titleSize;
    factTitle.anchorPoint = ccp(0,1.0);
    factTitle.position = titlePos;
    factTitle.fontSize = fontSize;
    factTitle.color = ccc3(198, 220, 15);
    
    // factText.dimensions = textSize;
    [factText setWidth:textSize.width];
    factText.anchorPoint = ccp(0,1.0);
    factText.position = textPos;
    factText.color = ccGRAY;
    
    [self addChild:factData];
    [self addChild:factTitle];
    [self addChild:factText];
    NSString *alog = [NSString stringWithFormat: @"Fact Detail %@ %@", animal.key, key];
    
    [super showWithOpenBlock:openBlock closeBlock:closeBlock analyticsKey:alog];
}

-(CGSize) setFactDataScale: (CCNode<CCRGBAProtocol> *) fdata {
    float scale = 1.0;
    if (fdata.contentSize.width > background.contentSize.width * BORDER_SCALE) {
        float s = background.contentSize.width * BORDER_SCALE / fdata.contentSize.width;
        if (s < scale) {
            scale = s;
        }
    }
    
    if (fdata.contentSize.height > background.contentSize.height * BORDER_SCALE) {
        float s = background.contentSize.height * BORDER_SCALE / fdata.contentSize.height;
        if (s < scale) {
            scale = s;
        }
    }
    
    fdata.scale = scale;
    
    return CGSizeMake(fdata.contentSize.width * fdata.scale, fdata.contentSize.height * fdata.scale);
}

-(NSString *) imageForFactType: (FactFrameType) fact animal:(Animal *)animal {
    switch(fact) {
        case kHeightFactFrame:
            return [NSString stringWithFormat:@"%@_%@_large.png", [animal.key lowercaseString], [self keyForFactType: fact]];
        case kWeightFactFrame:
            return [NSString stringWithFormat:@"%@_%@_large.png", [animal.key lowercaseString], [self keyForFactType: fact]];
        case kEarthFactFrame:
            return [NSString stringWithFormat:@"mappin-%@.png", [animal.key lowercaseString]];
        case kFoodFactFrame:
            return [NSString stringWithFormat:@"%@-%@.png", [animal.key lowercaseString], [self keyForFactType: fact]];
        case kSpeedFactFrame:
            return [NSString stringWithFormat:@"%@_%@.png", [animal.key lowercaseString], [self keyForFactType: fact]];
        case kFaceFactFrame:
            return [NSString stringWithFormat:@"%@_%@.jpg", [animal.key lowercaseString], [self keyForFactType: fact]];
    }
}

-(NSString *) keyForFactType: (FactFrameType) fact {
    switch(fact) {
        case kHeightFactFrame:
            return @"height";
            break;
        case kWeightFactFrame:
            return @"weight";
            break;
        case kEarthFactFrame:
            return @"location";
            break;
        case kFoodFactFrame:
            return @"food";
            break;
        case kSpeedFactFrame:
            return @"speed";
            break;
        case kFaceFactFrame:
            return @"photo";
            break;
    }
}

-(void) setColor:(ccColor3B)color {
    [super setColor: color];
    factData.color = color;
    factTitle.color = color;
    factText.color = color;
}

-(ccColor3B) color {
    return background.color;
}

-(GLubyte) opacity {
    return background.opacity;
}

-(void) setOpacity: (GLubyte) opacity {
    [super setOpacity: opacity];
    factData.opacity = opacity;
    factTitle.opacity = opacity;
    factText.opacity = opacity;
}


@end
