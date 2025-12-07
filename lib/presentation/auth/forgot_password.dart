import 'package:flutter/material.dart';

// Definisikan warna utama (jika tidak diimport dari file lain)
const Color primaryColor = Color(0xFFD32F2F);

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  // Helper untuk membuat input field dengan Poppins font
  Widget _buildTextField(String label) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Poppins'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 10.0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  // Helper untuk membuat tombol dengan Poppins font
  Widget _buildSendEmailButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight,
          child: Column(
            children: <Widget>[
              // --- Bagian Header dengan Gradient ---
              Container(
                width: double.infinity,
                height: screenHeight * 0.25,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [primaryColor, Colors.red.shade400],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lupa Password?',
                        style:
                            Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ) ??
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kami siap membantu Anda',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'Poppins',
                            ) ??
                            TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'Poppins',
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Kartu Reset Password Putih ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Reset Password',
                          style:
                              Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ) ??
                              const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Masukkan email UNHAS Anda untuk menerima kode reset password',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
                              ) ??
                              TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
                              ),
                        ),
                        const SizedBox(height: 30),

                        // Input Email
                        Text(
                          'Email',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                        ),
                        const SizedBox(height: 8),
                        _buildTextField('Masukkan email UNHAS Anda'),
                        const SizedBox(height: 30),

                        // Tombol Send Email
                        _buildSendEmailButton('Kirim Email Reset'),

                        const SizedBox(height: 20),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                'atau',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.grey[600],
                                      fontFamily: 'Poppins',
                                    ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Tombol Kembali ke Login
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Kembali ke Login',
                              style:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ) ??
                                  const TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Informasi tambahan
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue.shade700),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Email reset akan dikirim dalam beberapa menit',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.blue.shade700,
                                        fontFamily: 'Poppins',
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
