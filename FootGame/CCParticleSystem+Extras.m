//
//  CCParticleSystem+Extras.m
//  FootGame
//
//  Created by Owyn Richen on 12/26/12.
//
//

#import "CCParticleSystem+Extras.h"
#import "CCAutoScaling.h"

@implementation CCParticleSystem(Extras)

-(float) elapsed {
    return elapsed;
}

-(void) matchScale: (CCNode *) node {
    self.scaleX = node.scaleX;
    self.scaleY = node.scaleY;
}

-(id) copy {
    // YES: I am lazy and don't want to write a full deep clone here...
    NSAssert(self.userObject != nil, @"This particle system's userObject property is nil and cannot be cloned");
    NSDictionary *dict = (NSDictionary *) self.userObject;
    
    NSString *plist = (NSString *) [dict objectForKey:@"plistFilename"];
    NSAssert(plist != nil, @"This particle system's plistFilename field is nil and cannot be cloned");
    
    CCParticleSystem *cpy = [[self.class alloc] initWithFile:plist params:dict];
    
    return cpy;
}

+(id)particleWithFile:(NSString *)plistFile params: (NSDictionary *) params {
    return [[[self alloc] initWithFile:plistFile params:params] autorelease];
}

-(id) initWithFile:(NSString *)plistFile params: (NSDictionary *) params {
    CGPoint point = [self parseCoordinate:[params objectForKey:@"position"]];
    BOOL touchPoint = [params objectForKey:@"touch_responsive"] != nil;
    
    self = [self initWithFile:plistFile];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:params];
    [dict setObject:plistFile forKey:@"plistFilename"];
    
    self.userObject = dict;
    
    if (touchPoint) {
        point = [self parseCoordinate:[params objectForKey:@"touch"]];
        self.position = ccp(point.x, point.y);
    } else {
        self.position = ccpToRatio(point.x, point.y);
    }
    
    if ([params objectForKey:@"sourcePositionVariance"] != nil) {
        self.posVar = [self parseCoordinate:[params objectForKey:@"sourcePositionVariance"]];
    }
    
    if ([params objectForKey:@"startParticleSize"] != nil) {
        self.startSize = [(NSNumber *) [params objectForKey:@"startParticleSize"] floatValue];
    }
    
    if ([params objectForKey:@"startParticleSizeVariance"] != nil) {
        self.startSizeVar = [(NSNumber *) [params objectForKey:@"startParticleSizeVariance"] floatValue];
    }
    
    if ([params objectForKey:@"maxParticles"] != nil) {
        self.totalParticles = [(NSNumber *) [params objectForKey:@"maxParticles"] floatValue];
    }
    
    if ([params objectForKey:@"duration"] != nil) {
        self.duration = [(NSNumber *) [params objectForKey:@"duration"] floatValue];
    }
    
    if ([params objectForKey:@"angle"] != nil) {
        self.angle = [(NSNumber *) [params objectForKey:@"angle"] floatValue];
    }
    
    if ([params objectForKey:@"angleVariance"] != nil) {
        self.angleVar = [(NSNumber *) [params objectForKey:@"angleVariance"] floatValue];
    }
    
    if ([params objectForKey:@"speed"] != nil) {
        self.speed = [(NSNumber *) [params objectForKey:@"speed"] floatValue];
        self.speed *= positionScaleForCurrentDevice(kDimensionY);
    }
    
    if ([params objectForKey:@"speedVariance"] != nil) {
        self.speedVar = [(NSNumber *) [params objectForKey:@"speedVariance"] floatValue];
        self.speedVar *= positionScaleForCurrentDevice(kDimensionY);
    }
    
    if ([params objectForKey:@"particleLifespan"] != nil) {
        self.life = [(NSNumber *) [params objectForKey:@"particleLifespan"] floatValue];
    }
    
    if ([params objectForKey:@"particleLifespanVariance"] != nil) {
        self.lifeVar = [(NSNumber *) [params objectForKey:@"particleLifespanVariance"] floatValue];
    }
    
    if ([params objectForKey:@"minRadius"] != nil) {
        mode.B.endRadius = [(NSNumber *) [params objectForKey:@"minRadius"] floatValue];
        mode.B.endRadius *= positionScaleForCurrentDevice(kDimensionY);
    }
    
    if ([params objectForKey:@"minRadiusVariance"] != nil) {
        mode.B.endRadiusVar = [(NSNumber *) [params objectForKey:@"minRadiusVariance"] floatValue];
        mode.B.endRadiusVar *= positionScaleForCurrentDevice(kDimensionY);
    }
    
    if ([params objectForKey:@"maxRadius"] != nil) {
        mode.B.startRadius = [(NSNumber *) [params objectForKey:@"maxRadius"] floatValue];
        mode.B.startRadius *= positionScaleForCurrentDevice(kDimensionY);
    }
    
    if ([params objectForKey:@"maxRadiusVariance"] != nil) {
        mode.B.startRadiusVar = [(NSNumber *) [params objectForKey:@"maxRadiusVariance"] floatValue];
        mode.B.startRadiusVar *= positionScaleForCurrentDevice(kDimensionY);
    }
    
    if ([params objectForKey:@"rotatePerSecond"] != nil) {
        mode.B.rotatePerSecond = [(NSNumber *) [params objectForKey:@"rotatePerSecond"] floatValue];
        mode.B.rotatePerSecond *= positionScaleForCurrentDevice(kDimensionY);
    }
    
    if ([params objectForKey:@"rotatePerSecondVariance"] != nil) {
        mode.B.rotatePerSecondVar = [(NSNumber *) [params objectForKey:@"rotatePerSecondVariance"] floatValue];
        mode.B.rotatePerSecondVar *= positionScaleForCurrentDevice(kDimensionY);
    }
    
    if ([params objectForKey:@"startColorRed"] != nil) {
        float sr = [(NSNumber *) [params objectForKey:@"startColorRed"] floatValue];
        float sg = [(NSNumber *) [params objectForKey:@"startColorGreen"] floatValue];
        float sb = [(NSNumber *) [params objectForKey:@"startColorBlue"] floatValue];
        float sa = [(NSNumber *) [params objectForKey:@"startColorAlpha"] floatValue];
        startColor = ccc4f(sr, sg, sb, sa);
    }
    
    if ([params objectForKey:@"startColorRedVariance"] != nil) {
        float srv = [(NSNumber *) [params objectForKey:@"startColorRedVariance"] floatValue];
        float sgv = [(NSNumber *) [params objectForKey:@"startColorGreenVariance"] floatValue];
        float sbv = [(NSNumber *) [params objectForKey:@"startColorBlueVariance"] floatValue];
        float sav = [(NSNumber *) [params objectForKey:@"startColorAlphaVariance"] floatValue];
        startColorVar = ccc4f(srv, sgv, sbv, sav);
    }
    
    if ([params objectForKey:@"finishColorRed"] != nil) {
        float fr = [(NSNumber *) [params objectForKey:@"finishColorRed"] floatValue];
        float fg = [(NSNumber *) [params objectForKey:@"finishColorGreen"] floatValue];
        float fb = [(NSNumber *) [params objectForKey:@"finishColorBlue"] floatValue];
        float fa = [(NSNumber *) [params objectForKey:@"finishColorAlpha"] floatValue];
        endColor = ccc4f(fr, fg, fb, fa);
    }
    
    if ([params objectForKey:@"finishColorRedVariance"] != nil) {
        float frv = [(NSNumber *) [params objectForKey:@"finishColorRedVariance"] floatValue];
        float fgv = [(NSNumber *) [params objectForKey:@"finishColorGreenVariance"] floatValue];
        float fbv = [(NSNumber *) [params objectForKey:@"finishColorBlueVariance"] floatValue];
        float fav = [(NSNumber *) [params objectForKey:@"finishColorAlphaVariance"] floatValue];
        endColorVar = ccc4f(frv, fgv, fbv, fav);
    }
    
    // TODO: insert more overrides here as needed...
    
    self.startSize = self.startSize * positionScaleForCurrentDevice(kDimensionY);
    self.startSizeVar = self.startSizeVar * positionScaleForCurrentDevice(kDimensionY);
    self.endSize = self.endSize * positionScaleForCurrentDevice(kDimensionY);
    self.endSizeVar = self.endSizeVar * positionScaleForCurrentDevice(kDimensionY);
    self.posVar = ccp(self.posVar.x * positionScaleForCurrentDevice(kDimensionY), self.posVar.y * positionScaleForCurrentDevice(kDimensionY));
    
    NSString *imageName = [params objectForKey:@"imageName"];
    
    if (imageName != nil) {
        CCTexture2D *texture = [[CCTextureCache sharedTextureCache] textureForKey:imageName];
        
        if (texture == nil) {
            texture = [[CCTextureCache sharedTextureCache] addImage:imageName];
        }
        
        if (texture != nil) {
            self.texture = texture;
        }
    }

    return self;
}

-(void) stopSystemAndCleanup {
    [self stopSystem];
    [self.actionManager removeAllActionsFromTarget:self];
    [self cleanupWhenDone];
}

-(void) cleanupWhenDone {
    CCDelayTime *delay = [CCDelayTime actionWithDuration:duration + life + lifeVar - elapsed];
    CCCallBlockN *cleanup = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
    }];
    
    [self runAction:[CCSequence actions:delay, cleanup, nil]];
}

-(void) moveToParentsParent {
    // TODO: detatch the current particle system from the base node
    // transform it's coordinates to world coordinates
    // reattach to the world
    // set a timer to kill it after it's done
    
    CCNode *p = self.parent;
    CGAffineTransform coords = [p nodeToParentTransform];
    [self removeFromParentAndCleanup:NO];
    self.scaleX *= coords.a;
    self.scaleY *= coords.d;
    
    // TODO: factor in rotation too...
    
    self.position = ccp((self.position.x * coords.a) + coords.tx, (self.position.y * coords.d) + coords.ty);
    [p.parent addChild:self];
}

@end
