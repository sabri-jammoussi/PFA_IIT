class SecretaryStats {
  final int pendingRequests;
  final int todayAppointments;
  final int waitingRoom;
  final int unpaidCount;
  final double unpaidTotal;

  const SecretaryStats({
    required this.pendingRequests,
    required this.todayAppointments,
    required this.waitingRoom,
    this.unpaidCount = 0,
    this.unpaidTotal = 0,
  });
}
