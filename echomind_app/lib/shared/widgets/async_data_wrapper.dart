import 'package:flutter/material.dart';
import 'package:echomind_app/shared/widgets/clay_loading_state.dart';
import 'package:echomind_app/shared/widgets/clay_error_state.dart';
import 'package:echomind_app/shared/widgets/clay_empty_state.dart';

/// The current state of an async data fetch.
enum AsyncStatus { loading, error, empty, data }

/// A wrapper widget that handles loading / error / empty / data states
/// with Claymorphism-styled placeholders.
class AsyncDataWrapper<T> extends StatelessWidget {
  final AsyncStatus status;
  final T? data;
  final Widget Function(BuildContext context, T data) builder;
  final bool Function(T data)? isEmpty;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String emptyMessage;
  final IconData emptyIcon;
  final int loadingItemCount;

  const AsyncDataWrapper({
    super.key,
    required this.status,
    this.data,
    required this.builder,
    this.isEmpty,
    this.errorMessage,
    this.onRetry,
    this.emptyMessage = '暂无数据',
    this.emptyIcon = Icons.inbox_rounded,
    this.loadingItemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case AsyncStatus.loading:
        return ClayLoadingState(itemCount: loadingItemCount);
      case AsyncStatus.error:
        return ClayErrorState(
          message: errorMessage ?? '加载失败，请稍后重试',
          onRetry: onRetry,
        );
      case AsyncStatus.empty:
        return ClayEmptyState(
          message: emptyMessage,
          icon: emptyIcon,
        );
      case AsyncStatus.data:
        if (data == null) {
          return ClayEmptyState(
            message: emptyMessage,
            icon: emptyIcon,
          );
        }
        if (isEmpty != null && isEmpty!(data as T)) {
          return ClayEmptyState(
            message: emptyMessage,
            icon: emptyIcon,
          );
        }
        return builder(context, data as T);
    }
  }
}
