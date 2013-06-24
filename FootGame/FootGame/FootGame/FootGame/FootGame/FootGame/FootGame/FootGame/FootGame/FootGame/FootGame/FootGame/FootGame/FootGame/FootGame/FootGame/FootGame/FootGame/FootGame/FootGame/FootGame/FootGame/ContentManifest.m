//
//  ContentManifest.m
//  FootGame
//
//  Created by Owyn Richen on 4/11/13.
//
//

#import "ContentManifest.h"
#import "MBProgressHUD.h"

@interface ContentManifest()
-(void) loadImageAsyncNext: (CCTexture2D *) tex;
-(void) loadAudioAsyncNext: (NSString *) audio;
@end

// #define SKIP_ASYNC 1

@implementation ContentManifest

@synthesize images;
@synthesize audio;

-(id) initWithImages: (NSArray *) imgs audio: (NSArray *) adio {
    self = [self init];
    
    [imgs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addImageFile:obj];
    }];
    
    [adio enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addAudioFile:obj];
    }];
    
    return self;
}

-(id) initWithManifests: (ContentManifest *) mfest, ... {
    self = [self init];
    
    va_list args;
    va_start(args, mfest);
    for (ContentManifest *arg = mfest; arg != nil; arg = va_arg(args, ContentManifest *))
    {
        [self addManifest:arg];
    }
    va_end(args);
    
    return self;
}

-(id) init {
    self = [super init];
    
    images = [[NSMutableArray alloc] init];
    audio = [[NSMutableArray alloc] init];
    
    loadedImageCount = 0;
    loadedAudioCount = 0;
    
    return self;
}

-(id) copyWithZone: (NSZone *) zone {
    ContentManifest *mfest = [[[self class] allocWithZone:zone] init];
    
    mfest.images = [[self.images copyWithZone:zone] autorelease];
    mfest.audio = [[self.audio copyWithZone:zone] autorelease];
    
    return mfest;
}

-(void) dealloc {
    CCLOGINFO( @"cocos2d: deallocing %@", self);
    
    [images release];
    [audio release];
    
    if (delegate != nil) {
        [delegate release];
        delegate = nil;
    }
    
    [super dealloc];
}

-(void) addImageFile: (NSString *) filename {
    if (filename == nil)
        return;
    
    [images addObject:filename];
}

-(void) addAudioFile: (NSString *) filename {
    if (filename == nil)
        return;
    
    [audio addObject:filename];
}

-(void) addManifest: (ContentManifest *) mfest {
    [mfest.images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addImageFile:obj];
    }];
    
    [mfest.audio enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addAudioFile:obj];
    }];
}

-(int) loadAsync: (id<ContentLoadDelegate>) del {
    if (delegate != nil) {
        [delegate release];
        delegate = nil;
    }
    
    if (del != nil) {
        delegate = [del retain];
    }
    
#ifndef SKIP_ASYNC
    
    loadedAudioCount = 0;
    loadedImageCount = 0;
    
    if (delegate != nil && [delegate respondsToSelector:@selector(loadStarted:)]) {
        [delegate loadStarted: [images count] + [audio count]];
    }
    
    if ([images count] > 0) {
        [[CCTextureCache sharedTextureCache] addImageAsync:[images objectAtIndex:0] target:self selector:@selector(loadImageAsyncNext:)];
    } else if ([audio count] > 0) {
        [[SoundManager sharedManager] preloadSoundAsync:[audio objectAtIndex:0] target:self selector:@selector(loadAudioAsyncNext:)];
    } else {
        if (delegate != nil && [delegate respondsToSelector:@selector(loadComplete)]) {
            [delegate loadComplete];
        }
    }
    
    return [images count] + [audio count];
#else
    if (delegate != nil && [delegate respondsToSelector:@selector(loadStarted:)]) {
        [delegate loadStarted: [images count] + [audio count]];
    }
    
    if (delegate != nil && [delegate respondsToSelector:@selector(loadProgress:totalCount:)]) {
        [delegate loadProgress:[images count] + [audio count] totalCount:[images count] + [audio count]];
    }
    
    if (delegate != nil && [delegate respondsToSelector:@selector(loadComplete)]) {
        [delegate loadComplete];
    }
#endif
}

