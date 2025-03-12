// views/screens/game_screen.dart
import 'package:chatapp/views/screens/home_screen.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<List<int>> board = [
    [1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1],
    [1, 1, 0, 2, 2],
    [2, 2, 2, 2, 2],
    [2, 2, 2, 2, 2],
  ];
  List<List<int>> backup = [
    [1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1],
    [1, 1, 0, 2, 2],
    [2, 2, 2, 2, 2],
    [2, 2, 2, 2, 2],
  ];

  int removedPiecesPlayer1 = 0;
  int removedPiecesPlayer2 = 0;

  int currentPlayer = 1;
  List<List<bool>> highlighted =
      List.generate(5, (i) => List.generate(5, (j) => false));
  int? selectedX;
  int? selectedY;

  void selectPiece(int x, int y) {
    if (board[y][x] == currentPlayer) {
      setState(() {
        selectedX = x;
        selectedY = y;
        highlightMoves(x, y);
      });
    }
  }

  void highlightMoves(int x, int y) {
    highlighted = List.generate(5, (i) => List.generate(5, (j) => false));

    List<List<int>> directions = [
      [-1, -1],
      [0, -1],
      [1, -1],
      [-1, 0],
      [1, 0],
      [-1, 1],
      [0, 1],
      [1, 1]
    ];

    for (var dir in directions) {
      int newX = x + dir[0];
      int newY = y + dir[1];
      if (isValid(newX, newY) && board[newY][newX] == 0) {
        highlighted[newY][newX] = true;
      }
    }

    for (var dir in directions) {
      int newX = x + dir[0];
      int newY = y + dir[1];
      if (isValid(newX, newY) &&
          board[newY][newX] != 0 &&
          board[newY][newX] != currentPlayer) {
        int afterEnemyX = newX + dir[0];
        int afterEnemyY = newY + dir[1];
        if (isValid(afterEnemyX, afterEnemyY) &&
            board[afterEnemyY][afterEnemyX] == 0) {
          highlighted[afterEnemyY][afterEnemyX] = true;
        }
      }
    }
  }

  bool isValid(int x, int y) {
    return x >= 0 && x < 5 && y >= 0 && y < 5;
  }

  void movePiece(int x, int y) {
    if (highlighted[y][x]) {
      setState(() {
        int oldX = selectedX!;
        int oldY = selectedY!;

        if ((x - oldX).abs() == 2 || (y - oldY).abs() == 2) {
          int midX = (x + oldX) ~/ 2;
          int midY = (y + oldY) ~/ 2;
          board[midY][midX] = 0; // Remove enemy piece if jumped over
          if (currentPlayer == 2) {
            removedPiecesPlayer1++;
          } else {
            removedPiecesPlayer2++;
          }
        }

        board[y][x] = currentPlayer;
        board[oldY][oldX] = 0;
        selectedX = null;
        selectedY = null;
        highlighted = List.generate(5, (i) => List.generate(5, (j) => false));
        currentPlayer = (currentPlayer == 1) ? 2 : 1;
      });
    }
    if (removedPiecesPlayer1 == 12) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Text("Player 2 Wins!", style: _textStyle()),
          content: Text("Congratulations Player 2! You have won the game.",
              style: _textStyle()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ));
              },
              child: Text("OK", style: _textStyle()),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  board = backup;
                  removedPiecesPlayer1 = 0;
                  removedPiecesPlayer2 = 0;
                  currentPlayer = 1;
                });
                Navigator.of(context).pop();
              },
              child: Text("Play Again", style: _textStyle()),
            ),
          ],
        ),
      );
    } else if (removedPiecesPlayer2 == 12) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Text("Player 1 Wins!", style: _textStyle()),
          content: Text("Congratulations Player 1! You have won the game.",
              style: _textStyle()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ));
              },
              child: Text("Quit", style: _textStyle()),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  board = backup;
                  removedPiecesPlayer1 = 0;
                  removedPiecesPlayer2 = 0;
                  currentPlayer = 1;
                });
                Navigator.of(context).pop();
              },
              child: Text("Play Again", style: _textStyle()),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.red,
          elevation: 0,
          title: const Text(
            "12 Kaatio",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
              shadows: [
                Shadow(
                  blurRadius: 40.0,
                  color: Colors.deepOrange,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade900, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPlayerInfo(
                  "Player 1", removedPiecesPlayer2, Colors.blue, Colors.red),
              Stack(
                children: [
                  CustomPaint(
                    size: Size(340, 340),
                    painter: GridPainter(),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    child: _buildBoard(),
                  )
                ],
              ),
              _buildPlayerInfo(
                  "Player 2", removedPiecesPlayer1, Colors.red, Colors.blue),
            ],
          ),
        ));
  }

  _buildBoard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (y) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (x) => GestureDetector(
              onTap: () {
                if (board[y][x] == currentPlayer) {
                  selectPiece(x, y);
                } else if (highlighted[y][x]) {
                  movePiece(x, y);
                }
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 60,
                height: 60,
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.cyan.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10.0,
                      color: highlighted[y][x]
                          ? Colors.pink
                          : board[y][x] == 1
                              ? Colors.blue
                              : board[y][x] == 2
                                  ? Colors.red
                                  : Colors.grey,
                      offset: Offset(0, 0),
                    ),
                  ],
                  color: highlighted[y][x]
                      ? Colors.pink
                      : board[y][x] == 1
                          ? Colors.blue
                          : board[y][x] == 2
                              ? Colors.red
                              : Colors.grey[800],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                    board[y][x] == 1
                        ? Icons.person_3_rounded
                        : board[y][x] == 2
                            ? Icons.person_2_rounded
                            : null,
                    color: board[y][x] == 1
                        ? Colors.white
                        : board[y][x] == 2
                            ? Colors.black
                            : null),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(
      String player, int removedPieces, Color playerColor, Color pieceColor) {
    return Column(
      children: [
        Text(
          "$player: $removedPieces",
          style: TextStyle(
              color: playerColor, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            removedPieces,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                color: pieceColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _textStyle() {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.deepOrange,
      shadows: [
        Shadow(
          blurRadius: 40.0,
          color: Colors.deepOrange,
          offset: Offset(0, 0),
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint shadowPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    Paint gridPaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    double cellSize = size.width / 5;
    double startX = 0;
    double startY = 0;

    List<Offset> positions = [];
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        positions.add(Offset(startX + j * cellSize + cellSize / 2,
            startY + i * cellSize + cellSize / 2));
      }
    }

    for (int i = 0; i < positions.length; i++) {
      for (int j = i + 1; j < positions.length; j++) {
        double dx = (positions[j].dx - positions[i].dx).abs();
        double dy = (positions[j].dy - positions[i].dy).abs();

        if ((dx == cellSize && dy == 0) ||
            (dy == cellSize && dx == 0) ||
            (dx == cellSize && dy == cellSize)) {
          canvas.drawLine(positions[i].translate(3, 3),
              positions[j].translate(3, 3), shadowPaint);
          canvas.drawLine(positions[i], positions[j], gridPaint);
        }
      }
    }

    Paint nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (Offset pos in positions) {
      canvas.drawCircle(pos.translate(3, 3), 6, shadowPaint);
      canvas.drawCircle(pos, 6, nodePaint);
      canvas.drawCircle(pos, 10, gridPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
