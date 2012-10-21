//
//  GameConfig.h
//  FootGame
//
//  Created by Owyn Richen on 3/23/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

#define MENU_COLOR ccc3(204,108,208)
#define MENU_STROKE ccWHITE

//
// Define here the type of autorotation that you want for your game
//
#define GAME_AUTOROTATION kGameAutorotationNone


#endif // __GAME_CONFIG_H