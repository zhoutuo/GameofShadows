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
        
        gameplayLayer = [GameplayLayer node];
        [self addChild:gameplayLayer z:3];
        
        gameplayMenuLayer = [GameplayMenuLayer node];
        [self addChild:gameplayMenuLayer z:4];

        
        [self initSwipeGestures];
        isPuzzleMode = true; //setting modes.
        [gameplayLayer startPuzzleMode];
        gamestats.isMonsterDead = false;
        gamestats.timeUsed = 0.0f;
        
    }
    return self;
    
}

-(void) dealloc {
    [self removeSwipeGestures];
    [super dealloc];
}
-(void) shift:(CGPoint) centerPoint{
    [backgroundLayer shift:centerPoint];
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


-(void) finishLightsCreation:(CCArray *)lights withRatios:(CCArray *)ratios {
    [shadowLayer castLightFrom:lights withRatios:ratios];
}

-(void) finishMovingOneLight:(NSInteger)lightTag withRatio:(CGPoint)ratio {
    
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
        //cancel touches: make sure shadow monster does not move when swiping up
        swipeUp.cancelsTouchesInView = YES;
        swipeDown.cancelsTouchesInView = YES;
        swipeLeft.cancelsTouchesInView = YES;
        swipeRight.cancelsTouchesInView = YES;

        [shadowLayer finishActionMode];
        [gameplayLayer startPuzzleMode];
    }

    
}
-(void) twoFingerSwipeDown {
    if (isPuzzleMode) {
        isPuzzleMode = false;
        //do not cancel touches: make sure that OMS operations are normal, no hang in the air
        swipeUp.cancelsTouchesInView = NO;
        swipeDown.cancelsTouchesInView = NO;
        swipeLeft.cancelsTouchesInView = NO;
        swipeRight.cancelsTouchesInView = NO;
        
        [gameplayLayer finishPuzzleMode];
        [shadowLayer startActionMode];
    }
}




-(void) initSwipeGestures{
    
    swipeRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerSwipeRight)]autorelease];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeRight setNumberOfTouchesRequired:2];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeRight];
    
    swipeLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerSwipeLeft)]autorelease];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeLeft setNumberOfTouchesRequired:2];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeLeft];

    
    swipeUp = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerSwipeUp)]autorelease];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeUp setNumberOfTouchesRequired:2];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeUp];
    
    swipeDown = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerSwipeDown)]autorelease];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [swipeDown setNumberOfTouchesRequired:2];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeDown];
    
}

-(void) removeSwipeGestures{
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:swipeUp];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:swipeDown];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:swipeLeft];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:swipeRight];
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

-(void) shadowMonsterTransition {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionPageTurn transitionWithDuration:1 scene:[GameplayScene node]]];
    CCLOG(@"TRANSITIONING, ZHOTO SUCKS");
}

@end
