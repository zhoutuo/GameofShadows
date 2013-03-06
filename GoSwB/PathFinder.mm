//
//  PathFinder.m
//  Game of Shadows
//
//  Created by Ryan Schubert on 2/27/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "PathFinder.h"
#import "ShadowsLayer.h"

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
/*********************************************************************************/


/******************************** Min Heap *****************************************/
@interface MinHeap : PathFindNode{
    int heapSize;
    NSMutableArray* heap;
}

@end

@implementation MinHeap


-(id) init{
    if(self = [super init]){
        heap = [[NSMutableArray alloc] init];
        
    }
    return self;
}

-(void)insert:(PathFindNode*) inNode{
    heapSize++;
    heap[heapSize] = inNode;
    //heapify
    
}

-(void) heapify{
    
}

-(void)siftDown: (int)start :(int)end{
    int root = start;
    
    while(root * 2 + 1 <= end){
        int child = root * 2 + 1;
        int swap = root;
        
        //check if root is smaller than left child
    //    PathFindNode* swap = heap[swap];
     //   if(heap[swap]-> cost){
            
      //  }
    }
}


-(void) swap: (int)a :(int)b{
    PathFindNode* temp = heap[a];
    
    heap[a] = heap[b];
    heap[b] = temp;
}

-(PathFindNode*) getMin{
    if(heapSize > 0){
        return heap[0];
        //heapify
    }else{
        return NULL;
    }
}


@end


/*********************************************************************************/






@implementation PathFinder



-(id)initSize:(int)MonsterSizeIn :(int)DeviceWidthIn :(int)DeviceHeightIn :(int[768][1024])mapIn{
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




-(PathFindNode*)nodeInArray:(NSMutableArray*)a withX:(int)x Y:(int)y
{
	//Quickie method to find a given node in the array with a specific x,y value
	NSEnumerator *e = [a objectEnumerator];
	PathFindNode *n;
	
	while((n = [e nextObject]))
	{

		 if((n->nodeX == x) && (n->nodeY == y))
		{
			return n;
		}
	}
	
	return nil;
}




-(PathFindNode*)lowestCostNodeInArray:(NSMutableArray*)a
{
	//Finds the node in a given array which has the lowest cost
	PathFindNode *n, *lowest;
	lowest = nil;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"cost" ascending:YES];
    [a sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	NSEnumerator *e = [a objectEnumerator];
	int count =0;
	while((n = [e nextObject]))
	{
    //    NSLog(@"cost is: %d", n->cost);
		if(lowest == nil)
		{
			lowest = n;
            // return lowest;
		}
		else
		{
			if(n->cost < lowest->cost)
			{
				lowest = n;
                NSLog(@"The count is: %d",count);
                return lowest;
			}
		}
        count++;
	}
  //  NSLog(@"The end count is: %d",count);
  //  NSLog(@"end cost is: %d", lowest->cost);
	return lowest;
}

//simple distance formula 
-(double) heuristic:(int)startX :(int)startY :(int)endX :(int) endY{
    double x = pow((endX - startX),2);
    double y = pow((endY - startY),2);
    
    
    return sqrt( x+y );
    
}


-(NSMutableArray*)findPath:(int)startX :(int)startY :(int)endX :(int)endY
{
	//find path function. takes a starting point and end point and performs the A-Star algorithm
	//to find a path, if possible. Once a path is found it can be traced by following the last
	//node's parent nodes back to the start
	
    NSLog(@"start find path");
    
    
    NSMutableArray *path;    
	int x,y;
	int newX,newY;
	int currentX,currentY;
	NSMutableArray *openList, *closedList;
    CGPoint tempLoc;
    
    path = [NSMutableArray array];
    
    if([self spaceIsBlocked:endX :endY ]){
        return path;
    }
	
	if((startX == endX) && (startY == endY)){
        NSLog(@"Path Found!");
        tempLoc.x = endX;
        tempLoc.y = endY;
        [path addObject: [NSValue valueWithCGPoint:tempLoc]];
        
		return path; //make sure we're not already there
    }
	
	openList = [NSMutableArray array]; //array to hold open nodes
    
	closedList = [NSMutableArray array]; //array to hold closed nodes
    
    

	
	PathFindNode *currentNode = nil;
	PathFindNode *aNode = nil;
	
	//create our initial 'starting node', where we begin our search
	PathFindNode *startNode = [PathFindNode node];
	startNode->nodeX = startX;
	startNode->nodeY = startY;
	startNode->parentNode = nil;
	startNode->cost = 0.0;
	//add it to the open list to be examined
	[openList addObject: startNode];
	
	while([openList count])
	{
		//while there are nodes to be examined...
		
		//get the lowest cost node so far:
		//currentNode = [self lowestCostNodeInArray: openList];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"cost" ascending:YES];
        [openList sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        currentNode = openList[0];
      //  NSLog(@"Current Cost: %f",currentNode->cost);
        
		
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
            
            
            
            NSLog(@"Path Found!");
			return path;
			//*****************************************//
		}
		else
		{
           // NSLog(@"Made it to the else");
			//...otherwise, examine this node.
			//remove it from open list, add it to closed:
			[closedList addObject: currentNode];
			[openList removeObject: currentNode];
			
         //   NSLog(@"size of openlist: %d", openList.count);
            
			//lets keep track of our coordinates:
			currentX = currentNode->nodeX;
			currentY = currentNode->nodeY;
			
			//check all the surrounding nodes/tiles:
			for(y=-1;y<=1;y++)
			{
				newY = currentY+y;
				for(x=-1;x<=1;x++)
				{
					newX = currentX+x;
					if(y || x) //avoid 0,0
					{
						// bounds check 
						if((newX>=0)&&(newY>=0)&&(newX<1024)&&(newY<768))
						{
							//if the node isn't in the open list...
							if(![self nodeInArray: openList withX: newX Y:newY])
							{
								//and its not in the closed list...
								if(![self nodeInArray: closedList withX: newX Y:newY])
								{
									//and the space isn't blocked
									if(![self spaceIsBlocked: newX :newY])
									{
										//then add it to our open list and figure out
										//the 'cost':
										aNode = [PathFindNode node];
										aNode->nodeX = newX;
										aNode->nodeY = newY;
										aNode->parentNode = currentNode;
										//aNode->cost = currentNode->cost + 1.0;
										
										
										//distance, added to the existing cost
										aNode->cost += [self heuristic:newX :newY :endX :endY];
										
										[openList addObject: aNode];
										
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
    return path;
}
@end
