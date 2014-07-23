//
//  MGWUMinigameTemplate
//
//  Created by Zachary Barryte on 6/6/14.
//  Copyright 2014 Apportable. All rights reserved.
//

#import "MyMinigame.h"
#import "block.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation MyMinigame{

CCPhysicsNode *_physicsNode;
NSArray *_currentScene;
NSArray *_nextScene;
int _columns;
int _rows;
CCTime _startingDelay;
CCTime _delayDecrement;
CCTime _latency;
CGPoint _touchStart;
bool _jumpStarted;
float _sliderDelta;

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
        self.instructions = @"Swipe left/right on the left half of the screen to move. Press on the right half of the screen to move up.  Don't get caught in the middle of the blocks when they turn solid!";
    }
    return self;
}

-(void)didLoadFromCCB {
    NSLog(@"didLoadFromCCB");
    // Set up anything connected to Sprite Builder here
    self.userInteractionEnabled = TRUE;
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
    
}

-(void)onEnter {
    NSLog(@"onEnter");
    [super onEnter];
    // _currentScene = [self buildStage];
    // Create anything you'd like to draw here
}

-(void)update:(CCTime)delta {
    // Called each update cycle
    // n.b. Lag and other factors may cause it to be called more or less frequently on different devices or sessions
    // delta will tell you how much time has passed since the last cycle (in seconds)
    _latency += delta;
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
        _finalScore += 5;
    }
    if (_startingDelay <= 0) {
        [self endMinigameWithScore:100];
    }
    if (_jumpStarted) {
        [self.hero.physicsBody applyForce:ccp(0, 10000)];
    }
    [self.hero.physicsBody applyForce:ccp(100*_sliderDelta, 0)];
    [self physicsLimit];
    NSLog(@"%f",self.hero.position.x);
}

-(void)physicsLimit{
    float _epsilon = .000001;
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
    int _stageNum = (arc4random() % 2/*5*/) + /*1*/ 2;
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
    NSLog(@"Pyramid");
    return _nextScene;
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
            }
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
    for (int i = 0; i < _columns; i++){
        for (int j = 0; j < _rows; j++) {
            if ((i % (_gridSize *2)) < _gridSize == (j % (_gridSize * 2)) < _gridSize) {
                [_tempScene addObject:(block*)[CCBReader load:@"Block"]];
                int _arrayLength = [_tempScene count] - 1;
                block *_tempBlock = [_tempScene objectAtIndex:_arrayLength];
                _tempBlock.position = ccp(39*i, 39*j);
                [_physicsNode addChild:_tempBlock];
            }
        }
    }
    return _tempScene;
}

-(NSArray*)buildTower{
    //A multi layered towers with possible hazards off to the sides
    //Coins located in the levels of the tower
    NSLog(@"Tower");
    return _nextScene;
}

-(NSArray*)buildHazards{
    //A two level area with spikes and falling rocks
    //Coins located randomly
    NSLog(@"Hazards");
    return _nextScene;
}


-(void)endMinigame {
    // Be sure you call this method when you end your minigame!
    // Of course you won't have a random score, but your score *must* be between 1 and 100 inclusive
    [self endMinigameWithScore:arc4random()%100 + 1];
}

-(void)boost {
    CGPoint Force = ccp(0, 8000);
    [self.hero.physicsBody applyForce:Force];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchLocation = [touch locationInNode:self];
    if (touchLocation.x <= 264) {
        _touchStart = touchLocation;
    }
    else{
        NSLog(@"%f",touchLocation.x);
        _jumpStarted = TRUE;
    }
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchLocation = [touch locationInNode:self];
    if (touchLocation.x <= 264) {
        _sliderDelta = touchLocation.x - _touchStart.x;
    }
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchLocation = [touch locationInNode:self];
    if (touchLocation.x <= 264) {
        _sliderDelta = 0;
        self.hero.physicsBody.velocity = ccp(0.f, self.hero.physicsBody.velocity.y);
    }
    else{
        _jumpStarted = false;
    }
}

// DO NOT DELETE!
-(MyCharacter *)hero {
    return (MyCharacter *)self.character;
}
// DO NOT DELETE!


@end
