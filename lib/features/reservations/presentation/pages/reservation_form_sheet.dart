import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/extract_error_message_util.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/reservation_model.dart';
import '../providers/reservations_provider.dart';

class ReservationFormSheet extends ConsumerStatefulWidget {
  const ReservationFormSheet({
    super.key,
    required this.branchId,
    this.reservation,
  });

  final String branchId;
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

  String? _selectedZoneId;
  String? _errorMessage;
  bool _saving = false;

  bool get isEditing => widget.reservation != null;

  @override
  void initState() {
    super.initState();

    final reservation = widget.reservation;

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

    _selectedZoneId = reservation?.zoneId;
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
    if (!_formKey.currentState!.validate()) return;

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
          branchId: widget.branchId,
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
          branchId: widget.branchId,
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

  @override
  Widget build(BuildContext context) {
    final zonesState = ref.watch(branchZonesProvider(widget.branchId));
    final session = ref.watch(authProvider).value;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Editar Reservación' : 'Nueva Reservación',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sucursal: ${session?.user.branch?.name ?? 'Sucursal asignada'}',
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha (YYYY-MM-DD)',
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Ingresa la fecha'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _timeController,
                    decoration: const InputDecoration(
                      labelText: 'Hora (HH:mm)',
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Ingresa la hora'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _guestCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Personas'),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      final parsed = int.tryParse(text);
                      if (parsed == null || parsed < 1) return 'Valor inválido';
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
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedZoneId,
                        decoration: const InputDecoration(labelText: 'Zona'),
                        items: zones
                            .map(
                              (zone) => DropdownMenuItem<String>(
                                value: zone.id,
                                child: Text(zone.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedZoneId = value);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _eventTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de evento',
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Ingresa el evento'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(labelText: 'Cliente'),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Ingresa el cliente'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phonePrimaryController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono principal',
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Ingresa el teléfono'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneSecondaryController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono secundario',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _notesController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'Notas'),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saving ? null : _submit,
                          child: Text(
                            _saving
                                ? 'Guardando...'
                                : (isEditing ? 'Actualizar' : 'Crear'),
                          ),
                        ),
                      ),
                    ],
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
