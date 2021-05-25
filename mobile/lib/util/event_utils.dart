import '../models/old/event_type.dart';
import './asset_utils.dart';

List<EventType> eventTypes = [
  EventType(
      eventTitle: "Activities",
      eventDescription: "Create an event centered around physical"
          " activities such as working out, hiking, bike riding,"
          " sports, nature walks, etc....",
      eventType: 1,
      useColor: false,
      assetImage: activities
  ),
  EventType(
      eventTitle: "Community Service",
      eventDescription:
      "Create an event focused on serving your local community"
          " such as feeding the homeless, volunteering at a youth"
          " event, cleaning a park, planting a community garden, "
          "volunteering at a senior assisted living home etc....",
      eventType: 2,
      useColor: true,
      assetImage: community_service
  ),
  EventType(
      eventTitle: "Bible Study/Prayer Group",
      eventDescription:
      "Create an event to come together and study the Word of God "
          "or join in prayer on a conference call or video chat, at"
          " a local coffee shop, church, library etc. RESTRICTION: "
          "No in home bible study (events must be at a public place)",
      eventType: 3,
      useColor: false,
      assetImage: bible_study
  ),
  EventType(
      eventTitle: "Hangouts",
      eventDescription:
      "Create an event to hang out with and meet other believers."
          " Includes events you've discovered or created such as open "
          "mic night, movies, restaurants, painting/pottery, sporting "
          "event, concerts, festivals etc...",
      eventType: 4,
      useColor: true,
      assetImage: hangout
  ),
  EventType(
      eventTitle: "Business",
      eventDescription:
      "Are you organizing an event for your business such as a siminar, "
          "workshop, pop up shop, book release, marketing event etc.?"
          " Create that event here",
      eventType: 5,
      useColor: false,
      assetImage: promotion
  ),
  EventType(
      eventTitle: "Conference",
      eventDescription:
      "Are you organizing a conference, retreat, revival or similar event? "
          "Create that event here.",
      eventType: 5,
      useColor: false,
      assetImage: conference
  ),
];

const int PENDING = 0;
const int APPROVED = 1;
const int REJECTED = 2;
const int INACTIVE = 3;
const int COMPLETED = 4;