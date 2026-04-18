import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:inksight/core/extensions/context_extensions.dart';
import 'package:inksight/features/auth/presentation/viewmodels/auth_state_viewmodel.dart';
import 'package:inksight/features/settings/presentation/viewmodels/theme_mode_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _supportedLocales = [
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateViewModelProvider);
    final themeAsync = ref.watch(themeModeViewModelProvider);
    final dims = context.dimensions;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('settings.title')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(dims.spacingMd),
        children: [
          Text(
            context.tr('settings.profile_section'),
            style: context.appTextTheme.titleMedium.copyWith(
              color: context.appColors.textSubtle,
            ),
          ),
          SizedBox(height: dims.spacingSm),
          Card(
            child: Padding(
              padding: EdgeInsets.all(dims.spacingMd),
              child: user == null
                  ? Text(
                      context.tr('settings.profile_unavailable'),
                      style: context.appTextTheme.bodyMedium,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          context.tr('settings.email_label'),
                          style: context.appTextTheme.bodySmall.copyWith(
                            color: context.appColors.textSubtle,
                          ),
                        ),
                        SizedBox(height: dims.spacingXs),
                        Text(
                          user.email,
                          style: context.appTextTheme.bodyLarge,
                        ),
                        SizedBox(height: dims.spacingMd),
                        Text(
                          context.tr('settings.member_since'),
                          style: context.appTextTheme.bodySmall.copyWith(
                            color: context.appColors.textSubtle,
                          ),
                        ),
                        SizedBox(height: dims.spacingXs),
                        Text(
                          DateFormat.yMMMMd(
                            context.locale.toString(),
                          ).format(user.createdAt),
                          style: context.appTextTheme.bodyMedium,
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: dims.spacingLg),
          Text(
            context.tr('settings.appearance_section'),
            style: context.appTextTheme.titleMedium.copyWith(
              color: context.appColors.textSubtle,
            ),
          ),
          SizedBox(height: dims.spacingSm),
          Card(
            child: Padding(
              padding: EdgeInsets.all(dims.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.tr('settings.theme_label'),
                    style: context.appTextTheme.bodySmall.copyWith(
                      color: context.appColors.textSubtle,
                    ),
                  ),
                  SizedBox(height: dims.spacingSm),
                  switch (themeAsync) {
                    AsyncData(:final value) => SegmentedButton<ThemeMode>(
                      segments: [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text(
                            context.tr('settings.theme_system'),
                            overflow: TextOverflow.ellipsis,
                          ),
                          icon: const Icon(Icons.brightness_auto),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text(
                            context.tr('settings.theme_light'),
                            overflow: TextOverflow.ellipsis,
                          ),
                          icon: const Icon(Icons.light_mode),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text(
                            context.tr('settings.theme_dark'),
                            overflow: TextOverflow.ellipsis,
                          ),
                          icon: const Icon(Icons.dark_mode),
                        ),
                      ],
                      selected: {value},
                      onSelectionChanged: (selection) {
                        final selected = selection.first;
                        unawaited(
                          ref
                              .read(themeModeViewModelProvider.notifier)
                              .setThemeMode(selected),
                        );
                      },
                    ),
                    AsyncLoading() => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    AsyncError() => Text(context.tr('errors.unknown')),
                  },
                ],
              ),
            ),
          ),
          SizedBox(height: dims.spacingLg),
          Text(
            context.tr('settings.language_section'),
            style: context.appTextTheme.titleMedium.copyWith(
              color: context.appColors.textSubtle,
            ),
          ),
          SizedBox(height: dims.spacingSm),
          Card(
            child: Padding(
              padding: EdgeInsets.all(dims.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.tr('settings.language_label'),
                    style: context.appTextTheme.bodySmall.copyWith(
                      color: context.appColors.textSubtle,
                    ),
                  ),
                  SizedBox(height: dims.spacingSm),
                  DropdownButton<Locale>(
                    isExpanded: true,
                    value: _localeOrFallback(context.locale),
                    items: _supportedLocales
                        .map(
                          (locale) => DropdownMenuItem(
                            value: locale,
                            child: Text(_languageLabel(context, locale)),
                          ),
                        )
                        .toList(),
                    onChanged: (locale) {
                      if (locale != null) {
                        unawaited(context.setLocale(locale));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Locale _localeOrFallback(Locale locale) {
    for (final supported in _supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }
    return const Locale('en');
  }

  String _languageLabel(BuildContext context, Locale locale) {
    return switch (locale.languageCode) {
      'es' => context.tr('settings.language_es'),
      'fr' => context.tr('settings.language_fr'),
      _ => context.tr('settings.language_en'),
    };
  }
}
