//
//  ParentGatePopup.m
//  FootGame
//
//  Created by Richen, Owyn on 12/31/13.
//
//

#import "ParentGatePopup.h"
#import "LocalizationManager.h"

@implementation ParentGatePopup

@synthesize clickBlock;

+(ParentGatePopup *) popupWithSummaryKey: (NSString *) key clickBlock: (ParentClickBlock) pcBlock {
    return [[[self alloc] initWithSummaryKey:key clickBlock:pcBlock] autorelease];
}

-(id) initWithSummaryKey: (NSString *) key clickBlock: (ParentClickBlock) pcBlock {
    CGSize size = CGSizeMake(650, 500);
    self = [super initWithSize:size];
    
    self.clickBlock = [pcBlock copy];
    
    title = [CCLabelTTFWithExtrude labelWithString:locstr(@"parent_gate_title", @"strings", @"") fontName:@"Rather Loud" fontSize:75 * fontScaleForCurrentDevice()];
    [title setColor: ccc3(206, 216, 47)];
    [title setExtrudeColor: ccc3(130, 141, 55)];
    title.extrudeDepth = 10 * fontScaleForCurrentDevice();
    [title drawExtrude];
    title.position = ccpToRatio(325, 400);
    [self addChild:title];
    
    girls = [CCAutoScalingSprite spriteWithFile:@"girls_camo.png"];
    girls.scale = 0.9;
    girls.anchorPoint = ccp(0, 1);
    girls.position = ccpToRatio(25, 330);
    [self addChild:girls];
    
    summary = [CCLabelTTFWithStroke labelWithString: locstr(key, @"strings", @"") fontName:@"Rather Loud" fontSize:36 * fontScaleForCurrentDevice() dimensions:CGSizeMake(300, 300) hAlignment:kCCTextAlignmentLeft];
    
    summary.color = ccBLACK;
    summary.strokeColor = ccWHITE;
    summary.strokeSize = 3 * fontScaleForCurrentDevice();
    [summary drawStroke];
    summary.anchorPoint = ccp(0, 1);
    summary.position = ccpToRatio(325, 330);
    [self addChild:summary];
    
    __block ParentGatePopup *pointer = self;
    
    button = [LongPressButton buttonWithBlock:^(CCNode *sender) {
        pointer.clickBlock();
        [pointer hide: kPopupCloseStateSuccess];
    }];
    button.delay = 5.0;

    button.position = ccpToRatio(325, 80);
    [self addChild:button];
    
    return self;
}

-(void) dealloc {
    self.clickBlock = nil;
    [super dealloc];
}

-(void) setColor:(ccColor3B)color {
    [title setColor:color];
    [summary setColor:color];
    [girls setColor:color];
    [button setColor:color];
    [super setColor:color];
}

-(ccColor3B) color {
    return [super color];
}

-(GLubyte) opacity {
    return [super opacity];
}

-(void) setOpacity: (GLubyte) opacity {
    title.opacity = opacity;
    summary.opacity = opacity;
    girls.opacity = opacity;
    button.opacity = opacity;
    [super setOpacity:opacity];
}

@end
