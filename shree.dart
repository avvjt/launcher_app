

class ConditionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {









    bool lovesMe = false; // Change this based on your feelings
    bool knowsMeWell = false; // She only knows you for a week
    String location = "Halishahar";
    int age = 18;
    String studyYear = "2nd year in BCA";
    String message;



    if (lovesMe) {
      message = "She loves me. She will say, 'I love you!'";
    } else if (!knowsMeWell && location == "Halishahar" && age == 18 && studyYear == "2nd year in BCA") {
      message = "Given that she doesn't know me well and is focused on her studies, chances are high she might block me instead.";
    } else {
      message = "It's uncertain how she'll respond.";
    }








    return Scaffold(
      appBar: AppBar(
        title: Text('Condition Result'),
      ),
      body: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
