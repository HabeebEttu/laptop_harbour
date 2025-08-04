import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PageTitle extends StatelessWidget {
  const PageTitle({super.key, required this.titleList , this.trailer});

  final List<String> titleList;
  final Widget? trailer;
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        titleList[0],
        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 22),
      ),
      subtitle: Text(
        titleList[1],
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          fontSize: 15,
          color: Colors.grey[500],
        ),
      ),
      leading: GestureDetector(
        child: Icon(Icons.arrow_back),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      trailing:trailer!=null ? SizedBox(
        width: 120,
        child: trailer):SizedBox(),
    );
  }
}
