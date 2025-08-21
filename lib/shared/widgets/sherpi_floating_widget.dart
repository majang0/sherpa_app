import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/global_sherpi_provider.dart';
import 'sherpi_widget.dart';

// 플로팅 셰르피 위젯 - 화면 어디든 드래그 가능
class SherpiFloatingWidget extends ConsumerStatefulWidget {
  final bool isDraggable;
  final Offset? initialPosition;

  const SherpiFloatingWidget({
    Key? key,
    this.isDraggable = true,
    this.initialPosition,
  }) : super(key: key);

  @override
  ConsumerState<SherpiFloatingWidget> createState() => _SherpiFloatingWidgetState();
}

class _SherpiFloatingWidgetState extends ConsumerState<SherpiFloatingWidget> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition ?? const Offset(20, 100);
  }

  @override
  Widget build(BuildContext context) {
    final isVisible = ref.watch(sherpiVisibilityProvider);

    if (!isVisible) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: widget.isDraggable
          ? Draggable(
        feedback: SherpiWidget(
          width: 100,
          height: 100,
          showDialogue: false,
        ),
        childWhenDragging: Container(),
        onDragEnd: (details) {
          setState(() {
            _position = Offset(
              details.offset.dx.clamp(0, screenSize.width - 120),
              details.offset.dy.clamp(0, screenSize.height - 120),
            );
          });
        },
        child: SherpiWidget(
          width: 100,
          height: 100,
          showDialogue: true,
        ),
      )
          : SherpiWidget(
        width: 100,
        height: 100,
        showDialogue: true,
      ),
    );
  }
}
