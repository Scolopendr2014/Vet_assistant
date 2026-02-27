import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../templates/domain/entities/protocol_template.dart';

/// VET-150, VET-172: форма редактирования раздела «Таблица» — размерность, ячейки, объединения, размеры в мм, картинки в ячейках.
class TableSectionEditPage extends StatefulWidget {
  const TableSectionEditPage({
    super.key,
    required this.section,
    this.keysUsedInOtherSections = const {},
  });

  final TemplateSection section;
  final Set<String> keysUsedInOtherSections;

  @override
  State<TableSectionEditPage> createState() => _TableSectionEditPageState();
}

class _TableSectionEditPageState extends State<TableSectionEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _orderController;
  late TextEditingController _rowsController;
  late TextEditingController _colsController;
  late List<TableCellConfig> _cells;
  late List<TableMergeRegion> _mergeRegions;
  late List<double?> _columnWidthsMm;
  late List<double?> _rowHeightsMm;
  final ImagePicker _imagePicker = ImagePicker();

  static const _fieldTypes = ['text', 'number', 'date', 'select', 'bool'];

  @override
  void initState() {
    super.initState();
    final tc = widget.section.tableConfig ?? const TableSectionConfig();
    _titleController = TextEditingController(text: widget.section.title);
    _orderController = TextEditingController(text: '${widget.section.order}');
    _rowsController = TextEditingController(text: '${tc.tableRows}');
    _colsController = TextEditingController(text: '${tc.tableCols}');
    _cells = List.from(tc.cells);
    _mergeRegions = List.from(tc.mergeRegions);
    _columnWidthsMm = List<double?>.from(tc.columnWidthsMm ?? []);
    _rowHeightsMm = List<double?>.from(tc.rowHeightsMm ?? []);
    _syncCellsToGrid();
    _trimMergeRegionsToGrid();
    _syncSizesToGrid();
  }

  void _syncCellsToGrid() {
    final rCount = (int.tryParse(_rowsController.text) ?? 2).clamp(1, 20);
    final cCount = (int.tryParse(_colsController.text) ?? 2).clamp(1, 10);
    final map = <int, TableCellConfig>{};
    for (final c in _cells) {
      map[c.row * 100 + c.col] = c;
    }
    _cells = [];
    for (var r = 0; r < rCount; r++) {
      for (var c = 0; c < cCount; c++) {
        _cells.add(map[r * 100 + c] ?? TableCellConfig(row: r, col: c));
      }
    }
  }

  /// Обрезка объединений по границам таблицы. Не вызывает setState (допустимо из initState).
  void _trimMergeRegionsToGrid() {
    final rows = _rows;
    final cols = _cols;
    _mergeRegions.removeWhere((m) {
      if (m.row < 0 || m.col < 0 || m.row + m.rowSpan > rows || m.col + m.colSpan > cols) {
        return true;
      }
      if (m.mainCellRow < m.row || m.mainCellRow >= m.row + m.rowSpan) {
        return true;
      }
      if (m.mainCellCol < m.col || m.mainCellCol >= m.col + m.colSpan) {
        return true;
      }
      return false;
    });
  }

  /// Подгонка списков размеров под текущую размерность. Не вызывает setState (допустимо из initState).
  void _syncSizesToGrid() {
    final rows = _rows;
    final cols = _cols;
    while (_columnWidthsMm.length > cols) {
      _columnWidthsMm.removeLast();
    }
    while (_columnWidthsMm.length < cols) {
      _columnWidthsMm.add(null);
    }
    while (_rowHeightsMm.length > rows) {
      _rowHeightsMm.removeLast();
    }
    while (_rowHeightsMm.length < rows) {
      _rowHeightsMm.add(null);
    }
  }

  static bool _mergeRegionsOverlap(TableMergeRegion a, TableMergeRegion b) {
    final aR1 = a.row;
    final aR2 = a.row + a.rowSpan;
    final aC1 = a.col;
    final aC2 = a.col + a.colSpan;
    final bR1 = b.row;
    final bR2 = b.row + b.rowSpan;
    final bC1 = b.col;
    final bC2 = b.col + b.colSpan;
    return aR1 < bR2 && aR2 > bR1 && aC1 < bC2 && aC2 > bC1;
  }

  String? _validateMergeRegions() {
    final rows = _rows;
    final cols = _cols;
    for (final m in _mergeRegions) {
      if (m.row < 0 || m.col < 0 || m.row + m.rowSpan > rows || m.col + m.colSpan > cols) {
        return 'Объединение (стр. ${m.row + 1}, столб. ${m.col + 1}) выходит за границы таблицы.';
      }
      if (m.mainCellRow < m.row || m.mainCellRow >= m.row + m.rowSpan || m.mainCellCol < m.col || m.mainCellCol >= m.col + m.colSpan) {
        return 'Главная ячейка (${m.mainCellRow + 1}, ${m.mainCellCol + 1}) должна быть внутри объединения (${m.row + 1}–${m.row + m.rowSpan}, ${m.col + 1}–${m.col + m.colSpan}).';
      }
    }
    for (var i = 0; i < _mergeRegions.length; i++) {
      for (var j = i + 1; j < _mergeRegions.length; j++) {
        if (_mergeRegionsOverlap(_mergeRegions[i], _mergeRegions[j])) {
          return 'Объединения ячеек не должны пересекаться.';
        }
      }
    }
    return null;
  }

  Future<String?> _pickImageForCell() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Камера'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Галерея'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return null;
    final XFile? picked = await _imagePicker.pickImage(source: source);
    if (picked == null || !mounted) return null;
    final dir = await getApplicationDocumentsDirectory();
    final safeSectionId = widget.section.id.replaceAll(RegExp(r'[^\w\-.]'), '_');
    final cellImagesDir = Directory(p.join(dir.path, 'template_cell_images', safeSectionId));
    if (!await cellImagesDir.exists()) await cellImagesDir.create(recursive: true);
    final ext = p.extension(picked.path).isEmpty ? '.jpg' : p.extension(picked.path);
    final destPath = p.join(cellImagesDir.path, '${const Uuid().v4()}$ext');
    await File(picked.path).copy(destPath);
    return destPath;
  }

  int get _rows => (int.tryParse(_rowsController.text) ?? 2).clamp(1, 20);
  int get _cols => (int.tryParse(_colsController.text) ?? 2).clamp(1, 10);

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
    _rowsController.dispose();
    _colsController.dispose();
    super.dispose();
  }

  TableCellConfig _getCell(int row, int col) {
    for (final c in _cells) {
      if (c.row == row && c.col == col) return c;
    }
    return TableCellConfig(row: row, col: col);
  }

  void _setCell(int row, int col, TableCellConfig cell) {
    setState(() {
      _cells.removeWhere((c) => c.row == row && c.col == col);
      _cells.add(cell);
    });
  }

  void _saveAndPop() {
    final order = int.tryParse(_orderController.text.trim()) ?? widget.section.order;
    final rows = _rows;
    final cols = _cols;
    _syncCellsToGrid();
    _trimMergeRegionsToGrid();
    _syncSizesToGrid();
    final mergeErr = _validateMergeRegions();
    if (mergeErr != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mergeErr)));
      return;
    }
    final usedKeys = Set<String>.from(widget.keysUsedInOtherSections);
    for (final c in _cells) {
      if (!c.isInputField || c.key == null || c.key!.isEmpty) continue;
      if (usedKeys.contains(c.key)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ключ «${c.key}» уже используется в этом шаблоне. Задайте уникальный ключ ячейке.'),
          ),
        );
        return;
      }
      usedKeys.add(c.key!);
    }
    List<double>? columnWidthsMm;
    if (_columnWidthsMm.any((v) => v != null && v > 0)) {
      columnWidthsMm = _columnWidthsMm.map((v) => (v != null && v > 0) ? v : 0.0).toList();
    }
    List<double>? rowHeightsMm;
    if (_rowHeightsMm.any((v) => v != null && v > 0)) {
      rowHeightsMm = _rowHeightsMm.map((v) => (v != null && v > 0) ? v : 0.0).toList();
    }
    final config = TableSectionConfig(
      tableRows: rows,
      tableCols: cols,
      cells: _cells,
      mergeRegions: _mergeRegions,
      columnWidthsMm: columnWidthsMm,
      rowHeightsMm: rowHeightsMm,
    );
    Navigator.pop(
      context,
      widget.section.copyWith(
        title: _titleController.text.trim().isEmpty ? widget.section.title : _titleController.text.trim(),
        order: order.clamp(1, 999),
        tableConfig: config,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    final cols = _cols;
    if (_cells.length != rows * cols || _columnWidthsMm.length != cols || _rowHeightsMm.length != rows) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _syncCellsToGrid();
            _trimMergeRegionsToGrid();
            _syncSizesToGrid();
          });
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование раздела «Таблица»'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Отмена',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAndPop,
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Название раздела',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _orderController,
              decoration: const InputDecoration(labelText: 'Порядок', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            // VET-179: выбор количества строк и столбцов из выпадающего списка
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _rows.clamp(1, 20),
                    decoration: const InputDecoration(labelText: 'Строк', border: OutlineInputBorder()),
                    isExpanded: true,
                    items: List.generate(20, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                    onChanged: (v) {
                      if (v != null) {
                        _rowsController.text = '$v';
                        setState(() {});
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _cols.clamp(1, 10),
                    decoration: const InputDecoration(labelText: 'Столбцов', border: OutlineInputBorder()),
                    isExpanded: true,
                    items: List.generate(10, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                    onChanged: (v) {
                      if (v != null) {
                        _colsController.text = '$v';
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text('Объединения ячеек'),
              initiallyExpanded: _mergeRegions.isNotEmpty,
              children: [
                ..._mergeRegions.asMap().entries.map((e) => _MergeRegionEditor(
                  region: e.value,
                  maxRows: rows,
                  maxCols: cols,
                  onChanged: (m) => setState(() => _mergeRegions[e.key] = m),
                  onRemove: () => setState(() => _mergeRegions.removeAt(e.key)),
                )),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FilledButton.tonal(
                    onPressed: () => setState(() => _mergeRegions.add(const TableMergeRegion(row: 0, col: 0, rowSpan: 1, colSpan: 1, mainCellRow: 0, mainCellCol: 0))),
                    child: const Text('Добавить объединение'),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text('Размеры (мм)'),
              initiallyExpanded: _columnWidthsMm.any((v) => v != null) || _rowHeightsMm.any((v) => v != null),
              children: [
                Text('Ширина столбцов (мм). Пусто = поровну.', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(cols, (i) {
                    return SizedBox(
                      width: 72,
                      child: TextFormField(
                        key: ValueKey('cw$i'),
                        initialValue: _columnWidthsMm[i] != null ? '${_columnWidthsMm[i]!.round()}' : '',
                        decoration: InputDecoration(labelText: 'Столб. ${i + 1}', isDense: true, border: const OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        onChanged: (s) {
                          final v = double.tryParse(s.replaceAll(',', '.'));
                          setState(() => _columnWidthsMm[i] = v);
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text('Высота строк (мм). Пусто = поровну.', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(rows, (i) {
                    return SizedBox(
                      width: 72,
                      child: TextFormField(
                        key: ValueKey('rh$i'),
                        initialValue: _rowHeightsMm[i] != null ? '${_rowHeightsMm[i]!.round()}' : '',
                        decoration: InputDecoration(labelText: 'Строка ${i + 1}', isDense: true, border: const OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        onChanged: (s) {
                          final v = double.tryParse(s.replaceAll(',', '.'));
                          setState(() => _rowHeightsMm[i] = v);
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
              ],
            ),
            const SizedBox(height: 16),
            Text('Ячейки (для каждой: поле ввода или статичный текст)', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...List.generate(rows * cols, (i) {
              final r = i ~/ cols;
              final c = i % cols;
              final cell = _getCell(r, c);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _TableCellEditor(
                  row: r,
                  col: c,
                  cell: cell,
                  onChanged: (newCell) => _setCell(r, c, newCell),
                  fieldTypes: _fieldTypes,
                  onPickImage: _pickImageForCell,
                ),
              );
            }),
            const SizedBox(height: 24),
            FilledButton(onPressed: _saveAndPop, child: const Text('Сохранить')),
          ],
        ),
      ),
    );
  }
}

class _MergeRegionEditor extends StatefulWidget {
  const _MergeRegionEditor({
    required this.region,
    required this.maxRows,
    required this.maxCols,
    required this.onChanged,
    required this.onRemove,
  });

  final TableMergeRegion region;
  final int maxRows;
  final int maxCols;
  final ValueChanged<TableMergeRegion> onChanged;
  final VoidCallback onRemove;

  @override
  State<_MergeRegionEditor> createState() => _MergeRegionEditorState();
}

class _MergeRegionEditorState extends State<_MergeRegionEditor> {
  late TextEditingController _rowC;
  late TextEditingController _colC;
  late TextEditingController _rowSpanC;
  late TextEditingController _colSpanC;
  late TextEditingController _mainRowC;
  late TextEditingController _mainColC;

  @override
  void initState() {
    super.initState();
    _rowC = TextEditingController(text: '${widget.region.row + 1}');
    _colC = TextEditingController(text: '${widget.region.col + 1}');
    _rowSpanC = TextEditingController(text: '${widget.region.rowSpan}');
    _colSpanC = TextEditingController(text: '${widget.region.colSpan}');
    _mainRowC = TextEditingController(text: '${widget.region.mainCellRow + 1}');
    _mainColC = TextEditingController(text: '${widget.region.mainCellCol + 1}');
  }

  @override
  void dispose() {
    _rowC.dispose();
    _colC.dispose();
    _rowSpanC.dispose();
    _colSpanC.dispose();
    _mainRowC.dispose();
    _mainColC.dispose();
    super.dispose();
  }

  void _notifyChanged() {
    final row1 = (int.tryParse(_rowC.text) ?? 1).clamp(1, widget.maxRows);
    final col1 = (int.tryParse(_colC.text) ?? 1).clamp(1, widget.maxCols);
    final row = row1 - 1;
    final col = col1 - 1;
    final rowSpan = (int.tryParse(_rowSpanC.text) ?? 1).clamp(1, widget.maxRows);
    final colSpan = (int.tryParse(_colSpanC.text) ?? 1).clamp(1, widget.maxCols);
    final mainRow1 = (int.tryParse(_mainRowC.text) ?? 1).clamp(row1, row1 + rowSpan - 1);
    final mainCol1 = (int.tryParse(_mainColC.text) ?? 1).clamp(col1, col1 + colSpan - 1);
    widget.onChanged(TableMergeRegion(row: row, col: col, rowSpan: rowSpan, colSpan: colSpan, mainCellRow: mainRow1 - 1, mainCellCol: mainCol1 - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: _rowC, decoration: const InputDecoration(labelText: 'Строка', isDense: true), keyboardType: TextInputType.number, onChanged: (_) => _notifyChanged())),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _colC, decoration: const InputDecoration(labelText: 'Столбец', isDense: true), keyboardType: TextInputType.number, onChanged: (_) => _notifyChanged())),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _rowSpanC, decoration: const InputDecoration(labelText: 'Высота', isDense: true), keyboardType: TextInputType.number, onChanged: (_) => _notifyChanged())),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: _colSpanC, decoration: const InputDecoration(labelText: 'Ширина', isDense: true), keyboardType: TextInputType.number, onChanged: (_) => _notifyChanged())),
                IconButton(icon: const Icon(Icons.delete_outline), onPressed: widget.onRemove, tooltip: 'Удалить'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Главная ячейка: ', style: Theme.of(context).textTheme.bodySmall),
                SizedBox(width: 56, child: TextField(controller: _mainRowC, decoration: const InputDecoration(labelText: 'Стр.', isDense: true), keyboardType: TextInputType.number, onChanged: (_) => _notifyChanged())),
                const SizedBox(width: 8),
                SizedBox(width: 56, child: TextField(controller: _mainColC, decoration: const InputDecoration(labelText: 'Столб.', isDense: true), keyboardType: TextInputType.number, onChanged: (_) => _notifyChanged())),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TableCellEditor extends StatelessWidget {
  const _TableCellEditor({
    required this.row,
    required this.col,
    required this.cell,
    required this.onChanged,
    required this.fieldTypes,
    this.onPickImage,
  });

  final int row;
  final int col;
  final TableCellConfig cell;
  final void Function(TableCellConfig) onChanged;
  final List<String> fieldTypes;
  final Future<String?> Function()? onPickImage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // VET-175: строка с индексом ячейки, иконка «Поле ввода», при включённом — выбор типа поля
            Row(
              children: [
                Text('[${row + 1},${col + 1}]', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Поле ввода',
                  icon: Icon(cell.isInputField ? Icons.edit_note : Icons.text_snippet),
                  onPressed: () => onChanged(TableCellConfig(
                    row: row,
                    col: col,
                    isInputField: !cell.isInputField,
                    fieldType: cell.fieldType,
                    key: cell.key,
                    label: cell.label,
                    staticText: cell.staticText,
                    imageRef: cell.imageRef,
                  )),
                ),
                if (cell.isInputField)
                  Expanded(
                    child: DropdownButton<String>(
                      value: cell.fieldType ?? 'text',
                      isExpanded: true,
                      items: fieldTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => onChanged(TableCellConfig(
                        row: row,
                        col: col,
                        isInputField: true,
                        fieldType: v ?? 'text',
                        key: cell.key ?? 'cell_${row}_$col',
                        label: cell.label ?? '',
                        staticText: cell.staticText,
                        imageRef: cell.imageRef,
                      )),
                    ),
                  ),
              ],
            ),
            // Поле «Текст» под настройкой «Поле ввода» (только для статичной ячейки)
            if (!cell.isInputField) ...[
              const SizedBox(height: 4),
              TextFormField(
                decoration: const InputDecoration(isDense: true, hintText: 'Текст', border: OutlineInputBorder()),
                initialValue: cell.staticText ?? '',
                onChanged: (v) => onChanged(TableCellConfig(
                  row: row,
                  col: col,
                  isInputField: false,
                  staticText: v.isEmpty ? null : v,
                  imageRef: cell.imageRef,
                )),
              ),
            ],
            if (cell.isInputField) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Ключ', isDense: true, border: OutlineInputBorder()),
                      initialValue: cell.key ?? 'cell_${row}_$col',
                      onChanged: (v) => onChanged(TableCellConfig(row: row, col: col, isInputField: true, fieldType: cell.fieldType, key: v.isEmpty ? null : v, label: cell.label, staticText: cell.staticText, imageRef: cell.imageRef)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Подпись', isDense: true, border: OutlineInputBorder()),
                      initialValue: cell.label ?? '',
                      onChanged: (v) => onChanged(TableCellConfig(row: row, col: col, isInputField: true, fieldType: cell.fieldType, key: cell.key, label: v.isEmpty ? null : v, staticText: cell.staticText, imageRef: cell.imageRef)),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                if (onPickImage != null)
                  TextButton.icon(
                    icon: const Icon(Icons.image_outlined, size: 20),
                    label: Text(cell.imageRef != null ? 'Сменить картинку' : 'Картинка'),
                    onPressed: () async {
                      final path = await onPickImage!();
                      if (path != null && context.mounted) {
                        onChanged(TableCellConfig(row: row, col: col, isInputField: cell.isInputField, fieldType: cell.fieldType, key: cell.key, label: cell.label, staticText: cell.staticText, imageRef: path));
                      }
                    },
                  ),
                if (cell.imageRef != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cell.imageRef!.length > 40 ? '${cell.imageRef!.substring(0, 40)}...' : cell.imageRef!,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    tooltip: 'Убрать картинку',
                    onPressed: () => onChanged(TableCellConfig(row: row, col: col, isInputField: cell.isInputField, fieldType: cell.fieldType, key: cell.key, label: cell.label, staticText: cell.staticText, imageRef: null)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
