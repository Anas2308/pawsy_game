import 'package:flutter/material.dart';
import '../logic/action_card_controller.dart';

class ActionCardPopup extends StatefulWidget {
  final ActionCardType actionType;
  final List<String> playerCards;
  final List<String> aiCards;
  final Function(ActionCardResult) onActionComplete;
  final VoidCallback? onSkip;

  const ActionCardPopup({
    super.key,
    required this.actionType,
    required this.playerCards,
    required this.aiCards,
    required this.onActionComplete,
    this.onSkip,
  });

  @override
  State<ActionCardPopup> createState() => _ActionCardPopupState();
}

class _ActionCardPopupState extends State<ActionCardPopup> {
  int? selectedPlayerCard;
  int? selectedAICard;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.green[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 20),
            _buildCardSelection(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          _getActionIcon(),
          color: _getActionColor(),
          size: 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            ActionCardController.getActionName(widget.actionType),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onSkip?.call();
          },
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        ActionCardController.getActionDescription(widget.actionType),
        style: const TextStyle(color: Colors.white70, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCardSelection() {
    return Column(
      children: [
        if (widget.actionType == ActionCardType.look || widget.actionType == ActionCardType.trade) ...[
          _buildPlayerCardSelection(),
          if (widget.actionType == ActionCardType.trade) const SizedBox(height: 16),
        ],
        if (widget.actionType == ActionCardType.spy || widget.actionType == ActionCardType.trade) ...[
          _buildAICardSelection(),
        ],
      ],
    );
  }

  Widget _buildPlayerCardSelection() {
    return Column(
      children: [
        const Text(
          'Deine Karten:',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            final isSelected = selectedPlayerCard == index;
            final canSelect = widget.playerCards[index] != 'LEER';

            return GestureDetector(
              onTap: canSelect ? () => setState(() => selectedPlayerCard = index) : null,
              child: Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.yellow[700]
                      : (canSelect ? Colors.blue[900] : Colors.grey[600]),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? Colors.yellow : Colors.white,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pos ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (canSelect)
                        Text(
                          '❓',
                          style: const TextStyle(fontSize: 20),
                        )
                      else
                        const Text(
                          'X',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAICardSelection() {
    return Column(
      children: [
        const Text(
          'KI Karten:',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            final isSelected = selectedAICard == index;
            final canSelect = widget.aiCards[index] != 'LEER';

            return GestureDetector(
              onTap: canSelect ? () => setState(() => selectedAICard = index) : null,
              child: Container(
                width: 50,
                height: 70,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.red[700]
                      : (canSelect ? Colors.blue[900] : Colors.grey[600]),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? Colors.red : Colors.white,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'KI ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (canSelect)
                        Text(
                          '❓',
                          style: const TextStyle(fontSize: 20),
                        )
                      else
                        const Text(
                          'X',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final canExecute = _canExecuteAction();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onSkip?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: const Text('Überspringen'),
            ),
            ElevatedButton(
              onPressed: canExecute ? _executeAction : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canExecute ? _getActionColor() : Colors.grey,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ausführen'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tipp: Du kannst die Aktionskarte auch überspringen',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  bool _canExecuteAction() {
    switch (widget.actionType) {
      case ActionCardType.look:
        return selectedPlayerCard != null;
      case ActionCardType.spy:
        return selectedAICard != null;
      case ActionCardType.trade:
        return selectedPlayerCard != null && selectedAICard != null;
      case ActionCardType.none:
        return false;
    }
  }

  void _executeAction() {
    ActionCardResult result;

    switch (widget.actionType) {
      case ActionCardType.look:
        result = ActionCardController.executeLookAction(widget.playerCards, selectedPlayerCard!);
        break;
      case ActionCardType.spy:
        result = ActionCardController.executeSpyAction(widget.aiCards, selectedAICard!);
        break;
      case ActionCardType.trade:
        result = ActionCardController.executeTradeAction(
            widget.playerCards,
            widget.aiCards,
            selectedPlayerCard!,
            selectedAICard!
        );
        break;
      case ActionCardType.none:
        result = ActionCardResult.failure('Keine Aktion');
        break;
    }

    Navigator.of(context).pop();
    widget.onActionComplete(result);
  }

  IconData _getActionIcon() {
    switch (widget.actionType) {
      case ActionCardType.look:
        return Icons.visibility;
      case ActionCardType.spy:
        return Icons.search;
      case ActionCardType.trade:
        return Icons.swap_horiz;
      case ActionCardType.none:
        return Icons.help;
    }
  }

  Color _getActionColor() {
    switch (widget.actionType) {
      case ActionCardType.look:
        return Colors.orange;
      case ActionCardType.spy:
        return Colors.red;
      case ActionCardType.trade:
        return Colors.purple;
      case ActionCardType.none:
        return Colors.grey;
    }
  }
}