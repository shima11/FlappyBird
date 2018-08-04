//
//  GameScene.m
//  FlappyBird5
//
//  Created by shima jinsei on 2014/10/29.
//  Copyright (c) 2014年 Jinsei Shima. All rights reserved.
//

#import "GameScene.h"
#import <FlatUIKit.h>
#import "TitleScene.h"
//#import "SubTitleScene.h"


//#define SIZE 96.0f
#define ROW 0

//game phase ゲームの場面
typedef NSUInteger RMMyScenePhase;

//phaseのパターン
enum {
    RMMyScenePhaseGetReady,
    RMMyScenePhaseGame,
    RMMyScenePhaseGameOver,
    RMMyScenePhaseMedal
};

//重力加速度
static const CGFloat kGravity = -9.8 * 0.9;
//ジャンプの力（上方向への加速度）
static const CGFloat kFlappingVelocityY = 360.0;

// wall
static const int kWallWidth = 50;
//static const int wall_minHeight = 200;
//static const int wall_maxHeight = 400;

static const int kUpperWallHeightMin = 3;//wallの最低サイズ（画面高さを15分割した時の数）
static const int kUpperWallHeightMax = 12;//wallの最高サイズ（画面高さを15分割した時の数）
//static const CGFloat kHoleHeight = 4.0;//wall間の距離
//static const CGFloat kIntervalBetweenWallProductions = 1.2;//wallの出現頻度
//static const CGFloat TimeTakenForWallGoThroughScreen = 2.6;//画面移動の速度（障害物の出現間隔）


//以下の3つの変数で難易度調整
//wall間の距離とwallの出現頻度を調整（ステージが進むごとに小さくしていく）
CGFloat HoleHeight = 3.0;//3.0~4.5
CGFloat IntervalBetweenWallProductions = 1.8;//1.2~2.0
CGFloat TimeTakenForWallGoThroughScreen = 2.8;//1.0~3.0


SKSpriteNode *bird;
SKAction *forever;
SKSpriteNode *wall;
SKSpriteNode *tapImage;
SKLabelNode *startLabel;
SKSpriteNode *wall;


@interface GameScene(){
    
    RMMyScenePhase phase_;//ゲームの状況の判別
    //CGFloat intervalBetweenWallProductions;//wallの出現頻度
    NSInteger points_;//ゲームの得点
    NSMutableArray *array;//得点を保存しておく配列
    SKAction *sound1;//ジャンプする音
    SKAction *sound2;//得点する音
    //SKAction *sound3;//衝突時の音

}
@end



@implementation GameScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        [self removeAllChildren];
        [self removeAllActions];
        
        [self setBackGround];
        [self setBird];
        [self setGround];
        
        [self setStartItem];
        
        //衝突を召喚する魔法
        self.physicsWorld.gravity = CGVectorMake(0,kGravity);
        self.physicsWorld.contactDelegate = self;
        
        phase_ = RMMyScenePhaseGetReady;
        
        //効果音の設定
        sound1 = [SKAction playSoundFileNamed:@"jump1.mp3" waitForCompletion:NO];//ジャンプの音
        sound2 = [SKAction playSoundFileNamed:@"point1.mp3" waitForCompletion:NO];//得点の音
        //sound3 = [SKAction playSoundFileNamed:@"bomb1.mp3" waitForCompletion:NO];//衝突の音
        
        //UserDefaultsの初期化
        [self setUserDefaults];
        
    }
    return self;
}


//NSUserDefaultsの初期化処理
-(void)setUserDefaults{
    
    // NSUserDefaultsからデータを削除する
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    [ud removeObjectForKey:@"POINTS"];  // KEY_Iを削除する
    
    // NSUserDefaultsに初期値を登録する
    //NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults setObject:@"0" forKey:@"POINTS"];  // をKEY_Iというキーの初期値は99
    [ud registerDefaults:defaults];
    //userdefaultsの初期化は値があると値を代入し、元から値があると何もしないので便利。
}

