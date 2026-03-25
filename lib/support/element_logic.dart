import 'package:flutter/material.dart';

enum OhaengElement { wood, fire, earth, metal, water }

class ElementTheme {
  const ElementTheme({
    required this.title,
    required this.symbol,
    required this.description,
    required this.accent,
    required this.cardColor,
    required this.buttonColor,
  });

  final String title;
  final String symbol;
  final String description;
  final Color accent;
  final Color cardColor;
  final Color buttonColor;
}

const generates = {
  OhaengElement.wood: OhaengElement.fire,
  OhaengElement.fire: OhaengElement.earth,
  OhaengElement.earth: OhaengElement.metal,
  OhaengElement.metal: OhaengElement.water,
  OhaengElement.water: OhaengElement.wood,
};

const controls = {
  OhaengElement.wood: OhaengElement.earth,
  OhaengElement.earth: OhaengElement.water,
  OhaengElement.water: OhaengElement.fire,
  OhaengElement.fire: OhaengElement.metal,
  OhaengElement.metal: OhaengElement.wood,
};

const defaultRecommendation = {
  'interaction': 'neutral',
  'explanation': 'Balance your energy with simple, steady routines today.',
  'k': ['Warm barley tea'],
  'global': ['Herbal tea', 'Light stretching'],
  'supplement': ['Multivitamin'],
  'avoid': ['Stress', 'Skipping meals'],
};

