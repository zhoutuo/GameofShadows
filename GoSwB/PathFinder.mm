//
//  PathFinder.m
//  Game of Shadows
//
//  Created by Ryan Schubert on 2/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PathFinder.h"

/****************** PathFindNode <--- Object that holds node information (cost, x, y, etc.) */
@interface PathFindNode : NSObject {
@public
	int nodeX,nodeY;
	double cost;
	PathFindNode *parentNode;
}
+(id)node;
@end
@implementation PathFindNode
+(id)node
{
	return [[[PathFindNode alloc] init] autorelease];
}


@end
/************************ PathFindNode END ************************************************/




/******************************** Min Heap ************************************************/
@interface MinHeap : PathFindNode{
    int heapSize;
    NSMutableArray* q;
}
-(void)insertNode:(PathFindNode*)item;
-(bool)nodeInArray: (int)x :(int)y;
-(PathFindNode*)getMin;
-(int) count;

@end

@implementation MinHeap


-(id)init{
    
    if ([super init]) {
        q = [NSMutableArray array];
    }
    
    return self;
}

-(int) count{
    return [q count];
}


-(void) printHeap{
    PathFindNode *temp;
    for(int i =0; i < [q count]; i++){
        temp = [q objectAtIndex:i];
        NSLog(@"%f",temp->cost);
    }
    
}

-(bool)nodeInArray: (int)x :(int)y{
    PathFindNode *temp;
    for(int i =0; i < [q count]; i ++){
        temp = [q objectAtIndex:i];
        if(temp->nodeX == x && temp->nodeY == y){
            return true;
        }
    }
    return false;
}

- (void)insertNode:(PathFindNode*)item {
    
    int index;
    
    [q addObject:item];
    
    index = [q count] - 1;
    
    // Maintain heap-ness
    while(YES) {
        PathFindNode* temp;
        temp = [q objectAtIndex:index];
        
        PathFindNode* temp2;
        temp2 = [q objectAtIndex:((index - 1)/2)];
        
        if(temp->cost < temp2->cost) {
            [q exchangeObjectAtIndex:index withObjectAtIndex:((index - 1)/ 2)];
            index = (index - 1)/ 2;
        }
        else{
            break;
        }
            
    }
}

- (PathFindNode*)getMin{
    
    // Exchange the first element with the last element to save
    // the cost of moving them all forward and then re-heaping it
    PathFindNode *e;
    
    int size = [q count];
    
    if(size == 0){
        return nil;
    }
    
    [q exchangeObjectAtIndex:0 withObjectAtIndex:(size - 1)];
    
  //  [[q objectAtIndex:(size - 1)] getValue:e];
    e = [[q objectAtIndex:(size - 1)] retain];
    
    [q removeLastObject];
    
    // Now one of 0 or 1 are the next min...
    // If there are 0 or 1
    [self heapify:0];
    // Do the update to maintain heap property
    return e;
}

- (void)heapify:(int)i{

        int left, right;
        int min;
        int max_index = [q count];
    
        left = 2 * i + 1;
        right = 2 * i + 2;
        
        
        
        PathFindNode *leftNode, *rightNode, *minNode, *iNode;

        min = i;
        if(left < max_index) {
            leftNode = [q objectAtIndex:left];
            iNode = [q objectAtIndex:i];
            
            if(leftNode->cost < iNode->cost){
                min = left;
            }
        }else{
            min = i;
        }
        
        if(right < max_index) {
            rightNode = [q objectAtIndex:right];
            minNode = [q objectAtIndex:min];
            
            if(rightNode->cost < minNode->cost){
                min = right;
            }
        }
    
        if(min != i) {
            [q exchangeObjectAtIndex:i withObjectAtIndex:min];
            [self heapify:min];
        }
}


@end


/******************************* Min Heap END *****************************************/






@implementation PathFinder



-(id)init:(int)MonsterSizeIn :(int)DeviceWidthIn :(int)DeviceHeightIn :(int[768][1024])mapIn{
    if(self = [super init]){
        monsterSize = MonsterSizeIn;
        
        deviceHeight = DeviceHeightIn;
        deviceWidth = DeviceWidthIn;
        
        map = mapIn;
       
        
    }
    return self;
}



//if the space is blocked then it will return true
-(bool)spaceIsBlocked:(int)x :(int)y{
 //   NSLog(@"X: %d  Y: %d", x,y);
    if(map[y][x] < monsterSize){
 //      NSLog(@"Doesn't Fit - Current Size %d", map[y][x]);
        return true;
    }else{
  //      NSLog(@"Fits - Current Size %d", map[y][x]);
        return false;
    }
    
}


