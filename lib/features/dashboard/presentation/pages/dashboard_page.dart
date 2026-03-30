import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/base_card.dart';
import '../../../../core/widgets/info_row.dart';
import '../../../../core/widgets/responsive_container.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).value;
    final user = session?.user;
    final isAdmin = session?.isAdmin == true;
    final selectedDate = ref.watch(dashboardSelectedDateNotifierProvider);
    final selectedBranchId = ref.watch(
      dashboardSelectedBranchIdNotifierProvider,
    );

    final branchesState = ref.watch(dashboardBranchesProvider);
    final summaryState = ref.watch(dashboardSummaryProvider);
    final detailState = ref.watch(dashboardDayDetailProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveContainer(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardBranchesProvider);
              ref.invalidate(dashboardSummaryProvider);
              ref.invalidate(dashboardDayDetailProvider);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                BaseCard(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 28,
                  elevation: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido(a)',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          IconBadge(
                            icon: Icons.verified_user_outlined,
                            label: user?.role ?? '-',
                          ),
                          IconBadge(
                            icon: Icons.storefront_outlined,
                            label: user?.branch?.name ?? 'Administrador',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (isAdmin)
                  branchesState.when(
                    loading: () =>
                        const LoadingCard(message: 'Cargando sucursales...'),
                    error: (_, _) => const ErrorCard(
                      message: 'No se pudieron cargar las sucursales.',
                    ),
                    data: (branches) {
                      return BaseCard(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedBranchId,
                          decoration: const InputDecoration(
                            labelText: 'Sucursal',
                            prefixIcon: Icon(Icons.storefront_outlined),
                          ),
                          items: branches
                              .map(
                                (branch) => DropdownMenuItem<String>(
                                  value: branch.id,
                                  child: Text(branch.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            ref
                                .read(
                                  dashboardSelectedBranchIdNotifierProvider
                                      .notifier,
                                )
                                .updateBranchId(value);
                          },
                        ),
                      );
                    },
                  ),

                if (isAdmin) const SizedBox(height: 16),

                BaseCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha seleccionada',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () async {
                          final now = DateTime.now();
                          final current =
                              DateTime.tryParse(selectedDate) ?? now;

                          final selected = await showDatePicker(
                            context: context,
                            firstDate: DateTime(now.year - 1),
                            lastDate: DateTime(now.year + 2),
                            initialDate: current,
                          );

                          if (selected != null) {
                            ref
                                .read(
                                  dashboardSelectedDateNotifierProvider
                                      .notifier,
                                )
                                .updateDate(DateFormatter.toIsoDate(selected));
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  DateFormatter.formatDate(selectedDate),
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (selectedBranchId == null || selectedBranchId.isEmpty)
                  const ErrorCard(
                    message:
                        'Selecciona una sucursal para consultar el dashboard.',
                  )
                else ...[
                  summaryState.when(
                    loading: () => _buildSummaryLoading(),
                    error: (_, _) => const ErrorCard(
                      message: 'No se pudo cargar el resumen mensual.',
                    ),
                    data: (summary) {
                      final selectedCount = summary
                          .where(
                            (item) =>
                                item.date.split('T').first == selectedDate,
                          )
                          .fold<int>(0, (sum, item) => sum + item.count);

                      final totalMonth = summary.fold<int>(
                        0,
                        (sum, item) => sum + item.count,
                      );

                      return Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              title: 'Del día',
                              value: selectedCount.toString(),
                              icon: Icons.today_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              title: 'Del mes',
                              value: totalMonth.toString(),
                              icon: Icons.date_range_outlined,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  detailState.when(
                    loading: () => _buildDetailLoading(),
                    error: (_, _) => const ErrorCard(
                      message: 'No se pudo cargar el detalle del día.',
                    ),
                    data: (detail) {
                      if (detail == null) {
                        return const ErrorCard(
                          message:
                              'No se encontró información para la consulta.',
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Detalle del día',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: MiniStatCard(
                                  title: 'Total',
                                  value: detail.total.toString(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: MiniStatCard(
                                  title: 'Activas',
                                  value: detail.activeCount.toString(),
                                  backgroundColor: AppColors.successBg,
                                  textColor: AppColors.successText,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: MiniStatCard(
                                  title: 'Canceladas',
                                  value: detail.cancelledCount.toString(),
                                  backgroundColor: AppColors.errorBg,
                                  textColor: AppColors.errorText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (detail.items.isEmpty)
                            const EmptyStateCard(
                              message: 'No hay reservaciones para este día',
                              icon: Icons.event_busy_outlined,
                            )
                          else
                            ...detail.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _ReservationDetailCard(item: item),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryLoading() {
    return Row(
      children: [
        Expanded(child: LoadingCard()),
        const SizedBox(width: 12),
        Expanded(child: LoadingCard()),
      ],
    );
  }

  Widget _buildDetailLoading() {
    return const LoadingCard(message: 'Cargando detalle del día...');
  }
}

class _ReservationDetailCard extends StatelessWidget {
  const _ReservationDetailCard({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      padding: const EdgeInsets.all(16),
      elevation: 1,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.customerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusBadge(status: item.status),
            ],
          ),
          const SizedBox(height: 12),
          InfoRow(
            icon: Icons.schedule_outlined,
            label: 'Hora',
            value: DateFormatter.formatTime(item.reservationTime),
          ),
          const SizedBox(height: 8),
          InfoRow(
            icon: Icons.place_outlined,
            label: 'Zona',
            value: item.zone?.name ?? item.zoneId,
          ),
          const SizedBox(height: 8),
          InfoRow(
            icon: Icons.groups_2_outlined,
            label: 'Personas',
            value: item.guestCount.toString(),
          ),
          const SizedBox(height: 8),
          InfoRow(
            icon: Icons.celebration_outlined,
            label: 'Evento',
            value: item.eventType,
          ),
          const SizedBox(height: 8),
          InfoRow(
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            value: item.phonePrimary,
          ),
          if ((item.notes ?? '').toString().trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            InfoRow(
              icon: Icons.sticky_note_2_outlined,
              label: 'Notas',
              value: item.notes!,
            ),
          ],
        ],
      ),
    );
  }
}
