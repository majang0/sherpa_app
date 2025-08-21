// lib/shared/widgets/components/molecules/search_bar_2025.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors_2025.dart';

/// 2025 트렌드 검색바 - Glassmorphism과 고급 애니메이션 효과
class SearchBar2025 extends StatefulWidget {
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onFilterTap;
  final VoidCallback? onMicTap;
  final TextEditingController? controller;
  final bool showFilter;
  final bool showMic;
  final bool showSuggestions;
  final List<String> suggestions;
  final EdgeInsets margin;
  
  const SearchBar2025({
    super.key,
    this.hintText = '모임을 검색해보세요',
    this.onChanged,
    this.onSubmitted,
    this.onFilterTap,
    this.onMicTap,
    this.controller,
    this.showFilter = true,
    this.showMic = false,
    this.showSuggestions = false,
    this.suggestions = const [],
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  });

  @override
  State<SearchBar2025> createState() => _SearchBar2025State();
}

class _SearchBar2025State extends State<SearchBar2025> 
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late AnimationController _focusController;
  late AnimationController _suggestionController;
  late Animation<double> _focusAnimation;
  late Animation<double> _suggestionAnimation;
  
  bool _isFocused = false;
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _suggestionController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    
    _focusAnimation = CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeOutCubic,
    );
    
    _suggestionAnimation = CurvedAnimation(
      parent: _suggestionController,
      curve: Curves.easeOutCubic,
    );
    
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    _focusController.dispose();
    _suggestionController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _focusController.forward();
      if (widget.showSuggestions && _controller.text.isNotEmpty) {
        _showSuggestionsPanel();
      }
    } else {
      _focusController.reverse();
      _hideSuggestionsPanel();
    }
  }

  void _handleTextChange() {
    widget.onChanged?.call(_controller.text);
    
    if (widget.showSuggestions) {
      _updateSuggestions(_controller.text);
    }
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      _hideSuggestionsPanel();
      return;
    }
    
    final filtered = widget.suggestions
        .where((suggestion) => 
            suggestion.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
    
    setState(() {
      _filteredSuggestions = filtered;
    });
    
    if (filtered.isNotEmpty && _isFocused) {
      _showSuggestionsPanel();
    } else {
      _hideSuggestionsPanel();
    }
  }

  void _showSuggestionsPanel() {
    if (!_showSuggestions) {
      setState(() => _showSuggestions = true);
      _suggestionController.forward();
    }
  }

  void _hideSuggestionsPanel() {
    if (_showSuggestions) {
      _suggestionController.reverse().then((_) {
        if (mounted) {
          setState(() => _showSuggestions = false);
        }
      });
    }
  }

  void _handleSuggestionTap(String suggestion) {
    _controller.text = suggestion;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    widget.onSubmitted?.call(suggestion);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: widget.margin,
      child: Column(
        children: [
          // Main Search Bar
          AnimatedBuilder(
            animation: _focusAnimation,
            builder: (context, child) {
              return Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: _isFocused
                        ? AppColors2025.glassBlue20
                        : AppColors2025.shadowLight,
                      blurRadius: _isFocused ? 20 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                            ? [
                                AppColors2025.glassWhite10,
                                AppColors2025.glassWhite10.withOpacity(0.5),
                              ]
                            : [
                                AppColors2025.surface,
                                AppColors2025.surfaceElevated,
                              ],
                        ),
                        border: Border.all(
                          color: _isFocused
                            ? AppColors2025.borderFocus
                            : AppColors2025.glassBorder,
                          width: _isFocused ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          // Search Icon
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.search,
                                size: 22,
                                color: _isFocused
                                  ? AppColors2025.primary
                                  : (isDark ? AppColors2025.textOnDark.withOpacity(0.7) : AppColors2025.textSecondary),
                              ),
                            ),
                          ),
                          
                          // Text Field
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? AppColors2025.textOnDark : AppColors2025.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: widget.hintText,
                                hintStyle: TextStyle(
                                  color: isDark 
                                    ? AppColors2025.textOnDark.withOpacity(0.5)
                                    : AppColors2025.textTertiary,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: widget.onSubmitted,
                            ),
                          ),
                          
                          // Action Buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_controller.text.isNotEmpty)
                                _buildActionButton(
                                  icon: Icons.close,
                                  onTap: () {
                                    _controller.clear();
                                    widget.onChanged?.call('');
                                  },
                                  isDark: isDark,
                                ),
                              
                              if (widget.showMic && widget.onMicTap != null)
                                _buildActionButton(
                                  icon: Icons.mic_outlined,
                                  onTap: widget.onMicTap!,
                                  isDark: isDark,
                                ),
                              
                              if (widget.showFilter && widget.onFilterTap != null)
                                _buildActionButton(
                                  icon: Icons.tune,
                                  onTap: widget.onFilterTap!,
                                  isDark: isDark,
                                  isLast: true,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Suggestions Panel
          if (_showSuggestions)
            AnimatedBuilder(
              animation: _suggestionAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _suggestionAnimation.value,
                  alignment: Alignment.topCenter,
                  child: Opacity(
                    opacity: _suggestionAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors2025.shadowLight,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                  ? [
                                      AppColors2025.glassWhite10,
                                      AppColors2025.glassWhite10.withOpacity(0.5),
                                    ]
                                  : [
                                      AppColors2025.surface,
                                      AppColors2025.surfaceElevated,
                                    ],
                              ),
                              border: Border.all(
                                color: AppColors2025.glassBorder,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: _filteredSuggestions.map((suggestion) {
                                final index = _filteredSuggestions.indexOf(suggestion);
                                final isLast = index == _filteredSuggestions.length - 1;
                                
                                return _buildSuggestionItem(
                                  suggestion,
                                  isDark: isDark,
                                  showDivider: !isLast,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    bool isLast = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        margin: EdgeInsets.only(
          right: isLast ? 8 : 4,
          left: 4,
        ),
        decoration: BoxDecoration(
          color: isDark 
            ? AppColors2025.glassWhite10
            : AppColors2025.neuBase.withOpacity(0.5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? AppColors2025.textOnDark.withOpacity(0.7) : AppColors2025.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(
    String suggestion, {
    required bool isDark,
    required bool showDivider,
  }) {
    return GestureDetector(
      onTap: () => _handleSuggestionTap(suggestion),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: isDark 
                    ? AppColors2025.glassBorderSoft
                    : AppColors2025.borderLight,
                  width: 0.5,
                ),
              )
            : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 18,
              color: isDark ? AppColors2025.textOnDark.withOpacity(0.6) : AppColors2025.textTertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors2025.textOnDark.withOpacity(0.7) : AppColors2025.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.north_west,
              size: 16,
              color: isDark ? AppColors2025.textOnDark.withOpacity(0.38) : AppColors2025.textQuaternary,
            ),
          ],
        ),
      ),
    );
  }
}