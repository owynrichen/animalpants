//
//  CCButtonMenuItem.m
//  FootGame
//
//  Created by Owyn Richen on 6/10/13.
//
//

#import "CCButtonMenuItem.h"
#import "CCAutoScaling.h"

@implementation CCButtonMenuItem

+(id) itemWithButton: (CCNode<CCRGBAProtocol> *) btn text: (NSString *) text block: (void (^)(id))block {
    return [[[CCButtonMenuItem alloc] initWithButton:btn text:text block:block] autorelease];
}

-(id) initWithButton: (CCNode<CCRGBAProtocol> *) btn text: (NSString *) text block: (void (^)(id))block {
    self = [super initWithBlock:block];
    self.anchorPoint = ccp(0, 0.5);
    
    button = btn;
    button.anchorPoint = ccp(0, 0);
    button.position = ccp(0,0);
    [self addChild:button];
    
    label = [CCLabelTTFWithStroke labelWithString:text fontName:@"Rather Loud" fontSize:42 * fontScaleForCurrentDevice()];
    label.strokeSize = 4 * fontScaleForCurrentDevice();
    label.color = MENU_COLOR;
    label.strokeColor = MENU_STROKE;
    label.anchorPoint = ccp(0, -0.5);
    [label drawStroke];
    label.position = ccpToRatio(button.contentSize.width * 1.02, -label.contentSize.height / 4);
    [self addChild:label];
    originalScale = 1.0;
    
    self.contentSize = CGSizeMake(button.contentSize.width * button.scaleX * 1.02 + label.contentSize.width,
                                  button.contentSize.height * button.scaleY);
    
    return self;
}

-(void) dealloc {
    if (downBlock != nil)
        [downBlock release];
    
    downBlock = nil;
    
    [super dealloc];
}
//
//-(void) draw {
//    [super draw];
//    
//    ccDrawColor4B(0,255,0,180);
//    CGRect rect = [self rect];
//    rect.origin = CGPointZero;
//    ccDrawRect(rect.origin, CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height));
//}

-(void) addDownEvent: (void (^)(id sender)) block {
    downBlock = [block copy];
}

-(CGRect) rect
{
	return CGRectMake( position_.x + contentSize_.width*anchorPoint_.x,
					  position_.y + contentSize_.height*anchorPoint_.y,
					  contentSize_.width, contentSize_.height);
}

-(void) setScale:(float)scale {
    scaleX_ = scaleY_ = scale;
    originalScale = scale;
}

-(void) selected {
    [super selected];
    self.scaleX = self.scaleY = originalScale * 1.1;
    if (downBlock != nil) {
        downBlock(self);
    }
}

-(void) unselected {
    self.scaleX = self.scaleY = originalScale;
}

-(void) setColor:(ccColor3B)color {
    [button setColor:color];
    [label setColor:color];
}

-(ccColor3B) color {
    return label.color;
}

-(GLubyte) opacity {
    return label.opacity;
}

-(void) setOpacity: (GLubyte) opacity {
    [button setOpacity:opacity];
    [label setOpacity:opacity];
}

@end
