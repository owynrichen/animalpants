//
//  CCLabelTTFWithExtrude.m
//  FootGame
//
//  Created by Owyn Richen on 7/14/13.
//
//

#import "CCLabelTTFWithExtrude.h"

@implementation CCLabelTTFWithExtrude

#define kTagExtrude 1029384757

@synthesize extrudeColor = extrudeColor_;
@synthesize extrudeDepth = extrudeDepth_;

-(void) setExtrudeColor:(ccColor3B)extrudeColor {
    extrudeColor_ = extrudeColor;
}

-(void) setExtrudeDepth:(float)extrudeDepth {
    extrudeDepth_ = extrudeDepth;
}

-(void) setVisible:(BOOL)visible {
    [super setVisible:visible];
    if (extrudeTexture) {
        [extrudeTexture setVisible:visible];
    }
}

-(void) setString:(NSString *)string
{
	[super setString:string];
}

-(void) setOpacity:(GLubyte)opacity {
    [super setOpacity:opacity];
    if (extrudeTexture) {
        [extrudeTexture.sprite setOpacity:opacity];
        if (opacity == 0) {
            [extrudeTexture setVisible:NO];
        } else {
            [extrudeTexture setVisible:YES];
        }
    }
}

-(void) drawExtrude {
    if (extrudeTexture) {
        [extrudeTexture release];
        extrudeTexture = nil;
    }
    
    [self removeChildByTag:kTagExtrude cleanup:YES];
    extrudeTexture = [[CCLabelTTFWithExtrude createExtrude:self size:extrudeDepth_ color:extrudeColor_] retain];
    [self setContentSize:extrudeTexture.sprite.contentSize];
    [self addChild:extrudeTexture z:-1 tag:kTagExtrude];
}

+(CCRenderTexture*) createExtrude: (CCLabelTTF*) label size:(float)size color:(ccColor3B)cor
{
	CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:label.texture.contentSize.width+size*2 height:label.texture.contentSize.height+size*2];
	CGPoint originalPos = [label position];
	ccColor3B originalColor = [label color];
	BOOL originalVisibility = [label visible];
    
    int div = size / 4;
	[label setColor:ccc3(cor.r / div, cor.g / div, cor.b / div)];
	[label setVisible:YES];
    
	ccBlendFunc originalBlend = [label blendFunc];
	[label setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA }];
    
	CGPoint startPos = ccp(label.texture.contentSize.width * label.anchorPoint.x + size, label.texture.contentSize.height * label.anchorPoint.y);
    
    // glBlendEquation(GL_FUNC_SUBTRACT);
	[rt begin];
	for (int i=1; i<=size; i++) // you should optimize that for your needs
	{
		[label setPosition:ccp(startPos.x - i, startPos.y + i)];
		[label visit];
	}
	[rt end];
    
    // glBlendEquation(GL_FUNC_ADD);
    
	[label setPosition:originalPos];
	[label setColor:originalColor];
	[label setBlendFunc:originalBlend];
	[label setVisible:originalVisibility];
	[rt setPosition:startPos];
    [rt.sprite.texture setAntiAliasTexParameters];
    
	return rt;
}


@end
