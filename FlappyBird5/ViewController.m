//
//  ViewController.m
//  FlappyBird5
//
//  Created by shima jinsei on 2014/10/29.
//  Copyright (c) 2014年 Jinsei Shima. All rights reserved.
//

#import "ViewController.h"
#import "TitleScene.h"
//#import "SubTitleScene.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    SKView *skView;
    SKScene *scene;
    
    //TitleScene *titleScene = [[TitleScene alloc]init];
    //titleScene.delegate = self;
    
    // SKViewオブジェクトの生成と追加
    skView = [[SKView alloc] initWithFrame:self.view.frame];
    //skView.showsFPS = YES; // FPSの表示(デバッグ用設定)
    //skView.showsNodeCount = YES; // 配置されているノードの数を表示(デバッグ用設定)
    [self.view addSubview:skView];
    
    // SKSceneオブジェクトの生成と配置
    scene = [TitleScene sceneWithSize:skView.bounds.size];
    
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.userInteractionEnabled = YES;
        
    // シーンの表示
    [skView presentScene:scene];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
