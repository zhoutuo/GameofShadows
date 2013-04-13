//
//  LightSource.m
//  Game of Shadows
//
//  Created by Zhoutuo Yang on 4/2/13.
//
//

#import "LightSource.h"

@implementation LightSource

-(id) initWithProperties: (NSString*)on_name :(NSString*)off_name :(float)on_dur :(float) off_dur :(float)vertical_per {
    if(self = [super initWithFile:on_name]) {
        on_filename = [[NSString alloc] initWithString:on_name];
        off_filename = [[NSString alloc] initWithString:off_name];
        on_duration = on_dur;
        off_duration = off_dur;
        vertical_percentage = vertical_per;
        turn_on_texture = [[CCSprite alloc] initWithFile:off_name];
    }
    return self;
}


-(void) dealloc {
    [super dealloc];
    [turn_on_texture release];
    [on_filename release];
    [off_filename release];
}

-(void) execActions {
    if (on_duration > 0.0 or off_duration > 0.0) {
        //this is a fake action just used for the duration
        id on_action = [CCMoveBy actionWithDuration:on_duration position:ccp(0, 0)];
        id on_callback = [CCCallFunc actionWithTarget:self selector:@selector(turnOn)];
        id off_action = [CCMoveBy actionWithDuration:off_duration position:ccp(0, 0)];
        id off_callback = [CCCallFunc actionWithTarget:self selector:@selector(turnOff)];
        id seq = [CCSequence actions:on_action, on_callback, off_action, off_callback, nil];
        [self runAction:[CCRepeatForever actionWithAction:seq]];
    }
}

-(void) turnOn {
    isOn = true;
    [self addChild:turn_on_texture];
}

-(void) turnOff {
    isOn = false;
    [self addChild:turn_on_texture];
}

-(bool) isOn {
    return isOn;
}

-(CGRect) getInnerBoundingBox {
    CGRect innerBoundingBox;
    //init the inner bouding box
    innerBoundingBox.size.width = self.boundingBox.size.width / 2;
    innerBoundingBox.size.height = self.boundingBox.size.height / 2;
    innerBoundingBox.origin = ccpAdd(self.boundingBox.origin,
                                     ccp(self.boundingBox.size.width / 4, self.boundingBox.size.height / 4));
    return innerBoundingBox;
}


@end
