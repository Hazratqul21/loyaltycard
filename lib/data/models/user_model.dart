import 'package:hive/hive.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends UserEntity {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String email;
  
  @HiveField(2)
  final String? displayName;
  
  @HiveField(3)
  final String? photoUrl;
  
  @HiveField(4)
  final String? phoneNumber;
  
  @HiveField(5)
  final bool isEmailVerified;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.isEmailVerified = false,
  }) : super(
          id: id,
          email: email,
          displayName: displayName,
          photoUrl: photoUrl,
          phoneNumber: phoneNumber,
          isEmailVerified: isEmailVerified,
        );

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      phoneNumber: entity.phoneNumber,
      isEmailVerified: entity.isEmailVerified,
    );
  }
}
