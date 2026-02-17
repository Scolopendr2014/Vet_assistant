import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../templates/domain/entities/protocol_template.dart'
    show
        sectionKindPhotos,
        AnamnesisPrintSettings,
        ProtocolHeaderPrintSettings,
        PhotosPrintSettings,
        SectionPrintSettings,
        TemplateSection;

/// Размеры A4 в мм (VET-068).
const double _a4WidthMm = 210;
const double _a4HeightMm = 297;

/// Шаг сетки в пикселях превью.
const double _gridStepPx = 10;

/// Ширина зоны у грани блока для ресайза одним пальцем (VET-098), в пикселях превью.
const double _edgeResizeZonePx = 16;

/// Результат сохранения визуального редактора. VET-149: фото-разделы входят в sections.
typedef PrintLayoutSaveResult = ({
  List<TemplateSection> sections,
  ProtocolHeaderPrintSettings? headerPrintSettings,
  AnamnesisPrintSettings? anamnesisPrintSettings,
});

/// Описание блока: тип, индекс, rect (мм), pageIndex.
class _BlockInfo {
  _BlockInfo({
    required this.type,
    required this.index,
    required this.rect,
    required this.pageIndex,
    this.section,
  });

  final _BlockType type;
  final int index;
  final RectMm rect;
  int pageIndex;
  final TemplateSection? section;
}

enum _BlockType { header, anamnesis, photos, section }

/// Грань блока для ресайза одним пальцем (VET-098).
enum _EdgeResizeSide { left, right, top, bottom }

class RectMm {
  RectMm(this.left, this.top, this.width, this.height);
  double left;
  double top;
  double width;
  double height;
}

double _snapToGridPx(double px) => (px / _gridStepPx).round() * _gridStepPx;

/// Определяет, какая грань блока затронута касанием (VET-098).
_EdgeResizeSide? _hitTestEdge(Offset localPoint, double widthPx, double heightPx) {
  if (localPoint.dx < _edgeResizeZonePx) return _EdgeResizeSide.left;
  if (localPoint.dx > widthPx - _edgeResizeZonePx) return _EdgeResizeSide.right;
  if (localPoint.dy < _edgeResizeZonePx) return _EdgeResizeSide.top;
  if (localPoint.dy > heightPx - _edgeResizeZonePx) return _EdgeResizeSide.bottom;
  return null;
}

/// Визуальный редактор: единый скролл, страницы с нумерацией, авто-добавление/удаление страниц.
/// VET-095: Ресайз раздела — жестом pinch (два пальца), без ручки в углу; при ресайзе показывается размер в рамке.
/// VET-097: Приоритет drag над scroll; подсветка раздела при нажатии и при перетаскивании.
/// VET-098: Ресайз одним пальцем за конкретную грань (край блока).
class PrintLayoutEditorPage extends StatefulWidget {
  const PrintLayoutEditorPage({
    super.key,
    required this.sections,
    required this.onSave,
    this.headerPrintSettings,
    this.anamnesisPrintSettings,
  });

  final List<TemplateSection> sections;
  final void Function(PrintLayoutSaveResult result) onSave;
  final ProtocolHeaderPrintSettings? headerPrintSettings;
  final AnamnesisPrintSettings? anamnesisPrintSettings;

  @override
  State<PrintLayoutEditorPage> createState() => _PrintLayoutEditorPageState();
}

class _PrintLayoutEditorPageState extends State<PrintLayoutEditorPage> {
  late List<_BlockInfo> _blocks;
  int _pageCount = 2;
  int? _draggingIndex;
  int? _resizingIndex;
  int? _edgeResizeIndex; // VET-098
  _EdgeResizeSide? _edgeResizeSide;
  double? _scaleStartWidthMm;
  double? _scaleStartHeightMm;

  @override
  void initState() {
    super.initState();
    _initBlocks();
  }

