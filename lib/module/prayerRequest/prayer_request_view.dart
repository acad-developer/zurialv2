// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:zuriel/models/prayerrequest.dart';
import 'package:zuriel/tools/default_dropdown.dart';
import 'package:zuriel/tools/helpers.dart';
import 'package:zuriel/tools/tools.dart';

class PrayerRequestView extends StatefulWidget {
  static const route_name = "addprayerrequest";
  const PrayerRequestView({Key? key}) : super(key: key);

  @override
  State<PrayerRequestView> createState() => _PrayerRequestViewState();
}

class _PrayerRequestViewState extends State<PrayerRequestView> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  Country? country;
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  int? prayerRequestType;
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Center(
      child: Container(
        width: DeviceTemplate.formWidth(),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          ),
        ),
        margin: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: SpacedColumn(
            verticalSpace: 10,
            children: [
              Text(
                "Submit a Prayer Request",
                style: TextStyle(fontSize: DeviceTemplate.headerFontSize),
                textAlign: TextAlign.center,
              ),
              DefaultTextField(
                label: "Name",
                controller: nameController,
                validator: (p0) {
                  if (p0!.isEmpty) {
                    return "Name is required";
                  }
                  return null;
                },
              ),
              //email
              DefaultTextField(
                label: "Email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (p0) {
                  if (p0!.isEmpty) {
                    return "Email is required";
                  }
                  if (RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$")
                          .hasMatch(p0) ==
                      false) {
                    return "Invalid email";
                  }
                  return null;
                },
              ),
              DefaultTextField(
                label: "Country",
                controller: country != null
                    ? TextEditingController(
                        text: country != null
                            ? "${country!.flagEmoji} ${country!.name}"
                            : '')
                    : null,
                enabled: false,
                onTap: () {
                  showCountryPicker(
                      context: context,
                      onSelect: (value) {
                        setState(() {
                          country = value;
                        });
                      });
                },
              ),
              Row(
                children: [
                  Container(width: 50, child:Text("+${country != null ? country!.phoneCode : "91"} ")),
                  Container(
                      width: DeviceTemplate.formWidth() - 68,
                      child: DefaultTextField(
                        label: "Phone",
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        validator: (p0) {
                          if (p0!.isEmpty) {
                            return "Phone is required";
                          }
                          return null;
                        },
                      )),
                ],
              ),

              DefaultTextField(
                label: "State",
                controller: stateController,
              ),
              DefaultTextField(
                label: "City",
                controller: cityController,
              ),
              //prayer request type
              DefaultDropdown(
                  items: [
                    for (final item in prayerRequestTypes.entries)
                      DefaultMenuItem(id: item.key, title: item.value)
                  ],
                  width: double.infinity,
                  valueId: prayerRequestType,
                  label: "Prayer Request Type",
                  hasSearchBox: true,
                  onChanged: (value) {
                    setState(() {
                      prayerRequestType = value.id;
                    });
                  }),
              //message
              DefaultTextField(
                label: "Message",
                controller: messageController,
                maxLines: 5,
                validator: (p0) {
                  if (p0!.isEmpty) {
                    return "Message is required";
                  }
                  return null;
                },
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
                  ElevatedButton.icon(
                    icon: Icon(Icons.save),
                    label: const Text("Submit"),
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      if (country == null) {
                        // context.showError("Please select a country");
                        return;
                      }
                      if (prayerRequestType == null) {
                        // context.showError("Please select a prayer request type");
                        return;
                      }
                      _submit();
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    )));
  }

  void _submit() {
    final CollectionReference collection =
        FirebaseFirestore.instance.collection('prayerrequest');
    PrayerRequestMd praydata = PrayerRequestMd.init().copyWith(
      message: messageController.text,
      email: emailController.text,
      country: country!.name,
      city: cityController.text,
      contactNo:
          "+" + country!.phoneCode.toString() + " " + phoneController.text,
      fullname: nameController.text,
      prayerFor: prayerRequestType,
      state: stateController.text,
    );
    collection.add(praydata.toJson());
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    stateController.clear();
    cityController.clear();
    messageController.clear();
    setState(() {
      country = null;
      prayerRequestType = null;
    });
  }
}
