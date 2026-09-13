import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/default_profile_avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({
    Key? key,
    required this.user,
  }) : super(key: key);

  final UsersRecord user;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 300),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Color(0x19000000),
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient background
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      FlutterFlowTheme.of(context).primary,
                      FlutterFlowTheme.of(context).secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Profile Picture
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).info,
                            width: 3,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(3),
                          child: user.photoUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: CachedNetworkImage(
                                    imageUrl: user.photoUrl,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        DefaultProfileAvatar(
                                      displayName: user.displayName,
                                      size: 120,
                                    ),
                                  ),
                                )
                              : DefaultProfileAvatar(
                                  displayName: user.displayName,
                                  size: 120,
                                ),
                        ),
                      ),
                      SizedBox(height: 16),
                      // User Name
                      Text(
                        user.displayName,
                        style:
                            FlutterFlowTheme.of(context).headlineSmall.override(
                                  fontFamily: 'Inter Tight',
                                  color: FlutterFlowTheme.of(context).info,
                                  letterSpacing: 0,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              // Profile Details
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone Number
                    if (user.phoneNumber.isNotEmpty) ...[
                      _buildInfoRow(
                        context,
                        'Phone',
                        user.phoneNumber,
                        Icons.phone_outlined,
                      ),
                      SizedBox(height: 16),
                    ],
                    // Join Date
                    _buildInfoRow(
                      context,
                      'Member Since',
                      _formatDate(user.createdTime),
                      Icons.calendar_today_outlined,
                    ),
                    SizedBox(height: 16),
                    // About Me Section
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context)
                            .primary
                            .withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: FlutterFlowTheme.of(context)
                              .primary
                              .withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  color: FlutterFlowTheme.of(context).primary,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'About Me',
                                  style: FlutterFlowTheme.of(context)
                                      .titleSmall
                                      .override(
                                        fontFamily: 'Inter',
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                        letterSpacing: 0,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              user.shortDescription.isNotEmpty
                                  ? user.shortDescription
                                  : 'No information provided',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Inter',
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Close Button
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlutterFlowTheme.of(context).secondary,
                      foregroundColor: FlutterFlowTheme.of(context).info,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Inter',
                            color: FlutterFlowTheme.of(context).info,
                            letterSpacing: 0,
                          ),
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

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: FlutterFlowTheme.of(context).primary,
            size: 24,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      fontFamily: 'Inter',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0,
                    ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: FlutterFlowTheme.of(context).titleMedium.override(
                      fontFamily: 'Inter',
                      color: FlutterFlowTheme.of(context).primaryText,
                      letterSpacing: 0,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
