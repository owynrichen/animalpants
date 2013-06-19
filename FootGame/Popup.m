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
    
    close = [CircleButton buttonWithFile:@"close-x.png"];
    close.scale = 0.6;
    close.position = ccp(size.width - 50, size.height - 50);
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
    return background.opacity;
}

-(void) setOpacity: (GLubyte) opacity {
    background.opacity = opacity;
    close.opacity = opacity;
}

@end
