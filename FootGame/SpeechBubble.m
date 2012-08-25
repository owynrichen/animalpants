//
//  SpeechBubble.m
//  FootGame
//
//  Created by Owyn Richen on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SpeechBubble.h"
#import "CCAutoScaling.h"

@interface SpeechBubble()
-(CGPoint *) buildBubblePointsFromRect: (CGRect) rect andPoint: (CGPoint) point withScale: (CGPoint) scale andOffset: (CGPoint) offset;
-(CGPoint) calculateAngle: (CGPoint) center angle: (float) angleDegrees radius: (float) radius;
-(CGPoint *) calculateRounded: (CGPoint) corner center: (CGPoint) center smoothness: (int) pointCount;
-(void) ccEllipse: (CGPoint) center ab: (CGPoint) ab samples: (int) numSamples;
-(CCRenderTexture *) drawBubble;
@end

@implementation SpeechBubble

-(id) initWithStoryKey:(NSString *)storyKey typingInterval: (ccTime) ival rect: (CGRect) tRect point: (CGPoint) bPoint {
    self = [super init];
    
    // TODO: this is all fucking wrong - draw it out and then re-write...
    
    talkDrawRect = autoScaledRectToPositionForCurrentDevice(tRect);
    talkPositionRect = autoScaledRectToPositionForCurrentDevice(tRect);

    bubblePoint = bPoint;
    
    bubbleSprite = [self drawBubble];
    bubbleSprite.anchorPoint = ccp(0,0);
    bubbleSprite.position = ccpToRatio(0,talkPositionRect.size.height);
    [self addChild:bubbleSprite];
    
    // Setup the size of the label to be 10% smaller than the size of the talk bubble rectangle
    // TODO: MAKE SURE NO DIMENSION IS > 2048
    CGSize labelSize = CGSizeMake(talkDrawRect.size.width - (talkDrawRect.size.width * 0.1), talkDrawRect.size.height - (talkDrawRect.size.height * 0.1));
    
    storyText = NSLocalizedStringFromTable(storyKey, @"strings", @"");
    
    label = [[CCLabelTTFWithStroke alloc] initWithString:storyText dimensions:labelSize hAlignment:kCCTextAlignmentLeft lineBreakMode:kCCLineBreakModeWordWrap fontName:@"Marker Felt" fontSize:40 * fontScaleForCurrentDevice()];
    label.color = ccWHITE;
    label.strokeSize = 3 * fontScaleForCurrentDevice();
    label.strokeColor = ccBLACK;
    label.anchorPoint = ccp(0,0);
    label.position = ccpToRatio((talkPositionRect.size.width * 0.05), - (talkPositionRect.size.height  * 0.10));
    label.string = @"";
    [label drawStroke];
    
    [self addChild:label];
    interval = ival;

    return self;
}

-(void) dealloc {
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    
    if (touchBlock != NULL) {
        touchBlock = NULL;
    }
    
    if (storyText != NULL) {
        [storyText release];
    }
    
    [super dealloc];
}

-(CCRenderTexture *) drawBubble {
    float size = 10.0 * autoScaleForCurrentDevice();
    CCRenderTexture *tex = [[[CCRenderTexture alloc] initWithWidth:talkDrawRect.size.width + (size * 2) height:talkDrawRect.size.height + (size * 4) + bubblePoint.y pixelFormat:kCCTexture2DPixelFormat_RGB888] autorelease];
    
    [tex.sprite setBlendFunc:(ccBlendFunc) {GL_SRC_ALPHA, GL_ONE} ];
    [tex begin];

    CGPoint *talkBubblePoints = [self buildBubblePointsFromRect:talkDrawRect andPoint:bubblePoint withScale:ccp(size, size) andOffset:ccp(0, talkDrawRect.origin.y + bubblePoint.y)];
    
    ccDrawSolidPoly(talkBubblePoints, 24, ccc4f(1.0, 1.0, 1.0, 1.0));
  
//
// THIS IS DEBUG CODE to draw the points and triangles of the dialog box

//    for (int i = 0; i < 24; i++) {
//        CGPoint point = talkBubblePoints[i];
//        ccDrawColor4F(1.0 / (i + 1), 0.5, 0.1 * ((i + 1) / 2), 1.0);
//        ccPointSize(4.0);
//        ccDrawPoint(point);
//        ccDrawLine(talkBubblePoints[0], talkBubblePoints[i]);
//    }

    free(talkBubblePoints);
    
    [tex end];
    
    tex.sprite.anchorPoint = ccp(0,0);
    return tex;
}

-(void) ccEllipse: (CGPoint) center ab: (CGPoint) ab samples: (int) numSamples {
    // TODO: maybe switch the talk bubble to an ellipse
}

-(CGPoint) calculateAngle: (CGPoint) center angle:(float) angleDegrees radius: (float) radius {
    float angleRadians = 3.14159265 * angleDegrees / 180.0f;
    float x = center.x + sinf(angleRadians) * radius;
    float y = center.y + cosf(angleRadians) * radius;
    
    return ccp(x,y);
}

