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
#import "AnimalPartRepository.h"

@implementation InGameSettingsMenuPopup

+(id) inGameSettingsMenuPopupWithGoHomeBlock: (GoHomeBlock) ghBlock factPageBlock: (FactPageBlock) fpBlock forAnimalKey: (NSString *) key {
    return [[[InGameSettingsMenuPopup alloc] initwithGoHomeBlock:ghBlock factPageBlock:fpBlock forAnimalKey:key] autorelease];
}

-(id) initwithGoHomeBlock: (GoHomeBlock) ghBlock factPageBlock: (FactPageBlock) fpBlock forAnimalKey: (NSString *) key {
    CGSize size = CGSizeMake(650, 500);
    self = [super initWithSize:size];
    
    _goHome = [ghBlock copy];
    _facts = [fpBlock copy];
    _animalKey = [key retain];
    
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
    
    CircleButton *factIcon = [CircleButton buttonWithFile:@"lips.png"];
    factIcon.position = ccp(0,0);
    factIcon.scale = 0.7;
    
    CCButtonMenuItem *fact = [CCButtonMenuItem itemWithButton: factIcon text:[NSString stringWithFormat:locstr(@"facts_about",@"strings",@""), [[[AnimalPartRepository sharedRepository] getAnimalByKey:_animalKey] localizedName]] block:^(id sender) {
        if (pointer.opacity < 255)
            return;
        
        [pointer hide];
        pointer.facts(_animalKey);
    }];
    
    fact.position = ccpToRatio(0, -go.contentSize.height);
    
    CircleButton *narrationIcon = [CircleButton buttonWithFile:@"lips.png"];
    narrationIcon.position = ccp(0,0);
    narrationIcon.scale = 0.7;
    
    narration = [CCVolumeMenuItem buttonWithVolumeType:kSoundVolume button:narrationIcon text:locstr(@"sound_volume", @"strings", @"")];
    
    narration.position = ccpToRatio(self.contentSize.width * 0.1, (self.contentSize.height * 0.8) + (-1 * (go.contentSize.height + fact.contentSize.height)));
    narration.opacity = 0;
    narration.visible = NO;
    
    CircleButton *musicIcon = [CircleButton buttonWithFile:@"music.png"];
    musicIcon.position = ccp(0,0);
    musicIcon.scale = 0.7;
    
    music = [CCVolumeMenuItem buttonWithVolumeType:kMusicVolume button:musicIcon text:locstr(@"music_volume", @"strings", @"")];
    
    music.position = ccpToRatio(self.contentSize.width * 0.1, (self.contentSize.height * 0.8) + (-1 * (go.contentSize.height + fact.contentSize.height + narration.contentSize.height)));
    music.opacity = 0;
    music.visible = NO;
    
    menu = [CCMenu menuWithItems:go, fact, nil];
    menu.position = ccp(self.contentSize.width * 0.1, self.contentSize.height * 0.8);
    menu.visible = NO;
    menu.isTouchEnabled = NO;
    menu.opacity = 0;
    
    [self addChild:menu];
    [self addChild:narration];
    [self addChild:music];
    
    return self;
}

-(void) dealloc {
    if (_goHome) {
        [_goHome release];
    }
    
    if (_facts) {
        [_facts release];
    }
    
    if (_animalKey) {
        [_animalKey release];
    }
    
    [super dealloc];
}

-(void) setColor:(ccColor3B)color {
    [menu setColor:color];
    [music setColor:color];
    [narration setColor:color];
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
    music.opacity = opacity;
    narration.opacity = opacity;
    [super setOpacity:opacity];
}

-(void) showWithOpenBlock:(PopupBlock)openBlock closeBlock:(PopupBlock)closeBlock analyticsKey:(NSString *)key {
    [super showWithOpenBlock:openBlock closeBlock:closeBlock analyticsKey:key];
    
    menu.visible = YES;
    menu.isTouchEnabled = YES;
    music.visible = YES;
    narration.visible = YES;
}

-(void) hide {
    menu.visible = NO;
    menu.isTouchEnabled = NO;
    music.visible = NO;
    narration.visible = NO;
    [super hide];
}

@end
