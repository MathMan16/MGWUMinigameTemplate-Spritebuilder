//
//  MGWUMinigameTemplate
//
//  Created by Zachary Barryte on 6/6/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "MyMinigame.h"
#import "HarryThamanblock.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "HarryThamanRock.h"
#import "HarryThamanGem.h"
@implementation MyMinigame{

    CCPhysicsNode *_physicsNode;
//    CCNode *_collisionNode;
    NSArray *_currentScene;
    NSArray *_nextScene;
    int _columns;
    int _rows;
    CCTime _startingDelay;
    CCTime _delayDecrement;
    CCTime _latency;
    CGPoint _touchStart;
    CGPoint _touchDelta;
    bool _jumpStarted;
    float _sliderDelta;
    BOOL _endGame;
//    NSMutableArray *_touchList;

    block *_currentBlock;

    float _upperEdge;
    float _lowerEdge;
    float _rightEdge;
    float _leftEdge;
    float _maxHorizontalVelocity;
    float _maxVerticalVelociy;
    float _finalScore;

}

-(id)init {
    if ((self = [super init])) {
        // Initialize any arrays, dictionaries, etc in here
        self.instructions = @"Swipe left/right to move, swipe up to fly. Collect the gems for points and don't get stuck in the walls!";
    }
    return self;
}

-(void)didLoadFromCCB {
//    _physicsNode.debugDraw = TRUE;
    _physicsNode.collisionDelegate = self;
//    _touchList = [NSMutableArray new];
    // Set up anything connected to Sprite Builder here
    self.userInteractionEnabled = TRUE;
//    self.multipleTouchEnabled = TRUE;
    // We're calling a public method of the character that tells it to jump!
    _latency = 0;
    _startingDelay = 5.25;
    _delayDecrement = .25;
    _columns = 15;
    _rows = 9;
    _jumpStarted = false;
    _upperEdge = 1;
    _lowerEdge = 0;
    _rightEdge = 1;
    _leftEdge = 0;
    _maxHorizontalVelocity = 150;
    _maxVerticalVelociy = 100;
    _finalScore = 0;
    _endGame = FALSE;
//    _collisionNode.physicsBody.collisionMask = @[];
//    [_touchList addObject:(touch*)[CCBReader load:@"touch"]];
}

-(void)onEnter {
    [super onEnter];
    // _currentScene = [self buildStage];
    // Create anything you'd like to draw here
    for (int i = 0; i <= _columns; i++) {
        block *_tempBlock = (block*)[CCBReader load:@"Block"];
        _tempBlock.position = ccp(39.f*i, 0);
        [_physicsNode addChild:_tempBlock];
    }
}

-(void)update:(CCTime)delta {
    // Called each update cycle
    // n.b. Lag and other factors may cause it to be called more or less frequently on different devices or sessions
    // delta will tell you how much time has passed since the last cycle (in seconds)
    _latency += delta;
    if (_touchDelta.y > 0) {
        _jumpStarted = TRUE;
    }
    else{
        _jumpStarted = FALSE;
    }
    _sliderDelta = _touchDelta.x;
    if (_latency >= _startingDelay/2.0 && _nextScene == nil){
        _nextScene = [self buildStage];
        [self displayStage:_nextScene Faded:YES];
    }
    if (_latency >= _startingDelay)
    {
        _latency = 0;
        _startingDelay -= _delayDecrement;
        [self clearStage:_currentScene];
        _currentScene = _nextScene;
        _nextScene = nil;
        [self displayStage:_currentScene Faded:NO];
        _finalScore += 1;
    }
    if (_startingDelay <= 0||_finalScore >= 100||_endGame) {
        [self endMinigame];
    }
    if (_jumpStarted) {
        [self.hero.physicsBody applyForce:ccp(0, 1500)];
    }
    [self.hero.physicsBody applyForce:ccp(10*_sliderDelta, 0)];
    if (_sliderDelta == 0) {
        self.hero.physicsBody.velocity = ccp(0, self.hero.physicsBody.velocity.y);
    }
    [self physicsLimit];
//    _collisionNode.position = self.hero.position;
}