-(void)setStartItem{
    SKTexture *texture = [SKTexture textureWithImageNamed:@"tap2"];
    tapImage = [[SKSpriteNode alloc] initWithTexture:texture];
    tapImage.size = CGSizeMake(texture.size.width, texture.size.height);
    tapImage.xScale = 0.15;
    tapImage.yScale = 0.15;
    tapImage.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:tapImage];
    
    //SKLabelNode *startLabel;
    startLabel = [SKLabelNode labelNodeWithFontNamed:@"Hiragino Kaku Gothic ProN W6"];
    startLabel.text = @"tap start!";
    startLabel.fontColor = [UIColor blackColor];
    startLabel.fontSize = 20;
    startLabel.position = CGPointMake(self.size.width/2, self.size.height/2-tapImage.frame.size.height);
    [self addChild:startLabel];
    
}

//背景の設定
-(void)setBackGround{
    SKTexture *texture = [SKTexture textureWithImageNamed:@"angry_back4"];

    SKSpriteNode *background = [[SKSpriteNode alloc] initWithTexture:texture];
    background.size = CGSizeMake(texture.size.width, texture.size.height);
    
    background.yScale = self.size.height / texture.size.height;
    background.xScale = self.size.height / texture.size.height;
    
    background.position = CGPointMake(background.size.width/2, self.size.height/2);
    [self addChild:background];

    
}


//birdの設定
-(void)setBird{
    SKTexture *bird_texture = [SKTexture textureWithImageNamed:@"AnglyBirds3"];
    NSMutableArray *textures = @[].mutableCopy;
    for (int col = 0; col < 4; col++) {
        CGFloat x = col * 64 / bird_texture.size.width;
        CGFloat y = ROW * 60 / bird_texture.size.height;
        CGFloat w = 64 / bird_texture.size.width;
        CGFloat h = 60 / bird_texture.size.height;
        SKTexture *texture = [SKTexture textureWithRect:CGRectMake(x, y, w, h) inTexture:bird_texture];
        [textures addObject:texture];
    }
    bird = [SKSpriteNode spriteNodeWithTexture:textures.firstObject];
    //bird = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:bird.size];
    bird.position = CGPointMake(50.0f, self.frame.size.height/2);
    bird.physicsBody.contactTestBitMask = 0x1 << 0;//衝突のためのマスクを設定
    bird.xScale = 0.65;
    bird.yScale = 0.65;
    [self addChild:bird];
    
    //birdのテクスチャの間隔と動き
    SKAction *walk = [SKAction animateWithTextures:textures timePerFrame:0.1f];
    forever = [SKAction repeatActionForever:walk];
    [bird runAction:forever];

}


//ボタンの設定
-(void)setButton{
    SKTexture *texture = [SKTexture textureWithImageNamed:@"button"];
    SKSpriteNode *button = [[SKSpriteNode alloc] initWithTexture:texture];
    button.size = CGSizeMake(texture.size.width, texture.size.height);
    button.name = @"button";
    button.xScale = 0.3;
    button.yScale = 0.3;
    button.position = CGPointMake(30, self.size.height-50);
    [self addChild:button];
}

