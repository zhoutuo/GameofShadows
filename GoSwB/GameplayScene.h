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
#import "GameStats.h"
#import "GameplayMenuLayer.h"

@interface GameplayScene : CCScene {
    BackgroundLayer* backgroundLayer;
    ShadowsLayer* shadowLayer;
    GameplayLayer* gameplayLayer;
    GameplayMenuLayer* gameplayMenuLayer;
    
    GameStats* gamestats;

    //Mode
    bool isPuzzleMode;
    
    //Swipe Gesture Recognizer
    UISwipeGestureRecognizer *swipeRight;
    UISwipeGestureRecognizer *swipeLeft;
    UISwipeGestureRecognizer *swipeUp;
    UISwipeGestureRecognizer *swipeDown;
}

+(NSInteger) TagGenerater;
-(void) finishObjectsCreation: (CCArray*) objects withRatios:(CCArray*) ratios;
-(void) finishLightsCreation: (CCArray*) lights withRatios:(CCArray*) ratios;
-(void) finishMovingOneObject: (NSInteger) objectTag withRatio:(CGPoint) ratio;
-(void) finishMovingOneLight: (NSInteger) lightTag withRatio:(CGPoint) ratio;
-(void) finishRotatingOneObject: (NSInteger) objectTag withAngle:(float) angle;
-(void) shadowMonsterDead;
-(void) shadowMonterRescued;
-(void) shadowMonsterTransition;
-(void) shift:(CGPoint) centerPoint;
@end
