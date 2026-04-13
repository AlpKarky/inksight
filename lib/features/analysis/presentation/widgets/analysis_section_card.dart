import 'package:flutter/material.dart';
import 'package:inksight/core/extensions/context_extensions.dart';

class AnalysisSectionCard extends StatelessWidget {
  const AnalysisSectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.data,
    super.key,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          context.dimensions.radiusLg,
        ),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(title: title, icon: icon, color: color),
          Padding(
            padding: EdgeInsets.all(context.dimensions.spacingMd),
            child: _DataContent(data: data),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.dimensions.spacingMd,
        vertical: context.dimensions.spacingSm + 4,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.dimensions.radiusLg),
          topRight: Radius.circular(context.dimensions.radiusLg),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: context.dimensions.spacingSm),
          Expanded(
            child: Text(
              title,
              style: context.appTextTheme.titleMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataContent extends StatelessWidget {
  const _DataContent({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Text('No data available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        final value = entry.value;

        if (value is Map) {
          return _buildNestedMap(context, entry.key, value);
        }
        if (value is List) {
          return _buildList(context, entry.key, value);
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: context.dimensions.spacingSm,
          ),
          child: _buildKeyValue(context, entry.key, value),
        );
      }).toList(),
    );
  }

  Widget _buildKeyValue(
    BuildContext context,
    String key,
    Object? value,
  ) {
    final label = _formatKey(key);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.appTextTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: context.dimensions.spacingXs),
        Text(
          value?.toString() ?? '',
          style: context.appTextTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildNestedMap(
    BuildContext context,
    String key,
    Map<dynamic, dynamic> map,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.dimensions.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatKey(key),
            style: context.appTextTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.dimensions.spacingXs),
          ...map.entries.map(
            (e) => Padding(
              padding: EdgeInsets.only(
                left: context.dimensions.spacingMd,
                bottom: context.dimensions.spacingXs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_formatKey(e.key.toString())}: ',
                    style: context.appTextTheme.bodyMedium
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                  Expanded(
                    child: Text(
                      e.value?.toString() ?? '',
                      style: context.appTextTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    String key,
    List<dynamic> list,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.dimensions.spacingSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatKey(key),
            style: context.appTextTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: context.dimensions.spacingXs),
          ...list.map(
            (item) => Padding(
              padding: EdgeInsets.only(
                bottom: context.dimensions.spacingXs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• '),
                  Expanded(
                    child: Text(
                      item.toString(),
                      style: context.appTextTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (w) => w.isNotEmpty
              ? '${w[0].toUpperCase()}${w.substring(1)}'
              : '',
        )
        .join(' ');
  }
}
