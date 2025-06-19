// lib/main.dart - Pawsy mit echten CABO-Regeln
import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const PawsyApp());
}

class PawsyApp extends StatelessWidget {
  const PawsyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pawsy',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF1B5E20),
      ),
      home: const PawsyGameScreen(),
    );
  }
}

class PawsyGameScreen extends StatefulWidget {
  const PawsyGameScreen({Key? key}) : super(key: key);
  
  @override
  PawsyGameScreenState createState() => PawsyGameScreenState();
}

class PawsyGameScreenState extends State<PawsyGameScreen> {
  List<int> playerCards = [0, 0, 0, 0]; // Spielerkarten (0 = unbekannt)
  List<bool> playerCardVisible = [false, false, false, false]; // Welche Karten sichtbar sind
  List<int> opponentCards = [0, 0, 0, 0]; // Gegnerkarten
  int topCard = 6; // Oberste Karte vom Ablagestapel
  int coins = 50; // Münzen des Spielers
  bool gameStarted = false;
  bool gamePhase = false; // false = Spielstart (2 Karten anschauen), true = Spielphase
  int cardsLookedAt = 0; // Anzahl angeschauter Karten beim Start
  bool playerTurn = true;
  String gameMessage = "Schaue dir 2 deiner Karten an!";
  
  // Deck für realistische Karten
  List<int> deck = [];
  Random random = Random();

  @override
  void initState() {
    super.initState();
    newGame();
  }

  void initializeDeck() {
    deck.clear();
    // Standard CABO Deck: 0-13, mehrere von jeder Karte
    for (int i = 0; i <= 13; i++) {
      for (int j = 0; j < 4; j++) {
        deck.add(i);
      }
    }
    deck.shuffle(random);
  }

