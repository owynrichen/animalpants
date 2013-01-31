//
//  CCMenuItemFontWithStroke.h
//  SockThatFool
//
//  Created by Owyn Richen on 4/8/12.
//  Copyright (c) 2012 Alchemist Interactive LLC. All rights reserved.
//

@interface CCMenuItemFontWithStroke : CCMenuItemFont

+(id) itemFromString: (NSString*) value target:(id) r selector:(SEL) s color:(ccColor3B)color strokeColor:(ccColor3B) sColor strokeSize: (float) size;

+(id) itemFromString: (NSString*) value color:(ccColor3B)color strokeColor:(ccColor3B) sColor strokeSize: (float) size block:(void (^)(id))block;

-(id) initFromString: (NSString*) value target:(id) rec selector:(SEL) cb color:(ccColor3B)color strokeColor:(ccColor3B) sColor strokeSize: (float) size;

-(id) initFromString: (NSString*) value color:(ccColor3B)color strokeColor:(ccColor3B) sColor strokeSize: (float) size block:(void (^)(id))block;

-(id) initFromString: (NSString *) value block:(void (^)(id)) block;

-(void) setStrokeColor:(ccColor3B)strokeColor;
-(void) setStrokeSize:(float)strokeSize;
-(void) setString:(NSString *)string;
-(void) resetContentSize;
@end