-(void) loadImageAsyncNext:(CCTexture2D *)tex {
    loadedImageCount += 1;
    
    if (delegate != nil && [delegate respondsToSelector:@selector(loadProgress:totalCount:)]) {
        [delegate loadProgress:loadedImageCount + loadedAudioCount totalCount:[images count] + [audio count]];
    }
    
    if (loadedImageCount == [images count]) {
        if ([audio count] > 0) {
            [[SoundManager sharedManager] preloadSoundAsync:[audio objectAtIndex:0] target:self selector:@selector(loadAudioAsyncNext:)];
        } else {
            if (delegate != nil && [delegate respondsToSelector:@selector(loadComplete)]) {
                [delegate loadComplete];
                [delegate release];
                delegate = nil;
            }
        }
    } else {
        [[CCTextureCache sharedTextureCache] addImageAsync:[images objectAtIndex:loadedImageCount] target:self selector:@selector(loadImageAsyncNext:)];
    }
}

-(void) loadAudioAsyncNext: (NSString *) adio {
    loadedAudioCount += 1;
    
    if (delegate != nil && [delegate respondsToSelector:@selector(loadProgress:totalCount:)]) {
        [delegate loadProgress:loadedImageCount + loadedAudioCount totalCount:[images count] + [audio count]];
    }
    
    if (loadedAudioCount == [audio count]) {
        if (delegate != nil && [delegate respondsToSelector:@selector(loadComplete)]) {
            [delegate loadComplete];
            [delegate release];
            delegate = nil;
        }
    } else {
        [[SoundManager sharedManager] preloadSoundAsync:[audio objectAtIndex:loadedAudioCount] target:self selector:@selector(loadAudioAsyncNext:)];
    }
}

-(void) unload: (id<ContentLoadDelegate>) del {
    if (delegate != nil) {
        [delegate release];
        delegate = nil;
    }
    
    if (del != nil) {
        delegate = [del retain];
    }
    
    [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [[CCTextureCache sharedTextureCache] removeTextureForKey:(NSString *) obj];
    }];
    
    [audio enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [[SoundManager sharedManager] unloadSound:(NSString *) obj];
    }];
    
    if (delegate != nil && [delegate respondsToSelector:@selector(unloadComplete)]) {
        [delegate unloadComplete];
        [delegate release];
        delegate = nil;
    }
}

@end

@implementation CCPreloadingLayer

+(ContentManifest *) myManifest {
    return [[[ContentManifest alloc] init] autorelease];
}

-(id) init {
    self = [super init];
    
    sync = [[NSObject alloc] init];
    contentLoaded = YES;
    
    return self;
}

-(void) dealloc {
    
    [sync release];
    sync = nil;
    
    if (manifestToLoad != nil) {
        [manifestToLoad release];
        manifestToLoad = nil;
    }
    
    [super dealloc];
}

-(id) retain {
    CCLOG(@"%@ retain called (%i) from: %@", self, [self retainCount], [NSThread callStackSymbols]);
    return [super retain];
}

-(oneway void) release {
    CCLOG(@"%@ release called (%i) from: %@", self, [self retainCount], [NSThread callStackSymbols]);
    [super release];
}

-(void) onEnter {
    [MBProgressHUD hideHUDForView:[CCDirector sharedDirector].view animated:YES];
    
    if (manifestToLoad != nil) {
        [manifestToLoad loadAsync:self];
    }
    
    [super onEnter];
}

-(void) onExitTransitionDidStart {
    [super onExitTransitionDidStart];
}

-(void) loadStarted: (int) totalCount {
    @synchronized(sync) {
        contentLoaded = NO;
    }
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
    [[CCTextureCache sharedTextureCache] dumpCachedTextureInfo];
    [[SoundManager sharedManager] unloadAllSounds];
    
    NSLog(@"Starting to load %i resources", totalCount);
}

-(void) loadProgress: (int) count totalCount: (int) totalCount {
    NSLog(@"Loaded %i of %i resources", count, totalCount);
}

-(void) loadComplete {
    @synchronized(sync) {
        contentLoaded = YES;
        
        if (loadCompleteBlock != nil) {
            loadCompleteBlock();
            [loadCompleteBlock release];
            loadCompleteBlock = nil;
        }
    }
    NSLog(@"Preload complete");
}

-(void) unloadComplete {
    @synchronized(sync) {
        contentLoaded = NO;
    }
}

-(void) doWhenLoadComplete: (NSString *) loadingStr blk: (void(^)(void)) loadBlock {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[CCDirector sharedDirector].view animated:YES];
    hud.labelText = loadingStr;

    @synchronized(sync) {
        if (contentLoaded) {
            loadBlock();
        } else {
            loadCompleteBlock = [loadBlock copy];
        }
    }
}

@end