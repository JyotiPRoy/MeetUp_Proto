part of 'session_data.dart';

mixin _SessionCalendarEvents {

  static final CollectionReference<Map<String,dynamic>> _userCollection
  = FirebaseFirestore.instance.collection('users');

  Future<Map<String,MeetingEvent>> getAllCalendarEvents(String userID) async {
    Map<String,MeetingEvent> _calendarEvents = {};
    final eventCollection = _userCollection.doc(userID).collection('calendarEvents');
    var querySnapshot = await eventCollection.get();
    querySnapshot.docs.forEach((element) {
      _calendarEvents[element.data()['roomID']] = MeetingEvent.fromMap(element.data());
    });
    return _calendarEvents;
    // refreshCalendarEvents(); // listener added
  }

  Future<void> addCalendarEvents(MeetingEvent event, String userID) async {
    try{
      List<String> participants = <String>[userID];
      if(event.participants != null && event.participants!.isNotEmpty){
        participants.addAll(event.participants!);
      }
      for(String participantID in participants){
        // Adding calendar event remotely to all participants in the meeting.
        // refresh will take care of adding it to the local store
        await _userCollection.doc(participantID).collection('calendarEvents').doc(event.roomID).set(event.toMap());
      }
    }catch(e){
      print('Exception: ${e.toString()} @AddCalEvent');
    }
  }

  Future<void> deleteCalendarEvent(MeetingEvent event, String userID) async {
    try{
      if(event.hostID == userID){
        List<String> participants = [userID];
        if(event.participants != null && event.participants!.isNotEmpty){
          participants.addAll(event.participants!);
        }
        for(String participantID in participants){
          await _userCollection.doc(participantID).collection('calendarEvents').doc(event.roomID).delete();
        }
      }else {
        var toDelete = _userCollection.doc(userID).collection('calendarEvents').doc(event.roomID);
        await toDelete.delete();
      }
    }catch(e){
      print('Exception: ${e.toString()} @DeleteCalEvent');
    }
  }

  Future<void> editCalendarEvent(String oldEventID, MeetingEvent event, String userID) async {
    try{
      var toEdit = _userCollection.doc(userID).collection('calendarEvents').doc(oldEventID);
      await toEdit.update(event.toMap());
    }catch(e){
      print('Exception: ${e.toString()} @EditCalEvent');
    }
  }
}