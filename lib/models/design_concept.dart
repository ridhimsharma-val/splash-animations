enum DesignCategory {
  splashScreen('Splash Screen'),
  onboarding('Onboarding');

  final String label;
  const DesignCategory(this.label);
}

enum DesignStatus {
  activePlaceholder('Interactive'),
  comingSoon('Coming Soon');

  final String label;
  const DesignStatus(this.label);
}

/// Metadata model describing an animation design entry in the lab.
class DesignConcept {
  final String id;
  final String number;
  final String title;
  final String description;
  final DesignCategory category;
  final DesignStatus status;

  const DesignConcept({
    required this.id,
    required this.number,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
  });

  /// The registered initial collection of 8 animation design concepts.
  static const List<DesignConcept> collection = [
    DesignConcept(
      id: 'design_01',
      number: '01',
      title: 'Donut Spin',
      description: '3D splash animation with gooey bounce, sprinkle particles & portal reveal.',
      category: DesignCategory.splashScreen,
      status: DesignStatus.activePlaceholder,
    ),
    DesignConcept(
      id: 'design_02',
      number: '02',
      title: 'Magic Fridge',
      description: 'Magical refrigerator splash with a 2.5D door opening, floating fresh ingredients, orbital gathering, and NutriFridge brand reveal.',
      category: DesignCategory.splashScreen,
      status: DesignStatus.activePlaceholder,
    ),
    DesignConcept(
      id: 'design_03',
      number: '03',
      title: 'Cinematic Splash',
      description: 'A more expressive, cinematic introduction using layered visual elements and coordinated movement.',
      category: DesignCategory.splashScreen,
      status: DesignStatus.comingSoon,
    ),
    DesignConcept(
      id: 'design_04',
      number: '04',
      title: 'Illustrated Onboarding',
      description: 'An onboarding screen where an illustration and its supporting content enter in a coordinated sequence.',
      category: DesignCategory.onboarding,
      status: DesignStatus.comingSoon,
    ),
    DesignConcept(
      id: 'design_05',
      number: '05',
      title: 'Parallax Onboarding',
      description: 'An onboarding experience that uses different movement speeds across visual layers to create depth.',
      category: DesignCategory.onboarding,
      status: DesignStatus.comingSoon,
    ),
    DesignConcept(
      id: 'design_06',
      number: '06',
      title: 'Morphing Onboarding Carousel',
      description: 'A multi-page onboarding experience with coordinated transitions between illustrations, titles, and descriptions.',
      category: DesignCategory.onboarding,
      status: DesignStatus.comingSoon,
    ),
    DesignConcept(
      id: 'design_07',
      number: '07',
      title: 'Liquid Page Indicators',
      description: 'An onboarding carousel with expressive, fluid page-indicator movement synchronized with page changes.',
      category: DesignCategory.onboarding,
      status: DesignStatus.comingSoon,
    ),
    DesignConcept(
      id: 'design_08',
      number: '08',
      title: 'Staggered Content Reveal',
      description: 'A carefully sequenced entrance for headings, descriptions, illustrations, and call-to-action buttons.',
      category: DesignCategory.onboarding,
      status: DesignStatus.comingSoon,
    ),
  ];
}
