//
//  PathFinder.h
//  Game of Shadows
//
//  Created by Ryan Schubert on 2/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"


@interface PathFinder : CCNode {
    int deviceHeight;
    int deviceWidth;
    int monsterSize;
    int (*map)[1024];
    
    
}
-(id)initSize:(int)MonsterSizeIn :(int)DeviceWidthIn :(int)DeviceHeightIn :(int[768][1024])mapIn;
-(void)findPath:(CGPoint)start :(CGPoint)end :(CCArray*) path;

@end
