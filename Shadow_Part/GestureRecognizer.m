//
//  GestureRecognizer.m
//  Shadow_Part
//
//  Created by Zhoutuo Yang on 2/11/13.
//
//

#import "GestureRecognizer.h"

@implementation GestureRecognizer

+(Gestures) recognizeGestures: (CCArray*) locations {
    if(locations.count == 1) {
        return Press;
    } else {
        return Swipe;
    }
}

@end
