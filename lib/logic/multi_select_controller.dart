class MultiSelectController {
  List<bool> selectedCards = [false, false, false, false];
  bool isMultiSelectMode = false;

  void resetSelection() {
    selectedCards = [false, false, false, false];
    isMultiSelectMode = false;
  }

  void toggleMultiSelectMode() {
    isMultiSelectMode = !isMultiSelectMode;
    if (!isMultiSelectMode) {
      selectedCards = [false, false, false, false];
    }
  }

  void toggleCardSelection(int cardIndex) {
    if (isMultiSelectMode) {
      selectedCards[cardIndex] = !selectedCards[cardIndex];
    }
  }

  List<int> getSelectedIndices() {
    final indices = <int>[];
    for (int i = 0; i < selectedCards.length; i++) {
      if (selectedCards[i]) indices.add(i);
    }
    return indices;
  }

  int get selectedCount => selectedCards.where((selected) => selected).length;

  bool checkIfAllSame(List<String> playerCards) {
    final selectedIndices = getSelectedIndices();
    if (selectedIndices.isEmpty) return false;

    final selectedValues = selectedIndices.map((i) => playerCards[i]).toList();
    final firstValue = selectedValues.first;
    return selectedValues.every((value) => value == firstValue);
  }
}