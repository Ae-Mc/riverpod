// A provider that controls the current page
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/* SNIPPET START */

final pageIndexProvider = StateProvider<int>((ref) => 0);

// Un provider que calcula si el usuario puede ir a la página anterior
/* highlight-start */
final canGoToPreviousPageProvider = Provider<bool>((ref) {
/* highlight-end */
  return ref.watch(pageIndexProvider) > 0;
});

class PreviousButton extends ConsumerWidget {
  const PreviousButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ahora estamos viendo nuestro nuevo Provider
    // Nuestro widget ya no calcula si podemos ir a la página anterior.
/* highlight-start */
    final canGoToPreviousPage = ref.watch(canGoToPreviousPageProvider);
/* highlight-end */

    void goToPreviousPage() {
      ref.read(pageIndexProvider.notifier).update((state) => state - 1);
    }

    return ElevatedButton(
      onPressed: canGoToPreviousPage ? goToPreviousPage : null,
      child: const Text('previous'),
    );
  }
}
