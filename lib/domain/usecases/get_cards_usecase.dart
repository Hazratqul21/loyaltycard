import '../repositories/loyalty_repository.dart';
import '../entities/loyalty_card.dart';
// Yoki Either tipidagi return uchun

class GetCardsUseCase {
  final LoyaltyRepository repository;

  GetCardsUseCase(this.repository);

  // Bu funksiya repositoriydan kartalarni so'raydi
  Future<List<LoyaltyCard>> call(String userId) async {
    return await repository.getAllCards();
  }
}
