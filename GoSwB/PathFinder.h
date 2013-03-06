//
//  PathFinder.h
//  Game of Shadows
//
//  Created by Ryan Schubert on 2/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define MONSTER_SIZE 24

@interface PathFinder : CCNode {
    int deviceHeight;
    int deviceWidth;
    int monsterSize;
    int (*map)[1024];
    
    
}
-(id)initSize:(int)MonsterSizeIn :(int)DeviceWidthIn :(int)DeviceHeightIn :(int[768][1024])mapIn;
-(bool)findPath:(int)startX :(int)startY :(int)endX :(int)endY;

@end
