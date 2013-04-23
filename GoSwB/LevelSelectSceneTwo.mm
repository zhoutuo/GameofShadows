//
//  LevelSelectScene2.m
//  Shadow UI
//
//  Created by Ryan Ball on 2/18/13.
//
//

#import "LevelSelectSceneTwo.h"
#import "CCBReader.h"
#import "CCMenu.h"
#import "Globals.h"
#import "GameplayScene.h"

#define LEVEL_2_1_TAG 1
#define LEVEL_2_2_TAG 2
#define LEVEL_2_3_TAG 3
#define LEVEL_2_4_TAG 4
#define LEVEL_2_5_TAG 5
#define LEVEL_2_6_TAG 6
#define LEVEL_2_7_TAG 7
#define LEVEL_2_8_TAG 8
#define BACK_BUTTON_TAG 10
#define FORWARD_BUTTON_TAG 11
#define HOME_BUTTON_TAG 20

@implementation LevelSelectSceneTwo

-(void)buttonPressed:(id)sender {
    CCMenuItem *button = (CCMenuItem*) sender;
    switch (button.tag) {
            //Temporarily all point back to main menu
            //CURRENT LEVEL INCREMENTED BY 10 FROM 1st level select
        case LEVEL_2_1_TAG:
            currentLevel = 11;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
            
        case LEVEL_2_2_TAG:
            currentLevel = 12;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
        case LEVEL_2_3_TAG:
            currentLevel = 13;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
        case LEVEL_2_4_TAG:
            currentLevel = 14;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
        case LEVEL_2_5_TAG:
            currentLevel = 15;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
        case LEVEL_2_6_TAG:
            currentLevel = 16;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
        case LEVEL_2_7_TAG:
            currentLevel = 17;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
        case LEVEL_2_8_TAG:
            currentLevel = 18;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
        case BACK_BUTTON_TAG:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[CCBReader sceneWithNodeGraphFromFile:@"LevelSelectScene.ccbi"]]];
            break;
        case FORWARD_BUTTON_TAG:
        case HOME_BUTTON_TAG:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[CCBReader sceneWithNodeGraphFromFile:@"MainMenuScene.ccbi"]]];
            break;
            
    }
}

@end

