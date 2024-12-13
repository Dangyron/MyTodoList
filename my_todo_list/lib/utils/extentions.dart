import 'package:my_todo_list/models/folder.dart';

extension CustomSorting on List<Folder> {
  List<Folder> pinnedSort() {
    sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });

    return this;
  }
}
