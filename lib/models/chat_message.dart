class ChatMessage {
  final String text;
  final bool isUser;
  final bool isLoading;
  final bool isResumeCard;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isLoading = false,
    this.isResumeCard = false,
  });

  Map<String, dynamic> toMap() => {
    'text': text,
    'isUser': isUser,
    'isLoading': isLoading,
    'isResumeCard': isResumeCard,
  };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
    text: map['text'] ?? '',
    isUser: map['isUser'] ?? false,
    isLoading: map['isLoading'] ?? false,
    isResumeCard: map['isResumeCard'] ?? false,
  );
}