-(void)physicsLimit{
    float _epsilon = .0001;
    if (self.hero.position.x < _leftEdge) {
        self.hero.position = ccp(_leftEdge + _epsilon,self.hero.position.y);
    }
    if (self.hero.position.x > _rightEdge) {
        self.hero.position = ccp(_rightEdge - _epsilon,self.hero.position.y);
    }
    if (self.hero.position.y < _lowerEdge) {
        self.hero.position = ccp(self.hero.position.x,_lowerEdge + _epsilon);
    }
    if (self.hero.position.y > _upperEdge) {
        self.hero.position = ccp(self.hero.position.x,_upperEdge - _epsilon);
        self.hero.physicsBody.velocity = ccp(self.hero.physicsBody.velocity.x, 0);
    }
    if (abs(self.hero.physicsBody.velocity.x) > _maxHorizontalVelocity){
        self.hero.physicsBody.velocity = ccp((self.hero.physicsBody.velocity.x * _maxHorizontalVelocity / abs(self.hero.physicsBody.velocity.x)), self.hero.physicsBody.velocity.y);
    }
    if (abs(self.hero.physicsBody.velocity.y > _maxVerticalVelociy)) {
        self.hero.physicsBody.velocity = ccp(self.hero.physicsBody.velocity.x, _maxVerticalVelociy);
    }
}

-(void)displayStage:(NSArray *)stage Faded:(BOOL)faded {
    float _opacity;
    if (faded){
        _opacity = 0.5;
    }
    else{
        _opacity = 1.0;
    }
    for (int i = 0; i < [stage count]; i++)
    {
        block *_tempBlock = [stage objectAtIndex: i];
        _tempBlock.opacity = _opacity;
        if (_opacity == 0.5) {
            _tempBlock.physicsBody.collisionMask = @[];
        }
        else{
            _tempBlock.physicsBody.collisionMask = nil;
            NSString *className = NSStringFromClass([_tempBlock class]);
            BOOL _leftBound = (self.hero.position.x*568 > (_tempBlock.position.x - 7));
            BOOL _rightBound = (self.hero.position.x*568 < (_tempBlock.position.x + 46));
            BOOL _lowerBound = (self.hero.position.y*320 > (_tempBlock.position.y - 7));
            BOOL _upperBound = (self.hero.position.y*320 < (_tempBlock.position.y + 46));
            if ([className  isEqual: @"block"]&&_leftBound&&_rightBound&&_lowerBound&&_upperBound){
                _endGame = TRUE;
            }
        }
    }
}

-(void)clearStage:(NSArray *)stage{
    for (int i = 0; i < [stage count]; i++) {
        block *_tempBlock = [stage objectAtIndex:i];
        [_tempBlock removeFromParent];
    }
}

-(NSArray*)buildStage{
    int _stageNum = (arc4random() % 5) + 1;
    //_stageNum = 3;//!!!
    if (_stageNum == 1) {
        return [self buildPyramid];
    }
    if (_stageNum == 2) {
        return [self buildColumns];
    }
    if (_stageNum == 3){
        return [self buildCheckers];
    }
    if (_stageNum == 4){
        return [self buildTower];
    }
    if (_stageNum == 5){
        return [self buildHazards];
    }
    return nil;
}

