import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_message.dart';

class ResumeModel {
  final String id;
  final String userId;
  final String title;
  final String field;
  final PersonalInfo personalInfo;
  final String summary;
  final List<Education> education;
  final List<Experience> experience;
  final List<String> skills;
  final List<String> languages;
  final List<Project> projects;
  final DateTime updatedAt;
  final int atsScore;
  final String template;
  final List<ChatMessage> chatHistory;

  ResumeModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.field,
    required this.personalInfo,
    required this.summary,
    required this.education,
    required this.experience,
    required this.skills,
    this.languages = const [],
    required this.projects,
    required this.updatedAt,
    required this.atsScore,
    this.template = 'Modern',
    this.chatHistory = const [],
  });

  factory ResumeModel.fromMap(Map<String, dynamic> map, String id) {
    return ResumeModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      field: map['field'] ?? '',
      summary: map['summary'] ?? '',
      atsScore: map['atsScore'] ?? 0,
      template: map['template'] ?? 'Modern',
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      personalInfo: PersonalInfo.fromMap(map['personalInfo'] ?? {}),
      education: (map['education'] as List? ?? []).map((e) => Education.fromMap(e)).toList(),
      experience: (map['experience'] as List? ?? []).map((e) => Experience.fromMap(e)).toList(),
      skills: List<String>.from(map['skills'] ?? []),
      languages: List<String>.from(map['languages'] ?? []),
      projects: (map['projects'] as List? ?? []).map((e) => Project.fromMap(e)).toList(),
      chatHistory: (map['chatHistory'] as List? ?? []).map((e) => ChatMessage.fromMap(e)).toList(),
    );
  }

  ResumeModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? field,
    PersonalInfo? personalInfo,
    String? summary,
    List<Education>? education,
    List<Experience>? experience,
    List<String>? skills,
    List<String>? languages,
    List<Project>? projects,
    DateTime? updatedAt,
    int? atsScore,
    String? template,
    List<ChatMessage>? chatHistory,
  }) {
    return ResumeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      field: field ?? this.field,
      personalInfo: personalInfo ?? this.personalInfo,
      summary: summary ?? this.summary,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
      projects: projects ?? this.projects,
      updatedAt: updatedAt ?? this.updatedAt,
      atsScore: atsScore ?? this.atsScore,
      template: template ?? this.template,
      chatHistory: chatHistory ?? this.chatHistory,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'field': field,
      'summary': summary,
      'atsScore': atsScore,
      'template': template,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'personalInfo': personalInfo.toMap(),
      'education': education.map((e) => e.toMap()).toList(),
      'experience': experience.map((e) => e.toMap()).toList(),
      'skills': skills,
      'languages': languages,
      'projects': projects.map((e) => e.toMap()).toList(),
      'chatHistory': chatHistory.map((e) => e.toMap()).toList(),
    };
  }
}

class PersonalInfo {
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final String linkedIn;
  final String github;
  final String portfolio;
  final String photoBase64;

  PersonalInfo({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    this.linkedIn = '',
    this.github = '',
    this.portfolio = '',
    this.photoBase64 = '',
  });

  factory PersonalInfo.fromMap(Map<String, dynamic> map) {
    return PersonalInfo(
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      location: map['location'] ?? '',
      linkedIn: map['linkedIn'] ?? '',
      github: map['github'] ?? '',
      portfolio: map['portfolio'] ?? '',
      photoBase64: map['photoBase64'] ?? '',
    );
  }

  PersonalInfo copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? location,
    String? linkedIn,
    String? github,
    String? portfolio,
    String? photoBase64,
  }) {
    return PersonalInfo(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      linkedIn: linkedIn ?? this.linkedIn,
      github: github ?? this.github,
      portfolio: portfolio ?? this.portfolio,
      photoBase64: photoBase64 ?? this.photoBase64,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'linkedIn': linkedIn,
      'github': github,
      'portfolio': portfolio,
      'photoBase64': photoBase64,
    };
  }
}

class Education {
  final String school;
  final String degree;
  final String startDate;
  final String endDate;
  final String description;

  Education({
    required this.school,
    required this.degree,
    required this.startDate,
    required this.endDate,
    this.description = '',
  });

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      school: map['school'] ?? '',
      degree: map['degree'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'school': school,
      'degree': degree,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
    };
  }
}

class Experience {
  final String company;
  final String role;
  final String startDate;
  final String endDate;
  final List<String> responsibilities;

  Experience({
    required this.company,
    required this.role,
    required this.startDate,
    required this.endDate,
    required this.responsibilities,
  });

  factory Experience.fromMap(Map<String, dynamic> map) {
    return Experience(
      company: map['company'] ?? '',
      role: map['role'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      responsibilities: List<String>.from(map['responsibilities'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'company': company,
      'role': role,
      'startDate': startDate,
      'endDate': endDate,
      'responsibilities': responsibilities,
    };
  }
}

class Project {
  final String name;
  final String description;
  final String technologies;
  final String link;

  Project({
    required this.name,
    required this.description,
    required this.technologies,
    required this.link,
  });

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      technologies: map['technologies'] ?? '',
      link: map['link'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'technologies': technologies,
      'link': link,
    };
  }
}
