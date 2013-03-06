//
//  GameplayScene.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "GameplayScene.h"


@implementation GameplayScene

static NSInteger tagSeed = 10000;

-(id) init {
    if (self = [super init]) {
                
        backgroundLayer = [BackgroundLayer node];
        [self addChild:backgroundLayer z:0];
    
        shadowLayer = [ShadowsLayer node];
        [self addChild:shadowLayer z:1];
        
        gameplayLayer = [GameplayLayer node];
        [self addChild:gameplayLayer z:2];
        
        [self initSwipeGestures];
        isPuzzleMode = true; //setting modes.
        
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
        [self removeTapGesture];
        [shadowLayer finishActionMode];
        [gameplayLayer startPuzzleMode];
    }

    
}
-(void) twoFingerSwipeDown {
    if (isPuzzleMode) {
        isPuzzleMode = false;
        [gameplayLayer finishPuzzleMode];
        [shadowLayer startActionMode];
        [self initTapGesture];
    }
}
-(void) tapRecognized:(UITapGestureRecognizer *) recognizer {
    CGPoint touchPoint = [recognizer locationOfTouch:0 inView: [[CCDirector sharedDirector]view]];
    int x =touchPoint.x;
    int y = DEVICE_HEIGHT - touchPoint.y;
    
    NSLog(@"Tap yay! x: %d  y: %d" ,x,y);
    [shadowLayer pathFinder:400 :400 :x :DEVICE_HEIGHT - y];
}

- (void) initTapGesture{
    tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)]autorelease];
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:tap];
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

- (void) removeTapGesture {
    [[[CCDirector sharedDirector]view] removeGestureRecognizer:tap];
}
@end
