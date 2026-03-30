import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/extract_error_message_util.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/reservation_model.dart';
import '../providers/reservations_provider.dart';

class ReservationFormSheet extends ConsumerStatefulWidget {
  const ReservationFormSheet({super.key, this.reservation});

  final ReservationModel? reservation;

  @override
  ConsumerState<ReservationFormSheet> createState() =>
      _ReservationFormSheetState();
}

class _ReservationFormSheetState extends ConsumerState<ReservationFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _guestCountController;
  late final TextEditingController _eventTypeController;
  late final TextEditingController _customerNameController;
  late final TextEditingController _phonePrimaryController;
  late final TextEditingController _phoneSecondaryController;
  late final TextEditingController _notesController;

  String? _selectedBranchId;
  String? _selectedZoneId;
  String? _errorMessage;
  bool _saving = false;

  bool get isEditing => widget.reservation != null;

  @override
  void initState() {
    super.initState();

    final reservation = widget.reservation;
    final session = ref.read(authProvider).value;

    _dateController = TextEditingController(
      text: reservation?.reservationDate ?? '',
    );
    _timeController = TextEditingController(
      text: reservation?.reservationTime.substring(0, 5) ?? '',
    );
    _guestCountController = TextEditingController(
      text: reservation?.guestCount.toString() ?? '1',
    );
    _eventTypeController = TextEditingController(
      text: reservation?.eventType ?? '',
    );
    _customerNameController = TextEditingController(
      text: reservation?.customerName ?? '',
    );
    _phonePrimaryController = TextEditingController(
      text: reservation?.phonePrimary ?? '',
    );
    _phoneSecondaryController = TextEditingController(
      text: reservation?.phoneSecondary ?? '',
    );
    _notesController = TextEditingController(text: reservation?.notes ?? '');

    if (reservation != null) {
      _selectedBranchId = reservation.branchId;
      _selectedZoneId = reservation.zoneId;
    } else if (session?.isCashier == true) {
      _selectedBranchId = session?.user.branchId;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _guestCountController.dispose();
    _eventTypeController.dispose();
    _customerNameController.dispose();
    _phonePrimaryController.dispose();
    _phoneSecondaryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_selectedBranchId == null || _selectedBranchId!.isEmpty) {
      setState(() => _errorMessage = 'Selecciona una sucursal');
      return;
    }

    if (_selectedZoneId == null || _selectedZoneId!.isEmpty) {
      setState(() => _errorMessage = 'Selecciona una zona');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final notifier = ref.read(reservationsProvider.notifier);

    try {
      if (isEditing) {
        await notifier.updateReservation(
          id: widget.reservation!.id,
          reservationDate: _dateController.text.trim(),
          reservationTime: _timeController.text.trim(),
          guestCount: int.parse(_guestCountController.text.trim()),
          branchId: _selectedBranchId!,
          zoneId: _selectedZoneId!,
          eventType: _eventTypeController.text.trim(),
          customerName: _customerNameController.text.trim(),
          phonePrimary: _phonePrimaryController.text.trim(),
          phoneSecondary: _phoneSecondaryController.text.trim().isEmpty
              ? null
              : _phoneSecondaryController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      } else {
        await notifier.create(
          reservationDate: _dateController.text.trim(),
          reservationTime: _timeController.text.trim(),
          guestCount: int.parse(_guestCountController.text.trim()),
          branchId: _selectedBranchId!,
          zoneId: _selectedZoneId!,
          eventType: _eventTypeController.text.trim(),
          customerName: _customerNameController.text.trim(),
          phonePrimary: _phonePrimaryController.text.trim(),
          phoneSecondary: _phoneSecondaryController.text.trim().isEmpty
              ? null
              : _phoneSecondaryController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      setState(() {
        _errorMessage = extractErrorMessage(
          error,
          fallback: 'No se pudo guardar la reservación',
        );
      });
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();

    final now = DateTime.now();
    DateTime initialDate = now;

    try {
      if (_dateController.text.trim().isNotEmpty) {
        initialDate = DateTime.parse(_dateController.text.trim());
      }
    } catch (_) {}

    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDate: initialDate,
    );

    if (selected != null) {
      _dateController.text =
          '${selected.year.toString().padLeft(4, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();

    final selected = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
    );

    if (selected != null) {
      _timeController.text =
          '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authProvider).value;
    final branchesState = ref.watch(branchesProvider);

    final zonesState = _selectedBranchId == null || _selectedBranchId!.isEmpty
        ? const AsyncValue<List<dynamic>>.data([])
        : ref.watch(branchZonesProvider(_selectedBranchId!));

    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing
                                    ? 'Editar reservación'
                                    : 'Nueva reservación',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isEditing
                                    ? 'Actualiza la información del cliente y del evento.'
                                    : 'Captura la información del cliente y del evento.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionTitle(
                              icon: Icons.event_note_outlined,
                              title: 'Datos de la reservación',
                            ),
                            const SizedBox(height: 14),

                            branchesState.when(
                              loading: () => const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: LinearProgressIndicator(),
                              ),
                              error: (_, _) => const Text(
                                'No se pudieron cargar las sucursales',
                              ),
                              data: (branches) {
                                if (session?.isCashier == true) {
                                  final branchName =
                                      session?.user.branch?.name ??
                                      'Sucursal asignada';

                                  return _ReadOnlyField(
                                    label: 'Sucursal',
                                    icon: Icons.storefront_outlined,
                                    value: branchName,
                                  );
                                }

                                return DropdownButtonFormField<String>(
                                  initialValue: _selectedBranchId,
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
                                  onChanged: _saving
                                      ? null
                                      : (value) {
                                          setState(() {
                                            _selectedBranchId = value;
                                            _selectedZoneId = null;
                                          });
                                        },
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? 'Selecciona una sucursal'
                                      : null,
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: _saving ? null : _pickDate,
                                    child: IgnorePointer(
                                      child: TextFormField(
                                        controller: _dateController,
                                        decoration: const InputDecoration(
                                          labelText: 'Fecha',
                                          prefixIcon: Icon(
                                            Icons.calendar_today_outlined,
                                          ),
                                        ),
                                        validator: (value) =>
                                            (value == null ||
                                                value.trim().isEmpty)
                                            ? 'Ingresa la fecha'
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: _saving ? null : _pickTime,
                                    child: IgnorePointer(
                                      child: TextFormField(
                                        controller: _timeController,
                                        decoration: const InputDecoration(
                                          labelText: 'Hora',
                                          prefixIcon: Icon(
                                            Icons.schedule_outlined,
                                          ),
                                        ),
                                        validator: (value) =>
                                            (value == null ||
                                                value.trim().isEmpty)
                                            ? 'Ingresa la hora'
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _guestCountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Número de personas',
                                prefixIcon: Icon(Icons.groups_2_outlined),
                              ),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                final parsed = int.tryParse(text);
                                if (parsed == null || parsed < 1) {
                                  return 'Valor inválido';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            zonesState.when(
                              loading: () => const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: LinearProgressIndicator(),
                              ),
                              error: (_, _) =>
                                  const Text('No se pudieron cargar las zonas'),
                              data: (zones) {
                                if (_selectedBranchId == null ||
                                    _selectedBranchId!.isEmpty) {
                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      'Selecciona una sucursal para cargar zonas.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  );
                                }

                                if (zones.isEmpty) {
                                  return Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorBg,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Text(
                                      'No hay zonas activas disponibles para la sucursal seleccionada.',
                                      style: TextStyle(
                                        color: AppColors.errorText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }

                                return DropdownButtonFormField<String>(
                                  initialValue: _selectedZoneId,
                                  decoration: const InputDecoration(
                                    labelText: 'Zona',
                                    prefixIcon: Icon(Icons.place_outlined),
                                  ),
                                  items: zones
                                      .map(
                                        (zone) => DropdownMenuItem<String>(
                                          value: zone.id,
                                          child: Text(zone.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: _saving
                                      ? null
                                      : (value) {
                                          setState(
                                            () => _selectedZoneId = value,
                                          );
                                        },
                                  validator: (value) =>
                                      (value == null || value.isEmpty)
                                      ? 'Selecciona una zona'
                                      : null,
                                );
                              },
                            ),

                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _eventTypeController,
                              decoration: const InputDecoration(
                                labelText: 'Tipo de evento',
                                prefixIcon: Icon(Icons.celebration_outlined),
                              ),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Ingresa el evento'
                                  : null,
                            ),

                            const SizedBox(height: 24),

                            _SectionTitle(
                              icon: Icons.person_outline,
                              title: 'Datos del cliente',
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _customerNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nombre del cliente',
                                prefixIcon: Icon(Icons.badge_outlined),
                              ),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Ingresa el cliente'
                                  : null,
                            ),

                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _phonePrimaryController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono principal',
                                prefixIcon: Icon(Icons.phone_outlined),
                              ),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Ingresa el teléfono'
                                  : null,
                            ),

                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _phoneSecondaryController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Teléfono secundario',
                                prefixIcon: Icon(Icons.phone_in_talk_outlined),
                              ),
                            ),

                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _notesController,
                              minLines: 3,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                labelText: 'Notas',
                                prefixIcon: Icon(Icons.sticky_note_2_outlined),
                                alignLabelWithHint: true,
                              ),
                            ),

                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.errorBg,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.errorText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _saving
                                ? null
                                : () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                            label: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _saving ? null : _submit,
                            icon: Icon(
                              isEditing
                                  ? Icons.save_outlined
                                  : Icons.add_circle_outline,
                            ),
                            label: Text(
                              _saving
                                  ? 'Guardando...'
                                  : (isEditing ? 'Actualizar' : 'Crear'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.icon,
    required this.value,
  });

  final String label;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
