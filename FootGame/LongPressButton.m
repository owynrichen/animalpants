//
//  LongPressButton.m
//  FootGame
//
//  Created by Owyn Richen on 5/9/13.
//
//

#import "LongPressButton.h"

@implementation LongPressButton

@synthesize delay;
@synthesize block;
@synthesize startTime;

+(LongPressButton *) buttonWithBlock: (LongPressBlock) blk {
    LongPressButton *btn = (LongPressButton *) [LongPressButton buttonWithFile:@"arrow.png"];
    
    btn.delay = 1.0;
    ((CCNode *) [btn.children objectAtIndex:1]).scale = 0.33;
    btn.baseScale = 1.0;
    __block LongPressButton *b = btn;

    [btn addEvent:@"touch" withBlock:^(CCNode *sender) {
        if (!b.visible)
            return;
        
        [((CCNode *)[sender.parent.children objectAtIndex:1]) runAction:[CCRotateBy actionWithDuration:b.delay angle:360]];
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:b.baseScale * 1.2]];
        btn.startTime = [[NSDate date] timeIntervalSince1970];
    }];
    
    [btn addEvent:@"touchupoutside" withBlock:^(CCNode *sender) {
        if (!b.visible)
            return;
        
        [((CCNode *)[sender.parent.children objectAtIndex:1]) stopAllActions];
        ((CCNode *)[sender.parent.children objectAtIndex:1]).rotation = 0;
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:b.baseScale * 1.0]];
    }];

    if (blk != nil)
        btn.block = [blk copy];
    
    [btn addEvent:@"touchup" withBlock:^(CCNode *sender) {
        if (!b.visible)
            return;
        
        [((CCNode *)[sender.parent.children objectAtIndex:1]) stopAllActions];
        ((CCNode *)[sender.parent.children objectAtIndex:1]).rotation = 0;
        [sender.parent runAction:[CCScaleTo actionWithDuration:0.1 scale:b.baseScale * 1.0]];
        
        double endTime = [[NSDate date] timeIntervalSince1970];
        
        if (b.block != nil && endTime - btn.startTime > 1.0 && b.visible)
            b.block(sender);
        
    }];

    return btn;
}

-(void) setScale:(float)scale {
    _baseScale = scale;
    [super setScale:scale];
}

-(void) dealloc {
    self.block = nil;
    [super dealloc];
}

@end
