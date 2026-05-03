import 'package:flutter/material.dart';
import 'package:jar/l10n/app_localizations.dart';
import 'package:jar/models/lot.dart';
import 'package:jar/ui/common/app_colors.dart';
import 'package:jar/ui/common/ui_helpers.dart';

class LotCard extends StatelessWidget {
  final Lot lot;
  final int palletsCount;
  final bool isDefective;
  final VoidCallback onAddPallets;
  final VoidCallback onSubtractPallets;
  final VoidCallback onMarkDefective;
  final String truckLoads;

  const LotCard({
    super.key,
    required this.lot,
    required this.palletsCount,
    required this.isDefective,
    required this.onAddPallets,
    required this.onSubtractPallets,
    required this.onMarkDefective,
    required this.truckLoads,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: isDefective
          ? _buildDefectiveCard(context, l10n)
          : _buildStandardCard(context, l10n),
    );
  }

  Widget _buildStandardCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final statusColor = theme.colorScheme.secondary;

    return Row(
      children: [
        Container(
          width: 90,
          color: statusColor,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                l10n.palletsTitle(palletsCount),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              verticalSpaceTiny,
              Text(
                palletsCount.toString(),
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lot.product?.name ?? l10n.withOutProduct,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (lot.product?.description != null &&
                        lot.product!.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Text(
                          lot.product!.description!,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                verticalSpaceSmall,
                _buildLotNameWithHighlight(
                  context,
                  lotName: lot.name ?? l10n.withOutName,
                  highlightColor: statusColor,
                ),
                verticalSpaceSmall,
                Row(
                  children: [
                    _buildMetric(
                      context,
                      icon: Icons.local_shipping_outlined,
                      label: truckLoads,
                      tooltip: l10n.tooltipTruckLoads,
                    ),
                    horizontalSpaceMedium,
                    _buildMetric(
                      context,
                      icon: Icons.date_range_outlined,
                      label: lot.createDate != null
                          ? DateFormatter.format(lot.createDate!)
                          : l10n.noDate,
                      tooltip: l10n.tooltipDateCreationBatch,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  children: [
                    _buildActionButton(
                      context,
                      icon: Icons.warning_amber_rounded,
                      onPressed: onMarkDefective,
                      color: theme.colorScheme.error,
                      tooltip: l10n.tooltipDefectivePallets,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionButton(
                          context,
                          icon: Icons.remove,
                          onPressed: onSubtractPallets,
                          color: statusColor,
                          tooltip: l10n.tooltipSubstractPallets,
                        ),
                        horizontalSpaceSmall,
                        _buildActionButton(
                          context,
                          icon: Icons.add,
                          onPressed: onAddPallets,
                          color: statusColor,
                          tooltip: l10n.tooltipAddPallets,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefectiveCard(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final statusColor = theme.colorScheme.error;

    return Row(
      children: [
        Container(
          width: 90,
          color: statusColor,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
              verticalSpaceSmall,
              Text(
                l10n.palletsTitle(palletsCount),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              verticalSpaceTiny,
              Text(
                palletsCount.toString(),
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.defectiveLot,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                ),
                Text(
                  lot.product?.name ?? l10n.withOutProduct,
                  style: theme.textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                verticalSpaceSmall,
                _buildLotNameWithHighlight(
                  context,
                  lotName: lot.name ?? l10n.withOutName,
                  highlightColor: statusColor,
                ),
                verticalSpaceSmall,
                _buildMetric(
                  context,
                  icon: Icons.date_range_outlined,
                  label: lot.createDate != null
                      ? DateFormatter.format(lot.createDate!)
                      : l10n.noDate,
                  tooltip: l10n.tooltipDateCreationBatch,
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1),
                ),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onSubtractPallets,
                    icon: const Icon(Icons.arrow_circle_right_outlined),
                    label: Text(l10n.discountPallets),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: statusColor,
                      side: BorderSide(color: statusColor.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLotNameWithHighlight(
    BuildContext context, {
    required String lotName,
    required Color highlightColor,
  }) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.bodyMedium?.copyWith(
      color: kcTextSecondary,
      fontSize: 16,
    );

    if (lotName.length <= 3) {
      return Text(lotName, style: defaultStyle);
    }

    final normalPart = lotName.substring(0, lotName.length - 3);
    final boldPart = lotName.substring(lotName.length - 3);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(normalPart, style: defaultStyle),
        Container(
          margin: const EdgeInsets.only(left: 4.0),
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: highlightColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(
            boldPart,
            style: defaultStyle?.copyWith(
              fontWeight: FontWeight.bold,
              color: highlightColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? tooltip,
  }) {
    final theme = Theme.of(context);
    Widget content = Row(children: [
      Icon(icon, color: kcTextSecondary, size: 16),
      horizontalSpaceTiny,
      Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: kcTextSecondary,
          fontSize: 14,
        ),
      ),
    ]);

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: content,
      );
    }
    return content;
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    String? tooltip,
  }) {
    return IconButton.filled(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(icon, size: 22),
      onPressed: onPressed,
    );
  }
}