  int drawFromDeck() {
    if (deck.isEmpty) {
      initializeDeck();
    }
    return deck.removeLast();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐾 Pawsy'),
        backgroundColor: Colors.green[800],
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.yellow),
                const SizedBox(width: 4),
                Text('$coins', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Spielnachricht
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              gameMessage,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Gegnerkarten (verdeckt)
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: opponentCards.asMap().entries.map((entry) {
                return Container(
                  width: 60,
                  height: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.pets, color: Colors.white, size: 30),
                );
              }).toList(),
            ),
          ),
          
          // Spielbereich (Mitte)
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Nachziehstapel
                  GestureDetector(
                    onTap: playerTurn && gamePhase ? () => drawCard() : null,
                    child: Container(
                      width: 80,
                      height: 120,
                      decoration: BoxDecoration(
                        color: playerTurn && gamePhase ? Colors.purple[900] : Colors.grey[600],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pets, color: Colors.white, size: 40),
                          Text('ZIEHEN', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  
                  // Ablagestapel
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      color: getCardColor(topCard),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        '$topCard',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Spielerkarten
          SizedBox(
            height: 160,
            child: Column(
              children: [
                const Text(
                  'Deine Karten',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: playerCards.asMap().entries.map((entry) {
                    int index = entry.key;
                    int cardValue = entry.value;
                    bool isVisible = playerCardVisible[index];
                    
                    return GestureDetector(
                      onTap: () => handleCardTap(index),
                      child: Container(
                        width: 70,
                        height: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isVisible ? getCardColor(cardValue) : Colors.grey[700],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white, 
                            width: isVisible ? 3 : 2
                          ),
                        ),
                        child: Center(
                          child: isVisible 
                            ? Text(
                                '$cardValue',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const Icon(Icons.pets, color: Colors.white, size: 40),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // Aktionsbuttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: gamePhase && canCallPawsy() ? () => callPawsy() : null,
                  icon: const Icon(Icons.pets),
                  label: const Text('PAWSY!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gamePhase && canCallPawsy() ? Colors.orange[600] : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => newGame(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Neues Spiel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color getCardColor(int cardValue) {
    if (cardValue >= 7 && cardValue <= 12) {
      return Colors.purple[700]!; // Aktionskarten
    } else if (cardValue == 13) {
      return Colors.red[800]!; // Hohe Karte
    } else if (cardValue == 0) {
      return Colors.green[700]!; // Niedrigste Karte
    }
    return Colors.orange[700]!; // Normale Karten
  }

  void handleCardTap(int index) {
    if (!gamePhase && cardsLookedAt < 2) {
      // Spielstart: Karten anschauen
      setState(() {
        playerCardVisible[index] = true;
        cardsLookedAt++;
        if (cardsLookedAt == 2) {
          gameMessage = "Spiel beginnt! Du bist dran.";
          gamePhase = true;
          // Nach 3 Sekunden Karten wieder verdecken
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                for (int i = 0; i < 4; i++) {
                  playerCardVisible[i] = false;
                }
                gameMessage = "Ziehe eine Karte oder spiele eine bekannte Karte!";
              });
            }
          });
        } else {
          gameMessage = "Schaue dir noch eine Karte an!";
        }
      });
    } else if (gamePhase && playerTurn && playerCardVisible[index]) {
      // Bekannte Karte spielen
      playCard(index);
    }
  }

  void drawCard() {
    int drawnCard = drawFromDeck();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gezogene Karte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                color: getCardColor(drawnCard),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  '$drawnCard',
                  style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(getCardDescription(drawnCard)),
            const SizedBox(height: 16),
            const Text('Was möchtest du tun?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              chooseCardToReplace(drawnCard);
            },
            child: const Text('Mit eigener Karte tauschen'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                topCard = drawnCard;
                checkForActionCard(drawnCard);
              });
              Navigator.pop(context);
              endPlayerTurn();
            },
            child: const Text('Ablegen'),
          ),
        ],
      ),
    );
  }

  String getCardDescription(int card) {
    if (card >= 7 && card <= 8) return "PEEK: Schaue dir eine Karte an";
    if (card >= 9 && card <= 10) return "SPY: Schaue dir Gegnerkarte an";
    if (card >= 11 && card <= 12) return "SWAP: Tausche Karten";
    if (card == 13) return "Hohe Karte (13 Punkte)";
    if (card == 0) return "Beste Karte (0 Punkte)";
    return "Normale Karte ($card Punkte)";
  }

  void chooseCardToReplace(int newCard) {
    setState(() {
      gameMessage = "Wähle eine deiner Karten zum Tauschen!";
    });
    
    // Temporär alle Karten sichtbar machen für die Auswahl
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Karte tauschen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Wähle eine Karte zum Tauschen:'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: playerCards.asMap().entries.map((entry) {
                int index = entry.key;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      topCard = playerCards[index];
                      playerCards[index] = newCard;
                      playerCardVisible[index] = true;
                    });
                    Navigator.pop(context);
                    checkForActionCard(newCard);
                    endPlayerTurn();
                  },
                  child: Container(
                    width: 50,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void checkForActionCard(int card) {
    if (card >= 7 && card <= 8) {
      // PEEK: Eigene Karte anschauen
      peekAction();
    } else if (card >= 9 && card <= 10) {
      // SPY: Gegnerkarte anschauen
      spyAction();
    } else if (card >= 11 && card <= 12) {
      // SWAP: Karten tauschen
      swapAction();
    }
  }

  void peekAction() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PEEK Aktion'),
        content: const Text('Wähle eine deiner verdeckten Karten zum Anschauen:'),
        actions: List.generate(4, (index) {
          if (!playerCardVisible[index]) {
            return TextButton(
              onPressed: () {
                setState(() {
                  playerCardVisible[index] = true;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Karte ${index + 1}: ${playerCards[index]} Punkte')),
                );
              },
              child: Text('Karte ${index + 1}'),
            );
          }
          return Container();
        }),
      ),
    );
  }

  void spyAction() {
    int randomOpponentCard = opponentCards[random.nextInt(4)];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SPY Aktion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Du siehst eine Gegnerkarte:'),
            const SizedBox(height: 16),
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                color: getCardColor(randomOpponentCard),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  '$randomOpponentCard',
                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void swapAction() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('SWAP Aktion'),
        content: const Text('Wähle eine deiner Karten zum Tauschen mit dem Gegner:'),
        actions: List.generate(4, (index) {
          return TextButton(
            onPressed: () {
              setState(() {
                // Einfacher Swap mit zufälliger Gegnerkarte
                int opponentIndex = random.nextInt(4);
                int temp = playerCards[index];
                playerCards[index] = opponentCards[opponentIndex];
                opponentCards[opponentIndex] = temp;
                playerCardVisible[index] = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Karte ${index + 1} getauscht!')),
              );
            },
            child: Text('Karte ${index + 1}'),
          );
        }),
      ),
    );
  }

  void playCard(int index) {
    setState(() {
      topCard = playerCards[index];
      playerCards[index] = drawFromDeck(); // Neue Karte ziehen
      playerCardVisible[index] = false; // Neue Karte ist verdeckt
    });
    
    checkForActionCard(topCard);
    endPlayerTurn();
  }

  void endPlayerTurn() {
    setState(() {
      playerTurn = false;
      gameMessage = "Gegner ist dran...";
    });
    
    // Einfache KI: Nach 2 Sekunden automatisch weiterspielen
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        opponentTurn();
      }
    });
  }

  void opponentTurn() {
    // Einfache KI-Logik
    if (random.nextBool()) {
      // KI zieht Karte
      int drawnCard = drawFromDeck();
      int randomIndex = random.nextInt(4);
      setState(() {
        topCard = opponentCards[randomIndex];
        opponentCards[randomIndex] = drawnCard;
      });
    } else {
      // KI spielt Karte
      int randomIndex = random.nextInt(4);
      setState(() {
        topCard = opponentCards[randomIndex];
        opponentCards[randomIndex] = drawFromDeck();
      });
    }
    
    setState(() {
      playerTurn = true;
      gameMessage = "Du bist dran!";
    });
  }

  bool canCallPawsy() {
    // Kann nur PAWSY rufen wenn mindestens 2 Karten bekannt sind
    int knownCards = playerCardVisible.where((visible) => visible).length;
    return knownCards >= 2;
  }

  void callPawsy() {
    int playerScore = 0;
    for (int i = 0; i < 4; i++) {
      playerScore += playerCards[i];
    }
    
    int opponentScore = opponentCards.fold(0, (sum, card) => sum + card);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🐾 PAWSY!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Deine Punkte: $playerScore'),
            Text('Gegner Punkte: $opponentScore'),
            const SizedBox(height: 16),
            Text(
              playerScore <= opponentScore ? 'Du gewinnst! 🎉' : 'Gegner gewinnt! 😔',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: playerScore <= opponentScore ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text('Münzen ${playerScore <= opponentScore ? "gewonnen" : "verloren"}: ${playerScore <= opponentScore ? "+15" : "-5"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                coins += playerScore <= opponentScore ? 15 : -5;
                if (coins < 0) coins = 0;
              });
              Navigator.pop(context);
              newGame();
            },
            child: const Text('Neues Spiel'),
          ),
        ],
      ),
    );
  }

  void newGame() {
    initializeDeck();
    setState(() {
      // Karten austeilen
      for (int i = 0; i < 4; i++) {
        playerCards[i] = drawFromDeck();
        opponentCards[i] = drawFromDeck();
        playerCardVisible[i] = false;
      }
      topCard = drawFromDeck();
      gameStarted = true;
      gamePhase = false;
      cardsLookedAt = 0;
      playerTurn = true;
      gameMessage = "Schaue dir 2 deiner Karten an!";
    });
  }
}