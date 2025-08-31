import 'package:flutter/material.dart';
import 'package:jar/models/lot.dart';
import 'package:jar/ui/common/app_colors.dart';
import 'package:jar/ui/common/app_strings.dart';
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
    final Color statusColor = isDefective ? kcDefectiveColor : kcPrimaryColor;
    final Color softBackgroundColor = statusColor.withOpacity(0.08);
    final Color mediumBackgroundColor = statusColor.withOpacity(0.15);

    return Card(
      elevation: 4.0,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            color: softBackgroundColor,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lot.product?.name ?? withOutProduct,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: statusColor,
                            ),
                          ),
                          if (lot.product?.description != null &&
                              lot.product!.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2.0),
                              child: Text(
                                lot.product!.description!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: kcTextColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (!isDefective)
                      PopupMenuButton<String>(
                        icon:
                            Icon(Icons.more_vert, color: Colors.grey.shade600),
                        onSelected: (value) {
                          if (value == 'mark_defective') onMarkDefective();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'mark_defective',
                            child: ListTile(
                                leading: Icon(Icons.warning_amber_rounded),
                                title: Text(tooltipDefectivePallets)),
                          ),
                        ],
                      )
                  ],
                ),
                verticalSpaceSmall,
                _buildLotNameWithHighlight(
                    lotName: lot.name ?? withOutName,
                    highlightColor: statusColor),
                verticalSpaceSmall,
                Row(
                  children: [
                    _buildMetric(
                        icon: Icons.local_shipping_outlined,
                        label: truckLoads),
                    horizontalSpaceMedium,
                    _buildMetric(
                        icon: Icons.date_range_outlined,
                        label: DateFormatter.format(lot.createDate!)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: mediumBackgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: isDefective
                ? _buildDefectiveAction(statusColor)
                                : _buildPalletController(statusColor),
          ),
        ],
      ),
    );
  }

  Widget _buildLotNameWithHighlight(
      {required String lotName, required Color highlightColor}) {
    final defaultStyle = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: Colors.grey.shade600,
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
          margin: const EdgeInsets.only(left: 4.0), // Pequeño espacio
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: highlightColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(
            boldPart,
            style: defaultStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: highlightColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Panel de control para un lote normal.
  Widget _buildPalletController(Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Etiqueta y número
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PALÉS EN INVENTARIO',
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            Text(
              palletsCount.toString(),
              style: const TextStyle(
                color: kcPrimaryColorDark,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // Botones de acción
        Row(
          children: [
            _buildActionButton(
              icon: Icons.remove,
              onPressed: onSubtractPallets,
              color: statusColor,
            ),
            _buildActionButton(
              icon: Icons.add,
              onPressed: onAddPallets,
              color: statusColor,
            ),
          ],
        ),
      ],
    );
  }

  /// Panel de acción para un lote defectuoso.
  Widget _buildDefectiveAction(Color statusColor) {
    return InkWell(
      onTap: onSubtractPallets,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOTE DEFECTUOSO',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '$palletsCount palés',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Descontar',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              horizontalSpaceSmall,
              Icon(Icons.arrow_circle_right_outlined,
                  color: statusColor, size: 28),
            ],
          ),
        ],
      ),
    );
  }

  // Helpers para métricas y botones
  Widget _buildMetric({required IconData icon, required String label}) {
    return Row(children: [
      Icon(icon, color: Colors.grey.shade700, size: 16),
      horizontalSpaceTiny,
      Text(label,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
    ]);
  }

  Widget _buildActionButton(
      {required IconData icon,
      required VoidCallback onPressed,
      required Color color}) {
    return IconButton.filled(
      style: IconButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
      ),
      icon: Icon(icon, color: color, size: 22),
      onPressed: onPressed,
    );
  }
}