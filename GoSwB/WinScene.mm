//
//  LossScene.m
//  Game of Shadows
//
//  Created by Ryan Ball on 3/11/13.
//
//

#import "WinScene.h"
#import "Globals.h"
#import "CCBReader.h"
#import "GameplayScene.h"

#define MAIN_MENU_TAG 10
#define REPLAY_TAG 1
#define NEXT_TAG 2


@implementation WinScene

-(void)buttonPressed:(id)sender{
    CCMenuItem *button = (CCMenuItem*) sender;
    switch (button.tag) {
        case MAIN_MENU_TAG:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[CCBReader sceneWithNodeGraphFromFile:@"MainMenuScene.ccbi"]]];
            break;
            
        case REPLAY_TAG:
            NSLog(@"Replay button pushed");
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1 scene:[GameplayScene node]]];
            break;
        case NEXT_TAG:
            NSLog(@"Next button pushed");
            currentLevel++;
            if(currentLevel == 9)
                currentLevel = 11;
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1 scene:[GameplayScene node]]];
            break;
        default:
            break;
    }
}

@end
