//
//  CCMenuItemFontWithStroke.m
//  SockThatFool
//
//  Created by Owyn Richen on 4/8/12.
//  Copyright (c) 2012 Alchemist Interactive LLC. All rights reserved.
//

#import "CCMenuItemFontWithStroke.h"
#import "CCLabelTTFWithStroke.h"

@implementation CCMenuItemFontWithStroke

+(id) itemFromString: (NSString*) value target:(id) r selector:(SEL) s color:(ccColor3B)color strokeColor:(ccColor3B) sColor strokeSize: (float) size
{
	return [[[self alloc] initFromString: value target:r selector:s color:color strokeColor:sColor strokeSize:size] autorelease];
}

+(id) itemFromString: (NSString*) value color:(ccColor3B)color strokeColor:(ccColor3B) sColor strokeSize: (float) size block:(void (^)(id))block {
    return [[[self alloc] initFromString: value color:color strokeColor:sColor strokeSize:size block:block] autorelease];
}

-(id) initFromString: (NSString *) value block:(void (^)(id)) block {
    NSAssert( [value length] != 0, @"Value length must be greater than 0");
	
	fontName_ = [[CCMenuItemFont fontName] copy];
	fontSize_ = [CCMenuItemFont fontSize];
	
	CCLabelTTFWithStroke *label = [CCLabelTTFWithStroke labelWithString:value fontName:fontName_ fontSize:fontSize_];
    
    if((self=[super initWithLabel:label block:block]) ) {
		// do something ?
        [self resetContentSize];
	}
    
    return self;
}

-(id) initFromString: (NSString*) value target:(id) rec selector:(SEL) cb
{
    __block id t = rec;
    
	self = [self initFromString:value block:^(id sender) {
        [t performSelector:cb];
    }];
    
    return self;
}

-(void) recreateLabel
{
	CCLabelTTFWithStroke *label = [CCLabelTTFWithStroke labelWithString:[label_ string] fontName:fontName_ fontSize:fontSize_];
	self.label = label;
    [self resetContentSize];
}

-(id) initFromString: (NSString*) value target:(id) rec selector:(SEL) cb color:(ccColor3B)color strokeColor:(ccColor3B) sColor strokeSize: (float) size
{
	self = [self initFromString:value target:rec selector:cb];
    [self setColor:color];
    
    CCLabelTTFWithStroke *l = (CCLabelTTFWithStroke *) label_;
	[l setStrokeSize:size];
    [l setStrokeColor:sColor];
    [l drawStroke];
    [self resetContentSize];
    
	return self;
}

-(id) initFromString: (NSString*) value color:(ccColor3B)color strokeColor:(ccColor3B) sColor strokeSize: (float) size block:(void (^)(id))block
{
	self = [self initFromString:value block:block];
    [self setColor:color];
    
    CCLabelTTFWithStroke *l = (CCLabelTTFWithStroke *) label_;
	[l setStrokeSize:size];
    [l setStrokeColor:sColor];
    [l drawStroke];
    [self resetContentSize];
    
	return self;
}

-(void) setString:(NSString *)string
{
	[super setString:string];
    CCLabelTTFWithStroke *l = (CCLabelTTFWithStroke *) label_;
    [l setStrokeSize:l.strokeSize];
    [l setStrokeColor:l.strokeColor];
    [l drawStroke];
    [self resetContentSize];
}

-(void) setStrokeColor:(ccColor3B)strokeColor {
    CCLabelTTFWithStroke *l = (CCLabelTTFWithStroke *) label_;
    [l setStrokeColor:strokeColor];
    [l drawStroke];
    [self resetContentSize];
}

-(void) setStrokeSize:(float)strokeSize {
    CCLabelTTFWithStroke *l = (CCLabelTTFWithStroke *) label_;
    [l setStrokeSize:strokeSize];
    [l drawStroke];
    [self resetContentSize];
}

-(void) resetContentSize {
    [self setContentSize:self.label.contentSize];
}


@end