//地面と天井の設定
-(void)setGround{
    //地面
    SKTexture *text = [SKTexture textureWithImageNamed:@"kusa"];

    //ground1
    SKSpriteNode *ground = [[SKSpriteNode alloc] initWithTexture:text];
    ground.size = CGSizeMake(self.size.width,50);
    ground.position = CGPointMake(self.size.width/2, 25);
    [self addChild:ground];
    
    //ground2
    SKSpriteNode *ground2 = [[SKSpriteNode alloc] initWithTexture:text];
    ground2.size = CGSizeMake(self.size.width,50);
    ground2.position = CGPointMake(ground2.size.width*3/2, 25);
    [self addChild:ground2];
    
    
    //天井
    SKTexture *texture = [SKTexture textureWithImageNamed:@"Cloud"];
    
    //cloud1
    SKSpriteNode *ceiling1 = [[SKSpriteNode alloc] initWithTexture:texture];
    ceiling1.size = CGSizeMake(self.size.width, 100);
    ceiling1.position = CGPointMake(ceiling1.size.width/2, self.size.height);
    [self addChild:ceiling1];
    
    //cloud2
    SKSpriteNode *ceiling2 = [[SKSpriteNode alloc] initWithTexture:texture];
    ceiling2.size = CGSizeMake(self.size.width, 100);
    ceiling2.position = CGPointMake(ceiling2.size.width*3/2, self.size.height);
    [self addChild:ceiling2];
    
    
    //天井の動き
    CGFloat speed = TimeTakenForWallGoThroughScreen / (ceiling1.size.width);
    NSTimeInterval interval =  ceiling1.size.width * speed;
    
    //cloud1の動き
    SKAction *move = [SKAction sequence:
                      @[[SKAction moveTo:CGPointMake(-ceiling1.size.width/2, ceiling1.position.y) duration:interval],
                        [SKAction moveTo:CGPointMake(ceiling1.size.width/2,ceiling1.position.y) duration:0.0]]];
    SKAction *moveing = [SKAction repeatActionForever:move];
    [ceiling1 runAction:moveing];
    
    //cloud2の動き
    SKAction *move2 = [SKAction sequence:
                      @[[SKAction moveTo:CGPointMake(ceiling2.size.width/2, ceiling2.position.y) duration:interval],
                        [SKAction moveTo:CGPointMake(ceiling2.size.width*3/2,ceiling2.position.y) duration:0.0]]];
    SKAction *moveing2 = [SKAction repeatActionForever:move2];
    [ceiling2 runAction:moveing2];
    
    
    //ground1の動き
    SKAction *move3 = [SKAction sequence:
                      @[[SKAction moveTo:CGPointMake(-ground.size.width/2, ground.position.y) duration:interval],
                        [SKAction moveTo:CGPointMake(ground.size.width/2,ground.position.y) duration:0.0]]];
    SKAction *moveing3 = [SKAction repeatActionForever:move3];
    [ground runAction:moveing3];
    
    //ground2の動き
    SKAction *move4 = [SKAction sequence:
                       @[[SKAction moveTo:CGPointMake(ground2.size.width/2, ground2.position.y) duration:interval],
                         [SKAction moveTo:CGPointMake(ground2.size.width*3/2,ground2.position.y) duration:0.0]]];
    SKAction *moveing4 = [SKAction repeatActionForever:move4];
    [ground2 runAction:moveing4];
    
    
    //地面と天井の衝突判定の基準
    SKSpriteNode *ground_boundary = [[SKSpriteNode alloc]initWithColor:[UIColor clearColor] size:CGSizeMake(self.size.width, 20)];
    SKSpriteNode *ceiling_boundary = [[SKSpriteNode alloc]initWithColor:[UIColor clearColor] size:CGSizeMake(self.size.width, 2)];
    //地面の衝突面
    ground_boundary.position = CGPointMake(ground_boundary.size.width/2, ground_boundary.size.height/2);
    ground_boundary.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ground_boundary.size];
    ground_boundary.physicsBody.dynamic = NO;
    ground_boundary.physicsBody.contactTestBitMask = 0x1 << 0;
    [self addChild:ground_boundary];
    //天井の衝突面
    ceiling_boundary.position = CGPointMake(ceiling_boundary.size.width/2, self.size.height - ceiling_boundary.size.height/2);
    ceiling_boundary.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ceiling_boundary.size];
    ceiling_boundary.physicsBody.dynamic = NO;
    ceiling_boundary.physicsBody.contactTestBitMask = 0x1 << 0;
    [self addChild:ceiling_boundary];
    
}



//wallの高さを設定
- (void)putWallWithHeight:(CGFloat)height y:(CGFloat)y {
    
    //SKTexture *texture = [SKTexture textureWithImageNamed:@"wall"];
    //SKSpriteNode *wall = [[SKSpriteNode alloc] initWithTexture:texture];
    //wall.size = CGSizeMake(kWallWidth, height);
    wall =
    [SKSpriteNode spriteNodeWithColor:[UIColor grayColor] size:CGSizeMake(kWallWidth, height)];
    
    [wall setPosition:CGPointMake(self.size.width + kWallWidth / 2., y)];
    
    SKPhysicsBody *body = [SKPhysicsBody bodyWithRectangleOfSize:wall.size];
    [body setAffectedByGravity:NO];
    [body setDynamic:NO];
    [wall setPhysicsBody:body];
    
    [wall runAction:[SKAction sequence:
                     @[[SKAction moveTo:
                        CGPointMake(-kWallWidth / 2., y) duration:TimeTakenForWallGoThroughScreen],
                       [SKAction removeFromParent]]]];
    [self addChild:wall];
}