-(NSArray*)buildPyramid{
    //Build a number of pyramids of certain sides
    //Options: One big, Two Medium, Three Small, Two Tiny, One Medium
    //Coins at the tops, sides or middle
    NSMutableArray *_tempScene = [NSMutableArray new];
    int _numPyramids = 1 + (arc4random()%2);
    //One pyramid generation:
    if(_numPyramids == 1){
        int _pyramidSize;
        _pyramidSize = 5 + (arc4random()%4);
        int _pyramidLocation = arc4random() % 9;
        for (int j = 1; j <= _pyramidSize - 1; j++) {
            for (int i = 0; i <= _pyramidSize - j + 1; i++) {
                [_tempScene addObject:(block*)[CCBReader load:@"Block"]];
                int _arrayLength = [_tempScene count] - 1;
                block *_tempBlock = [_tempScene objectAtIndex:_arrayLength];
                _tempBlock.position = ccp(39*(i+_pyramidLocation+(.5*j)), 39*j);
                [_physicsNode addChild:_tempBlock];
            }
            CGPoint _pyramidPeak;
            _pyramidPeak = ccp(39*(1 + _pyramidLocation + (_pyramidSize/2.f)), 39*(_pyramidSize + .5));
            [_tempScene addObject:(Gem*)[CCBReader load:@"Gem"]];
            int _arrayLength = [_tempScene count] - 1;
            Gem *_tempGem = [_tempScene objectAtIndex:_arrayLength];
            _tempGem.position = _pyramidPeak;
            [_physicsNode addChild:_tempGem];
        }
    }
    //Two Pyramid Generation:
    if(_numPyramids == 2){
        int _pyramidLocation1 = arc4random() % 6;
        int _pyramidSize1 = 3 + (arc4random() % 5);
        int _pyramidSize2 = arc4random() % 6;
        int _tempVarience = (_columns - _pyramidLocation1 - _pyramidSize1 - _pyramidSize2 - 2);
        if (_tempVarience == 0) {
            _tempVarience = 1;
        }
        int _pyramidLocation2 = (2 + _pyramidLocation1) + _pyramidSize1 + (arc4random() % _tempVarience);//!!!Look for issues here
        //Generate the first pyramid
        for (int j = 1; j <= _pyramidSize1 + 1; j++){
            for (int i = 0; i <= _pyramidSize1 - j + 1; i++) {
                [_tempScene addObject:(block*)[CCBReader load:@"Block"]];
                int _arrayLength = [_tempScene count] - 1;
                block *_tempBlock = [_tempScene objectAtIndex:_arrayLength];
                _tempBlock.position = ccp(39*(i+_pyramidLocation1+(.5*j)), 39*j);
                [_physicsNode addChild:_tempBlock];
            }
        }
        //Generate the second pyramid
        for (int j = 1; j <= _pyramidSize2 + 1; j++) {
            for (int i = 0; i <= _pyramidSize2 - j + 1; i++) {
                [_tempScene addObject:(block*)[CCBReader load:@"Block"]];
                block *_tempBlock = [_tempScene objectAtIndex:[_tempScene count] - 1];
                _tempBlock.position = ccp(39*(i+_pyramidLocation2+(.5*j)), 39*j);
                [_physicsNode addChild:_tempBlock];
            }
        }
        CGPoint _pyramidPeak1;
        CGPoint _pyramidPeak2;
        _pyramidPeak1 = ccp(39*(1 + _pyramidLocation1 + (_pyramidSize1/2.f)), 39*(_pyramidSize1 + 2.5));
        _pyramidPeak2 = ccp(39*(1 + _pyramidLocation2 + (_pyramidSize2/2.f)), 39*(_pyramidSize2 + 2.5));
        [_tempScene addObject:(Gem*)[CCBReader load:@"Gem"]];
        int _arrayLength = [_tempScene count] - 1;
        Gem *_tempGem = [_tempScene objectAtIndex:_arrayLength];
        _tempGem.position = _pyramidPeak1;
        [_physicsNode addChild:_tempGem];
        [_tempScene addObject:(Gem*)[CCBReader load:@"Gem"]];
        Gem *_tempGem2 = [_tempScene objectAtIndex:_arrayLength +1];
        _tempGem2.position = _pyramidPeak2;
        [_physicsNode addChild:_tempGem2];
    }
    return _tempScene;
}

-(NSArray*)buildColumns{
    //Build a number of towers of random sizes
    //Coins in the gaps
    NSMutableArray *_tempScene = [NSMutableArray new];
    for (int i = 0; i <= _columns; i++)
    {
        if(arc4random() % 4 == 0){
            int _tempHeight = 3 + arc4random() % 4;
            for (int j = 1; j <= _tempHeight; j++)
            {
                [_tempScene addObject:(block*)[CCBReader load:@"Block"]];
                int _arrayLength = [_tempScene count] - 1;
                block *_tempBlock = [_tempScene objectAtIndex:_arrayLength];
                _tempBlock.position = ccp(39*i, 39*j);
                [_physicsNode addChild:_tempBlock];
                //Generate a gem on top of the pilar
                if ((arc4random()%8)==0) {
                    [_tempScene addObject:(Gem*)[CCBReader load:@"Gem"]];
                    int _arrayLength = [_tempScene count] - 1;
                    Gem *_tempGem = [_tempScene objectAtIndex:_arrayLength];
                    _tempGem.position = ccp(39*(i + .5), 39*(_tempHeight + 1.5));
                    [_physicsNode addChild:_tempGem];
                }
            }
        }
        //Generate a gem next to the pilar
        else if (arc4random() % 10 == 0){
            [_tempScene addObject:(Gem*)[CCBReader load:@"Gem"]];
            int _arrayLength = [_tempScene count] - 1;
            Gem *_tempGem = [_tempScene objectAtIndex:_arrayLength];
            _tempGem.position = ccp(39*(i+.5), 39*((arc4random()%3)+1.5));
            [_physicsNode addChild:_tempGem];
        }
    }
    return _tempScene;
}

