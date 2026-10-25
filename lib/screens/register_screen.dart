import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _formKey = GlobalKey<FormState>();
// Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool isLoading = false;

  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  final List<String> genders = [
    'Male',
    'Female',
    'Other',
  ];

  final List<String> districts = [
    "Chattogram",
    "Dhaka",
    "Cumilla",
    "Cox's Bazar",
    "Noakhali",
    "Feni",
    "Sylhet",
    "Khulna",
    "Rajshahi",
    "Barisal",
    "Rangpur",
    "Mymensingh",
  ];



  String? selectedBloodGroup;
  String? selectedGender;
  bool isDonor = true;
  bool agree = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  DateTime? selectedDate;
  String? selectedDistrict;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),

      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          "Create Account",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 10),

                const Text(
                  "Join Blood Connect",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Become a donor and help save lives.",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 30),

                _buildTextField(
                  "Full Name",
                  Icons.person,
                  controller: fullNameController,
                ),

                const SizedBox(height: 18),

                _buildTextField(
                  "Email",
                  Icons.email,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 18),

                _buildTextField(
                  "Phone Number",
                  Icons.phone,
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 18),

                _buildTextField(
                  "Password",
                  Icons.lock,
                  controller: passwordController,
                  obscure: obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 18),

                _buildTextField(
                  "Confirm Password",
                  Icons.lock_outline,
                  controller: confirmPasswordController,
                  obscure: obscureConfirmPassword,
                  suffix: IconButton(
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  value: selectedBloodGroup,
                  decoration: _inputDecoration(
                    "Blood Group",
                    Icons.bloodtype,
                  ),
                  items: bloodGroups.map((group) {
                    return DropdownMenuItem(
                      value: group,
                      child: Text(group),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return "Please select your blood group";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      selectedBloodGroup = value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  value: selectedGender,
                  decoration: _inputDecoration(
                    "Gender",
                    Icons.person_outline,
                  ),
                  items: genders.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return "Please select your gender";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: _inputDecoration(
                      "Date of Birth",
                      Icons.calendar_month,
                    ),
                    child: Text(
                      selectedDate == null
                          ? "Select Date of Birth"
                          : "${selectedDate!.day.toString().padLeft(2, '0')}/"
                          "${selectedDate!.month.toString().padLeft(2, '0')}/"
                          "${selectedDate!.year}",
                      style: TextStyle(
                        color: selectedDate == null
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                DropdownButtonFormField<String>(
                  value: selectedDistrict,
                  decoration: _inputDecoration(
                    "District",
                    Icons.location_city,
                  ),
                  items: districts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return "Please select your district";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      selectedDistrict = value;
                    });
                  },
                ),

                const SizedBox(height: 18),

                _buildTextField(
                  "Full Address",
                  Icons.home,
                  controller: addressController,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),

                const SizedBox(height: 25),

                SwitchListTile(
                  activeColor: AppColors.primary,
                  title: const Text("Available to Donate"),
                  value: isDonor,
                  onChanged: (value) {
                    setState(() {
                      isDonor = value;
                    });
                  },
                ),

                CheckboxListTile(
                  activeColor: AppColors.primary,
                  value: agree,
                  title: const Text(
                    "I agree to the Terms & Conditions",
                  ),
                  onChanged: (value) {
                    setState(() {
                      agree = value!;
                    });
                  },
                ),

                // Privacy Policy link
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.privacy_tip_outlined, size: 16),
                    label: const Text("View Privacy Policy"),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(18)),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.privacy_tip,
                                        color: Colors.white),
                                    SizedBox(width: 10),
                                    Text(
                                      "Privacy Policy",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _policySection(
                                        "1. Information We Collect",
                                        "We collect your name, email address, phone number, blood group, district, and address when you register. This information is stored securely in Firebase Cloud Firestore.",
                                      ),
                                      _policySection(
                                        "2. How We Use Your Information",
                                        "Your personal data is used solely to connect blood donors with patients in need. Your blood group and location are visible to other app users to enable blood donation matching.",
                                      ),
                                      _policySection(
                                        "3. Data Sharing",
                                        "We do not sell, trade, or share your personal data with any third party. Your contact information is only visible to other registered users of Blood Connect.",
                                      ),
                                      _policySection(
                                        "4. Donor Eligibility",
                                        "By registering as a donor, you confirm that you are medically fit to donate blood and that you have not donated blood within the last 3 months (90 days).",
                                      ),
                                      _policySection(
                                        "5. Data Security",
                                        "Your data is protected using Google Firebase's industry-standard security. Passwords are encrypted and never stored in plain text.",
                                      ),
                                      _policySection(
                                        "6. Your Rights",
                                        "You can update or delete your account at any time through the Profile screen.",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 0, 20, 16),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text("I Understand"),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                    onPressed: () async {

                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      if (selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select your Date of Birth"),
                          ),
                        );
                        return;
                      }

                      if (!agree) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please accept the Terms & Conditions"),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        isLoading = true;
                      });

                      UserModel user = UserModel(
                        uid: "",
                        fullName: fullNameController.text.trim(),
                        email: emailController.text.trim(),
                        phone: phoneController.text.trim(),
                        bloodGroup: selectedBloodGroup!,
                        gender: selectedGender!,
                        district: selectedDistrict!,
                        address: addressController.text.trim(),
                        dateOfBirth:
                        "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                        isDonor: isDonor,
                      );

                      String? result = await AuthService().registerUser(
                        user: user,
                        password: passwordController.text.trim(),
                      );

                      if (!mounted) return;
                      setState(() {
                        isLoading = false;
                      });

                      if (result == null) {

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Colors.green,
                            content: Text("Registration Successful"),
                          ),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DashboardScreen(),
                          ),
                        );

                      } else {

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(result),
                          ),
                        );

                      }
                    },

                    child: isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Already have an account? Login",
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    addressController.dispose();

    super.dispose();
  }

  InputDecoration _inputDecoration(
      String label,
      IconData icon,
      ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      filled: true,
      fillColor: Colors.white,

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      IconData icon, {
        bool obscure = false,
        Widget? suffix,
        TextEditingController? controller,
        TextInputType keyboardType = TextInputType.text,
        TextInputAction textInputAction = TextInputAction.next,
        int maxLines = 1,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,

      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "$label is required";
        }

        if (label == "Email") {
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return "Enter a valid email";
          }
        }

        if (label == "Phone Number") {
          if (!RegExp(r'^01[3-9]\d{8}$').hasMatch(value)) {
            return "Enter a valid phone number";
          }
        }

        if (label == "Password") {
          if (value.length < 8) {
            return "Minimum 8 characters";
          }

          if (!RegExp(
              r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$')
              .hasMatch(value)) {
            return "Use upper, lower, number & special character";
          }
        }

        if (label == "Confirm Password") {
          if (value != passwordController.text) {
            return "Passwords do not match";
          }
        }

        return null;
      },

      decoration: _inputDecoration(label, icon).copyWith(
        suffixIcon: suffix,
      ),
    );
  }

  Widget _policySection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 3),
          Text(body,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.5)),
        ],
      ),
    );
  }
}