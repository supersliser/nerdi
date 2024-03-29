import 'package:flutter/material.dart';
import 'package:nerdi/InterestData.dart';
import 'package:nerdi/NavBar.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:nerdi/UserData.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nerdi/InterestPage.dart';
import 'dart:math';


class UserDescPage extends StatelessWidget {
  const UserDescPage({super.key, required this.User});
  final UserData User;

  Future<List<Widget>> generateTiles(UserData User, double width) async {
    final List<Widget> Output = List.empty(growable: true);

    final List<Interest> Interests = await User.getInterests();

    Output.add(LargeUserIcon(ImageURL: User.ProfilePictureURL, Width: width));
    Output.add(
        UserItem(Data: GenderEnum.values[User.Gender].name, Width: width));
    Output.add(UserItem(
        Data:
            "Age: ${User.getAge()}, Birthday in ${User.Birthday!.difference(DateTime.now()).inDays} Days",
        Width: width));
    Output.add(UserItem(Data: User.Description, Width: width));

    for (int i = 0; i < Interests.length; i++) {
      Output.add(InterestItem(
          interest: Interests[i], username: User.Username, Width: width));
    }
    Output.shuffle(Random(DateTime.now().hour));
    return Output;
  }

  @override
  Widget build(BuildContext context) {
    final Size appSize = MediaQuery.of(context).size;

    double width = appSize.width / (appSize.width / 300).floor();

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context);
          },
          backgroundColor: const Color(0xEEC78FFF),
          child: const Text("Back"),
        ),
        body: Row(
          children: [
            const NavBar(),
            Expanded(
            child: ListView(children: [
              FutureBuilder<List<Widget>>(
                  future: generateTiles(User, width),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final data = snapshot.data!;
                    return (StaggeredGrid.count(
                        crossAxisCount: (appSize.width / 300).floor(),
                        children: data));
                  })
            ]),
          ),
        ]));
  }
}

class InterestItem extends StatelessWidget {
  const InterestItem(
      {super.key,
      required this.interest,
      this.username = "this person",
      required this.Width});
  final Interest interest;
  final String username;
  final double Width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InterestPage(interest: interest)));
      },
      child: SizedBox(
        width: Width,
        child: Card.filled(
          clipBehavior: Clip.antiAlias,
          color: const Color(0xFFC78FFF),
          child: Column(
            children: [
              interest.ImageName == "Placeholder.svg"
                  ? const Padding(
                      padding: EdgeInsets.all(0),
                    )
                  : FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: interest.ImageURL,
                      width: Width,
                      fit: BoxFit.cover
                    ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                    child: Column(
                  children: [
                    Text(
                      "$username is interested in ${interest.Name}",
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(interest.Description)
                  ],
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserItem extends StatelessWidget {
  const UserItem({
    super.key,
    required this.Data,
    required this.Width,
  });

  final String Data;
  final double Width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Width,
      child: Card.filled(
        color: const Color(0xFFC78FFF),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: Text(Data)),
        ),
      ),
    );
  }
}

class LargeUserIcon extends StatelessWidget {
  const LargeUserIcon({
    super.key,
    required this.ImageURL,
    required this.Width,
  });

  final String ImageURL;
  final double Width;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      clipBehavior: Clip.hardEdge,
      color: const Color(0xFFC78FFF),
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: ImageURL,
        width: Width - 10,
        fit: BoxFit.cover,
      ),
    );
  }
}
