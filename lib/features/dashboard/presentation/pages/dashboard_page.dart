import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authProvider).value;
    final user = session?.user;
    final isAdmin = session?.isAdmin == true;
    final selectedDate = ref.watch(dashboardSelectedDateProvider);
    final selectedBranchId = ref.watch(dashboardSelectedBranchIdProvider);

    final branchesState = ref.watch(dashboardBranchesProvider);
    final summaryState = ref.watch(dashboardSummaryProvider);
    final detailState = ref.watch(dashboardDayDetailProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido(a)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
                        _Badge(
                          icon: Icons.verified_user_outlined,
                          label: user?.role ?? '-',
                        ),
                        _Badge(
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
                      const _LoadingCard(message: 'Cargando sucursales...'),
                  error: (_, _) => const _ErrorCard(
                    message: 'No se pudieron cargar las sucursales.',
                  ),
                  data: (branches) {
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
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
                              .read(dashboardSelectedBranchIdProvider.notifier)
                              .updateBranchId(value);
                        },
                      ),
                    );
                  },
                ),

              if (isAdmin) const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha seleccionada',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () async {
                        final now = DateTime.now();
                        final current = DateTime.tryParse(selectedDate) ?? now;

                        final selected = await showDatePicker(
                          context: context,
                          firstDate: DateTime(now.year - 1),
                          lastDate: DateTime(now.year + 2),
                          initialDate: current,
                        );

                        if (selected != null) {
                          final value =
                              '${selected.year.toString().padLeft(4, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';

                          ref
                              .read(dashboardSelectedDateProvider.notifier)
                              .updateDate(value);
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
                                _formatDate(selectedDate),
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
                const _ErrorCard(
                  message:
                      'Selecciona una sucursal para consultar el dashboard.',
                )
              else ...[
                summaryState.when(
                  loading: () => const _SummaryLoading(),
                  error: (_, _) => const _ErrorCard(
                    message: 'No se pudo cargar el resumen mensual.',
                  ),
                  data: (summary) {
                    final selectedCount = summary
                        .where(
                          (item) => item.date.split('T').first == selectedDate,
                        )
                        .fold<int>(0, (sum, item) => sum + item.count);

                    final totalMonth = summary.fold<int>(
                      0,
                      (sum, item) => sum + item.count,
                    );

                    return Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Del día',
                            value: selectedCount.toString(),
                            icon: Icons.today_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
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
                  loading: () => const _DetailLoading(),
                  error: (_, _) => const _ErrorCard(
                    message: 'No se pudo cargar el detalle del día.',
                  ),
                  data: (detail) {
                    if (detail == null) {
                      return const _ErrorCard(
                        message: 'No se encontró información para la consulta.',
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
                              child: _MiniStatCard(
                                title: 'Total',
                                value: detail.total.toString(),
                                bgColor: AppColors.surface,
                                textColor: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MiniStatCard(
                                title: 'Activas',
                                value: detail.activeCount.toString(),
                                bgColor: AppColors.successBg,
                                textColor: AppColors.successText,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MiniStatCard(
                                title: 'Canceladas',
                                value: detail.cancelledCount.toString(),
                                bgColor: AppColors.errorBg,
                                textColor: AppColors.errorText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (detail.items.isEmpty)
                          const _EmptyDetailState()
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
    );
  }

  static String _formatDate(String value) {
    try {
      final date = DateTime.parse(value);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return value;
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.bgColor,
    required this.textColor,
  });

  final String title;
  final String value;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationDetailCard extends StatelessWidget {
  const _ReservationDetailCard({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final isActive = item.status == 'ACTIVE';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.successBg : AppColors.errorBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isActive ? 'Activa' : 'Cancelada',
                  style: TextStyle(
                    color: isActive
                        ? AppColors.successText
                        : AppColors.errorText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DashboardInfoRow(
            icon: Icons.schedule_outlined,
            label: 'Hora',
            value: _formatTime(item.reservationTime),
          ),
          const SizedBox(height: 8),
          _DashboardInfoRow(
            icon: Icons.place_outlined,
            label: 'Zona',
            value: item.zone?.name ?? item.zoneId,
          ),
          const SizedBox(height: 8),
          _DashboardInfoRow(
            icon: Icons.groups_2_outlined,
            label: 'Personas',
            value: item.guestCount.toString(),
          ),
          const SizedBox(height: 8),
          _DashboardInfoRow(
            icon: Icons.celebration_outlined,
            label: 'Evento',
            value: item.eventType,
          ),
          const SizedBox(height: 8),
          _DashboardInfoRow(
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            value: item.phonePrimary,
          ),
          if ((item.notes ?? '').toString().trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _DashboardInfoRow(
              icon: Icons.sticky_note_2_outlined,
              label: 'Notas',
              value: item.notes!,
            ),
          ],
        ],
      ),
    );
  }

  static String _formatTime(String value) {
    try {
      final normalized = value.length >= 5 ? value.substring(0, 5) : value;
      final parts = normalized.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2000, 1, 1, hour, minute);
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return value;
    }
  }
}

class _DashboardInfoRow extends StatelessWidget {
  const _DashboardInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryLoading extends StatelessWidget {
  const _SummaryLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: LinearProgressIndicator(),
    );
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyDetailState extends StatelessWidget {
  const _EmptyDetailState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_busy_outlined,
            size: 42,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'No hay reservaciones registradas para este día',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const LinearProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.errorText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