//実際に配置する高さを計算
- (void)putWalls {
    CGFloat unit = self.size.height / 15.0;
    
    CGFloat upperWallHeight =
    unit * (arc4random() % (kUpperWallHeightMax - kUpperWallHeightMin) + kUpperWallHeightMin);
    
    CGFloat bottomWallHeight = self.size.height - upperWallHeight - unit * HoleHeight;
    //self.size.height - upperWallHeight - unit * kHoleHeight;
    
    [self putWallWithHeight:upperWallHeight
                          y:self.size.height - upperWallHeight / 2.];
    [self putWallWithHeight:bottomWallHeight
                          y:bottomWallHeight / 2.];
}


//wallを配置する
- (void)putWallsPeriodically {
    [self runAction:
     [SKAction repeatActionForever:
      [SKAction sequence:
//       @[[SKAction waitForDuration:kIntervalBetweenWallProductions],
       @[[SKAction waitForDuration:IntervalBetweenWallProductions],
         [SKAction runBlock:^{
          [self putWalls];
          [self getIntervalBetweenWallProductions];
          
          [self runAction:
           [SKAction sequence:
            @[[SKAction waitForDuration:TimeTakenForWallGoThroughScreen * 0.75],
              [SKAction runBlock:^{
               SKNode *ball = [self childNodeWithName:@"ball"];
               if ([ball position].y > self.size.height) {
                   //[self gameOver];
               }
               else {
                   [self incrementPoints];
               }
           }]]]];
      }]]]]];
}

//wallの出現頻度の取得
-(CGFloat)getIntervalBetweenWallProductions{
    CGFloat interval = IntervalBetweenWallProductions;
    return interval;
}

//ゲームの得点を表示の更新
- (void)incrementPoints {
    SKLabelNode *label = (SKLabelNode *)[self childNodeWithName:@"points"];
    [label setText:[NSString stringWithFormat:@"%ld", ++points_]];
    [self runAction:sound2];//得点の効果音
    /*
    if(points_%2 == 0){//5回クリアするごとに難易度を上げる
        if (HoleHeight >= 3.0) {//HoleHeight　初期値：4.5
        //    HoleHeight -= 0.3;
        }
        if (IntervalBetweenWallProductions >= 0.8) {//IntervalBetweenWallProductions 初期値：2.0
        //    IntervalBetweenWallProductions -= 0.4;
        }
        if(TimeTakenForWallGoThroughScreen > 1.5){
        //    TimeTakenForWallGoThroughScreen -= 0.4;
        }
    }*/
    NSLog(@"height:%f interval:%f",HoleHeight,IntervalBetweenWallProductions);

}

//ゲームの得点を表示
- (void)putPointsLabel {
    SKLabelNode *label =
    [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter-Bold"];
    [label setName:@"points"];
    [label setFontSize:42.0];
    [label setFontColor:[UIColor blackColor]];
    [label setText:@"0"];
    [label setPosition:CGPointMake(self.size.width/2., self.size.height*0.75)];
    [label setZPosition:5000];
    [self addChild:label];
}



//難易度調整用の値のリセット（wall間の距離、wallの出現頻度、wallの速度）
-(void)resetValue{
    HoleHeight = 3.0;//3.0~4.5
    IntervalBetweenWallProductions = 1.8;//1.2~2.0
    TimeTakenForWallGoThroughScreen = 2.8;//1.0~3.0
}


//画面をタッチした時の処理
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //最初にある説明文字と画像を削除
    //if(tapImage == nil && startLabel == nil){
        [tapImage removeFromParent];
        [startLabel removeFromParent];
    //}
    
    //重力をつける
    SKPhysicsBody *body = [SKPhysicsBody bodyWithCircleOfRadius:bird.size.width / 2.];
    [body setContactTestBitMask:1];
    bird.physicsBody = body;
    
    //birdを上に飛ばす
    [[bird physicsBody] setVelocity: CGVectorMake(0.0, kFlappingVelocityY)];

    //効果音(ジャンプする音)
    [self runAction:sound1];
    
    
    //ゲーム状況に応じた対応
    if (phase_ == RMMyScenePhaseGame) {
        
    }
    else if (phase_ == RMMyScenePhaseMedal) {
        
    }
    else if (phase_ == RMMyScenePhaseGetReady) {
        [self putWallsPeriodically];//wallの表示開始
        [self putPointsLabel];//得点の表示
        phase_ = RMMyScenePhaseGame;
        points_ = 0;
    }
    
    
}



