import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dentiflow/core/df_ui.dart';
import 'package:dentiflow/core/widgets/df_button.dart';
import '../models/appointment_model.dart';
import '../viewmodels/appointments_viewmodel.dart';

class PendingRequestsView extends StatelessWidget {
  const PendingRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppointmentsViewModel vm = Get.find<AppointmentsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Demandes en attente')),
      body: Obx(() {
        if (vm.pendingRequests.isEmpty) {
          return const DfEmptyState(
            icon: Icons.inbox_rounded,
            title: 'Aucune demande en attente',
            subtitle: 'Toutes les demandes ont été traitées.',
          );
        }
        return RefreshIndicator(
          onRefresh: vm.loadPending,
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.base),
            itemCount: vm.pendingRequests.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final Appointment req = vm.pendingRequests[index];
              return _RequestCard(
                request: req,
                onApprove: () => vm.approveRequest(req.id),
                onReject: () => vm.cancelAppointment(req.id),
              );
            },
          ),
        );
      }),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  final Appointment request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return DfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DfColors.warningFaint(context),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.person_rounded,
                    size: 20, color: DfColors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.patientFullName.isNotEmpty
                          ? request.patientFullName
                          : 'Patient #${request.patientId}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    Text(
                      request.dateHeure,
                      style: TextStyle(
                          fontSize: 13,
                          color: DfColors.mutedTextColor(context)),
                    ),
                  ],
                ),
              ),
              DfStatusBadge(
                label: 'En attente',
                color: DfColors.orange,
                faintColor: DfColors.orangeFaintLight,
              ),
            ],
          ),
          if (request.motif?.isNotEmpty == true) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              request.motif!,
              style: TextStyle(
                  fontSize: 13, color: DfColors.subTextColor(context)),
            ),
          ],
          const SizedBox(height: AppSpacing.base),
          Row(
            children: [
              Expanded(
                child: DfPrimaryButton(
                  label: 'Approuver',
                  icon: Icons.check_rounded,
                  onPressed: onApprove,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: DfDangerButton(
                  label: 'Rejeter',
                  icon: Icons.close_rounded,
                  onPressed: onReject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
