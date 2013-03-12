//
//  GameplayScene.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "GameplayScene.h"
#import "CCBReader.h"

@implementation GameplayScene

static NSInteger tagSeed = 10000;

-(id) init {
    if (self = [super init]) {
                
        backgroundLayer = [BackgroundLayer node];
        [self addChild:backgroundLayer z:0];
    
        shadowLayer = [ShadowsLayer node];
        [self addChild:shadowLayer z:1];
        
        shadowDisruptionLayer = [ShadowDisruptionLayer node];
        [self addChild:shadowDisruptionLayer z:2];
        
        gameplayLayer = [GameplayLayer node];
        [self addChild:gameplayLayer z:3];
        
        [self initSwipeGestures];
        isPuzzleMode = true; //setting modes.
        
        gamestats.isMonsterDead = false;
        gamestats.timeUsed = 0.0f;
        
    }
    return self;
    
}

-(void) dealloc {
    [self removeSwipeGestures];
    [super dealloc];
}


-(void) finishObjectsCreation:(CCArray *)objects withRatios:(CCArray *)ratios {
    [shadowLayer castShadowFrom:objects withRatios:ratios];
}


-(void) finishMovingOneObject:(NSInteger)objectTag withRatio:(CGPoint)ratio {
    [shadowLayer updateShadowPos:objectTag withRelativePos:ratio];
}

-(void) finishRotatingOneObject:(NSInteger)objectTag withAngle:(float)angle {
    [shadowLayer updateShadowRot:objectTag withAngle:angle];
}


+(NSInteger) TagGenerater {
    return tagSeed++;
}

-(void) twoFingerSwipeRight {
    if(isPuzzleMode){
        isPuzzleMode = true;
        [gameplayLayer moveOMStoRight];
    }
}
-(void) twoFingerSwipeLeft {
    if(isPuzzleMode){
        isPuzzleMode = true;
        [gameplayLayer moveOMStoLeft];
    }
}
-(void) twoFingerSwipeUp{
    if (!isPuzzleMode) {
        isPuzzleMode = true;
        [shadowLayer finishActionMode];
        [gameplayLayer startPuzzleMode];
    }

    
}
-(void) twoFingerSwipeDown {
    if (isPuzzleMode) {
        isPuzzleMode = false;
        [gameplayLayer finishPuzzleMode];
        [shadowLayer startActionMode];
    }
}




-(void) initSwipeGestures{
    
    swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerSwipeRight)]autorelease];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeRight setNumberOfTouchesRequired:2];
    swipeRight.cancelsTouchesInView = NO;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeRight];
    
    swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerSwipeLeft)]autorelease];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeLeft setNumberOfTouchesRequired:2];
    swipeLeft.cancelsTouchesInView  = NO;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeLeft];
    
    swipeUp = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerSwipeUp)]autorelease];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeUp setNumberOfTouchesRequired:2];
    swipeUp.cancelsTouchesInView  =NO;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeUp];
    
    swipeDown = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerSwipeDown)]autorelease];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [swipeDown setNumberOfTouchesRequired:2];
    swipeDown.cancelsTouchesInView  = NO;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeDown];
    
}

-(void) removeSwipeGestures{
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:swipeUp];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:swipeDown];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:swipeLeft];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:swipeRight];
}

-(bool) checkLightSourceCoordinates:(int)ycoor :(int)xcoor{
    return [shadowDisruptionLayer checkIfInLight:ycoor : xcoor];
}

-(void) shadowMonsterDead {
    gamestats.isMonsterDead = true;
    [shadowLayer finishActionMode];
    
    //Ryan Ball
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[CCBReader sceneWithNodeGraphFromFile:@"LossScene.ccbi"]]];
    CCLOG(@"LOST, U SUCK");
}

-(void) shadowMonterRescued {
    gamestats.isMonsterDead = false;
    [shadowLayer finishActionMode];
    //Ryan Ball TODO WinScene failing
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[CCBReader sceneWithNodeGraphFromFile:@"WinScene.ccbi"]]];
    CCLOG(@"WIN, STILL SUCK");
}

@end
