class EventsModel {
  int? eventId;
  String eventTitle;
  String? eventImageUrl;
  String eventCategory;
  String? eventDetails;
  String eventLocation;
  String eventSubDistrict;
  String eventDistrict;

  EventsModel({
    required this.eventId,
    required this.eventTitle,
    this.eventImageUrl,
    required this.eventCategory,
    this.eventDetails,
    required this.eventLocation,
    required this.eventDistrict,
    required this.eventSubDistrict,
  });

}
  List<EventsModel> eventsList = [
    EventsModel(eventId: 1,eventTitle: "Cricket", eventCategory: "Sports",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 2,eventTitle: "Football", eventCategory: "Sports",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 3,eventTitle: "Badminton", eventCategory: "Sports",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 4,eventTitle: "Handball", eventCategory: "Sports",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 5,eventTitle: "Volleyball", eventCategory: "Sports",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 6,eventTitle: "Basketball", eventCategory: "Sports",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 7,eventTitle: "Tenisball", eventCategory: "Sports",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 8,eventTitle: "kabaddi", eventCategory: "Sports",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 9,eventTitle: "100 years purti", eventCategory: "Politics",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 10,eventTitle: "16th December", eventCategory: "Sports",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 11,eventTitle: "26th March", eventCategory: "Sports",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 12,eventTitle: "Cricket", eventCategory: "Politics",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 13,eventTitle: "Cricket", eventCategory: "Sports",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 14,eventTitle: "Cricket", eventCategory: "Sports",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 15,eventTitle: "Cricket", eventCategory: "Sports",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 16,eventTitle: "Cricket", eventCategory: "Sports",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 17,eventTitle: "Cricket", eventCategory: "Sports",eventDetails: "in life time is  too short\\so we should \\ live to the end",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 18,eventTitle: "Cricket", eventCategory: "Sports",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
    EventsModel(eventId: 19,eventTitle: "Cricket", eventCategory: "Sports",eventLocation: "Birampur pilot high school",eventSubDistrict: "Birampur", eventDistrict: "Dinajpur"),
  ];


