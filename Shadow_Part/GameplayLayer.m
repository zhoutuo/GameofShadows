//
//  GameplayLayer.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 1/30/13.
//
//

#import "GameplayLayer.h"
#import "GameplayScene.h"
#import "GestureRecognizer.h"

@implementation GameplayLayer

@synthesize backgroundDepth = _backgroundDepth;
@synthesize itemsDepth = _itemsDepth;


-(id) init {
    if (self = [super init]) {

        self.isTouchEnabled = YES;
        
        touchRect = CGRectMake(0, 0, 700, 300);        //size of the touch rect
        touchedObjectTag = -1;              //the tag for the sprite being touched right now
        _backgroundDepth = 0;           //background sprite's z-order
        _itemsDepth = 1;            //other sprites' z-order
        touchArray = [CCArray array];
        [touchArray retain];
        //by making background sprite center on lower left corner will make it
        //easier to align it with the touch rect
        background = [CCSprite spriteWithFile:@"play_bg.png"];
        [background setAnchorPoint:ccp(0, 0)];
        [background setPosition:ccp(0, 0)];
        
        [self addChild:background z:_backgroundDepth tag:[GameplayScene TagGenerater]];
        
        CCSprite* droid1 = [CCSprite spriteWithFile:@"Droid1.png"];
        [droid1 setPosition:ccp(100, 100)];
        [self addChild:droid1 z:_itemsDepth tag:[GameplayScene TagGenerater]];
}
    
    return self;
}


-(void) dealloc {
    [touchArray release];
    [super dealloc];
}

-(void) fadeOutTouchRect {
    for (CCSprite* child in self.children) {
        id action = [CCFadeOut actionWithDuration:2];
        [child runAction:action];
    }
}

-(void) fadeInTouchRect {
    for (CCSprite* child in self.children) {
        id action = [CCFadeIn actionWithDuration:2];
        [child runAction:action];
    }
}

-(CGPoint) getSpriteRelativePos:(CCSprite *)object {
    CGPoint relativePos;
    relativePos.x = (object.position.x - touchRect.origin.x) / touchRect.size.width;
    relativePos.y = (object.position.y - touchRect.origin.y) / touchRect.size.height;
    return relativePos;
}


-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    [touchArray addObject:[NSValue valueWithCGPoint:location]];
    
    for (CCSprite* cur in self.children) {
        //check whether the touching point falls in some sprite's rect
        if (CGRectContainsPoint([cur boundingBox], location)) {
            //keep its tag
            touchedObjectTag = [cur tag];
            //if it is a item, and since item sprites should have
            //physics collisions, they cannot intersect or somehow
            //so that we can make sure there is only one sprite being touched
            //if it is a background, we do not return, because background has a lower
            //priority. otherwise we cannot touch other item sprites anymore
            if (cur.zOrder == _itemsDepth) {
                break;
            }
        }
    }
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    
    location = [[CCDirector sharedDirector] convertToGL:location];
    [touchArray addObject:[NSValue valueWithCGPoint:location]];

    if (touchedObjectTag != -1) {
        CCSprite* touched = (CCSprite*)[self getChildByTag:touchedObjectTag];
        if (touched.zOrder == _backgroundDepth) {
            
            //modifer locaiton to make sure that the location is in the middle
            //of the touchrect, because default anchor point is lower left corner
            //when you try to move the rect, the center pointer is left corner, it's user unfriendly
            
            //make the location lefter and lower than it is supposed to
            location.x -= touchRect.size.width / 2;
            location.y -= touchRect.size.height / 2;
            
            
            //update the origin position of touch rect
            touchRect.origin = location;
            
            //move all the children accordingly
            int diffX = location.x - touched.position.x;
            int diffY = location.y - touched.position.y;
            for (CCSprite* cur in self.children) {
                if (cur.zOrder == _itemsDepth) {
                    cur.position = ccpAdd(cur.position, ccp(diffX, diffY));
                }
            }
        
        } else {
            //since we did not change the anchor point of the children sprites
            //we do not need to change the position of locaiton
            //but we need to make sure that the location is inside the touch rect
            
            
            location.x = MIN(location.x, touchRect.origin.x + touchRect.size.width);
            location.x = MAX(location.x, touchRect.origin.x);
            location.y = MIN(location.y, touchRect.origin.y + touchRect.size.height);
            location.y = MAX(location.y, touchRect.origin.y);
            
        }
        touched.position = location;
        GameplayScene* scene = (GameplayScene*)[[CCDirector sharedDirector] runningScene];
        [scene updateShadowPos:touched];
    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //test gestures the user made
    Gestures result = [GestureRecognizer recognizeGestures:touchArray];
    switch (result) {
        case Press:
            NSLog(@"tag %d got pressed", touchedObjectTag);
            break;
        case Swipe:
            [self fadeInTouchRect];
        default:
            break;
    }
    
    
    //clear the object tag
    touchedObjectTag = -1;

    //clear the touch array
    [touchArray removeAllObjects];
}

@end
