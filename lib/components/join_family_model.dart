import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'join_family_widget.dart' show JoinFamilyWidget;
import 'package:flutter/material.dart';

class JoinFamilyModel extends FlutterFlowModel<JoinFamilyWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for JoinCodeText widget.
  FocusNode? joinCodeTextFocusNode;
  TextEditingController? joinCodeTextTextController;
  String? Function(BuildContext, String?)? joinCodeTextTextControllerValidator;
  // Stores action output result for [Firestore Query - Query a collection] action in Button widget.
  List<FamiliesRecord>? familyQuery;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    joinCodeTextFocusNode?.dispose();
    joinCodeTextTextController?.dispose();
  }
}
