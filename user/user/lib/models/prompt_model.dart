import 'package:cloud_firestore/cloud_firestore.dart';

class PromptModel {
  String? question;
  String? responses;

  PromptModel({
    this.question,
    this.responses,
  });

  factory PromptModel.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PromptModel(
      question: data['question'],
      responses: data['responses'],
    );
  }
}
