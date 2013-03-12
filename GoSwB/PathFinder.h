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
    char ocList[768][1024];
    
    
}
-(id)init:(int)MonsterSizeIn :(int)DeviceWidthIn :(int)DeviceHeightIn :(int[768][1024])mapIn;
-(void)findPath:(CGPoint)start :(CGPoint)end :(NSMutableArray*) path;

@end
