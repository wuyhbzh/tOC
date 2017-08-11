#import <UIKit/UIKit.h>
typedef enum WinKind{
    BlackWin,
    WhiteWin,
    Equal,
    NoOneWinNow
}WinKind;
@interface ChessView : UIView

@property (nonatomic , assign) NSInteger blackCount;

@property (nonatomic , assign) NSInteger whiteCount;

@property (nonatomic , assign) WinKind winKind;

- (void)judgeCanChess;

- (void)getAllChess;
@end
