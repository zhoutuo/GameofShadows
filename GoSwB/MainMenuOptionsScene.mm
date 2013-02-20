//
//  MainMenuOptionsScene.m
//  Shadow UI
//
//  Created by Ryan Ball on 2/18/13.
//
//

#import "MainMenuOptionsScene.h"
#import "CCBReader.h"
#import "CCMenu.h"

#define SOUND_BUTTON_TAG 1
#define MUSIC_BUTTON_TAG 2
#define GAMMA_BUTTON_TAG 3
#define LIGHT_BUTTON_TAG 4
#define HOME_BUTTON_TAG 20

@implementation MainMenuOptionsScene

//Eventually when options gets called in game, this function needs to be adjusted
-(void)buttonPressed:(id)sender {
    CCMenuItem *button = (CCMenuItem*) sender;
    switch (button.tag) {
        case SOUND_BUTTON_TAG:
        case MUSIC_BUTTON_TAG:
        case GAMMA_BUTTON_TAG:
        case LIGHT_BUTTON_TAG:
        case HOME_BUTTON_TAG:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[CCBReader sceneWithNodeGraphFromFile:@"MainMenuScene.ccbi"]]];
            break;
    }
}

@end
