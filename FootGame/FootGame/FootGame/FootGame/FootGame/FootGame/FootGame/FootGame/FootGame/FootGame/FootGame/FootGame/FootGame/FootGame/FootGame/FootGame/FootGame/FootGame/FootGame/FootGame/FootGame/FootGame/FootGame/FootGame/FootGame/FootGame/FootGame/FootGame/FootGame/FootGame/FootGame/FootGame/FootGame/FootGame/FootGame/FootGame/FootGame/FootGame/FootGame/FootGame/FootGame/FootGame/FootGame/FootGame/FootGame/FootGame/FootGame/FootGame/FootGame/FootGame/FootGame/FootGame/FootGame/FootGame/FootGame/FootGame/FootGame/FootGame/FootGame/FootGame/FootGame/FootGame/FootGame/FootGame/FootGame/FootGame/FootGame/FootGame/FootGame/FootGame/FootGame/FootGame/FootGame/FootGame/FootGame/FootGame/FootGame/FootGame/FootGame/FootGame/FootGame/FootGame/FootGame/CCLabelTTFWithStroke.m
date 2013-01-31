//
//  CCLabelTTFWithStroke.m
//  SockThatFool
//
//  Created by Owyn Richen on 4/8/12.
//  Copyright (c) 2012 Alchemist Interactive LLC. All rights reserved.
//

#import "CCLabelTTFWithStroke.h"

@implementation CCLabelTTFWithStroke

#define kTagStroke 1029384756

@synthesize strokeColor = strokeColor_;
@synthesize strokeSize = strokeSize_;

-(void) setStrokeColor:(ccColor3B)strokeColor {
    strokeColor_ = strokeColor;
}

-(void) setStrokeSize:(float)strokeSize {
    strokeSize_ = strokeSize;
}

-(void) setVisible:(BOOL)visible {
    [super setVisible:visible];
    if (strokeTexture) {
        [strokeTexture setVisible:visible];
    }
}

-(void) setString:(NSString *)string
{
	[super setString:string];
}

-(void) setOpacity:(GLubyte)opacity {
    [super setOpacity:opacity];
    if (strokeTexture) {
        [strokeTexture.sprite setOpacity:opacity];
        if (opacity == 0) {
            [strokeTexture setVisible:NO];
        } else {
            [strokeTexture setVisible:YES];
        }
    }
}

-(void) drawStroke {
    if (strokeTexture) {
        [strokeTexture release];
        strokeTexture = nil;
    }
    
    [self removeChildByTag:kTagStroke cleanup:YES];
    strokeTexture = [[CCLabelTTFWithStroke createStroke:self size:strokeSize_ color:strokeColor_] retain];
    [self setContentSize:strokeTexture.sprite.contentSize];
    [self addChild:strokeTexture z:-1 tag:kTagStroke];
}

+(CCRenderTexture*) createStroke: (CCLabelTTF*) label size:(float)size color:(ccColor3B)cor
{
	CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:label.texture.contentSize.width+size*2 height:label.texture.contentSize.height+size*2];
	CGPoint originalPos = [label position];
	ccColor3B originalColor = [label color];
	BOOL originalVisibility = [label visible];
	[label setColor:cor];
	[label setVisible:YES];
	ccBlendFunc originalBlend = [label blendFunc];
	[label setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
	CGPoint bottomLeft = ccp(label.texture.contentSize.width * label.anchorPoint.x + size, label.texture.contentSize.height * label.anchorPoint.y + size);
	CGPoint positionOffset = ccp(label.texture.contentSize.width * label.anchorPoint.x - label.texture.contentSize.width/2,label.texture.contentSize.height * label.anchorPoint.y - label.texture.contentSize.height/2);
	CGPoint position = ccpSub(label.anchorPoint, positionOffset);
    
	[rt begin];
	for (int i=0; i<360; i+=30) // you should optimize that for your needs
	{
		[label setPosition:ccp(bottomLeft.x + sin(CC_DEGREES_TO_RADIANS(i))*size, bottomLeft.y + cos(CC_DEGREES_TO_RADIANS(i))*size)];
		[label visit];
	}
	[rt end];
	[label setPosition:originalPos];
	[label setColor:originalColor];
	[label setBlendFunc:originalBlend];
	[label setVisible:originalVisibility];
	[rt setPosition:position];
    [rt.sprite.texture setAntiAliasTexParameters];
    
	return rt;
}

@end
