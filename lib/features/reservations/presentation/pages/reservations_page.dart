import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/models/reservation_model.dart';
import '../providers/reservations_provider.dart';
import 'cancel_reservation_dialog.dart';
import 'reservation_form_sheet.dart';

class ReservationsPage extends ConsumerWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsState = ref.watch(reservationsProvider);
    final filters = ref.watch(reservationFiltersNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => ReservationFormSheet(),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1024),
            child: reservationsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _ErrorState(),
                ),
              ),
              data: (items) {
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(reservationsProvider.notifier).refreshData(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Reservaciones',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _FiltersCard(
                            currentStatus: filters.status,
                            currentDate: filters.reservationDate,
                            onStatusChanged: (value) {
                              ref
                                  .read(
                                    reservationFiltersNotifierProvider.notifier,
                                  )
                                  .updateFilters(
                                    ReservationFilters(
                                      branchId: filters.branchId,
                                      reservationDate: filters.reservationDate,
                                      status: value,
                                    ),
                                  );
                            },
                            onDateChanged: (value) {
                              ref
                                  .read(
                                    reservationFiltersNotifierProvider.notifier,
                                  )
                                  .updateFilters(
                                    ReservationFilters(
                                      branchId: filters.branchId,
                                      reservationDate: value,
                                      status: filters.status,
                                    ),
                                  );
                            },
                            onClear: () {
                              ref
                                  .read(
                                    reservationFiltersNotifierProvider.notifier,
                                  )
                                  .reset();
                            },
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),
                      if (items.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 40, 16, 120),
                            child: _EmptyState(),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final reservation = items[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index < items.length - 1 ? 12 : 0,
                                ),
                                child: _ReservationCard(
                                  reservation: reservation,
                                  onEdit: reservation.status == 'ACTIVE'
                                      ? () async {
                                          await showModalBottomSheet<void>(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (_) =>
                                                ReservationFormSheet(
                                                  reservation: reservation,
                                                ),
                                          );
                                        }
                                      : null,
                                  onCancel: reservation.status == 'ACTIVE'
                                      ? () async {
                                          await showDialog<void>(
                                            context: context,
                                            builder: (_) =>
                                                CancelReservationDialog(
                                                  reservation: reservation,
                                                ),
                                          );
                                        }
                                      : null,
                                ),
                              );
                            }, childCount: items.length),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  const _FiltersCard({
    required this.currentStatus,
    required this.currentDate,
    required this.onStatusChanged,
    required this.onDateChanged,
    required this.onClear,
  });

  final String? currentStatus;
  final String? currentDate;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onDateChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final dateLabel = currentDate == null || currentDate!.isEmpty
        ? 'Todas las fechas'
        : _formatDate(currentDate!);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filtros',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(onPressed: onClear, child: const Text('Limpiar')),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: currentStatus,
            decoration: const InputDecoration(
              labelText: 'Estatus',
              prefixIcon: Icon(Icons.tune),
            ),
            items: const [
              DropdownMenuItem<String>(value: null, child: Text('Todos')),
              DropdownMenuItem<String>(value: 'ACTIVE', child: Text('Activas')),
              DropdownMenuItem<String>(
                value: 'CANCELLED',
                child: Text('Canceladas'),
              ),
            ],
            onChanged: onStatusChanged,
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () async {
              final now = DateTime.now();
              final selected = await showDatePicker(
                context: context,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 2),
                initialDate: now,
              );

              if (selected != null) {
                onDateChanged(DateFormat('yyyy-MM-dd').format(selected));
              }
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Fecha',
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              child: Text(
                dateLabel,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
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

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.onEdit,
    required this.onCancel,
  });

  final ReservationModel reservation;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final isActive = reservation.status == 'ACTIVE';

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reservation.customerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _StatusChip(isActive: isActive),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(reservation.reservationDate),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTime(reservation.reservationTime),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.celebration_outlined,
              label: 'Evento',
              value: reservation.eventType,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.place_outlined,
              label: 'Zona',
              value: reservation.zone?.name ?? reservation.zoneId,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.groups_2_outlined,
              label: 'Personas',
              value: reservation.guestCount.toString(),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Teléfono',
              value: reservation.phonePrimary,
            ),
            if ((reservation.notes ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.sticky_note_2_outlined,
                label: 'Notas',
                value: reservation.notes!,
              ),
            ],
            if (isActive) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
            ],
          ],
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successBg : AppColors.errorBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isActive ? 'Activa' : 'Cancelada',
        style: TextStyle(
          color: isActive ? AppColors.successText : AppColors.errorText,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
            'No hay reservaciones',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Prueba ajustando tus filtros o crea una nueva reservación.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'No se pudieron cargar las reservaciones',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
