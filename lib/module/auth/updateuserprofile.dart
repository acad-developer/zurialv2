// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zuriel/models/prayerrequest.dart';
import 'package:zuriel/models/userprofile.dart';
import 'package:zuriel/models/utils.dart';
import 'package:zuriel/tools/default_dropdown.dart';
import 'package:zuriel/tools/helpers.dart';
import 'package:zuriel/tools/imagehandler.dart';
import 'package:zuriel/tools/tools.dart';

class ProfileUpdate extends StatefulWidget {
  static const route_name = "userprofile";
  const ProfileUpdate({Key? key}) : super(key: key);

  @override
  State<ProfileUpdate> createState() => _ProfileUpdateState();
}

class _ProfileUpdateState extends State<ProfileUpdate> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  Country? country;
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  User? user;
  String? email = "";
  UserProfile? userProfile;
  bool loadingProfile = false;
  bool _isEditable = false;

  @override
  void initState() {
    initUser();
    super.initState();
  }

  initUser() async {
    setState(() {
      loadingProfile = true;
    });
    // ignore: await_only_futures
    user = await FirebaseAuth.instance.currentUser;
    print(user!.uid);
    DocumentSnapshot<Map<String, dynamic>> userProfileData =
        await FirebaseFirestore.instance
            .collection('userprofile')
            .doc(user!.uid)
            .get();
            
    Map<String, dynamic>? profiledata = userProfileData.data();
    setState(() {
      email = user!.email;
   
      if (profiledata != null) {
        userProfile = UserProfile.fromJson(profiledata as Map<String, dynamic>);
    
        nameController.text = userProfile != null ? userProfile!.fullname : "";
        phoneController.text =
            userProfile != null ? userProfile!.contactNo : "";
        // Country? country;
        stateController.text = userProfile != null ? userProfile!.state : "";
        cityController.text = userProfile != null ? userProfile!.city : "";
      } else {
        userProfile = UserProfile.init();
        userProfile!.id = user!.uid;
      }
      loadingProfile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("User Profile", context),
      body: loadingProfile
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Container(
                  width: DeviceTemplate.formWidth(),
                  margin:
                      EdgeInsets.only(top: 50, left: 12, right: 12, bottom: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.1),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SpacedColumn(
                      verticalSpace: 10,
                      children: [
                        Text(
                          userProfile!.fullname ?? "User Profile",
                          style: TextStyle(
                              fontSize: DeviceTemplate.headerFontSize),
                          textAlign: TextAlign.center,
                        ),
                        ImageHandler(
                          storageRef: "userprofileimage/${userProfile!.id}.jpg",
                          networkImage: userProfile!.imageUrl,
                          showFileChange: _isEditable,
                          callback: (String uploadedImageURl) async {
                            userProfile!.imageUrl = uploadedImageURl;
                            userProfile!.imageName = "${userProfile!.id}.jpg";
                          },
                        ),
                        Text(email!),
                        Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("To update profile please Check this: "),
                            Switch(
                              thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
                                  (Set<WidgetState> states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return const Icon(Icons.close);
                                }
                                return null; // All other states will use the default thumbIcon.
                              }),
                              value: _isEditable,
                              onChanged: (value) {
                                setState(() {
                                  _isEditable = value;
                                });
                              },
                              activeColor: Colors.green,
                              inactiveThumbColor: Colors.red,
                              inactiveTrackColor: Colors.red.shade100,
                            ),
                          ],
                        )),

                        DefaultTextField(
                          label: "Name",
                          controller: nameController,
                          enabled: _isEditable,
                          validator: (p0) {
                            if (p0!.isEmpty) {
                              return "Name is required";
                            }
                            return null;
                          },
                        ),
                        //email

                        DefaultTextField(
                          label: "Country",
                          controller: country != null
                              ? TextEditingController(
                                  text: country != null
                                      ? "${country!.flagEmoji} ${country!.name}"
                                      : userProfile!.country)
                              : TextEditingController(
                                  text: userProfile!.country),
                          enabled: _isEditable,
                          onTap: () {
                            _isEditable
                                ? showCountryPicker(
                                    context: context,
                                    onSelect: (value) {
                                      setState(() {
                                        country = value;
                                      });
                                    })
                                : null;
                          },
                        ),
                        DefaultTextField(
                          label: "Phone",
                          enabled: _isEditable,
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (p0) {
                            return null;
                          },
                        ),

                        DefaultTextField(
                          label: "State",
                          enabled: _isEditable,
                          controller: stateController,
                        ),
                        DefaultTextField(
                          label: "City",
                          enabled: _isEditable,
                          controller: cityController,
                        ),

                        //submit button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              icon: Icon(Icons.arrow_back),
                              label: const Text("Back"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            _isEditable
                                ? ElevatedButton.icon(
                                    icon: Icon(Icons.save),
                                    label: const Text("Submit"),
                                    onPressed: () {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }

                                      _submit();
                                    },
                                  )
                                : SizedBox(),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  updateUserProfile(UserProfile profiledata) async {
    String userProfileId =
        FirebaseFirestore.instance.collection('userprofile').doc(user!.uid).id;
    await FirebaseFirestore.instance
        .collection('userprofile')
        .doc(userProfileId)
        .update(profiledata.toJson());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile has been updated.')),
    );
  }

  void _submit() async {
    UserProfile profiledata = UserProfile.init().copyWith(
      id: user!.uid,
      country: country != null ? country!.name : userProfile!.country,
      city: cityController.text,
      contactNo: phoneController.text,
      fullname: nameController.text,
      state: stateController.text,
      email: user!.email,
      imageName: userProfile!.imageName,
      imageUrl: userProfile!.imageUrl,
      userType: userProfile!.userType,
      groupList:userProfile!.groupList
    );
    await updateUserProfile(profiledata);

    setState(() {
      userProfile = profiledata;
      _isEditable = false;
      country = null;
    });
  }
}
