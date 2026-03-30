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
    final filters = ref.watch(reservationFiltersProvider);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),

            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Reservaciones',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    await showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ReservationFormSheet(),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _FiltersCard(
              currentStatus: filters.status,
              currentDate: filters.reservationDate,
              onStatusChanged: (value) {
                ref
                    .read(reservationFiltersProvider.notifier)
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
                    .read(reservationFiltersProvider.notifier)
                    .updateFilters(
                      ReservationFilters(
                        branchId: filters.branchId,
                        reservationDate: value,
                        status: filters.status,
                      ),
                    );
              },
              onClear: () {
                ref.read(reservationFiltersProvider.notifier).reset();
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: reservationsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(
                child: Text('No se pudieron cargar las reservaciones'),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text('No hay reservaciones para el filtro actual'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(reservationsProvider.notifier).refreshData(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final reservation = items[index];

                      return _ReservationCard(
                        reservation: reservation,
                        onEdit: reservation.status == 'ACTIVE'
                            ? () async {
                                await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => ReservationFormSheet(
                                    reservation: reservation,
                                  ),
                                );
                              }
                            : null,
                        onCancel: reservation.status == 'ACTIVE'
                            ? () async {
                                await showDialog(
                                  context: context,
                                  builder: (_) => CancelReservationDialog(
                                    reservation: reservation,
                                  ),
                                );
                              }
                            : null,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey('status_${currentStatus ?? 'all'}'),
              initialValue: currentStatus,
              decoration: const InputDecoration(label: Text('Estado')),
              items: [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(value: 'ACTIVE', child: Text('Activas')),
                DropdownMenuItem(value: 'CANCELLED', child: Text('Canceladas')),
              ],
              onChanged: onStatusChanged,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('date_${currentDate ?? 'none'}'),
              initialValue: currentDate ?? '',
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Fecha (YYYY-MM-DD)',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
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
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onClear,
              child: const Text('Limpiar filtros'),
            ),
          ],
        ),
      ),
    );
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reservation.customerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${reservation.reservationDate} · ${reservation.reservationTime.substring(0, 5)}',
            ),
            const SizedBox(height: 4),
            Text('Evento: ${reservation.eventType}'),
            const SizedBox(height: 4),
            Text('Zona: ${reservation.zone?.name ?? reservation.zoneId}'),
            const SizedBox(height: 4),
            Text('Personas: ${reservation.guestCount}'),
            const SizedBox(height: 4),
            Text('Teléfono: ${reservation.phonePrimary}'),
            if ((reservation.notes ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Notas: ${reservation.notes}'),
            ],
            if (isActive) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onEdit,
                      child: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: onCancel,
                      child: const Text('Cancelar'),
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
}
