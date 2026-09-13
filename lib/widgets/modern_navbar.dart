import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/components/family_not_found_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModernNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final VoidCallback? onFABPressed;

  const ModernNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.onFABPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Custom shaped bottom navigation bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(double.infinity, 60),
              painter: NavBarPainter(
                color: FlutterFlowTheme.of(context).primary,
              ),
              child: Container(
                height: 60,
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.home_outlined,
                        color:
                            selectedIndex == 0 ? Colors.white : Colors.white70,
                        size: 26,
                      ),
                      onPressed: () {
                        if (selectedIndex != 0) {
                          context.pushNamed('home');
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.games_outlined,
                        color:
                            selectedIndex == 1 ? Colors.white : Colors.white70,
                        size: 26,
                      ),
                      onPressed: () {
                        if (selectedIndex != 1) {
                          context.pushNamed('GamesList');
                        }
                      },
                    ),
                    // Space for FAB
                    const SizedBox(width: 40),
                    IconButton(
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color:
                            selectedIndex == 2 ? Colors.white : Colors.white70,
                        size: 26,
                      ),
                      onPressed: () async {
                        if (selectedIndex != 2) {
                          final userFamilies = await queryFamiliesRecordOnce(
                            queryBuilder: (q) => q.where('members',
                                arrayContains: currentUserUid),
                            limit: 1,
                          );
                          if (userFamilies.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Please join or create a family first!'),
                                duration: Duration(milliseconds: 4000),
                                backgroundColor:
                                    FlutterFlowTheme.of(context).primary,
                              ),
                            );
                          } else {
                            context.pushNamed('FamilyChat');
                          }
                        }
                      },
                    ),
                    // Profile picture avatar replaces the profile icon
                    GestureDetector(
                      onTap: () {
                        if (selectedIndex != 3) {
                          context.pushNamed('auth_2_Profile');
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedIndex == 3
                                ? Colors.white
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: (currentUserPhoto != null &&
                                  currentUserPhoto.isNotEmpty)
                              ? NetworkImage(currentUserPhoto)
                              : null,
                          child: (currentUserPhoto == null ||
                                  currentUserPhoto.isEmpty)
                              ? Icon(
                                  Icons.person,
                                  color: selectedIndex == 3
                                      ? Colors.white
                                      : Colors.white70,
                                  size: 22,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Action Button
          Positioned(
            top: 0,
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () async {
                    final userFamilies = await queryFamiliesRecordOnce(
                      queryBuilder: (q) =>
                          q.where('members', arrayContains: currentUserUid),
                      limit: 1,
                    );
                    if (userFamilies.isEmpty) {
                      await showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return Dialog(
                            elevation: 0,
                            insetPadding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            alignment: AlignmentDirectional(0.0, 0.0)
                                .resolve(Directionality.of(context)),
                            child: GestureDetector(
                              onTap: () {
                                FocusScope.of(dialogContext).unfocus();
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              child: FamilyNotFoundWidget(),
                            ),
                          );
                        },
                      );
                    } else {
                      final familyRecord = userFamilies.first;
                      context.pushNamed(
                        'FamilyInformation',
                        queryParameters: {
                          'familyRef':
                              serializeParam(familyRecord, ParamType.Document),
                        }.withoutNulls,
                        extra: <String, dynamic>{
                          'familyRef': familyRecord,
                        },
                      );
                    }
                  },
                  child: const Center(
                    child: Icon(
                      Icons.family_restroom,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NavBarPainter extends CustomPainter {
  final Color color;

  NavBarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start from the bottom left
    path.moveTo(0, size.height);

    // Bottom edge
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);

    // Right edge
    path.lineTo(size.width, 20);

    // Top right rounded corner
    path.quadraticBezierTo(size.width, 0, size.width - 20, 0);

    // Top edge right side
    path.lineTo((size.width / 2) + 35, 0);

    // Curve for FAB (right side)
    path.quadraticBezierTo((size.width / 2) + 20, 0, size.width / 2 + 15, 15);

    // Bottom of curve
    path.arcToPoint(
      Offset(size.width / 2 - 15, 15),
      radius: const Radius.circular(20),
      clockwise: false,
    );

    // Curve for FAB (left side)
    path.quadraticBezierTo((size.width / 2) - 20, 0, (size.width / 2) - 35, 0);

    // Top edge left side
    path.lineTo(20, 0);

    // Top left rounded corner
    path.quadraticBezierTo(0, 0, 0, 20);

    // Left edge back to start
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
