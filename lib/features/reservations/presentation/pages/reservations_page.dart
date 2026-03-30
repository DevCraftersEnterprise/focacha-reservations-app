import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/base_card.dart';
import '../../../../core/widgets/info_row.dart';
import '../../../../core/widgets/responsive_container.dart';
import '../../../../core/widgets/state_widgets.dart';
import '../../../../core/widgets/status_badge.dart';
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
        child: ResponsiveContainer(
          child: reservationsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ErrorCard(message: 'Error al cargar reservaciones'),
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
                      child: FadeInDown(
                        duration: const Duration(milliseconds: 400),
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
                    ),
                    SliverToBoxAdapter(
                      child: FadeIn(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 100),
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
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 10)),
                    if (items.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 40, 16, 120),
                          child: EmptyStateCard(
                            message:
                                'No se encontraron reservaciones\npara los filtros seleccionados',
                            icon: Icons.search_off,
                          ),
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
                            return FadeInUp(
                              duration: const Duration(milliseconds: 400),
                              delay: Duration(milliseconds: 50 * index),
                              child: Padding(
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
    );
  }
}

/// Widget para los filtros de reservaciones
/// Aplica SRP: solo maneja la lógica de filtros
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
        : DateFormatter.formatDate(currentDate!);

    return BaseCard(
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
                onDateChanged(DateFormatter.toIsoDate(selected));
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
}

/// Widget para mostrar una tarjeta de reservación
/// Aplica SRP: solo renderiza la información de una reservación
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
    return BaseCard(
      elevation: 1,
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
              StatusBadge(status: reservation.status),
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
                DateFormatter.formatDate(reservation.reservationDate),
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
                DateFormatter.formatTime(reservation.reservationTime),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoRow(
            icon: Icons.celebration_outlined,
            label: 'Evento',
            value: reservation.eventType,
          ),
          const SizedBox(height: 8),
          InfoRow(
            icon: Icons.place_outlined,
            label: 'Zona',
            value: reservation.zone?.name ?? reservation.zoneId,
          ),
          const SizedBox(height: 8),
          InfoRow(
            icon: Icons.groups_2_outlined,
            label: 'Personas',
            value: reservation.guestCount.toString(),
          ),
          const SizedBox(height: 8),
          InfoRow(
            icon: Icons.phone_outlined,
            label: 'Teléfono',
            value: reservation.phonePrimary,
          ),
          if ((reservation.notes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            InfoRow(
              icon: Icons.sticky_note_2_outlined,
              label: 'Notas',
              value: reservation.notes!,
            ),
          ],
          if (reservation.status == 'ACTIVE') ...[
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
    );
  }
}