const recommendationData = {
  OhaengElement.wood: {
    'boost': {
      'explanation':
          'Today supports your Wood energy. This is a strong time for growth, planning, and trying something new.',
      'k': ['Mugwort tea', 'Seasoned greens'],
      'global': ['Green tea', 'Fresh vegetables'],
      'supplement': ['B-complex', 'Vitamin C'],
      'avoid': ['Overcommitting', 'Late-night screen time'],
    },
    'support': {
      'explanation':
          'You may feel busy helping the day move forward. Protect your focus so your energy does not scatter.',
      'k': ['Perilla leaf tea', 'Rice porridge'],
      'global': ['Warm lemon water', 'Whole grains'],
      'supplement': ['Magnesium', 'Multivitamin'],
      'avoid': ['Overworking', 'Too much caffeine'],
    },
    'control': {
      'explanation':
          'You are trying to direct today\'s flow, which can feel demanding. Move steadily and simplify decisions.',
      'k': ['Pear tea', 'Lotus root dishes'],
      'global': ['Chamomile tea', 'Simple soups'],
      'supplement': ['Magnesium', 'Vitamin B6'],
      'avoid': ['Rigid schedules', 'Emotional overload'],
    },
    'suppressed': {
      'explanation':
          'Your Wood energy may feel blocked today. Choose gentle movement and recovery over pressure.',
      'k': ['Warm jujube tea', 'Soft tofu soup'],
      'global': ['Ginger tea', 'Warm oatmeal'],
      'supplement': ['Vitamin D', 'Magnesium'],
      'avoid': ['Cold drinks', 'Heavy arguments'],
    },
  },
  OhaengElement.fire: {
    'boost': {
      'explanation':
          'Today gives extra warmth to your Fire energy. Expression, confidence, and motivation can come naturally.',
      'k': ['Yuja tea', 'Red bean porridge'],
      'global': ['Citrus tea', 'Berry snacks'],
      'supplement': ['CoQ10', 'B-complex'],
      'avoid': ['Impulsive choices', 'Sleep debt'],
    },
    'support': {
      'explanation':
          'You may spend energy uplifting the day around you. Stay bright, but do not burn yourself out.',
      'k': ['Ginseng tea', 'Steamed sweet potato'],
      'global': ['Warm water', 'Balanced meals'],
      'supplement': ['Vitamin C', 'Electrolytes'],
      'avoid': ['Too much sugar', 'Skipping rest'],
    },
    'control': {
      'explanation':
          'Fire is pushing against the day\'s energy. This can feel intense, so pace yourself and cool your mind.',
      'k': ['Omija tea', 'Cucumber sides'],
      'global': ['Mint tea', 'Fresh fruit'],
      'supplement': ['Magnesium', 'Omega-3'],
      'avoid': ['Hot tempers', 'Excess caffeine'],
    },
    'suppressed': {
      'explanation':
          'Your Fire energy may feel dimmed today. Choose warmth, encouragement, and small wins.',
      'k': ['Ginger tea', 'Seaweed soup'],
      'global': ['Warm soup', 'Roasted nuts'],
      'supplement': ['Iron', 'Vitamin B12'],
      'avoid': ['Isolation', 'Overstimulation'],
    },
  },
  OhaengElement.earth: {
    'boost': {
      'explanation':
          'Today strengthens your Earth energy. Stability, nourishment, and dependable habits will feel natural.',
      'k': ['Roasted barley tea', 'Pumpkin porridge'],
      'global': ['Root vegetables', 'Warm grain bowls'],
      'supplement': ['Probiotics', 'Vitamin D'],
      'avoid': ['Overeating', 'Staying inactive too long'],
    },
    'support': {
      'explanation':
          'You may be carrying and grounding the day for others. Offer support without ignoring your own needs.',
      'k': ['Doenjang soup', 'Brown rice'],
      'global': ['Bone broth', 'Bananas'],
      'supplement': ['Magnesium', 'Digestive enzymes'],
      'avoid': ['Taking on everyone\'s stress', 'Heavy late meals'],
    },
    'control': {
      'explanation':
          'Earth is trying to stabilize a day that resists structure. Keep things simple and practical.',
      'k': ['Lotus root tea', 'Steamed squash'],
      'global': ['Herbal tea', 'Simple proteins'],
      'supplement': ['Zinc', 'Magnesium'],
      'avoid': ['Perfectionism', 'Decision fatigue'],
    },
    'suppressed': {
      'explanation':
          'Your Earth energy may feel unsettled today. Focus on grounding routines and gentle nourishment.',
      'k': ['Jujube tea', 'Rice soup'],
      'global': ['Warm milk', 'Plain toast'],
      'supplement': ['Probiotics', 'Vitamin B6'],
      'avoid': ['Cold foods', 'Overthinking'],
    },
  },
  OhaengElement.metal: {
    'boost': {
      'explanation':
          'Today sharpens your Metal energy. Clarity, boundaries, and clean decision-making are supported.',
      'k': ['Bellflower root tea', 'Radish soup'],
      'global': ['Peppermint tea', 'Light salads'],
      'supplement': ['Zinc', 'Vitamin C'],
      'avoid': ['Harsh self-criticism', 'Dry environments'],
    },
    'support': {
      'explanation':
          'You may spend energy refining the day and bringing order. Stay organized without becoming rigid.',
      'k': ['Pear tea', 'White kimchi'],
      'global': ['Warm water', 'Steamed vegetables'],
      'supplement': ['Omega-3', 'Multivitamin'],
      'avoid': ['Overcontrolling', 'Skipping breaks'],
    },
    'control': {
      'explanation':
          'Metal is trying to cut through the day\'s energy, which can feel tense. Choose precision without pressure.',
      'k': ['Honey ginger tea', 'Mild soups'],
      'global': ['Chamomile tea', 'Soft fruits'],
      'supplement': ['Magnesium', 'Vitamin D'],
      'avoid': ['Conflict', 'Too much multitasking'],
    },
    'suppressed': {
      'explanation':
          'Your Metal energy may feel restricted today. Give yourself more room, rest, and clean breathing space.',
      'k': ['Warm pear juice', 'Seaweed rice'],
      'global': ['Eucalyptus tea', 'Simple hydration'],
      'supplement': ['Vitamin C', 'Magnesium'],
      'avoid': ['Dry foods', 'Holding everything in'],
    },
  },
  OhaengElement.water: {
    'boost': {
      'explanation':
          'Today nourishes your Water energy. Reflection, wisdom, and quiet resilience are easier to access.',
      'k': ['Seaweed soup', 'Black sesame tea'],
      'global': ['Green tea', 'Warm lemon water'],
      'supplement': ['Omega-3', 'Magnesium'],
      'avoid': ['Oversleeping', 'Withdrawing too much'],
    },
    'support': {
      'explanation':
          'You may feel drained while supporting growth around you. Keep your pace gentle and protect recovery time.',
      'k': ['Ginseng tea', 'Miyeok-guk'],
      'global': ['Herbal tea', 'Warm soup'],
      'supplement': ['B-complex', 'Multivitamin'],
      'avoid': ['Overworking', 'Too much caffeine'],
    },
    'control': {
      'explanation':
          'Water is working hard to manage today\'s heat. Slow down and conserve your emotional energy.',
      'k': ['Barley tea', 'Tofu stew'],
      'global': ['Chamomile tea', 'Coconut water'],
      'supplement': ['Magnesium', 'Electrolytes'],
      'avoid': ['Conflict', 'Mental overload'],
    },
    'suppressed': {
      'explanation':
          'Your Water energy may feel pressed down today. Restore yourself with warmth, stillness, and consistent care.',
      'k': ['Warm jujube tea', 'Soft rice porridge'],
      'global': ['Chamomile tea', 'Warm oatmeal'],
      'supplement': ['Magnesium', 'Vitamin D'],
      'avoid': ['Cold drinks', 'Skipping rest'],
    },
  },
};

String getInteraction(OhaengElement user, OhaengElement today) {
  if (generates[user] == today) {
    return 'support';
  } else if (generates[today] == user) {
    return 'boost';
  } else if (controls[user] == today) {
    return 'control';
  } else if (controls[today] == user) {
    return 'suppressed';
  } else {
    return 'neutral';
  }
}

Map<String, dynamic> getRecommendation(OhaengElement user, OhaengElement today) {
  final interaction = getInteraction(user, today);
  final base = recommendationData[user]?[interaction] as Map<String, dynamic>?;

  return {
    ...defaultRecommendation,
    ...?base,
    'interaction': interaction,
  };
}

