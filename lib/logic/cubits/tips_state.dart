part of 'tips_cubit.dart';

abstract class TipsState extends Equatable {
  const TipsState();

  @override
  List<Object?> get props => [];
}

class TipsInitial extends TipsState {
  const TipsInitial();
}

class TipsLoaded extends TipsState {
  final String tip;
  final String type; // 'nutrition', 'fitness', 'meal', 'random'

  const TipsLoaded({
    required this.tip,
    this.type = 'random',
  });

  @override
  List<Object?> get props => [tip, type];
}
