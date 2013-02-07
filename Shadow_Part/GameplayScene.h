//
//  GameplayScene.h
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "cocos2d.h"
#import "BackgroundLayer.h"
#import "ShadowsLayer.h"
#import "GameplayLayer.h"
@interface GameplayScene : CCScene {
    BackgroundLayer* backgroundLayer;
    ShadowsLayer* shadowLayer;
    GameplayLayer* gameplayLayer;
}
+(NSInteger) TagGenerater;
-(void) updateShadowPos:(CCSprite*)object;
@end
