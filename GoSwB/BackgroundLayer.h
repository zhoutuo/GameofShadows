//
//  BackgroundLayer.h
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "cocos2d.h"

@interface BackgroundLayer : CCLayer{
    
       CCSprite* spook;
    CCSprite* background;
    CCMenuItem *pauseMenuItem;
}

-(void) shift:(CGPoint) centerPoint;
@end
