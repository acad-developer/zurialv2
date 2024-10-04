import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//sha1 password generator using crypto package, with email, name and phone number as salt

String sha1Generator(String email, String name, String phone) {
  var bytes = utf8.encode(email + name + phone);
  var digest = sha1.convert(bytes);
  return digest.toString();
}

//generate pin using sha1 password generator
String generatePin(String hashedPassword) {
  return hashedPassword.toString().substring(0, 6);
}

/// 1 a.	Birthdays
/// 2 b.	Anniversaries
/// 3 c.	Home Visit
/// 4 d.	Emergency
/// 5 e.	Pastoral Visit to Bless New Home and/or New Business Opening
/// 6 f.	Counselling
/// 7 g.	Marriage Counselling
/// 8 h.	Pre Marriage-Counselling
/// 9 i.	Marriage Ceremony
/// 10 j.	Any other request
/// 11 k.	Request an appointment with a Pastor
Map<int, String> specialRequestTypes = {
  0: "Birthdays",
  1: "Anniversaries",
  2: "Home Visit",
  3: "Emergency",
  4: "Pastoral Visit to Bless New Home and/or New Business Opening",
  5: "Counselling",
  6: "Marriage Counselling",
  7: "Pre Marriage-Counselling",
  8: "Marriage Ceremony",
  9: "Any other request",
  10: "Request an appointment with a Pastor",
};

///List<String> items = [
//     "A Neighbour/Co-Worker",
//     "Abuse",
//     "Alcohol",
//     "Allergies",
//     "Cancer",
//     "Child Custody",
//     "Church",
//     "Cold & Flu",
//     "Deliverance from Addictions",
//     "Depression",
//     "Diabetes",
//     "Drugs",
//     "Emotional Distress",
//     "Family Member",
//     "Family Situations",
//     "For A brother/ Sister In Christ",
//     "For A Friend",
//     "For A Loved One",
//     "For Finances",
//     "For My Business",
//     "For My Family",
//     "For My Home Church",
//     "For My Job",
//     "For My Ministry",
//     "For Myself",
//     "For Provision",
//     "For The Current World Situation",
//     "For The Government",
//     "Heart Problems",
//     "Internal Organs",
//     "Legal Situation",
//     "Life Threats",
//     "Lung Disease",
//     "Marriage Restoration",
//     "Mental Illness",
//     "Military Service",
//     "Other",
//     "Physical Ailment",
//     "Protection",
//     "Rebellious Children",
//     "Salvation",
//     "Sexual Perversion",
//     "Stroke",
//     "Tobacco",
//   ];

//convert the above list into a map as <int, String>
Map<int, String> prayerRequestTypes = {
  0: "A Neighbour/Co-Worker",
  1: "Abuse",
  2: "Alcohol",
  3: "Allergies",
  4: "Cancer",
  5: "Child Custody",
  6: "Church",
  7: "Cold & Flu",
  8: "Deliverance from Addictions",
  9: "Depression",
  10: "Diabetes",
  11: "Drugs",
  12: "Emotional Distress",
  13: "Family Member",
  14: "Family Situations",
  15: "For A brother/ Sister In Christ",
  16: "For A Friend",
  17: "For A Loved One",
  18: "For Finances",
  19: "For My Business",
  20: "For My Family",
  21: "For My Home Church",
  22: "For My Job",
  23: "For My Ministry",
  24: "For Myself",
  25: "For Provision",
  26: "For The Current World Situation",
  27: "For The Government",
  28: "Heart Problems",
  29: "Internal Organs",
  30: "Legal Situation",
  31: "Life Threats",
  32: "Lung Disease",
  33: "Marriage Restoration",
  34: "Mental Illness",
  35: "Military Service",
  36: "Other",
  37: "Physical Ailment",
  38: "Protection",
  39: "Rebellious Children",
  40: "Salvation",
  41: "Sexual Perversion",
  42: "Stroke",
  43: "Tobacco",
};

final Map<String, Map<String, dynamic>> adminDestinations = {
  "books": {
    'route': "/books",
    'title': "Books",
    'icon': Icons.book_outlined,
  },
  "blogs": {
    'route': "/blogs",
    'title': "Blogs",
    'icon': Icons.newspaper_outlined,
  },
  //youtube videos
  "videos": {
    'route': "/videos",
    'title': "Videos",
    'icon': Icons.video_library_outlined,
  },
  //pillar of fire forms
  "fireForms": {
    'route': "/fireForms",
    'title': "Pillar of fire Forms",
    'icon': Icons.local_fire_department_outlined,
  },
  //pillar of cloud forms
  "cloudForms": {
    'route': "/cloudForms",
    'title': "Pillar of cloud Forms",
    'icon': Icons.cloud_outlined,
  },
  //albums
  "albums": {
    'route': "/albums",
    'title': "Albums",
    'icon': Icons.photo_album_outlined,
  },
  "contactUs": {
    'route': "/contactUs",
    'title': "Contact Us Forms",
    'icon': Icons.contact_mail_outlined,
  },
  "prayerRequest": {
    'route': "/prayerRequest",
    'title': "Prayer Request",
    'icon': Icons.send,
  },
};

Map<String, String> basicTypes = {
  "all": "All",
  "bibleSchool": "Bible School",
  "newComers": "New Comers Ministry",
  "praiseWorship": "Praise and Worship Ministry",
  "noahsArk": "Noah's Ark",
  "youthArose": "Youth Arose",
  "timothies": "Timothies & Andrews - Men’s Ministry",
  "lift": "LIFT – Women’s Ministries",
  "jobMinistry": "Job Ministry",
  "helpMinistry": "Helps Ministry",
};

///key is the type and value is the icon
Map<String, IconData> basicIcons = {
  "all": Icons.menu_outlined,
  "bibleSchool": Icons.school_outlined,
  "newComers": Icons.people_outline,
  "praiseWorship": Icons.music_note_outlined,
  "noahsArk": Icons.directions_boat_outlined,
  "youthArose": Icons.child_care_outlined,
  "timothies": Icons.man_2_outlined,
  "lift": Icons.woman_outlined,
  "jobMinistry": Icons.work_outline_outlined,
  "helpMinistry": Icons.help_outline_outlined,
};

Map<String, Map<String, dynamic>> socialMedia = {
  "Instagram": {
    "title": "Instagram",
    "icon": FontAwesomeIcons.instagram,
  },
  "Facebook": {
    "title": "Facebook",
    "icon": FontAwesomeIcons.facebook,
  },
  "Twitter": {
    "title": "Twitter",
    "icon": FontAwesomeIcons.twitter,
  },
  "Website": {
    "title": "Website",
    "icon": FontAwesomeIcons.globe,
  },
};
