//
//  ShadowDisruptionLayer.m
//  Game of Shadows
//
//  Created by Ludovic Lang on 3/8/13.
//
//

#import "GameplayLayer.h"
#import "ShadowDisruptionLayer.h"
#import "Globals.h"

@implementation ShadowDisruptionLayer

-(id)init{
    if (self = [super init]) {
        //load the light source information from plist
        NSDictionary* levelObjects = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"levelObjects" ofType:@"plist"]];
        //get the current level
        NSString* level = [NSString stringWithFormat: @"Level %d",currentLevel];
        //get the lights
        NSArray* lights = [[levelObjects objectForKey: level] objectForKey:@"Lights"];
        for(NSDictionary* lightSource in lights){
            //get the on_filename
            NSString* on_name = [NSString stringWithFormat:@"%@.png", [lightSource objectForKey:@"on_filename"]];
            //get the off_name
            NSString* off_name = [NSString stringWithFormat:@"%@.png", [lightSource objectForKey:@"off_filename"]];
            //get the on and off_duration
            float on_duration = [[lightSource objectForKey:@"on_duration"] floatValue];
            float off_duration = [[lightSource objectForKey:@"off_duration"] floatValue];
            LightSource* source = [[[LightSource alloc] initWithProperties:on_name :off_name :on_duration :off_duration] autorelease];
            //get the initial position
            [source setPosition:ccp([[lightSource objectForKey:@"origin_x"] floatValue],
                                               [[lightSource objectForKey:@"origin_y"] floatValue])];
            [self addChild:source];
            //execute actions of light source
            [source execActions];
            
        }
    }
    return self;
}


-(bool) checkIfInLight:(int)ycoor :(int)xcoor {
    CGPoint point = ccp(xcoor, ycoor);
    //iterate all elements of the light sources
    for (LightSource* cur in self.children) {
        if ([cur isOn] and CGRectContainsPoint([cur getInnerBoundingBox], point)) {
            return true;
        }
    }
    return false;
}



@end
