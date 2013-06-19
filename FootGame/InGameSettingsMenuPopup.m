//
//  InGameSettingsMenuPopup.m
//  FootGame
//
//  Created by Owyn Richen on 6/14/13.
//
//

#import "InGameSettingsMenuPopup.h"
#import "CCButtonMenuItem.h"
#import "LocalizationManager.h"

@implementation InGameSettingsMenuPopup

+(id) inGameSettingsMenuPopupWithGoHomeBlock: (GoHomeBlock) ghBlock {
    return [[[InGameSettingsMenuPopup alloc] initwithGoHomeBlock:ghBlock] autorelease];
}

-(id) initwithGoHomeBlock: (GoHomeBlock) ghBlock {
    CGSize size = CGSizeMake(650, 500);
    self = [super initWithSize:size];
    
    _goHome = [ghBlock copy];
    
    InGameSettingsMenuPopup *pointer = self;
    
    CircleButton *homeIcon = [CircleButton buttonWithFile:@"home.png"];
    homeIcon.position = ccp(0,0);
    homeIcon.scale = 0.7;
    
    CCButtonMenuItem *go = [CCButtonMenuItem itemWithButton: homeIcon text:locstr(@"go_home",@"strings",@"") block:^(id sender) {
        if (pointer.opacity < 255)
            return;
        
        [pointer hide];
        pointer.goHome();
    }];
    
    go.position = ccp(0,0);
    
    menu = [CCMenu menuWithItems:go, nil];
    menu.position = ccp(self.contentSize.width * 0.1, self.contentSize.height * 0.8);
    menu.visible = NO;
    menu.isTouchEnabled = NO;
    menu.opacity = 0;
    
    [self addChild:menu];
    
    return self;
}

-(void) dealloc {
    if (_goHome) {
        [_goHome release];
    }
    
    [super dealloc];
}

-(void) setColor:(ccColor3B)color {
    [menu setColor:color];
    [super setColor:color];
}

-(ccColor3B) color {
    return [super color];
}

-(GLubyte) opacity {
    return [super opacity];
}

-(void) setOpacity: (GLubyte) opacity {
    menu.opacity = opacity;
    [super setOpacity:opacity];
}

-(void) showWithOpenBlock:(PopupBlock)openBlock closeBlock:(PopupBlock)closeBlock analyticsKey:(NSString *)key {
    [super showWithOpenBlock:openBlock closeBlock:closeBlock analyticsKey:key];
    
    menu.visible = YES;
    menu.isTouchEnabled = YES;
}

-(void) hide {
    menu.visible = NO;
    menu.isTouchEnabled = NO;
    [super hide];
}

@end
