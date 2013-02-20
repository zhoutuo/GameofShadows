//
//  MainMenuScene.m
//  Shadow UI
//
//  Created by Ryan Ball on 2/4/13.
//
//

#import "MainMenuScene.h"
#import "CCBReader.h"
#import "CCMenu.h"
#import "GameplayScene.h"

#define PLAY_BUTTON_TAG 1
#define LEVEL_BUTTON_TAG 2
#define OPTIONS_BUTTON_TAG 3

@implementation MainMenuScene 

-(void)buttonPressed:(id)sender {
    CCMenuItem *button = (CCMenuItem*) sender;
    switch (button.tag) {
        case PLAY_BUTTON_TAG:
           [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
            break;
        case OPTIONS_BUTTON_TAG:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[CCBReader sceneWithNodeGraphFromFile:@"MainMenuOptionsScene.ccbi"]]];
            break;
        case LEVEL_BUTTON_TAG:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[CCBReader sceneWithNodeGraphFromFile:@"LevelSelectScene.ccbi"]]];
            break;
    }
}

@end
