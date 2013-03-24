//
//  LocalizationManager.m
//  FootGame
//
//  Created by Owyn Richen on 10/3/12.
//
//

#import "LocalizationManager.h"

#define USER_DEFAULTS_KEY_PREFERRED_LOCALE @"AppPreferredLocale"
#define DEFAULT_STRINGS_TABLE @"strings"

@interface LocalizationManager()
-(void) loadPreferredLanguageBundle: (NSString *) lang;
-(NSBundle *) getPreferredLanguageBundle: (NSString *) lang;
-(NSString *) getLocalizedStringForKey:(NSString *) key fromTable: (NSString *) table withBundle: (NSBundle *) bundle;
@end

@implementation LocalizationManager

static LocalizationManager* _instance;
static NSString *_sync = @"";

+(LocalizationManager *) sharedManager {
    if (_instance == nil) {
        @synchronized(_sync) {
            if (_instance == nil) {
                _instance = [[LocalizationManager alloc] init];
            }
        }
    }
    
    return _instance;
}

-(void) loadPreferredLanguageBundle:(NSString *)lang {
    if (strBundle != nil)
        [strBundle release];
    
    strBundle = [[self getPreferredLanguageBundle:lang] retain];
}

-(void) dealloc {
    if (strBundle != nil) {
        [strBundle release];
    }
    [super dealloc];
}

-(NSBundle *) getPreferredLanguageBundle: (NSString *) lang {
    if (lang == nil) {
        return [NSBundle mainBundle];
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:lang ofType:@"lproj" ];
    
    if (path == nil) {
        // there is no bundle for that language
        // use main bundle instead
        return [NSBundle mainBundle];
    } else {
        
        // use this bundle as my bundle from now on:
        return [NSBundle bundleWithPath:path];
        
        // to be absolutely sure (this is probably unnecessary):
        if (strBundle == nil) {
            return [NSBundle mainBundle];
        }
    }
}

-(id) init {
    self = [super init];
    
    [self loadPreferredLanguageBundle:[self getAppPreferredLocale]];
    
    return self;
}

-(NSString *) getLocalizedStringForKey:(NSString *) key {
    return [self getLocalizedStringForKey:key fromTable:DEFAULT_STRINGS_TABLE];
}

-(NSString *) getLocalizedStringForKey:(NSString *) key fromTable: (NSString *) table {
    return [self getLocalizedStringForKey:key fromTable:table withBundle:strBundle];
}

-(NSString *) getLocalizedStringForKey:(NSString *) key fromTable: (NSString *) table forLanguage: (NSString *) lang {
    NSBundle *bundle = [self getPreferredLanguageBundle:lang];
    
    return [self getLocalizedStringForKey:key fromTable:table withBundle:bundle];
}

-(NSString *) getLocalizedStringForKey:(NSString *) key fromTable: (NSString *) table withBundle: (NSBundle *) bundle {
    NSString * locStr = nil;
    
    if (bundle != nil) {
        locStr = [bundle localizedStringForKey:key value:@"" table:table];
    }
    
    if (locStr == nil) {
        locStr = NSLocalizedStringFromTable(key, table, @"");
    }
    
    return locStr;
}

-(NSString *) getLanguageProductForKey: (NSString *) key {
    return [NSString stringWithFormat:@"com.alchemistinteractive.footgame.language.%@", key];
}

-(void) setAppPreferredLocale: (NSString *) locale {
    [[NSUserDefaults standardUserDefaults] setObject:locale forKey:USER_DEFAULTS_KEY_PREFERRED_LOCALE];
    [self loadPreferredLanguageBundle:locale];
}

-(NSString *) getAppPreferredLocale {
    NSLocale *loc = [self getAppPreferredNSLocale];
    return [loc.localeIdentifier substringToIndex:2];
}

-(NSLocale *) getAppPreferredNSLocale {
    NSString *appLocale = (NSString *) [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_PREFERRED_LOCALE];
    
    if (appLocale != nil) {
        return [[NSLocale alloc] initWithLocaleIdentifier:appLocale];
    } else {
        return [NSLocale currentLocale];
    }
}

-(NSString *) getLocalizedFilename: (NSString *) baseFilename {
    return [self getLocalizedFilename:baseFilename withLocale:[self getAppPreferredLocale]];
}

-(NSString *) getLocalizedFilename: (NSString *) baseFilename withLocale: (NSString *) lang {
    NSString *pathWithoutExtension = [baseFilename stringByDeletingPathExtension];
    NSString *extension = [baseFilename pathExtension];

    NSString *returnPath = nil;
    NSString *localePath = [NSString stringWithFormat:@"%@.%@.%@", pathWithoutExtension, lang, extension];
    NSString *fullPath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath: localePath];
        
    NSString *relPath = [fullPath lastPathComponent];
    returnPath = [strBundle pathForResource:relPath ofType:nil];
    
    if (returnPath == nil) {
        // NSString *dir = [fullPath stringByDeletingLastPathComponent];
        returnPath = [[NSBundle mainBundle] pathForResource:relPath ofType:nil];
    }
    
    return returnPath;
}

-(NSString *) getLocalizedImageFilename: (NSString *) baseImageFilename {
    return nil;
}

-(NSArray *) getAvailableLanguages {
    // TODO: sort by preferred languages first?
    return [NSArray arrayWithObjects:@"en", @"es", @"fr", @"de", @"ja", nil];
}

-(NSString *) getSystemLanguageHelperString: (NSString *) key fromTable: (NSString *) table {
    NSString *appLang = [self getLocalizedStringForKey:key fromTable:table];
    NSString *sysLang = NSLocalizedStringFromTable(key, table, @"");
    
    if ([appLang isEqualToString:sysLang]) {
        return appLang;
    } else {
        return [NSString stringWithFormat:@"%@ (%@)",
                appLang,
                sysLang
                ];
    }
}

-(NSString *) getLanguageNameString: (NSString *) lang {
    return [NSString stringWithFormat:@"%@ (%@)",
            [self getLocalizedStringForKey:lang fromTable:@"strings" forLanguage:lang],
            [self getLocalizedStringForKey:lang fromTable:@"strings"]
     ];
}

-(NSArray *) getAvailableLanguageStrings {
    NSMutableArray *langStrs = [[[NSMutableArray alloc] init] autorelease];
    
    for(NSString *lang in [self getAvailableLanguages]) {
        // TODO: wire this up so it's aware when the app preferred locale is different
        // than the system preferred locale
        
        NSString *langStr = [self getLanguageNameString:lang];
        
        [langStrs addObject:langStr];
    }
    
    return langStrs;
}

@end
