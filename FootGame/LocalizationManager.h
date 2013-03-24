//
//  LocalizationManager.h
//  FootGame
//
//  Created by Owyn Richen on 10/3/12.
//
//

#import <Foundation/Foundation.h>

#define locstr(key, tbl, comment) \
[[LocalizationManager sharedManager] getLocalizedStringForKey:(key) fromTable:(tbl)]

#define menulocstr(key, tbl, comment) \
[[LocalizationManager sharedManager] getSystemLanguageHelperString: (key) fromTable: (tbl)]

#define locfile(file) \
[[LocalizationManager sharedManager] getLocalizedFilename: (file)]

#define locfile2(file, locale) \
[[LocalizationManager sharedManager] getLocalizedFilename: (file) withLocale: (locale)]

@interface LocalizationManager : NSObject {
    NSBundle *strBundle;
}

+(LocalizationManager *) sharedManager;

-(NSString *) getLocalizedStringForKey:(NSString *) key;
-(NSString *) getLocalizedStringForKey:(NSString *) key fromTable: (NSString *) table;
-(NSString *) getLocalizedStringForKey:(NSString *) key fromTable: (NSString *) table forLanguage: (NSString *) lang;
-(void) setAppPreferredLocale: (NSString *) locale;
-(NSString *) getAppPreferredLocale;
-(NSString *) getLanguageProductForKey: (NSString *) key;

-(NSString *) getLocalizedFilename: (NSString *) baseFilename;
-(NSString *) getLocalizedImageFilename: (NSString *) baseImageFilename;
-(NSString *) getLocalizedFilename: (NSString *) baseFilename withLocale: (NSString *) lang;

-(NSArray *) getAvailableLanguages;
-(NSArray *) getAvailableLanguageStrings;
-(NSString *) getSystemLanguageHelperString: (NSString *) key fromTable: (NSString *) table;
-(NSString *) getLanguageNameString: (NSString *) lang;

-(NSLocale *) getAppPreferredNSLocale;

@end
