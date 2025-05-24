import 'package:flutter/material.dart';
import 'package:perpustakaan/notifiers/navbar_notifiers.dart';
import 'package:perpustakaan/route_destination.dart';

class NavbarWidget extends StatefulWidget {
  const NavbarWidget({super.key});

  @override
  State<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends State<NavbarWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      currentIndex: navIndexNotifier.value,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: "Buku",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Peminjaman"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Setting"),
      ],
      onTap: (index) {
        if (index == 0) {
          RouteDestination.GoToHome(context);
        }
        else if (index == 1) {
          RouteDestination.GoToBuku(context);
        }
        else if(index == 2) {
          RouteDestination.GoToPeminjaman(context);
        }
        else {
          RouteDestination.GoToSetting(context);
        }
      },
    );
  }
}