//simple distance formula 
-(double) heuristic:(int)startX :(int)startY :(int)endX :(int) endY{
    double x = pow((endX - startX),2);
    double y = pow((endY - startY),2);
    
    
    return sqrt( x+y );
    
}


-(void)findPath:(CGPoint)start :(CGPoint)end :(NSMutableArray *)path
{
	//find path function. takes a starting point and end point and performs the A-Star algorithm
	//to find a path, if possible. Once a path is found it can be traced by following the last
	//node's parent nodes back to the start
    //(int)startX :(int)startY :(int)endX :(int)endY
    
    int startX = (int)start.x;
    int startY = (int)start.y;
    int endX = (int)end.x;
    int endY = (int)end.y;
    
    
	
    NSLog(@"Start Find Path");
    
    int x,y;
	int newX,newY;
	int currentX,currentY;
    CGPoint tempLoc;
    
    MinHeap *openListMin = [[[MinHeap alloc] init] autorelease];
    
    
    if([self spaceIsBlocked:endX :endY] || [self spaceIsBlocked:startX :startY ]){
        NSLog(@"No Path Found :(");
        return;
    }
	
	if((startX == endX) && (startY == endY)){
        NSLog(@"Path Found!");
        tempLoc.x = endX;
        tempLoc.y = endY;
        [path addObject: [NSValue valueWithCGPoint:tempLoc]];
        
		return; //make sure we're not already there
    }

    //n is empty
    //o is open list
    //c is closed list
    for(int i=0; i < 768;i ++){
        for(int j=0; j < 1024; j ++){
            ocList[i][j] = 'n';
        }
    }
    
	
	PathFindNode *currentNode = nil;
	PathFindNode *aNode = nil;
	
	//create our initial 'starting node', where we begin our search
	PathFindNode *startNode = [PathFindNode node];
	startNode->nodeX = startX;
	startNode->nodeY = startY;
	startNode->parentNode = nil;
	startNode->cost = 0.0;
    
	//add it to the open list to be examined
    [openListMin insertNode:startNode];
    ocList[startY][startX] = 'o';
    
	
	while([openListMin count] > 0)
	{
        currentNode = [openListMin getMin];

        ocList[currentNode->nodeY][currentNode->nodeX] = 0;
		
		if((currentNode->nodeX == endX) && (currentNode->nodeY == endY))
		{
			//if the lowest cost node is the end node, we've found a path
			
			//********** PATH FOUND ********************
            
            	aNode = currentNode->parentNode;
            		while(aNode->parentNode != nil)
            		{
                        
                        tempLoc.x = aNode->nodeX;
                        tempLoc.y = aNode->nodeY;
                      //  NSLog(@"X: %f  Y: %f", tempLoc.x,tempLoc.y);
                        [path addObject: [NSValue valueWithCGPoint:tempLoc]];
                                          
                        aNode = aNode->parentNode;
            		}
            
            
            
            NSLog(@"Path Found! You Go Gurl!");
			return;
			//*****************************************//
		}
		else
		{
            ocList[currentNode->nodeY][currentNode->nodeX] = 'c';
            
			//lets keep track of our coordinates:
			currentX = currentNode->nodeX;
			currentY = currentNode->nodeY;
			
			//check all the surrounding nodes/tiles:
			for(y=-1;y<=1;y++){
                
				newY = currentY+y;
				for(x=-1;x<=1;x++){
                    
					newX = currentX+x;
                    
                    //avoid 0,0
					if(y || x) {
                        
						// bounds check 
						if((newX>=0)&&(newY>=0)&&(newX<1024)&&(newY<768)){
                            
							//if the node isn't in the open list...
                            if(ocList[newY][newX] == 'n'){
                                
								//and its not in the closed list...
                                if(ocList[newY][newX] == 'n'){
                                    
									//and the space isn't blocked
									if(![self spaceIsBlocked: newX :newY]){
                                        
										//then add it to our open list and figure out
										//the 'cost':
										aNode = [PathFindNode node];
										aNode->nodeX = newX;
										aNode->nodeY = newY;
										aNode->parentNode = currentNode;
										aNode->cost = currentNode->cost;
										
										//distance, added to the existing cost
										aNode->cost += [self heuristic:newX :newY :endX :endY];
										
                                        [openListMin insertNode:aNode];
                                        ocList[newY][newX] = 'o';
										
									}
								}
							}
						}
					}
				}
			}
		}
	}
	//**** NO PATH FOUND *****
    NSLog(@"No Path Found :(");
    return;
}
@end
