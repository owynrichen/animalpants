//
//  CircleButton.m
//  FootGame
//
//  Created by Owyn Richen on 2/14/13.
//
//

#import "CircleButton.h"

@implementation CircleButton

+(id) buttonWithFile: (NSString *) img {
    return [[[[self class] alloc] initWithFile:img] autorelease];
}

+(id) buttonWithNode: (CCNode *) node {
    return [[[[self class] alloc] initWithNode:node] autorelease];
}

-(id) initWithFile: (NSString *) img {
    self = [self initWithNode:[CCAutoScalingSprite spriteWithFile:img]];
    
    return self;
}

-(id) initWithNode: (CCNode<CCRGBAProtocol> *) node {
    self = [super init];
    
    back = [CCAutoScalingSprite spriteWithFile:@"circle-button-back.png"];
    back.position = ccp(52,52);
    middle = node;
    middle.position = ccp(52,52);
    sheen = [CCAutoScalingSprite spriteWithFile:@"circle-button-front.png"];
    sheen.position = ccp(52,52);
    
    self.contentSize = back.contentSize;
    self.anchorPoint = ccp(0.5,0.5);
    
    [self addChild:back];
    [self addChild:middle];
    [self addChild:sheen];
    
    return self;
}

-(void) dealloc {
    [super dealloc];
}

-(void) onEnter {
    [super onEnter];
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:2 swallowsTouches:YES];
}

-(void) onExit {
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}

//-(void) draw {
//    [super draw];
//    
//    ccDrawColor4B(0,0,255,180);
//    ccDrawRect(self.boundingBox.origin, CGPointMake(self.boundingBox.origin.x + self.boundingBox.size.width, self.boundingBox.size.height));
//
//    ccDrawColor4B(0,255,0,180);
//    ccPointSize(8);
//    ccDrawPoint(self.anchorPointInPoints);
//}

-(void) addEvent: (NSString *) event withBlock: (void (^)(CCNode * sender)) blk {
    [back addEvent:event withBlock:blk];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    return [back ccTouchBegan:touch withEvent:event];
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    [back ccTouchMoved:touch withEvent:event];
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [back ccTouchEnded:touch withEvent:event];
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    [back ccTouchCancelled:touch withEvent:event];
}

-(void) setColor:(ccColor3B)color {
    back.color = color;
    sheen.color = color;
    middle.color = color;
}

-(ccColor3B) color {
    return back.color;
}

-(GLubyte) opacity {
    return back.opacity;
}

-(void) setOpacity: (GLubyte) opacity {
    back.opacity = opacity;
    sheen.opacity = opacity;
    middle.opacity = opacity;
}

@end
