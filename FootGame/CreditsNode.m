//
//  CreditsNode.m
//  FootGame
//
//  Created by Owyn Richen on 8/1/13.
//
//

#import "CreditsNode.h"
#import "LocalizationManager.h"
#import "CCLabelTTFWithExtrude.h"
#import "CCLabelTTFWithStroke.h"
#import "CCAutoScaling.h"

@implementation CreditsNode

-(id) init {
    self = [super init];
    
    NSString *markup = locstr(@"credits_markup",@"strings",@"");
    NSArray *lines = [markup componentsSeparatedByString:@"\n"];
    
    __block float currentHeight = 0;
    __block float currentWidth = 0;
    
    [lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *line = (NSString *) obj;
        
        if ([line hasPrefix:@"<h>"]) {
            CCLabelTTFWithExtrude *title = [CCLabelTTFWithExtrude labelWithString:[line stringByReplacingOccurrencesOfString:@"<h>" withString:@""] fontName:@"Rather Loud" fontSize:54];
            [title setColor: ccc3(206, 216, 47)];
            [title setExtrudeColor: ccc3(130, 141, 55)];
            title.extrudeDepth = 10 * fontScaleForCurrentDevice();
            [title drawExtrude];
            title.position = ccpToRatio(0, currentHeight - 10);
            
            currentHeight -= (title.contentSize.height - 10) * 1.01;
            
            if (title.contentSize.width > currentWidth) {
                currentWidth = title.contentSize.width;
            }
            
            [self addChild:title];
            
        } else {
            CCLabelTTFWithStroke *text = [CCLabelTTFWithStroke labelWithString: line fontName:@"Rather Loud" fontSize:36 * fontScaleForCurrentDevice()];
            text.color = ccBLACK;
            text.strokeColor = ccWHITE;
            text.strokeSize = 3 * fontScaleForCurrentDevice();
//             text.anchorPoint = ccp(0,0);
            [text drawStroke];
            text.position = ccpToRatio(0, currentHeight);
        
            currentHeight -= text.contentSize.height * 1.01;
            
            if (text.contentSize.width > currentWidth) {
                currentWidth = text.contentSize.width;
            }
            
            [self addChild:text];
        }
    }];
    
    self.contentSize = CGSizeMake(currentWidth, currentHeight * -1);
    
    return self;
}

@end