  void _initBlocks() {
    final list = <_BlockInfo>[];

    final h = widget.headerPrintSettings;
    final headerRect = h != null && h.positionX != null && h.positionY != null &&
            h.width != null && h.height != null
        ? RectMm(h.positionX!, h.positionY!, h.width!, h.height!)
        : RectMm(15, 15, 180, 45);
    list.add(_BlockInfo(
      type: _BlockType.header,
      index: 0,
      rect: headerRect,
      pageIndex: h?.pageIndex ?? 0,
    ));

    final a = widget.anamnesisPrintSettings;
    final anamRect = a != null && a.positionX != null && a.positionY != null &&
            a.width != null && a.height != null
        ? RectMm(a.positionX!, a.positionY!, a.width!, a.height!)
        : RectMm(15, 75, 180, 60);
    list.add(_BlockInfo(
      type: _BlockType.anamnesis,
      index: 0,
      rect: anamRect,
      pageIndex: a?.pageIndex ?? 0,
    ));

    // VET-149: один блок на каждый раздел «Фотографии» (настройки из section.photosPrintSettings).
    var photosBlockIndex = 0;
    for (var i = 0; i < widget.sections.length; i++) {
      final sec = widget.sections[i];
      if (sec.sectionKind != sectionKindPhotos) continue;
      final p = sec.photosPrintSettings;
      final photosRect = p != null && p.positionX != null && p.positionY != null &&
              p.width != null && p.height != null
          ? RectMm(p.positionX!, p.positionY!, p.width!, p.height!)
          : RectMm(15.0 + (photosBlockIndex % 2) * 95, 145.0 + (photosBlockIndex ~/ 2) * 45, 90, 40);
      list.add(_BlockInfo(
        type: _BlockType.photos,
        index: i,
        rect: photosRect,
        pageIndex: p?.pageIndex ?? 1,
        section: sec,
      ));
      photosBlockIndex++;
    }

    for (var i = 0; i < widget.sections.length; i++) {
      final sec = widget.sections[i];
      if (sec.sectionKind == sectionKindPhotos) continue;
      final ps = sec.printSettings;
      final rect = ps != null &&
              ps.positionX != null &&
              ps.positionY != null &&
              ps.width != null &&
              ps.height != null
          ? RectMm(ps.positionX!, ps.positionY!, ps.width!, ps.height!)
          : RectMm(20.0 + (i % 2) * 100, 20.0 + (i ~/ 2) * 35, 80, 25);
      list.add(_BlockInfo(
        type: _BlockType.section,
        index: i,
        rect: rect,
        pageIndex: ps?.pageIndex ?? 1,
        section: sec,
      ));
    }

    _blocks = list;
    _recomputePageCount();
  }

  void _clampToPage(RectMm r) {
    r.left = r.left.clamp(0.0, _a4WidthMm - 10);
    r.top = r.top.clamp(0.0, _a4HeightMm - 10);
    r.width = r.width.clamp(10.0, _a4WidthMm - r.left);
    r.height = r.height.clamp(8.0, _a4HeightMm - r.top);
  }

  void _recomputePageCount() {
    if (_blocks.isEmpty) {
      _pageCount = 1;
      return;
    }
    final maxPage = _blocks.map((b) => b.pageIndex).reduce((a, b) => a > b ? a : b);
    _pageCount = maxPage + 1;
  }

  void _onBlockMoved(int blockIdx, int newPageIndex, double newTop) {
    if (newPageIndex < 0) {
      for (final b in _blocks) {
        b.pageIndex = b.pageIndex + 1;
      }
      newPageIndex = 0;
      _pageCount++;
    }
    _blocks[blockIdx].pageIndex = newPageIndex;
    _blocks[blockIdx].rect.top = newTop.clamp(0.0, _a4HeightMm - _blocks[blockIdx].rect.height);
    _clampToPage(_blocks[blockIdx].rect);
    if (newPageIndex >= _pageCount) {
      _pageCount = newPageIndex + 1;
    }
  }

  void _removeEmptyPages() {
    final usedPages = _blocks.map((b) => b.pageIndex).toSet();
    if (usedPages.isEmpty) {
      _pageCount = 1;
      return;
    }
    final sorted = usedPages.toList()..sort();
    final oldToNew = <int, int>{};
    for (var i = 0; i < sorted.length; i++) {
      oldToNew[sorted[i]] = i;
    }
    for (final b in _blocks) {
      b.pageIndex = oldToNew[b.pageIndex] ?? b.pageIndex;
    }
    _pageCount = sorted.length;
  }

