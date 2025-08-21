// lib/shared/widgets/components/molecules/create_meeting_fab_2025.dart

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// 2025 트렌드 모임 생성 플로팅 액션 버튼 - 고급 애니메이션과 3D 효과
class CreateMeetingFAB2025 extends StatefulWidget {
  final VoidCallback onTap;
  final bool isExpanded;
  final List<FABAction>? actions;
  final Color? backgroundColor;
  final IconData icon;
  final String? tooltip;
  final bool showPulse;
  
  const CreateMeetingFAB2025({
    super.key,
    required this.onTap,
    this.isExpanded = false,
    this.actions,
    this.backgroundColor,
    this.icon = Icons.add,
    this.tooltip,
    this.showPulse = false,
  });

  @override
  State<CreateMeetingFAB2025> createState() => _CreateMeetingFAB2025State();
}

class _CreateMeetingFAB2025State extends State<CreateMeetingFAB2025>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _expandController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _expandAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.125, // 45도 회전
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _expandAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutBack,
    ));

    if (widget.showPulse) {
      _startPulseAnimation();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _startPulseAnimation() {
    _pulseController.repeat(reverse: true);
  }

  void _stopPulseAnimation() {
    _pulseController.stop();
    _pulseController.reset();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _mainController.forward();
    _stopPulseAnimation();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _mainController.reverse();
    widget.onTap();
    
    if (widget.showPulse) {
      _startPulseAnimation();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _mainController.reverse();
    
    if (widget.showPulse) {
      _startPulseAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = widget.backgroundColor ?? 
                        Theme.of(context).primaryColor;
    
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Expanded Actions
        if (widget.actions != null && widget.isExpanded)
          ..._buildExpandedActions(isDark),
        
        // Main FAB
        AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimation,
            _pulseAnimation,
            _rotationAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: widget.showPulse 
                  ? _pulseAnimation.value * _scaleAnimation.value
                  : _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 2 * math.pi,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor,
                        primaryColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.4),
                        blurRadius: _isPressed ? 15 : 20,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: _isPressed ? 25 : 35,
                        offset: const Offset(0, 12),
                      ),
                      // Inner highlight for 3D effect (alternative approach)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(-1, -1),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(32),
                      onTapDown: _handleTapDown,
                      onTapUp: _handleTapUp,
                      onTapCancel: _handleTapCancel,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Center(
                              child: Icon(
                                widget.icon,
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Pulse Ring (when active)
        if (widget.showPulse)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 64 * _pulseAnimation.value,
                  height: 64 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32 * _pulseAnimation.value),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3 / _pulseAnimation.value),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  List<Widget> _buildExpandedActions(bool isDark) {
    if (widget.actions == null) return [];
    
    return widget.actions!.asMap().entries.map((entry) {
      final index = entry.key;
      final action = entry.value;
      
      return AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          final offset = (index + 1) * 70.0 * _expandAnimation.value;
          
          return Positioned(
            bottom: offset,
            right: 0,
            child: Transform.scale(
              scale: _expandAnimation.value,
              child: Opacity(
                opacity: _expandAnimation.value,
                child: _buildActionButton(action, isDark),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildActionButton(FABAction action, bool isDark) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              action.backgroundColor,
              action.backgroundColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: action.backgroundColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          action.icon,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// 확장 FAB 액션 모델
class FABAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  
  const FABAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor = Colors.blue,
  });
}

/// 간단한 원형 액션 버튼
class CircularActionButton2025 extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final String? tooltip;
  
  const CircularActionButton2025({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
    this.size = 48,
    this.tooltip,
  });

  @override
  State<CircularActionButton2025> createState() => _CircularActionButton2025State();
}

class _CircularActionButton2025State extends State<CircularActionButton2025>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.backgroundColor,
                    widget.backgroundColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(widget.size / 2),
                boxShadow: [
                  BoxShadow(
                    color: widget.backgroundColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(-1, -1),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                widget.icon,
                size: widget.size * 0.4,
                color: widget.iconColor,
              ),
            ),
          ),
        );
      },
    );
  }
}