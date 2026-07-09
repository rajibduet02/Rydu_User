import '../../domain/entities/confidence_item_entity.dart';
import '../models/confidence_item_model.dart';
import '../models/destination_model.dart';
import '../models/intercity_content_model.dart';

abstract interface class IntercityLocalDatasource {
  Future<IntercityContentModel> fetchIntercityContent();
}

class IntercityLocalDatasourceImpl implements IntercityLocalDatasource {
  static const _destinations = <DestinationModel>[
    DestinationModel(
      id: 'rajshahi',
      cityName: 'Rajshahi',
      startingPrice: 'Starting at Tk.499',
      imagePath:
          'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=400&h=300&fit=crop',
    ),
    DestinationModel(
      id: 'sylhet',
      cityName: 'Sylhet',
      startingPrice: 'Starting at Tk.699',
      imagePath:
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop',
    ),
  ];

  static const _confidenceItems = <ConfidenceItemModel>[
    ConfidenceItemModel(
      id: 'top_drivers',
      title: 'Top-rated drivers',
      iconType: ConfidenceIconType.award,
    ),
    ConfidenceItemModel(
      id: 'trusted',
      title: 'Trusted worldwide',
      iconType: ConfidenceIconType.shield,
    ),
    ConfidenceItemModel(
      id: 'prebook',
      title: 'Pre-book up to 90 Days',
      iconType: ConfidenceIconType.calendar,
    ),
    ConfidenceItemModel(
      id: 'tracking',
      title: 'Live Trip Tracking',
      iconType: ConfidenceIconType.mapPin,
    ),
  ];

  @override
  Future<IntercityContentModel> fetchIntercityContent() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return const IntercityContentModel(
      popularDestinations: _destinations,
      confidenceItems: _confidenceItems,
    );
  }
}