OhaengElement getTodayElement() {
  final days = DateTime.now().difference(DateTime(1984, 2, 2)).inDays;
  final ganzhiIndex = days % 60;
  final stemIndex = ganzhiIndex % 10;
  return getElementFromStem(stemIndex);
}

OhaengElement getElementFromStem(int stemIndex) {
  switch (stemIndex) {
    case 0:
    case 1:
      return OhaengElement.wood;
    case 2:
    case 3:
      return OhaengElement.fire;
    case 4:
    case 5:
      return OhaengElement.earth;
    case 6:
    case 7:
      return OhaengElement.metal;
    case 8:
    case 9:
      return OhaengElement.water;
    default:
      return OhaengElement.earth;
  }
}

OhaengElement getUserElementFromBirthdate(DateTime birthdate) {
  final month = birthdate.month;
  final day = birthdate.day;

  if (day == 10 || day == 20 || day == 30) {
    return OhaengElement.earth;
  }
  if (month >= 3 && month <= 5) {
    return OhaengElement.wood;
  }
  if (month >= 6 && month <= 8) {
    return OhaengElement.fire;
  }
  if (month >= 9 && month <= 11) {
    return OhaengElement.metal;
  }
  return OhaengElement.water;
}

String formatElement(OhaengElement element) {
  switch (element) {
    case OhaengElement.wood:
      return 'Wood';
    case OhaengElement.fire:
      return 'Fire';
    case OhaengElement.earth:
      return 'Earth';
    case OhaengElement.metal:
      return 'Metal';
    case OhaengElement.water:
      return 'Water';
  }
}

String capitalize(String value) {
  if (value.isEmpty) {
    return value;
  }
  return value[0].toUpperCase() + value.substring(1);
}

String joinItems(List<String> items) {
  return items.join(', ');
}

String formatBirthDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

String formatBirthTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String displayElementIcon(OhaengElement? element, String fallback) {
  switch (element) {
    case OhaengElement.wood:
      return '🌿';
    case OhaengElement.fire:
      return '🔥';
    case OhaengElement.earth:
      return '⛰️';
    case OhaengElement.metal:
      return '💎';
    case OhaengElement.water:
      return '🌊';
    case null:
      return fallback;
  }
}

ElementTheme elementTheme(OhaengElement element) {
  switch (element) {
    case OhaengElement.wood:
      return const ElementTheme(
        title: 'Wood (木) - Vitality',
        symbol: '🌿',
        description:
            'Wood energy is associated with growth, renewal, and forward movement. In a Korean saju-inspired reading based on your birth date and birth time, it can suggest flexibility, creativity, and the drive to begin something new.',
        accent: Color(0xFF5E8B63),
        cardColor: Color(0xFFE7F3E8),
        buttonColor: Color(0xFFD7EAD9),
      );
    case OhaengElement.fire:
      return const ElementTheme(
        title: 'Fire (火) - Passion',
        symbol: '🔥',
        description:
            'Fire energy reflects warmth, expression, and visible vitality. In a Korean saju-inspired reading based on your birth date and birth time, it can point to confidence, enthusiasm, and a strong desire to connect, act, and shine outward.',
        accent: Color(0xFFD96C3D),
        cardColor: Color(0xFFFFE9DE),
        buttonColor: Color(0xFFFFD5C2),
      );
    case OhaengElement.earth:
      return const ElementTheme(
        title: 'Earth (土) - Balance',
        symbol: '⛰️',
        description:
            'Earth energy stands for steadiness, nourishment, and balance. In a Korean saju-inspired reading based on your birth date and birth time, it often reflects grounded care, emotional stability, and the ability to hold things together for yourself and others.',
        accent: Color(0xFFA77A3F),
        cardColor: Color(0xFFF8EED8),
        buttonColor: Color(0xFFF1DFB8),
      );
    case OhaengElement.metal:
      return const ElementTheme(
        title: 'Metal (金) - Strength',
        symbol: '💎',
        description:
            'Metal energy represents clarity, discipline, and inner strength. In a Korean saju-inspired reading based on your birth date and birth time, it often suggests focus, self-respect, and the ability to refine what matters most.',
        accent: Color(0xFF7A8088),
        cardColor: Color(0xFFF1F3F5),
        buttonColor: Color(0xFFE0E4E8),
      );
    case OhaengElement.water:
      return const ElementTheme(
        title: 'Water (水) - Wisdom',
        symbol: '🌊',
        description:
            'Water energy is linked to reflection, intuition, and deep wisdom. In a Korean-style elemental reading based on your birth date and birth time, it can suggest emotional depth, calm thinking, and quiet resilience.',
        accent: Color(0xFF4E6FAE),
        cardColor: Color(0xFFE6EEF9),
        buttonColor: Color(0xFFD6E3F6),
      );
  }
}
