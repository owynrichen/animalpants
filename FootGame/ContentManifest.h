//
//  ContentManifest.h
//  FootGame
//
//  Created by Owyn Richen on 4/11/13.
//
//

#import <Foundation/Foundation.h>
#import "SoundManager.h"
#import "CCBaseLayer.h"

@protocol ContentLoadDelegate <NSObject>

@optional
-(void) loadStarted: (int) totalCount;
-(void) loadProgress: (int) count totalCount: (int) totalCount;
-(void) loadComplete;
-(void) unloadComplete;

@end

@interface ContentManifest : NSObject {
    id<ContentLoadDelegate> delegate;
    
    int loadedImageCount;
    int loadedAudioCount;
}

@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *audio;

-(id) initWithImages: (NSArray *) images audio: (NSArray *) audio;
-(id) initWithManifests: (ContentManifest *) mfest, ...;

-(void) addImageFile: (NSString *) filename;
-(void) addAudioFile: (NSString *) filename;
-(void) addManifest: (ContentManifest *) mfest;

-(int) loadAsync: (id<ContentLoadDelegate>) delegate;
-(void) unload: (id<ContentLoadDelegate>) delegate;

@end

@interface CCPreloadingLayer : CCBaseLayer<ContentLoadDelegate> {
    BOOL contentLoaded;
    NSObject *sync;
    void (^loadCompleteBlock)(void);
    
    ContentManifest *manifestToLoad;
}

+(ContentManifest *) myManifest;

-(void) doWhenLoadComplete: (NSString *) loadingStr blk: (void(^)(void)) loadBlock;

@end