-(NSArray*)buildCheckers{
    //Build a checkerboard with small, medium or large checks
    //Small spaces has large hollow in the middle
    //Coins are located in empty spaces
    int _gridSize;
    NSMutableArray *_tempScene = [NSMutableArray new];
    _gridSize = (arc4random() % 3) + 1;
    int _leftSide;
    int _bottomEdge;
    int _width;
    int _height;
    _leftSide = 6 + (arc4random() % 2);
    _bottomEdge = 3 +(arc4random() % 2);
    _width = 5 + (arc4random() % 2);
    _height = 4 + (arc4random() % 2);
    
    for (int i = 0; i < _columns; i++){
        for (int j = 1; j < _rows; j++) {
            if ((_gridSize == 1) && (i > _leftSide) && (i < (_leftSide + _width)) && (j > _bottomEdge) && (j < (_bottomEdge + _height))) {
                //Do Nothing
            }
            else if ((_gridSize == 1)&&((((i == _leftSide) || (i == _leftSide + _width))&&((_bottomEdge <= j)&&(j <= _bottomEdge + _height)))||(((j == _bottomEdge) || (j ==_bottomEdge + _height))&&((_leftSide <= i)&&(i <= _leftSide + _width))))){
                [_tempScene addObject:(block*)[CCBReader load:@"Block"]];
                int _arrayLength = [_tempScene count] - 1;
                block *_tempBlock = [_tempScene objectAtIndex:_arrayLength];
                _tempBlock.position = ccp(39*i, 39*j);
                [_physicsNode addChild:_tempBlock];
            }
            else if ((i % (_gridSize *2)) < _gridSize == (j % (_gridSize * 2)) < _gridSize) {
                [_tempScene addObject:(block*)[CCBReader load:@"Block"]];
                int _arrayLength = [_tempScene count] - 1;
                block *_tempBlock = [_tempScene objectAtIndex:_arrayLength];
                _tempBlock.position = ccp(39*i, 39*j);
                [_physicsNode addChild:_tempBlock];
            }
            else{
                if (arc4random()%20 == 0) {
                    [_tempScene addObject:(Gem*)[CCBReader load:@"Gem"]];
                    int _arrayLength = [_tempScene count] - 1;
                    Gem *_tempGem = [_tempScene objectAtIndex:_arrayLength];
                    _tempGem.position = ccp(39.f*(i+.5), 39.f*(j+.5));
                    [_physicsNode addChild:_tempGem];
                }
            }
        }
    }
    return _tempScene;
}

-(NSArray*)buildTower{
    NSMutableArray *_tempScene = [NSMutableArray new];
    int _leftSide = 2 + (arc4random() % 5);
    int _width = 3 + (arc4random() % 4);
    int _floors = 1 + (arc4random() % 4);
    if (_leftSide + _width >= _columns) {
        _width = _columns - _leftSide - 1;
    }
    for (int i = 0; i <= _columns; i ++) {
        if ((i >= _leftSide)&&(i<=_leftSide+_width)) {
            for (int j = 1; j <= _floors*2 + 1; j++) {
                if ((i == _leftSide)||(i == _leftSide + _width)||((j%2==0))) {
                    [_tempScene addObject:(block*)[CCBReader load:@"Block"]];
                    int _arrayLength = [_tempScene count] - 1;
                    block *_tempBlock = [_tempScene objectAtIndex:_arrayLength];
                    _tempBlock.position = ccp(39*i, 39*j);
                    [_physicsNode addChild:_tempBlock];
                }
                else if (arc4random()%12 == 0){
                    [_tempScene addObject:(Gem*)[CCBReader load:@"Gem"]];
                    int _arrayLength = [_tempScene count] - 1;
                    Gem *_tempGem = [_tempScene objectAtIndex:_arrayLength];
                    _tempGem.position = ccp(39.f*(i+.5), 39.f*(j+.5));
                    [_physicsNode addChild:_tempGem];
                }
            }
        }
    }
    
    //A multi layered towers with possible hazards off to the sides
    return _tempScene;
}

