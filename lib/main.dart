import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      builder: (context) => GameModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameView(),
    );
  }
}

class GameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ScoreBoard(),
          MaterialButton(
            onPressed: () => Provider.of<GameModel>(context).newGame(),
            child: Text("New Game"),
          ),
          Board(),
        ],
      ),
    );
  }
}

class GameModel extends ChangeNotifier {
  String banner = "Players tied";

  int played = 0 ;
  bool gameEnd = false ;
  List<int> scores = List<int>.filled(2, 0);
  int currentPlayer = 1;
  List<List<int>> board = List.generate(3, (_) => List.generate(3, (_) => 0));
  void changePlayer() {
    currentPlayer = (currentPlayer == 1) ? 2 : 1;
  }

  void play(int x, int y) {
    if (board[x][y] == 0) {
      played += 1;
      board[x][y] = currentPlayer;
      changePlayer();
      int t = winningState();
      if (t > 0) {
        declareWinner(t);
      }else if(played == 9){
        playerTied();
      }
      notifyListeners();
    }
  }
  void playerTied(){
    banner = "Players tied";
    gameEnd = true;
  }
  void declareWinner(int player) {
    banner = "Player $player won";
    scores[player - 1] += 1;
    gameEnd = true ;
  }

  int winningState() {
    int t = board[0][0];
    if (t > 0) {
      if (board[1][0] == board[2][0] && board[1][0] == t) {
        return t;
      }
      if (board[1][1] == board[2][2] && board[1][1] == t) {
        return t;
      }
      if (board[0][1] == board[0][2] && board[0][1] == t) {
        return t;
      }
    }
    t = board[2][2];
    if (t > 0) {
      if (board[0][2] == board[1][2] && board[0][2] == t) {
        return t;
      }
      if (board[2][0] == board[2][1] && board[2][0] == t) {
        return t;
      }
    }
    t = board[1][1];
    if (t > 0) {
      if (board[0][2] == board[2][0] && board[0][2] == t) {
        return t;
      }
      if (board[1][0] == board[1][2] && board[1][0] == t) {
        return t;
      }
      if (board[0][1] == board[2][1] && board[0][1] == t) {
        return t;
      }
    }
    return 0;
  }

  String boxText(int x, int y) {
    if (board[x][y] == 0) return "";
    if (board[x][y] == 1) return "X";
    if (board[x][y] == 2) return "O";
    return "";
  }

  void newGame() {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        board[i][j] = 0;
      }
    }
    played = 0;
    gameEnd = false ;
    notifyListeners();
  }

  int getScore(int playerNumber) {
    return scores[playerNumber];
  }
}

class Board extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(
        builder: (context, gameModel, child) => Container(
              height: 400,
              width: 400,
              child: (gameModel.gameEnd)
                  ? Center(child: Text("${gameModel.banner}"))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List<Widget>.generate(
                        3,
                        (idx) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List<Widget>.generate(
                              3,
                              (idx2) {
                                return BoardTile(
                                  Key("$idx $idx2"),
                                  gameModel,
                                  idx,
                                  idx2,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ));
  }
}

class BoardTile extends StatelessWidget {
  final gameModel;
  final idx;
  final idx2;
  const BoardTile(Key key, this.gameModel, this.idx, this.idx2)
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => gameModel.play(idx, idx2),
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(width: 12, color: Colors.black)),
        height: 100,
        width: 100,
        child: Center(child: Text("${gameModel.boxText(idx, idx2)}")),
      ),
    );
  }
}

class ScoreBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(
      builder: (context, gameModel, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: List<Widget>.generate(2, (_) {
            return Container(
              child: Column(
                children: <Widget>[
                  Text("player ${_+1}"),
                  Text("${gameModel.getScore(_)}")
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
