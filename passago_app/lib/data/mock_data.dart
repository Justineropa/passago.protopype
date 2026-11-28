/// All sample data lives in this one file so the screens never contain
/// hard-coded names, numbers or places. Everything here is PLACEHOLDER data
/// copied from the Stitch designs. Replace it with real data (Firebase or
/// another backend) later without touching the screens.

enum DriverStatus { available, onTrip, onBreak }

enum Shift { am, pm }

extension ShiftInfo on Shift {
  String get label => this == Shift.am ? 'AM' : 'PM';
  String get hours =>
      this == Shift.am ? '5:00 AM – 1:00 PM' : '1:00 PM – 9:00 PM';
}

class QueueDriver {
  const QueueDriver({
    required this.name,
    required this.bodyNo,
    required this.passengers,
    required this.status,
    required this.waitMinutes,
  });

  final String name;
  final String bodyNo;
  final int passengers;
  final DriverStatus status;
  final int waitMinutes;
}

class TripRecord {
  const TripRecord({
    required this.daysAgo,
    required this.time,
    required this.shift,
    required this.destination,
    required this.passengers,
    required this.distanceKm,
    required this.turnNo,
    required this.fare,
    this.cancelled = false,
  });

  final int daysAgo;
  final String time;
  final Shift shift;
  final String destination;
  final int passengers;
  final double distanceKm;
  final int turnNo;
  final int fare;
  final bool cancelled;
}

class TripOffer {
  const TripOffer({
    required this.destination,
    required this.passengers,
    required this.bay,
    required this.distanceKm,
    required this.fare,
  });

  final String destination;
  final int passengers;
  final String bay;
  final double distanceKm;
  final int fare;
}

class DemandArea {
  const DemandArea({
    required this.name,
    required this.bays,
    required this.waitMinutes,
    required this.waiting,
    required this.level,
  });

  final String name;
  final String bays;
  final int waitMinutes;
  final int waiting;
  final String level;
}

class MockData {
  static const terminalName = 'Poblacion Market Terminal';
  static const routeName = 'Poblacion Public Market (Route 3)';

  // The signed-in driver (placeholder).
  static const driverName = 'Ramon Dela Cruz';
  static const driverBodyNo = '127';

  // Drivers shown in the queue, besides the signed-in driver.
  static const otherDrivers = <QueueDriver>[
    QueueDriver(
        name: 'Jun Bautista',
        bodyNo: '089',
        passengers: 5,
        status: DriverStatus.available,
        waitMinutes: 6),
    QueueDriver(
        name: 'Arnel Santos',
        bodyNo: '214',
        passengers: 7,
        status: DriverStatus.available,
        waitMinutes: 18),
    QueueDriver(
        name: 'Edwin Reyes',
        bodyNo: '056',
        passengers: 11,
        status: DriverStatus.available,
        waitMinutes: 9),
    QueueDriver(
        name: 'Mario Lopez',
        bodyNo: '033',
        passengers: 12,
        status: DriverStatus.available,
        waitMinutes: 6),
    QueueDriver(
        name: 'Carlo Mendoza',
        bodyNo: '171',
        passengers: 8,
        status: DriverStatus.onTrip,
        waitMinutes: 0),
    QueueDriver(
        name: 'Nestor Garcia',
        bodyNo: '098',
        passengers: 10,
        status: DriverStatus.onTrip,
        waitMinutes: 0),
    QueueDriver(
        name: 'Rey Villanueva',
        bodyNo: '142',
        passengers: 13,
        status: DriverStatus.onBreak,
        waitMinutes: 0),
  ];

  static const offer = TripOffer(
    destination: 'Brgy. San Isidro',
    passengers: 3,
    bay: 'Bay 2',
    distanceKm: 2.8,
    fare: 45,
  );

  static const demand = <DemandArea>[
    DemandArea(
        name: 'Brgy. San Isidro',
        bays: 'Bay 1 & 2',
        waitMinutes: 5,
        waiting: 8,
        level: 'High demand'),
    DemandArea(
        name: 'Poblacion East',
        bays: 'Bay 3',
        waitMinutes: 8,
        waiting: 6,
        level: 'Moderate'),
    DemandArea(
        name: 'Brgy. Malinis',
        bays: 'Bay 4',
        waitMinutes: 6,
        waiting: 5,
        level: 'Normal'),
  ];

  static const dispatchSummary =
      'Poblacion Main Bay 1–4 • 23 waiting passengers • 6 min avg wait';
  static const advisory =
      'Advisory: Rizal Ave. road drainage work. Detour via Mabini St.';

  // Number of drivers per shift, shown on the Schedule screen.
  static const driversPerShift = {Shift.am: 18, Shift.pm: 14};

  static const trips = <TripRecord>[
    TripRecord(
        daysAgo: 0,
        time: '09:42 AM',
        shift: Shift.am,
        destination: 'Brgy. San Isidro',
        passengers: 3,
        distanceKm: 2.8,
        turnNo: 14,
        fare: 45),
    TripRecord(
        daysAgo: 0,
        time: '08:51 AM',
        shift: Shift.am,
        destination: 'Poblacion East',
        passengers: 2,
        distanceKm: 1.6,
        turnNo: 10,
        fare: 30),
    TripRecord(
        daysAgo: 0,
        time: '08:05 AM',
        shift: Shift.am,
        destination: 'Bagong Silang',
        passengers: 0,
        distanceKm: 0,
        turnNo: 6,
        fare: 0,
        cancelled: true),
    TripRecord(
        daysAgo: 0,
        time: '07:18 AM',
        shift: Shift.am,
        destination: 'Brgy. Malinis',
        passengers: 2,
        distanceKm: 3.4,
        turnNo: 3,
        fare: 50),
    TripRecord(
        daysAgo: 1,
        time: '03:12 PM',
        shift: Shift.pm,
        destination: 'Poblacion East',
        passengers: 4,
        distanceKm: 1.6,
        turnNo: 9,
        fare: 60),
    TripRecord(
        daysAgo: 1,
        time: '06:30 AM',
        shift: Shift.am,
        destination: 'Brgy. San Isidro',
        passengers: 2,
        distanceKm: 2.8,
        turnNo: 2,
        fare: 30),
    TripRecord(
        daysAgo: 4,
        time: '10:05 AM',
        shift: Shift.am,
        destination: 'Brgy. Malinis',
        passengers: 3,
        distanceKm: 3.4,
        turnNo: 11,
        fare: 75),
    TripRecord(
        daysAgo: 12,
        time: '02:40 PM',
        shift: Shift.pm,
        destination: 'Bagong Silang',
        passengers: 2,
        distanceKm: 4.1,
        turnNo: 5,
        fare: 40),
  ];
}
