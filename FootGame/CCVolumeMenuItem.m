//
//  CCButtonMenuItem.m
//  FootGame
//
//  Created by Owyn Richen on 6/10/13.
//
//

#import "CCVolumeMenuItem.h"
#import "CCAutoScaling.h"
#import "SoundManager.h"
#import "AnalyticsPublisher.h"

@interface CCVolumeMenuItem()
-(float) getVolume;
-(void) setVolume: (float) vol;
@end

@implementation CCVolumeMenuItem

+(id) buttonWithVolumeType:(VolumeType)type button:(CCNode<CCRGBAProtocol> *)btn text:(NSString *)text {
    return [[[CCVolumeMenuItem alloc] initWithVolumeType:type button:btn text:text] autorelease];
}

-(id) initWithVolumeType: (VolumeType) type button: (CCNode<CCRGBAProtocol> *) btn text: (NSString *) text; {
    self = [super initWithButton:btn text:text block:nil];
    
    t = type;

    potentiometer = [CCControlPotentiometer potentiometerWithTrackFile:@"potentiometerTrack.png"
                                                                           progressFile:@"potentiometerProgress.png"
                                                                              thumbFile:@"potentiometerButton.png"];
    
    potentiometer.value = [self getVolume];
    potentiometer.position = ccp(self.contentSize.width * 1.12, 20);
    [potentiometer setBlock:^(id sender, CCControlEvent event) {
        float volume = ((CCControlPotentiometer *)sender).value;
        [self setVolume:volume];
        NSString *vType;
        
        if (t == kMusicVolume)
            vType = @"music";
        else
            vType = @"sound";
        
        NSString *sVol = [NSString stringWithFormat:@"%f", volume];
        apEvent(@"volume", vType, sVol);
    } forControlEvents:CCControlEventValueChanged];
    potentiometer.scale = 0.7;
    [self addChild:potentiometer];
    
    contentSize_ = CGSizeMake(contentSize_.width * 1.1 + potentiometer.contentSize.width, contentSize_.height);
    
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

-(float) getVolume {
    if (t == kMusicVolume) {
        return [[SoundManager sharedManager] getMusicVolume];
    } else {
        return [[SoundManager sharedManager] getSoundVolume];
    }
}

-(void) setVolume:(float)vol {
    if (t == kMusicVolume) {
        [[SoundManager sharedManager] setMusicVolume:vol];
    } else {
        [[SoundManager sharedManager] setSoundVolume:vol];
    }
}

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

}

-(void) unselected {
}

-(void) setColor:(ccColor3B)color {
    [button setColor:color];
    [label setColor:color];
    [potentiometer setColor:color];
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
    [potentiometer setOpacity:opacity];
}

@end
