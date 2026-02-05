/// ==========================================================================
/// family_group.dart
/// ==========================================================================
/// Oilaviy guruh (Family Sharing) entity.
/// ==========================================================================
library;

class FamilyMember {
  final String id;
  final String displayName;
  final String role; // 'admin', 'member'
  final int contributedPoints;

  const FamilyMember({
    required this.id,
    required this.displayName,
    required this.role,
    this.contributedPoints = 0,
  });
}

class FamilyGroup {
  final String id;
  final String name;
  final String adminId;
  final List<FamilyMember> members;
  final int sharedWalletBalance;

  const FamilyGroup({
    required this.id,
    required this.name,
    required this.adminId,
    required this.members,
    this.sharedWalletBalance = 0,
  });

  FamilyGroup copyWith({
    String? id,
    String? name,
    String? adminId,
    List<FamilyMember>? members,
    int? sharedWalletBalance,
  }) {
    return FamilyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      adminId: adminId ?? this.adminId,
      members: members ?? this.members,
      sharedWalletBalance: sharedWalletBalance ?? this.sharedWalletBalance,
    );
  }
}
