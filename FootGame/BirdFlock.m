//
//  BirdFlock.m
//  FootGame
//
//  Created by Owyn Richen on 9/2/13.
//
//

#import "BirdFlock.h"

@interface BirdFlock()

-(void) tick: (ccTime) dt;

@end

@implementation BirdFlock

+(id) birdsWithBirds:(int)count position:(CGPoint)pos direction:(CGPoint)dir scale: (float) scale color: (ccColor3B) color {
    return [[[self alloc] initWithBirds:count position:pos direction:dir scale:scale color:color] autorelease];
}

-(id) initWithBirds:(int)count position:(CGPoint)pos direction:(CGPoint)dir scale: (float) scale color: (ccColor3B) color {
    self = [super init];
    
    srandom(time(NULL));
    
    //[self setColor: ccc3(128, 128, 128)];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    touchSet = nil;
    
    [[CCAnimationCache sharedAnimationCache] addAnimationsWithFile:@"birdsheet-animation.plist"];
    
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"bird_f1.png"];
    
    _flockPointer = [Boid spriteWithSpriteFrame:frame];
    direction = dir;
    
    Boid* previousBoid = _flockPointer;
    Boid *boid = _flockPointer;
    
    
    // Create many of them
    for (int i = 0; i < count; i++)
    {
        // Create a linked list
        // The first one has no previous and is made for us already
        if(i != 0)
        {
            boid = [Boid spriteWithSpriteFrame:frame borders: CGRectMake(-100, -100, 1200, 800)];
            previousBoid->_next = boid; // special case for the first one
        }
        
        previousBoid = boid;
        
        boid.doRotation = NO;
        boid.color = color;
        
        [boid setSpeedMax: 4.2f withRandomRangeOf:2.15f andSteeringForceMax:1.0f withRandomRangeOf:0.15f];
        [boid setWanderingRadius: 20.0f lookAheadDistance: 70.0f andMaxTurningAngle:0.2f];
        [boid setEdgeBehaviorSides: EDGE_WRAP];
        [boid setEdgeBehaviorTopBottom:EDGE_BOUNCE];
        
        // Cocos properties
        [boid setScale: scale + (CCRANDOM_MINUS1_1() * scale)];
        [boid setPos: ccp( CCRANDOM_MINUS1_1() * screenSize.width, pos.y + CCRANDOM_MINUS1_1() * 100)];
        // Color
        [boid setOpacity:255];
        [boid seek:dir usingMultiplier:0.35f];
        [boid runAction:[CCSequence actions:[CCDelayTime actionWithDuration:CCRANDOM_0_1()], [CCAnimate actionWithAnimation:[[CCAnimationCache sharedAnimationCache] animationByName:@"birds_fly"]], nil]];
        [self addChild:boid];
    }
    
    return self;
}

-(void) onEnter {
    [super onEnter];
    [self schedule: @selector(tick:)];
    [[[CCDirector sharedDirector] touchDispatcher] addStandardDelegate:self priority:0];
}

-(void) onExit {
    [self unschedule:@selector(tick:)];
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
    [super onExit];
}

-(void) dealloc {
    if (touchSet != nil) {
        [touchSet release];
        touchSet = nil;
    }
    
    [super dealloc];
}

-(void) tick: (ccTime) dt
{
	Boid* boid = _flockPointer;
	while(boid)
	{
		Boid* b = boid;
		boid = b->_next;
		[b wander: 0.55f];
		[b
		 flock:_flockPointer
		 withSeparationWeight:1.0f
		 andAlignmentWeight:0.1f
		 andCohesionWeight:0.2f
		 andSeparationDistance:10.0f
		 andAlignmentDistance:30.0f
		 andCohesionDistance:20.0f
		 ];
        
        [boid seek:direction usingMultiplier:0.35f];
		
        if (touchSet != nil) {
            [touchSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                UITouch *touch = (UITouch *) obj;
                
                CGPoint pnt = [[CCDirector sharedDirector] convertToGL: [touch locationInView:[touch view]]];
                
                [boid flee:pnt panicAtDistance:30 usingMultiplier:5.14f];
            }];
        }
        
		[b update];
	}
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touchSet != nil)
        [touchSet release];
    
    touchSet = [touches retain];
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touchSet != nil)
        [touchSet release];
    
    touchSet = [touches retain];
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touchSet != nil)
        [touchSet release];
    
    if ([touches count] > 0)
        touchSet = [touches retain];
    else
        touchSet = nil;
}

-(void) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touchSet != nil)
        [touchSet release];
    
    if ([touches count] > 0)
        touchSet = [touches retain];
    else
        touchSet = nil;
}

@end
