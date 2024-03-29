//
//  LevelSelectScene.m
//  Shadow UI
//
//  Created by Ryan Ball on 2/18/13.
//
//

#import "LevelSelectScene.h"
#import "CCBReader.h"
#import "CCMenu.h"
#import "Globals.h"
#import "GameplayScene.h"

#define LEVEL_1_1_TAG 1
#define LEVEL_1_2_TAG 2
#define LEVEL_1_3_TAG 3
#define LEVEL_1_4_TAG 4
#define LEVEL_1_5_TAG 5
#define LEVEL_1_6_TAG 6
#define LEVEL_1_7_TAG 7
#define LEVEL_1_8_TAG 8
#define BACK_BUTTON_TAG 10
#define FORWARD_BUTTON_TAG 11
#define HOME_BUTTON_TAG 20

@implementation LevelSelectScene

-(void)buttonPressed:(id)sender {
    CCMenuItem *button = (CCMenuItem*) sender;
    switch (button.tag) {
            //Temporarily all point back to main menu
            
        case LEVEL_1_1_TAG:
            currentLevel = 1;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;

        case LEVEL_1_2_TAG:
            currentLevel = 2;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
        case LEVEL_1_3_TAG:
            currentLevel = 3;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
        case LEVEL_1_4_TAG:
            currentLevel = 4;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
        case LEVEL_1_5_TAG:
            currentLevel = 5;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
        case LEVEL_1_6_TAG:
            currentLevel = 6;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
        case LEVEL_1_7_TAG:
            currentLevel = 7;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
        case LEVEL_1_8_TAG:
            currentLevel = 8;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
        case FORWARD_BUTTON_TAG:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[CCBReader sceneWithNodeGraphFromFile:@"LevelSelectSceneTwo.ccbi"]]];
            break;
        case BACK_BUTTON_TAG:
        case HOME_BUTTON_TAG:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[CCBReader sceneWithNodeGraphFromFile:@"MainMenuScene.ccbi"]]];
            break;
            
    }
}

@end