//衝突開始時
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    phase_ = RMMyScenePhaseGameOver;
    
    self.paused = YES;//一時停止

    [self removeAllActions];//すべてのアクションを削除
    
    //[self runAction:sound3];//衝突時の音

    [self setAlert];//アラートを表示

    [self setRecord];//記録を表示

    
}


//アラートビューを表示
-(void)setAlert{

    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Game Over"
                                                          message:[self recordLabel]
                                                         delegate:self cancelButtonTitle:@"もう一回"
                                                otherButtonTitles:@"タイトルに戻る", nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    [alertView show];
}


// アラートのボタンが押された時に呼ばれるデリゲート
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0://もう一度ボタン：画面をリセット
            [self removeAllChildren];
            [self removeAllActions];
            
            [self resetValue];
            [self setBackGround];
            [self setBird];
            [self setGround];
            [self setStartItem];
            
            
            phase_ = RMMyScenePhaseGetReady;
            
            self.paused = NO;
            break;
            
        case 1://戻るボタン：タイトル画面に戻る
            //self.paused = NO;
            [self resetValue];
            [self removeAllChildren];
            [self removeAllActions];
            
            SKScene *scene = [[TitleScene alloc] initWithSize:self.size];
            SKTransition *transition = [SKTransition crossFadeWithDuration:1.0];
            [self.view presentScene:scene transition:transition];
            
            //[self transition];
            break;
    }
}

/*
//タイトル画面に遷移
-(void)transition{
    SKScene *titleScene = [[TitleScene alloc] initWithSize:self.size];
    SKTransition *transition = [SKTransition crossFadeWithDuration:0.2];
    [self.view presentScene:titleScene transition:transition];
}
*/


//記録の保存
-(void)setRecord{
    //BestRecordのみ保存する。
    
    // NSUserDefaultsからデータを読み込む
    NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];  // 取得
    NSInteger point_before = [uds integerForKey:@"POINTS"];  // KEY_Iの内容をint型として取得
    NSLog(@"point_before:%ld",(long)point_before);
    NSLog(@"point_:%ld",(long)points_);
    
    if(points_ > point_before){//今回のポイントが以前よりも大きい場合、記録を保存する。
        // NSUserDefaultsに保存・更新する
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
        [ud setInteger:points_ forKey:@"POINTS"];// Integerの保存
        [ud synchronize];  // NSUserDefaultsに即時反映させる
        
    }

}


-(void)newRecordLabel{
    SKLabelNode *label =
    [SKLabelNode labelNodeWithFontNamed:@"AmericanTypewriter-Bold"];
    [label setFontSize:64.0];
    [label setFontColor:[UIColor blackColor]];
    [label setText:[NSString stringWithFormat:@"New Records! %ldポイント！\nCongratulation！",(long)points_]];
    [label setPosition:CGPointMake(self.size.width/2., self.size.height*0.5)];
    [label setZPosition:100000];
    [self addChild:label];
}



//アラートに表示する文字の設定(記録によって変更する)
-(NSString *)recordLabel{
    NSString *recordLabel;
    
    NSUserDefaults *uds = [NSUserDefaults standardUserDefaults];  // 取得
    NSInteger point_before = [uds integerForKey:@"POINTS"];  // KEY_Iの内容をint型として取得
    if(points_ > point_before){//今回のポイントが以前よりも大きい場合、記録を保存する。
        recordLabel = [NSString stringWithFormat:@"New Records! %ldポイント！！！\nCongratulation！",(long)points_];
    }else{
        recordLabel = [NSString stringWithFormat:@"Your Records is  %ld ポイント\nBest Records is  %ld ポイント",(long)points_,point_before];
    }
    
    return recordLabel;
}


@end
