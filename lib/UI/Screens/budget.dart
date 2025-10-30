// import 'dart:math' as math;

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:go_router/go_router.dart';
// import 'package:send_snap/UI/Components/bottombar.dart';

// class CreateBudgetPage extends StatefulWidget {
//   const CreateBudgetPage({super.key});

//   @override
//   State<CreateBudgetPage> createState() => _CreateBudgetPageState();
// }

// class _CreateBudgetPageState extends State<CreateBudgetPage> {
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();
//   DateTimeRange? _selectedDateRange;

//   Future<void> _pickDateRange() async {
//     final now = DateTime.now();
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(now.year - 1),
//       lastDate: DateTime(now.year + 2),
//       initialDateRange: DateTimeRange(
//         start: now,
//         end: now.add(const Duration(days: 30)),
//       ),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF7F3DFF),
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() => _selectedDateRange = picked);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: const Color(0xFF7F3DFF),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF7F3DFF),
//         elevation: 0,
//         leading: IconButton(
//           icon: SvgPicture.asset(
//             'assets/icons/arrow-left.svg',
//             colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Create Budget",
//           style: TextStyle(
//             color: Colors.white,
//             fontFamily: 'Inter',
//             fontWeight: FontWeight.w700,
//             fontSize: 18,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: [
//           Positioned(
//             top: 180,
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(32),
//                   topRight: Radius.circular(32),
//                 ),
//               ),
//             ),
//           ),
//           SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Column(
//               children: [
//                 const SizedBox(height: 40),
//                 // Amount Section
//                 const Text(
//                   "How much?",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w400,
//                     fontSize: 18,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: _amountController,
//                   keyboardType: TextInputType.number,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontFamily: 'Inter',
//                     fontWeight: FontWeight.w700,
//                     fontSize: 36,
//                   ),
//                   textAlign: TextAlign.center,
//                   decoration: const InputDecoration(
//                     border: InputBorder.none,
//                     hintText: "0",
//                     hintStyle: TextStyle(
//                       color: Colors.white54,
//                       fontFamily: 'Inter',
//                       fontWeight: FontWeight.w700,
//                       fontSize: 36,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 50),

//                 // White Card Section
//                 Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
//                     borderRadius: BorderRadius.circular(32),
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 28,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Category
//                       const Text(
//                         "Category",
//                         style: TextStyle(
//                           fontFamily: 'Inter',
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                           color: Color(0xFF7F3DFF),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       GestureDetector(
//                         onTap: () {},
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 14,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isDark
//                                 ? const Color(0xFF3A3A3A)
//                                 : Colors.grey[100],
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               const Text(
//                                 "Select Category",
//                                 style: TextStyle(
//                                   fontFamily: 'Inter',
//                                   fontSize: 15,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               SvgPicture.asset(
//                                 'assets/icons/arrow-down-2.svg',
//                                 colorFilter: const ColorFilter.mode(
//                                   Colors.grey,
//                                   BlendMode.srcIn,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       // Date Range
//                       const Text(
//                         "Date Range",
//                         style: TextStyle(
//                           fontFamily: 'Inter',
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                           color: Color(0xFF7F3DFF),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       GestureDetector(
//                         onTap: _pickDateRange,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 14,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isDark
//                                 ? const Color(0xFF3A3A3A)
//                                 : Colors.grey[100],
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 _selectedDateRange == null
//                                     ? "Select Date Range"
//                                     : "${_selectedDateRange!.start.toLocal().toString().split(' ')[0]} - ${_selectedDateRange!.end.toLocal().toString().split(' ')[0]}",
//                                 style: const TextStyle(
//                                   fontFamily: 'Inter',
//                                   fontSize: 15,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               Icon(Icons.calendar_month_rounded),
//                             ],
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 20),

//                       // Description
//                       const Text(
//                         "Description",
//                         style: TextStyle(
//                           fontFamily: 'Inter',
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                           color: Color(0xFF7F3DFF),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       TextField(
//                         controller: _noteController,
//                         maxLines: 2,
//                         decoration: InputDecoration(
//                           hintText: "Add a note...",
//                           hintStyle: const TextStyle(
//                             fontFamily: 'Inter',
//                             color: Colors.grey,
//                           ),
//                           filled: true,
//                           fillColor: isDark
//                               ? const Color(0xFF3A3A3A)
//                               : Colors.grey[100],
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(16),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),

//                       const SizedBox(height: 40),

//                       // Create Budget Button
//                       SizedBox(
//                         width: double.infinity,
//                         height: 55,
//                         child: ElevatedButton(
//                           onPressed: () {},
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF7F3DFF),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                           ),
//                           child: const Text(
//                             "Create Budget",
//                             style: TextStyle(
//                               fontFamily: 'Inter',
//                               fontWeight: FontWeight.w600,
//                               fontSize: 16,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 60),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: SizedBox(
//         width: 60,
//         height: 60,
//         child: FloatingActionButton(
//           backgroundColor: const Color(0xFF7F3DFF),
//           elevation: 0,
//           shape: const CircleBorder(),
//           onPressed: () {
//             context.pushNamed('/addExpense');
//           },
//           child: Transform.rotate(
//             angle: 25 * math.pi / 100,
//             child: SvgPicture.asset(
//               width: 40,
//               height: 40,
//               'assets/icons/close.svg',
//               colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
//             ),
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavBar(currentIndex: 2),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateBudgetPage extends StatefulWidget {
  const CreateBudgetPage({super.key});

  @override
  State<CreateBudgetPage> createState() => _CreateBudgetPageState();
}

class _CreateBudgetPageState extends State<CreateBudgetPage> {
  final _budgetNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _currencyController = TextEditingController(text: 'USD');
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _budgetNameController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final purple = const Color(0xFF7F3DFF);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            // --- AppBar Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    child: SvgPicture.asset(
                      'assets/icons/arrow-left.svg',
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Text(
                    "Create Budget",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Amount Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 64,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      controller: _currencyController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // --- White Card Section ---
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Budget Name
                      TextFormField(
                        controller: _budgetNameController,
                        decoration: _inputDecoration('Budget Name'),
                      ),
                      const SizedBox(height: 12),

                      // Start Date
                      TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        decoration: _inputDecorationWithIcon(
                          'Start Date',
                          Icons.calendar_month_rounded,
                          () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2050),
                            );
                            if (picked != null) {
                              _startDateController.text =
                                  "${picked.day}/${picked.month}/${picked.year}";
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // End Date
                      TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        decoration: _inputDecorationWithIcon(
                          'End Date',
                          Icons.calendar_month_rounded,
                          () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2050),
                            );
                            if (picked != null) {
                              _endDateController.text =
                                  "${picked.day}/${picked.month}/${picked.year}";
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _inputDecoration('Description (optional)'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // --- Bottom Button ---
      bottomNavigationBar: Container(
        color: theme.colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Budget Created (UI only)')),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: theme.colorScheme.primary,
              ),
              child: const Text(
                "Create Budget",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final theme = Theme.of(context);

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: theme.textTheme.bodyMedium!.color),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      fillColor: theme.colorScheme.surface,
      filled: true,
    );
  }

  InputDecoration _inputDecorationWithIcon(
    String hint,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: theme.textTheme.bodyMedium!.color),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      fillColor: theme.colorScheme.surface,
      filled: true,
      suffixIcon: GestureDetector(
        onTap: onTap,
        child: Icon(icon, color: theme.iconTheme.color),
      ),
    );
  }
}