-(NSArray*)buildHazards{
    int _transitionPoint = 5 + (arc4random()%6);
    int _upperHeight = 3 + (arc4random() % 4);
    NSMutableArray *_tempScene = [NSMutableArray new];
    for(int i = 0; i < _columns; i ++){
        int _tempHeight = 0;
        if(i == _transitionPoint - 1){
            [_tempScene addObject:(block*)[CCBReader load:@"Block"]];
            int _arrayLength = [_tempScene count] - 1;
            block *_tempBlock = [_tempScene objectAtIndex:_arrayLength];
            _tempBlock.position = ccp(39*(i), 39);
            [_physicsNode addChild:_tempBlock];
            _tempHeight = 1;
        }
        if (i == _transitionPoint) {
            for (int j = 1; j <= (_upperHeight/2) + 1; j++) {
                [_tempScene addObject:(block*)[CCBReader load:@"Block"]];
                int _arrayLength = [_tempScene count] - 1;
                block *_tempBlock = [_tempScene objectAtIndex:_arrayLength];
                _tempBlock.position = ccp(39*(i), j*39);
                [_physicsNode addChild:_tempBlock];
            }
            _tempHeight = (_upperHeight/2)+2;
        }
        if (i == _transitionPoint + 1) {
            for (int j = 1; j < _upperHeight; j++) {
                [_tempScene addObject:(block*)[CCBReader load:@"Block"]];
                int _arrayLength = [_tempScene count] - 1;
                block *_tempBlock = [_tempScene objectAtIndex:_arrayLength];
                _tempBlock.position = ccp(39*(i), j*39);
                [_physicsNode addChild:_tempBlock];
            }
            _tempHeight = _upperHeight - 1;
        }
        if (i > _transitionPoint + 1) {
            for (int j = 1; j <= _upperHeight; j++) {
                [_tempScene addObject:(block*)[CCBReader load:@"Block"]];
                int _arrayLength = [_tempScene count] - 1;
                block *_tempBlock = [_tempScene objectAtIndex:_arrayLength];
                _tempBlock.position = ccp(39*(i), j*39);
                [_physicsNode addChild:_tempBlock];
            }
            _tempHeight = _upperHeight;
        }
        if (arc4random()%10 == 0) {
            [_tempScene addObject:(Gem*)[CCBReader load:@"Gem"]];
            int _arrayLength = [_tempScene count] - 1;
            Gem *_tempGem = [_tempScene objectAtIndex:_arrayLength];
            _tempGem.position = ccp((i+.5)*39.f, (_tempHeight + 2.5)*39.f);
            [_physicsNode addChild:_tempGem];
        }
    }
    //A two level area with spikes and falling rocks
    //Coins located randomly
    return _tempScene;
}


-(void)endMinigame {
    // Be sure you call this method when you end your minigame!
    // Of course you won't have a random score, but your score *must* be between 1 and 100 inclusive
    NSLog(@"%f",_finalScore);
    [self endMinigameWithScore:_finalScore];
}

-(void)boost {
    CGPoint Force = ccp(0, 8000);
    [self.hero.physicsBody applyForce:Force];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchLocation = [touch locationInNode:self];
//    [self addTouchPoint:touchLocation];
        _touchStart = touchLocation;
}


-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchLocation = [touch locationInNode:self];
    _touchDelta = ccp(touchLocation.x - _touchStart.x, touchLocation.y - _touchStart.y);
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    _touchDelta = ccp(0, 0);
}

/*-(void)addTouchPoint:(CGPoint)point {
    [_touchList addObject:(touch*)[CCBReader load:@"touch"]];
    int _arrayLength = [_touchList count] - 1;
    touch *_tempTouch = [_touchList objectAtIndex:_arrayLength];
    _tempTouch.position = point;
}*/

/*-(touch*)findNearestTouch:(CGPoint)point{//!!! Update to return index
    touch *_closestTouch = [_touchList objectAtIndex:0];
    float _minDistance = sqrt(pow((_closestTouch.position.x - point.x),2.f) + pow((_closestTouch.position.x- point.x),2.f));
    for (int i = 1; i < [_touchList count]; i++) {
        touch *_tempTouch = [_touchList objectAtIndex:i];
        int _tempDistance = sqrt(pow((_tempTouch.position.x - point.x),2.f)+pow((_tempTouch.position.x - point.x),2.f));
        if (_tempDistance < _minDistance) {
            _minDistance = _tempDistance;
            _closestTouch = _tempTouch;
        }
    }
    return _closestTouch;
}*/

- (void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair Gem:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    [nodeA removeFromParent];
    _finalScore += 3;
}

// DO NOT DELETE!
-(MyCharacter *)hero {
    return (MyCharacter *)self.character;
}
// DO NOT DELETE!



@end