-(CGPoint *) calculateRounded: (CGPoint) corner center: (CGPoint) center smoothness: (int) pointCount {
    NSAssert(pointCount > 0, @"smoothness needs to be > 0");
    
    CGPoint *points = malloc(pointCount * sizeof(CGPoint));
    
    if (pointCount == 1) {
        points[0] = corner;
        return points;
    }
    
    float radius = abs(corner.x - center.x);
    float startAngle = 270.0f;
    
    if (corner.x > center.x && corner.y > center.y) {
        startAngle = 0.0f;
    } else if (corner.x < center.x && corner.y > center.y) {
        startAngle = 270.0f;
    } else if (corner.x > center.x && corner.y < center.y) {
        startAngle = 90.0f;
    } else if (corner.x < center.x && corner.y < center.y) {
        startAngle = 180.0f;
    }
    
    float angleIncrement = 90.0f / pointCount;
    
    for (int i = 0; i < pointCount; i++) {
        points[i] = [self calculateAngle: center angle: startAngle + (angleIncrement * i) radius:radius];
    }
    
    return points;
}

-(CGPoint *) buildBubblePointsFromRect: (CGRect) rect andPoint: (CGPoint) point withScale: (CGPoint) scale andOffset:(CGPoint)offset {
    CGPoint nodeSpacePoint1 = ccp(offset.x + point.x, -offset.y + point.y); // - (scale.y * 2));
    //CGPoint nodeSpacePoint2 = ccp(offset.x + point.x + (scale.x * 2), -offset.y + point.y - (scale.y * 2));
    CGPoint nodeSpacePoint2 = nodeSpacePoint1;
    
    CGPoint bl = ccp(offset.x + rect.origin.x, offset.y + rect.origin.y);
    CGPoint br = ccp(offset.x + rect.origin.x + rect.size.width + (scale.x * 2), offset.y + rect.origin.y);
    CGPoint tr = ccp(offset.x + rect.origin.x + rect.size.width + (scale.x * 2), offset.y + rect.origin.y + rect.size.height + (scale.y * 2));
    CGPoint tl = ccp(offset.x + rect.origin.x, offset.y + rect.origin.y + rect.size.height + (scale.y * 2));
    
#define RADIUS 10
    
    CGPoint tlc = ccp(tl.x + RADIUS, tl.y - RADIUS);
    CGPoint trc = ccp(tr.x - RADIUS, tr.y - RADIUS);
    CGPoint brc = ccp(br.x - RADIUS, br.y + RADIUS);
    CGPoint blc = ccp(bl.x + RADIUS, bl.y + RADIUS);
    
    CGPoint *tlp = [self calculateRounded:tl center:tlc smoothness:5];
    CGPoint *trp = [self calculateRounded:tr center:trc smoothness:5];
    CGPoint *blp = [self calculateRounded:bl center:blc smoothness:5];
    CGPoint *brp = [self calculateRounded:br center:brc smoothness:5];
    
    CGPoint caratStart = ccp(offset.x + nodeSpacePoint2.x + (scale.x * 2), br.y);
    CGPoint caratEnd = ccp(offset.x + nodeSpacePoint1.x - 10, br.y);
    
    // so the carat doesn't go beyond the speech bubble
    if (caratEnd.x <= bl.x) {
        caratEnd = ccp(offset.x + bl.x + nodeSpacePoint1.x + 5 + RADIUS, br.y);
        caratStart = ccp(offset.x + bl.x + nodeSpacePoint1.x + 15 + RADIUS + (scale.x * 2), br.y);
    }
    
    CGPoint points[24] =
    {
        caratEnd, nodeSpacePoint1, nodeSpacePoint2,
        caratStart, brp[4], brp[3], brp[2], brp[1], brp[0],
        trp[4], trp[3], trp[2], trp[1], trp[0],
        tlp[4], tlp[3], tlp[2], tlp[1], tlp[0],
        blp[4], blp[3], blp[2], blp[1], blp[0]
    };
    
    CGPoint *retPoints = malloc(sizeof(points));
    memcpy(retPoints, points, sizeof(points));

    free(tlp);
    free(trp);
    free(blp);
    free(brp);
    
    return retPoints;
}

-(void) startWithFinishBlock: (void (^)(CCNode *node)) callback touchBlock: (void(^)(CCNode *node, BOOL finished)) touchCallback {
    touchBlock = [touchCallback copy];
    
    CCCallBlockN *updateTxt = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        int index = [label.string length] + 1;
        if (index > storyText.length) {
            index = storyText.length;
        }
        [label setString:[storyText substringToIndex:index]];
        [label drawStroke];
    }];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:interval];
    CCSequence *update = [CCSequence actions:updateTxt, delay, nil];
    
    CCRepeat *repeat = [CCRepeat actionWithAction:update times:[storyText length]];
    CCSequence *seq = [CCSequence actions:repeat, [CCCallBlockN actionWithBlock:callback], nil];
    
    [label runAction:seq];
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:1 swallowsTouches:NO];
}

// CCRGBAProtocol
-(void) setColor:(ccColor3B)color {
    bubbleSprite.sprite.color = color;
    label.color = color;
}
/** returns the color
 @since v0.8
 */
-(ccColor3B) color {
    return bubbleSprite.sprite.color;
}

/// returns the opacity
-(GLubyte) opacity {
    return bubbleSprite.sprite.opacity;
}
/** sets the opacity.
 @warning If the the texture has premultiplied alpha then, the R, G and B channels will be modifed.
 Values goes from 0 to 255, where 255 means fully opaque.
 */
-(void) setOpacity: (GLubyte) opacity {
    bubbleSprite.sprite.opacity = opacity;
    label.opacity = opacity;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    // TODO: speed up the typing?
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    BOOL finished = [storyText length] == [label.string length];
    if (touchBlock != NULL)
        touchBlock(self, finished);
}

@end
