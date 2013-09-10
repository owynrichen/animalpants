//
//  Popup.m
//  FootGame
//
//  Created by Owyn Richen on 5/14/13.
//
//

#import "Popup.h"
#import "AnalyticsPublisher.h"
#import "SoundManager.h"

@implementation Popup

#define BG2_OPACITY (200.0f / 255.0f)
#define BG_OPACITY (160.0f / 255.0f)

+(Popup *) popup {
    return [[[Popup alloc] init] autorelease];
}

+(Popup *) popupWithSize:(CGSize)size {
    return [[[Popup alloc] initWithSize:size] autorelease];
}

-(id) initWithSize:(CGSize)size {
    self = [super init];
    
    background = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 0)];
    background.contentSize = size;
    background.blendFunc = (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };
    [self addChild:background];
    
    background2 = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 0)];
    background2.contentSize = CGSizeMake(size.width * 1.02, size.height * 1.03);
    background2.position = ccp(-size.width * 0.01, -size.height * 0.015);
    background2.blendFunc = (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };
    [self addChild:background2];
    
    close = [CircleButton buttonWithFile:@"close-x.png"];
    close.scale = 0.6;
    close.position = ccp(size.width - 60, size.height - 60);
    [self addChild:close z:100];
    
    __block Popup *pointer = self;
    
    [close addEvent:@"touch" withBlock:^(CCNode * sender) {
        if (pointer.opacity < 128)
            return;
        
        [[SoundManager sharedManager] playSound:@"glock__g1.mp3"];
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.8]];
    }];
    
    [close addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        if (pointer.opacity < 128)
            return;
        
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.6]];
    }];
    
    [close addEvent:@"touchup" withBlock:^(CCNode *sender) {
        if (pointer.opacity < 128)
            return;
        
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:0.6]];
        Popup *p = (Popup *) sender.parent.parent;
        [p hide];
    }];
    
    self.contentSize = background.contentSize;
    self.opacity = 0;
    self.scale = 0.8;
    self.anchorPoint = ccp(0.5,0.5);
    
    return self;
}

-(id) init {
    self = [self initWithSize:CGSizeMake(950, 600)];
    
    return self;
}

-(void) dealloc {
    if (cBlock != nil) {
        [cBlock release];
        cBlock = nil;
    }
    [super dealloc];
}

-(void) showWithOpenBlock:(PopupBlock) openBlock closeBlock:(PopupBlock) closeBlock analyticsKey:(NSString *)key {
    if (openBlock != nil)
        openBlock(self);
    
    cBlock = [closeBlock copy];
    
    [self runAction:[CCFadeIn actionWithDuration:0.3]];
    [self runAction:[CCScaleTo actionWithDuration:0.3 scale:1.0]];
    apView(key);
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
}

-(ccColor3B) color {
    return background.color;
}

-(GLubyte) opacity {
    return op_;
}

-(void) setOpacity: (GLubyte) opacity {
    op_ = opacity;
    background.opacity = (GLubyte) ((float) opacity * BG_OPACITY);
    background2.opacity = (GLubyte) ((float) opacity * BG2_OPACITY);
    close.opacity = opacity;
}

@end
