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
#import "SoundManager.h"

#define BORDER_SCALE 1.0
#define TITLE_FONT @"Rather Loud"
#define TEXT_FONT @"Mill"
#define TITLE_FONT_SIZE 48
#define TEXT_FONT_SIZE 44

@interface FactDetailPopup()
-(CGSize) setFactDataScale: (CCNode<CCRGBAProtocol> *) fdata;
@end

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
        [[SoundManager sharedManager] playSound:@"glock__g1.mp3"];
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
    CGPoint half = ccp(background.contentSize.width / 2, background.contentSize.height / 2);
    CGPoint titlePos = ccp(background.contentSize.width / 2, background.contentSize.height / 4);
    CGPoint textPos = ccp(0,0);
    CGSize titleSize;
    CGSize textSize;
    NSString *imgFile;
    CGSize cSize;
    
    NSString *titlestr = [animal factTitle:fact];
    NSString *txtstr = [animal factText:fact];
    
    factTitle = [CCLabelTTF labelWithString:titlestr fontName:TITLE_FONT fontSize:TITLE_FONT_SIZE * fontScaleForCurrentDevice() dimensions:titleSize hAlignment:kCCTextAlignmentLeft];
    
    factText = [CCLabelTTF labelWithString:txtstr fontName:TEXT_FONT fontSize:TEXT_FONT_SIZE * fontScaleForCurrentDevice() dimensions:textSize hAlignment:kCCTextAlignmentLeft vAlignment:kCCVerticalTextAlignmentTop];
    
    switch(fact) {
        case kHeightFactFrame:
            key = @"height";
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
            key = @"weight";
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
            key = @"location";
            WorldMapNode *wmn = [WorldMapNode worldMapWithMap:@"world-map.png" projectionType:kRobinsonProjection];
            
            NSString *pinimg = [NSString stringWithFormat:@"mappin-%@.png", [animal.key lowercaseString]];
            [animal enumerateHabitiatLocationsWithBlock:^(LatitudeLongitude ll) {
                [wmn addMapPin:[WorldMapPin worldMapPinWithImage:pinimg ll:ll]];
            }];
            // This block could return immediately if the lat/lng is cached
            [[LocationManager sharedManager] getLocation:^(LatitudeLongitude ll) {
                NSString *unit = [[LocationManager sharedManager] currentLocaleUsesMetric] ? locstr(@"kilometers", @"strings",@"") : locstr(@"miles", @"string",@"");
                __block CGFloat shortestDistance = MAX_INT;
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
            
            titleSize = CGSizeMake(cSize.width * 0.9, 500);
            textSize = CGSizeMake(cSize.width * 0.9, 500);
            titlePos = ccpToRatio(half.x * 0.1, factData.position.y - (cSize.height / 2)); 
            textPos = ccpToRatio(half.x * 0.1, factData.position.y - (cSize.height / 2));
            
            break;
        case kFoodFactFrame:
            key = @"food";
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
    
    
    titleSize = [titlestr sizeWithFont:[UIFont fontWithName:TITLE_FONT size:TITLE_FONT_SIZE * fontScaleForCurrentDevice()] constrainedToSize:titleSize lineBreakMode:NSLineBreakByWordWrapping];
    textSize = [txtstr sizeWithFont:[UIFont fontWithName:TEXT_FONT size:TEXT_FONT_SIZE * fontScaleForCurrentDevice()] constrainedToSize:textSize lineBreakMode:NSLineBreakByWordWrapping];
    
    textPos = ccp(textPos.x, textPos.y - titleSize.height);
    
    factTitle.dimensions = titleSize;
    factTitle.anchorPoint = ccp(0,1.0);
    factTitle.position = titlePos;
    factTitle.color = ccc3(198, 220, 15);
    
    factText.dimensions = textSize;
    factText.anchorPoint = ccp(0,1.0);
    factText.position = textPos;
    factText.color = ccGRAY;
    
    [self addChild:factData];
    [self addChild:factTitle];
    [self addChild:factText];
    
    if (openBlock != nil)
        openBlock(self);
    
    cBlock = [[closeBlock copy] retain];
    
    [self runAction:[CCFadeIn actionWithDuration:0.3]];
    [self runAction:[CCScaleTo actionWithDuration:0.3 scale:1.0]];
    NSString *alog = [NSString stringWithFormat: @"Fact Detail %@ %@", animal.key, key];
    apView(alog);
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

-(void) hide {
    if (cBlock != nil) {
        cBlock(self);
        [cBlock release];
        cBlock = nil;
    }
    
    [[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
    
    [self runAction:[CCFadeOut actionWithDuration:0.3]];
    [self runAction:[CCScaleTo actionWithDuration:0.3 scale:0.8]];
}

-(void) setColor:(ccColor3B)color {
    background.color = color;
    close.color = color;
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
    background.opacity = opacity;
    close.opacity = opacity;
    factData.opacity = opacity;
    factTitle.opacity = opacity;
    factText.opacity = opacity;
}


@end
