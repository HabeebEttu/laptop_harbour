import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/providers/user_provider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> profileButtons = [
      {'icon': Icons.inventory_2_outlined, 'title': 'Order History', 'url': ''},
      {
        'icon': Icons.favorite_border_outlined,
        'title': 'Wishlist Access',
        'url': '',
      },
      {'icon': Icons.lock_outline, 'title': 'Change Password', 'url': ''},
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final userProfile = userProvider.userProfile;

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: BoxBorder.all(
                        color: Colors.grey[500]!,
                        width: 0.75,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage:
                                        (userProfile?.profilePic?.isNotEmpty ??
                                            false)
                                        ? NetworkImage(userProfile!.profilePic!)
                                        : null,
                                    backgroundColor: Colors.grey[500],
                                    child:
                                        !(userProfile?.profilePic?.isNotEmpty ??
                                            false)
                                        ? const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.blueAccent,
                                      child: IconButton(
                                        icon: const FaIcon(
                                          FontAwesomeIcons.penToSquare,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/settings',
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          userProfile != null
                              ? '${userProfile.firstName} ${userProfile.lastName}'
                              : 'Guest User',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          userProfile?.email ?? 'Not logged in',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      border: BoxBorder.all(
                        color: Colors.grey[500]!,
                        width: 0.75,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Column(
                            children: List.generate(profileButtons.length, (
                              index,
                            ) {
                              dynamic button = profileButtons[index];
                              return Column(
                                children: [
                                  ListTile(
                                    leading: Icon(button['icon']),
                                    title: Text(button['title']),
                                    trailing: Icon(Icons.navigate_next),
                                    
                                  ),
                                  if(index<2)Divider(height: 0.75,
                                  color: Colors.grey[500],
                                  )
                                ],
                              );
                            }),
                          ),
                        ),
                        
                        
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  InkWell(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 10,
                        children: [
                          Icon(
                            Icons.logout,
                            color: Colors.white70,
                          ),
                          Text(
                            'Logout',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
