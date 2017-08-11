#import <UIKit/UIKit.h>

typedef enum ChessKind{
    NormalChess = 0,
    CanChess,
    BlackChess,
    WhiteChess
}ChessKind;

@interface ChessPiecesView : UIView

@property (nonatomic , assign) ChessKind chessKind;

@property (nonatomic , strong,readonly) NSIndexPath *indexPath;

- (instancetype)initWithFrame:(CGRect)frame andIndexPath:(NSIndexPath *)indexPath;

@end
