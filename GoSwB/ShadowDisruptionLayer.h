//
//  ShadowDisruptionLayer.h
//  Game of Shadows
//
//  Created by Ludovic Lang on 3/8/13.
//
//

#import <Foundation/Foundation.h>

#define DEVICE_WIDTH 1024
#define DEVICE_HEIGHT 768
#define LIGHT_SOURCE_DEPTH 5
@interface ShadowDisruptionLayer : CCLayer{

    bool lightSourceMap[DEVICE_HEIGHT][DEVICE_WIDTH];
}
-(void) addLightSource : (CCSprite*) lightSource;
-(bool) checkIfInLight: (int)xcoor :(int) ycoor;

@end