  void _saveAndPop() {
    _removeEmptyPages();

    final updatedSections = <TemplateSection>[];
    for (var i = 0; i < widget.sections.length; i++) {
      _BlockInfo? block;
      for (final b in _blocks) {
        if ((b.type == _BlockType.section || b.type == _BlockType.photos) && b.index == i) {
          block = b;
          break;
        }
      }
      if (block == null) {
        updatedSections.add(widget.sections[i]);
        continue;
      }
      final r = block.rect;
      _clampToPage(r);
      final sec = widget.sections[i];
      if (sec.sectionKind == sectionKindPhotos) {
        final prev = sec.photosPrintSettings;
        updatedSections.add(sec.copyWith(
          photosPrintSettings: PhotosPrintSettings(
            positionX: r.left,
            positionY: r.top,
            width: r.width,
            height: r.height,
            pageIndex: block.pageIndex,
            photosPerRow: prev?.photosPerRow ?? 2,
          ),
        ));
      } else {
        final ps = sec.printSettings;
        updatedSections.add(sec.copyWith(
          printSettings: SectionPrintSettings(
            positionX: r.left,
            positionY: r.top,
            width: r.width,
            height: r.height,
            pageIndex: block.pageIndex,
            fontSize: ps?.fontSize,
            bold: ps?.bold ?? false,
            italic: ps?.italic ?? false,
            showBorder: ps?.showBorder ?? false,
            borderShape: ps?.borderShape ?? 'rectangular',
          ),
        ));
      }
    }

    _BlockInfo? headerBlock;
    for (final b in _blocks) {
      if (b.type == _BlockType.header) {
        headerBlock = b;
        break;
      }
    }
    final headerRect = headerBlock?.rect ?? RectMm(15, 15, 180, 45);
    _clampToPage(headerRect);
    final header = widget.headerPrintSettings != null
        ? ProtocolHeaderPrintSettings(
            fontSize: widget.headerPrintSettings!.fontSize,
            bold: widget.headerPrintSettings!.bold,
            italic: widget.headerPrintSettings!.italic,
            showTitle: widget.headerPrintSettings!.showTitle,
            showTemplateType: widget.headerPrintSettings!.showTemplateType,
            showDate: widget.headerPrintSettings!.showDate,
            showPatient: widget.headerPrintSettings!.showPatient,
            showOwner: widget.headerPrintSettings!.showOwner,
            positionX: headerRect.left,
            positionY: headerRect.top,
            width: headerRect.width,
            height: headerRect.height,
            pageIndex: headerBlock?.pageIndex ?? 0,
          )
        : ProtocolHeaderPrintSettings(
            positionX: headerRect.left,
            positionY: headerRect.top,
            width: headerRect.width,
            height: headerRect.height,
            pageIndex: 0,
          );

    _BlockInfo? anamBlock;
    for (final b in _blocks) {
      if (b.type == _BlockType.anamnesis) {
        anamBlock = b;
        break;
      }
    }
    final anamRect = anamBlock?.rect ?? RectMm(15, 75, 180, 60);
    _clampToPage(anamRect);
    final anamnesis = AnamnesisPrintSettings(
      positionX: anamRect.left,
      positionY: anamRect.top,
      width: anamRect.width,
      height: anamRect.height,
      pageIndex: anamBlock?.pageIndex ?? 0,
    );

    widget.onSave((
      sections: updatedSections,
      headerPrintSettings: header,
      anamnesisPrintSettings: anamnesis,
    ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расположение на странице'),
        actions: [
          TextButton(
            onPressed: _saveAndPop,
            child: const Text('Сохранить'),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scale = math.min(
            constraints.maxWidth / _a4WidthMm,
            (constraints.maxHeight - 48) / _a4HeightMm,
          ).clamp(0.5, 4.0);
          final pageWidth = _a4WidthMm * scale;
          final pageHeight = _a4HeightMm * scale;

          final isBlockActive = _draggingIndex != null ||
              _resizingIndex != null ||
              _edgeResizeIndex != null;
          return Listener(
            onPointerUp: (_) {
              // VET-099: отложенный сброс, чтобы onScaleEnd успел применить привязку к сетке
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _draggingIndex = null;
                    _resizingIndex = null;
                    _edgeResizeIndex = null;
                    _edgeResizeSide = null;
                  });
                }
              });
            },
            onPointerCancel: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _draggingIndex = null;
                    _resizingIndex = null;
                    _edgeResizeIndex = null;
                    _edgeResizeSide = null;
                  });
                }
              });
            },
            child: SingleChildScrollView(
              physics: isBlockActive
                  ? const NeverScrollableScrollPhysics()
                  : null,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                    'Перетащите блок — перемещение. Два пальца — изменение размера. Потяните за край блока — ресайз одной гранью. При выходе за границу добавляется страница. Пустые страницы удаляются. Масштаб: ${(scale * 100).round()}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    ...List.generate(_pageCount, (pageIdx) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: pageIdx < _pageCount - 1 ? 12 : 0,
                        ),
                        child: _buildPage(
                          pageIdx,
                          scale,
                          pageWidth,
                          pageHeight,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
        );
        },
      ),
    );
  }

  Widget _buildPage(
    int pageIdx,
    double scale,
    double pageWidth,
    double pageHeight,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: Colors.grey.shade200,
          child: Text(
            'Страница ${pageIdx + 1}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          width: pageWidth,
          height: pageHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: pageWidth,
                height: pageHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              CustomPaint(
                size: Size(pageWidth, pageHeight),
                painter: _GridPainter(stepPx: _gridStepPx),
              ),
              ...() {
                final list = <Widget>[];
                for (var i = 0; i < _blocks.length; i++) {
                  final b = _blocks[i];
                  if (b.pageIndex == pageIdx) {
                    list.add(_buildBlock(i, b, scale, pageWidth, pageHeight));
                  }
                }
                return list;
              }(),
            ],
          ),
        ),
      ],
    );
  }

  /// VET-151: сетка ячеек таблицы в визуальном редакторе (размеры в мм, объединения не отрисовываем в превью).
  Widget _buildTableBlockContent(
    BuildContext context,
    String title,
    Color color,
    double widthPx,
    double heightPx,
    TemplateSection section,
    double scale,
  ) {
    final tc = section.tableConfig;
    if (tc == null) {
      return Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color.withValues(alpha: 1),
              fontWeight: FontWeight.w600,
            ),
      );
    }
    const titleHeight = 22.0;
    final rows = tc.tableRows.clamp(1, 20);
    final cols = tc.tableCols.clamp(1, 10);
    final availableW = widthPx - 12;
    final availableH = heightPx - titleHeight - 12;
    final colWidths = List.generate(cols, (c) {
      if (tc.columnWidthsMm != null && c < tc.columnWidthsMm!.length) {
        return (tc.columnWidthsMm![c] * scale).clamp(8.0, availableW);
      }
      return availableW / cols;
    });
    final rowHeights = List.generate(rows, (r) {
      if (tc.rowHeightsMm != null && r < tc.rowHeightsMm!.length) {
        return (tc.rowHeightsMm![r] * scale).clamp(8.0, availableH);
      }
      return availableH / rows;
    });
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color.withValues(alpha: 1),
                fontWeight: FontWeight.w600,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        ...List.generate(rows, (r) {
          final h = r < rowHeights.length ? rowHeights[r].clamp(4.0, 80.0) : availableH / rows;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(cols, (c) {
              final w = c < colWidths.length ? colWidths[c].clamp(4.0, 100.0) : availableW / cols;
              return Container(
                width: w,
                height: h,
                decoration: BoxDecoration(
                  border: Border.all(color: color.withValues(alpha: 0.7)),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  /// VET-152: схематичная сетка фото в блоке раздела «Фотографии» по настройке «фото в ряд».
  Widget _buildPhotosBlockContent(
    BuildContext context,
    String title,
    Color color,
    double widthPx,
    double heightPx,
    int photosPerRow,
  ) {
    const int placeholderRows = 2;
    final cols = photosPerRow.clamp(1, 4);
    const gap = 4.0;
    final availableW = widthPx - 12;
    final availableH = heightPx - 28;
    final cellW = availableW > 0 && cols > 0
        ? (availableW - (cols - 1) * gap) / cols
        : 24.0;
    final cellH = availableH > 0 && placeholderRows > 0
        ? (availableH - (placeholderRows - 1) * gap) / placeholderRows
        : 20.0;
    final cells = <Widget>[];
    for (var row = 0; row < placeholderRows; row++) {
      for (var col = 0; col < cols; col++) {
        cells.add(
          Container(
            width: cellW.clamp(8.0, 80.0),
            height: cellH.clamp(8.0, 60.0),
            decoration: BoxDecoration(
              border: Border.all(color: color.withValues(alpha: 0.8)),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Icon(Icons.photo_outlined, size: (cellW.clamp(8.0, 80.0) * 0.4).clamp(8.0, 24.0), color: color.withValues(alpha: 0.6)),
          ),
        );
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color.withValues(alpha: 1),
                fontWeight: FontWeight.w600,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: cells,
        ),
      ],
    );
  }

  Widget _buildBlock(
    int blockIdx,
    _BlockInfo block,
    double scale,
    double pageWidth,
    double pageHeight,
  ) {
    final r = block.rect;
    final left = r.left * scale;
    final top = r.top * scale;
    final width = r.width * scale;
    final height = r.height * scale;
    final isResizing = _resizingIndex == blockIdx;
    final isEdgeResizing = _edgeResizeIndex == blockIdx; // VET-098
    final isDragging = _draggingIndex == blockIdx;
    final isHighlighted = isResizing || isEdgeResizing || isDragging;

    String title;
    Color color;
    switch (block.type) {
      case _BlockType.header:
        title = 'Шапка';
        color = Colors.green;
        break;
      case _BlockType.anamnesis:
        title = 'Анамнез';
        color = Colors.orange;
        break;
      case _BlockType.photos:
        title = block.section?.title ?? 'Фотографии';
        color = Colors.purple;
        break;
      case _BlockType.section:
        title = block.section?.title ?? 'Раздел';
        color = Colors.blue;
        break;
    }

    return Positioned(
      left: left,
      top: top,
      child: Listener(
        onPointerDown: (_) {
          setState(() {
            _draggingIndex = blockIdx;
          });
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: (details) {
          setState(() {
            if (details.pointerCount >= 2) {
              _resizingIndex = blockIdx;
              _scaleStartWidthMm = r.width;
              _scaleStartHeightMm = r.height;
              _draggingIndex = null;
              _edgeResizeIndex = null;
              _edgeResizeSide = null;
            } else {
              // VET-098: ресайз одним пальцем за грань
              final edge = _hitTestEdge(
                details.localFocalPoint,
                width,
                height,
              );
              if (edge != null) {
                _edgeResizeIndex = blockIdx;
                _edgeResizeSide = edge;
                _draggingIndex = null;
                _resizingIndex = null;
              } else {
                _draggingIndex = blockIdx;
                _resizingIndex = null;
                _edgeResizeIndex = null;
                _edgeResizeSide = null;
              }
            }
          });
        },
        onScaleUpdate: (details) {
          if (details.pointerCount >= 2 &&
              _resizingIndex == blockIdx &&
              _scaleStartWidthMm != null &&
              _scaleStartHeightMm != null) {
            setState(() {
              r.width = (_scaleStartWidthMm! * details.scale)
                  .clamp(20.0, _a4WidthMm - r.left);
              r.height = (_scaleStartHeightMm! * details.scale)
                  .clamp(12.0, _a4HeightMm - r.top);
            });
          } else if (details.pointerCount == 1 &&
              _edgeResizeIndex == blockIdx &&
              _edgeResizeSide != null) {
            // VET-098: ресайз за одну грань
            setState(() {
              final deltaX = details.focalPointDelta.dx / scale;
              final deltaY = details.focalPointDelta.dy / scale;
              switch (_edgeResizeSide!) {
                case _EdgeResizeSide.left:
                  final newLeft =
                      (r.left + deltaX).clamp(0.0, r.left + r.width - 20);
                  r.width = (r.left + r.width - newLeft)
                      .clamp(20.0, _a4WidthMm - newLeft);
                  r.left = newLeft;
                  break;
                case _EdgeResizeSide.right:
                  r.width = (r.width + deltaX)
                      .clamp(20.0, _a4WidthMm - r.left);
                  break;
                case _EdgeResizeSide.top:
                  final newTop =
                      (r.top + deltaY).clamp(0.0, r.top + r.height - 12);
                  r.height = (r.top + r.height - newTop)
                      .clamp(12.0, _a4HeightMm - newTop);
                  r.top = newTop;
                  break;
                case _EdgeResizeSide.bottom:
                  r.height = (r.height + deltaY)
                      .clamp(12.0, _a4HeightMm - r.top);
                  break;
              }
              _clampToPage(r);
            });
          } else if (details.pointerCount == 1 && _draggingIndex == blockIdx) {
            setState(() {
              final deltaX = details.focalPointDelta.dx / scale;
              final deltaY = details.focalPointDelta.dy / scale;
              final newLeft = (r.left + deltaX).clamp(0.0, _a4WidthMm - r.width);
              final newTop = r.top + deltaY;

              if (newTop + r.height > _a4HeightMm) {
                r.left = newLeft;
                final newTopOnNextPage = (newTop - _a4HeightMm).clamp(0.0, _a4HeightMm - r.height);
                _onBlockMoved(blockIdx, block.pageIndex + 1, newTopOnNextPage);
              } else if (newTop < 0) {
                r.left = newLeft;
                _onBlockMoved(blockIdx, block.pageIndex - 1, _a4HeightMm + newTop);
              } else {
                r.left = newLeft;
                r.top = newTop.clamp(0.0, _a4HeightMm - r.height);
                _clampToPage(r);
              }
            });
          }
        },
        onScaleEnd: (_) {
          setState(() {
            if (_draggingIndex == blockIdx) {
              final leftPx = _snapToGridPx(r.left * scale).clamp(0.0, pageWidth - 1);
              final topPx = _snapToGridPx(r.top * scale).clamp(0.0, pageHeight - 1);
              r.left = leftPx / scale;
              r.top = topPx / scale;
              _clampToPage(r);
            } else if (_resizingIndex == blockIdx ||
                _edgeResizeIndex == blockIdx) {
              final wPx = _snapToGridPx(r.width * scale)
                  .clamp(_gridStepPx * 2, pageWidth - r.left * scale);
              final hPx = _snapToGridPx(r.height * scale)
                  .clamp(_gridStepPx * 2, pageHeight - r.top * scale);
              r.width = (wPx / scale).clamp(20.0, _a4WidthMm - r.left);
              r.height = (hPx / scale).clamp(12.0, _a4HeightMm - r.top);
              final leftPx = _snapToGridPx(r.left * scale).clamp(0.0, pageWidth - 1);
              final topPx = _snapToGridPx(r.top * scale).clamp(0.0, pageHeight - 1);
              r.left = leftPx / scale;
              r.top = topPx / scale;
              _clampToPage(r);
            }
            _draggingIndex = null;
            _resizingIndex = null;
            _edgeResizeIndex = null;
            _edgeResizeSide = null;
            _scaleStartWidthMm = null;
            _scaleStartHeightMm = null;
            _removeEmptyPages();
          });
        },
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isHighlighted ? 0.35 : 0.2),
                  border: Border.all(
                    color: isResizing || isEdgeResizing
                        ? Colors.orange
                        : (isDragging ? Colors.deepPurple : color),
                    width: isHighlighted ? 2.5 : 1.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: block.type == _BlockType.photos
                      ? _buildPhotosBlockContent(
                          context,
                          title,
                          color,
                          width,
                          height,
                          (block.section?.photosPrintSettings?.photosPerRow ?? 2).clamp(1, 4),
                        )
                      : block.type == _BlockType.section && block.section?.isTableSection == true
                          ? _buildTableBlockContent(
                              context,
                              title,
                              color,
                              width,
                              height,
                              block.section!,
                              scale,
                            )
                          : Text(
                              title,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: color.withValues(alpha: 1),
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                ),
              ),
              // VET-095, VET-098: при ресайзе показывать размер в виде рамки
              if (isResizing || isEdgeResizing)
                Positioned(
                  left: 0,
                  right: 0,
                  top: -20,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${r.width.toStringAsFixed(0)} × ${r.height.toStringAsFixed(0)} мм',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.stepPx});
  final double stepPx;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += stepPx) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += stepPx) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
