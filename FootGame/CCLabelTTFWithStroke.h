//
//  CCLabelTTFWithStroke.h
//  SockThatFool
//
//  Created by Owyn Richen on 4/8/12.
//  Copyright (c) 2012 Alchemist Interactive LLC. All rights reserved.
//

@interface CCLabelTTFWithStroke : CCLabelTTF {
    ccColor3B strokeColor_;
    float strokeSize_;
    
    CCRenderTexture *strokeTexture;
}

@property (nonatomic, readonly) ccColor3B strokeColor;
@property (nonatomic, readonly) float strokeSize;

-(void) setStrokeColor:(ccColor3B)strokeColor;
-(void) setStrokeSize:(float)strokeSize;

-(void) drawStroke;

+(CCRenderTexture*) createStroke: (CCLabelTTF*) label size:(float)size color:(ccColor3B)cor;

@end
