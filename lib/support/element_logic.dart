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
  'reasonLine':
      'Today leans steady overall, so simple consistent choices will work best.',
  'k': ['Warm barley tea', 'Soft fruit', 'Simple soup'],
  'global': [
    'Wellness focus: stay hydrated and avoid overloading your schedule.',
    'If your energy feels low, a simple multivitamin or magnesium routine may help you feel steadier.',
  ],
  'supplement': ['Multivitamin'],
  'avoid': ['Stress', 'Skipping meals'],
};

const Map<String, String> _stateLeadLines = {
  'restore':
      'Today looks more draining than expansive, so recovery choices deserve more weight.',
  'focus':
      'Mental clarity matters more than speed today, so support concentration before volume.',
  'lift':
      'Your mood can shift quickly today, so choose options that stabilize rather than spike.',
  'steady':
      'Today is relatively balanced, which makes consistency more useful than intensity.',
  'spark':
      'You have more outward energy available today, so channel it cleanly instead of scattering it.',
  'cool':
      'The day can run hot or overstimulating, so cooling and calming choices will serve you well.',
};

const Map<String, List<String>> _supportFocusLibrary = {
  'restore': [
    'Wellness focus: make the day easier on yourself, hydrate early, and eat on time.',
    'Supplement angle: magnesium, vitamin D, or iron-supportive nutrients may suit lower-energy days.',
    'Choose steady, nourishing food over convenience if your body feels run down.',
    'Protect recovery first instead of trying to win the day with willpower alone.',
  ],
  'focus': [
    'Wellness focus: keep caffeine moderate, drink more water, and make meals less rushed.',
    'Supplement angle: B-complex, omega-3, or magnesium may suit focus-heavy days.',
    'A protein-rich meal and a short walk may help you stay focused longer.',
    'Build clarity with routine instead of waiting for motivation to appear.',
  ],
  'lift': [
    'Wellness focus: keep your energy steady and avoid long gaps between meals.',
    'Supplement angle: magnesium or B6 may suit days with tension or mood swings.',
    'Choose calm, grounding habits over sugary or overly stimulating fixes.',
    'Be a little gentler with yourself if your mood feels easy to knock off balance today.',
  ],
  'steady': [
    'Wellness focus: keep your best habits simple and easy to repeat.',
    'Supplement angle: a simple multivitamin, probiotics, or omega-3 can work well on maintenance days.',
    'Nothing extreme is needed today if you stay consistent with basics.',
    'Use the calmer rhythm to reinforce one habit that is already working.',
  ],
  'spark': [
    'Wellness focus: use your energy early, then keep your pace organized.',
    'Supplement angle: B-complex, CoQ10, or electrolytes may suit active, high-output days.',
    'This is a better day for channeling energy than for suppressing it.',
    'Pair momentum with hydration so a good day does not turn into burnout.',
  ],
  'cool': [
    'Wellness focus: reduce overstimulation, cool things down, and keep your choices simple.',
    'Supplement angle: magnesium, omega-3, or electrolytes may suit tense or overheated days.',
    'Cooling foods and calmer rhythms will likely work better than pushing harder.',
    'Reduce the noise around you if everything already feels intense.',
  ],
};

const Map<OhaengElement, List<String>> _elementFoodLibrary = {
  OhaengElement.wood: [
    'Leafy greens',
    'Herb-forward dishes',
    'Light grain bowls',
    'Tofu or bean-based meals',
    'Crunchy vegetables',
    'Fresh wraps',
    'Vegetable soups',
    'Citrus or kiwi',
  ],
  OhaengElement.fire: [
    'Hydrating fruit',
    'Cooling side dishes',
    'Lighter protein bowls',
    'Yogurt or kefir if it suits you',
    'Water-rich vegetables',
    'Bright fruit snacks',
    'Simple noodle dishes',
    'Electrolyte-friendly drinks',
  ],
  OhaengElement.earth: [
    'Warm cooked grains',
    'Root vegetables',
    'Stews or porridges',
    'Bean or lentil dishes',
    'Squash or pumpkin',
    'Soft balanced meals',
    'Simple savory breakfasts',
    'Gentle digestion-friendly snacks',
  ],
  OhaengElement.metal: [
    'Clean simple soups',
    'Pear or apple',
    'Lightly cooked vegetables',
    'Rice or noodle bowls with clear flavors',
    'Broth-based meals',
    'Hydrating produce',
    'Mild fermented sides',
    'Tofu or egg-based dishes',
  ],
  OhaengElement.water: [
    'Mineral-rich soups',
    'Dark grains or beans',
    'Seaweed or mushroom dishes',
    'Protein-supportive meals',
    'Warm breakfasts',
    'Soft savory bowls',
    'Sesame-based foods',
    'A steady amount of water with meals',
  ],
};

const Map<String, List<String>> _stateFoodLibrary = {
  'restore': [
    'A warm meal that feels easy to digest',
    'Protein with complex carbs',
    'Soup, porridge, or broth-based food',
    'Iron-supportive foods if you feel depleted',
    'Magnesium-rich foods like seeds or leafy greens',
    'Regular meals instead of grazing randomly',
    'Steady hydration with a little salt or minerals',
    'A calmer breakfast instead of only caffeine',
  ],
  'focus': [
    'Protein-first meals',
    'Lower-sugar snacks',
    'Omega-3 supportive choices',
    'Hydration before another coffee',
    'Fiber with lunch so energy stays even',
    'A meal that will not make you sluggish afterward',
    'Simple balanced food over convenience sugar',
    'A lighter dinner if your brain already feels crowded',
  ],
  'lift': [
    'Meals that help keep your energy steady',
    'Snacks with protein and fiber to help you feel more balanced',
    'Foods rich in magnesium',
    'Less sugary comfort food than usual',
    'Grounding warm drinks',
    'Something savory before reaching for sweets',
    'Calming carbs paired with protein',
    'Regular hydration if you feel emotionally unsettled',
  ],
  'steady': [
    'A balanced simple meal',
    'Repeatable basics that are easy to sustain',
    'Hydration spread across the day',
    'A normal amount of caffeine instead of extra',
    'Nothing too heavy right before work or study',
    'Whole-food snacks that keep momentum clean',
    'Consistent meals instead of skipping and catching up',
    'Enough protein to keep energy even',
  ],
  'spark': [
    'Fuel that matches a busier day',
    'Protein and carbs together before a demanding block',
    'Hydration with a little electrolyte support',
    'A substantial breakfast if your output is high',
    'Food that supports movement rather than crashes',
    'Light but energizing meals',
    'Portable snacks for a fast day',
    'A cleaner caffeine rhythm so energy stays useful',
  ],
  'cool': [
    'Cooling or lighter foods',
    'Extra hydration',
    'Less spicy or overly rich meals',
    'Fruit or vegetables with high water content',
    'Calmer drinks over more stimulants',
    'Simple meals that reduce internal heat',
    'A gentle dinner if the day feels overstimulating',
    'Electrolyte support if you feel wired and drained',
  ],
};

const Map<String, List<String>> _stateAvoidLibrary = {
  'restore': [
    'Skipping meals',
    'Using caffeine as a substitute for food',
    'Late-night catch-up work',
    'Overbooking yourself',
    'Ignoring signs that you need rest',
    'Pushing through exhaustion',
  ],
  'focus': [
    'Too many tabs or tasks at once',
    'Mindless snacking',
    'Erratic caffeine use',
    'Phone interruptions during deep work',
    'Heavy lunches before concentration blocks',
    'Switching priorities too often',
  ],
  'lift': [
    'Sugar spikes followed by crashes',
    'Impulsive decisions driven by emotion',
    'Doomscrolling when already tense',
    'Forgetting to drink water when you feel low',
    'All-or-nothing thinking',
    'Picking fights from fatigue',
  ],
  'steady': [
    'Breaking routines that are already helping',
    'Unnecessary overcomplication',
    'Eating too late',
    'Letting small tasks pile up',
    'Passive procrastination',
    'Low-quality recovery habits',
  ],
  'spark': [
    'Burning all your energy too early',
    'Too much caffeine on top of momentum',
    'Starting everything at once',
    'Impulse spending or sending messages too quickly',
    'Skipping recovery because you feel good',
    'Turning urgency into pressure',
  ],
  'cool': [
    'Overstimulation',
    'Conflict when you are already hot',
    'Spicy rich food if your body feels tense',
    'Another late coffee',
    'Noise without breaks',
    'Forcing intensity when you need calm',
  ],
};

const Map<String, List<String>> _traitFoodLibrary = {
  'Analytical': [
    'Simple meals with less decision fatigue',
    'Predictable balanced snacks',
  ],
  'Sensitive': [
    'Gentler foods that feel easy on your system',
    'Calming warm drinks',
  ],
  'Calm': [
    'Steady low-drama meals you can repeat',
    'Hydrating routines that keep your pace even',
  ],
  'Curious': [
    'One interesting but still balanced food choice',
    'A colorful meal that keeps you engaged',
  ],
  'Driven': [
    'Protein support before a long work block',
    'Portable fuel so intensity does not outrun your body',
  ],
  'Warm': [
    'Shared meals or nourishing comfort food',
    'Something supportive you would gladly offer someone else',
  ],
  'Independent': [
    'Easy self-directed meals you can assemble quickly',
    'Meal prep that makes it easier not to eat on impulse',
  ],
  'Social': [
    'Balanced snacks before social plans',
    'Hydration support if the day gets busy and outward',
  ],
  'Cautious': [
    'Safe familiar foods that still feel nourishing',
    'A routine meal you know sits well',
  ],
  'Creative': [
    'Meals that feel fresh without becoming chaotic',
    'Colorful produce or herb-forward dishes',
  ],
};

const Map<String, List<String>> _traitSupportLibrary = {
  'Analytical': [
    'Do one clean thing at a time instead of optimizing everything.',
  ],
  'Sensitive': ['Protect your nervous system from too much noise and stimulation today.'],
  'Calm': ['Keep the pace you trust instead of matching other people.'],
  'Curious': ['Let novelty be small and intentional rather than scattered.'],
  'Driven': ['Use structure to protect yourself from overextending.'],
  'Warm': ['Support others without losing your own center.'],
  'Independent': [
    'Choose routines that still work even when no one is watching.',
  ],
  'Social': ['Leave space to reset after outward energy.'],
  'Cautious': [
    'Favor low-friction progress over waiting for perfect certainty.',
  ],
  'Creative': ['Capture ideas, but ground them in one finished action.'],
};

const Map<String, List<String>> _stressSupportLibrary = {
  'Feeling rushed': [
    'Reduce rushed energy by eating before you are desperate and leaving more transition time.',
  ],
  'Conflict with others': [
    'Choose calming inputs and avoid feeding tension with stimulants.',
  ],
  'Uncertainty': [
    'Repeat a few basics instead of chasing more answers than you need.',
  ],
  'Fear of failure': [
    'Support your body first so pressure does not decide the tone of the day.',
  ],
  'Emotional overwhelm': [
    'Keep your meals and routines simpler than usual to calm things down internally.',
  ],
  'Too much pressure': [
    'Choose steadier meals and hydration so stress does not turn into a physical crash.',
  ],
  'Putting things off': [
    'Start with a low-friction task and a stabilizing meal rather than waiting to feel ready.',
  ],
  'Overthinking': [
    'Choose grounding habits over getting stuck in your head today.',
  ],
};

const Map<String, List<String>> _stressAvoidLibrary = {
  'Feeling rushed': ['Racing meals', 'Stacking too many errands back-to-back'],
  'Conflict with others': [
    'Reactive texting',
    'Escalating when you are already depleted',
  ],
  'Uncertainty': [
    'Constant checking for reassurance',
    'Changing plans every hour',
  ],
  'Fear of failure': ['Perfection paralysis', 'Overcorrecting small mistakes'],
  'Emotional overwhelm': [
    'Too much stimulation at once',
    'Skipping breaks because you feel behind',
  ],
  'Too much pressure': [
    'Treating every task like an emergency',
    'Using stress as motivation',
  ],
  'Putting things off': [
    'Endless preparation that keeps you from actually starting',
    'Waiting for the perfect mood',
  ],
  'Overthinking': [
    'Replaying the same decision repeatedly',
    'More input when clarity is already full',
  ],
};

const Map<int, List<String>> _weekdayFoodLibrary = {
  DateTime.monday: [
    'A focused breakfast before the week pulls harder',
    'A lunch that keeps your afternoon clear instead of sleepy',
    'Simple prep-friendly meals that reduce weekday friction',
  ],
  DateTime.tuesday: [
    'Reliable protein and fiber before momentum starts to dip',
    'Portable meals that keep effort sustainable',
    'A midweek lunch you can repeat without overthinking',
  ],
  DateTime.wednesday: [
    'A grounding meal that resets the middle of the week',
    'Comforting food that still leaves you mentally light',
    'A steadier snack before the afternoon slump hits',
  ],
  DateTime.thursday: [
    'Food that protects energy before the week gets noisy',
    'A cleaner dinner that does not steal tomorrow\'s energy',
    'Something replenishing instead of convenience-heavy',
  ],
  DateTime.friday: [
    'Balanced fuel before social or end-of-week plans',
    'Hydration support if your schedule stretches later',
    'A meal that keeps energy even before the evening starts',
  ],
  DateTime.saturday: [
    'A slower nourishing breakfast instead of skipping straight into plans',
    'Fresh simple food that supports movement and recovery',
    'Something restorative before you overfill the day',
  ],
  DateTime.sunday: [
    'A calming meal that helps you reset the week ahead',
    'A little extra water and simple food before Monday arrives',
    'A Sunday meal that feels settling rather than excessive',
  ],
};

const Map<int, List<String>> _weekdaySupportLibrary = {
  DateTime.monday: [
    'Set the tone early so the week does not decide it for you.',
    'Keep the first half of the day cleaner than usual.',
  ],
  DateTime.tuesday: [
    'Stay steady rather than adding pressure just because the week is moving.',
    'Protect consistency before ambition starts to sprawl.',
  ],
  DateTime.wednesday: [
    'Midweek works better with pacing than with force.',
    'Reset your body before trying to reset your productivity.',
  ],
  DateTime.thursday: [
    'Guard your energy so borrowed urgency does not become yours.',
    'Be more selective with what still deserves effort this week.',
  ],
  DateTime.friday: [
    'Finish cleanly instead of running hot into the evening.',
    'Leave enough energy for the part of the day that happens after work.',
  ],
  DateTime.saturday: [
    'Make room for recovery even if the day feels open and social.',
    'Choose a little spaciousness before filling the day with plans.',
  ],
  DateTime.sunday: [
    'Use the quieter rhythm to regulate rather than drift.',
    'Simplify the day so next week starts from a steadier place.',
  ],
};

const Map<int, List<String>> _weekdayAvoidLibrary = {
  DateTime.monday: [
    'Starting the week in reaction mode',
    'Letting inbox energy run your morning',
  ],
  DateTime.tuesday: [
    'Pretending you have endless capacity',
    'Letting momentum turn into overcommitment',
  ],
  DateTime.wednesday: [
    'Midweek autopilot that ignores what your body needs',
    'Using snacks and caffeine to patch over drag',
  ],
  DateTime.thursday: [
    'Spending tomorrow\'s energy today',
    'Adding extra tasks just to feel caught up',
  ],
  DateTime.friday: [
    'Crashing into the evening underfueled',
    'Treating celebration like recovery',
  ],
  DateTime.saturday: [
    'Overpacking a day that should have breathing room',
    'Skipping routines because the schedule feels loose',
  ],
  DateTime.sunday: [
    'All-day drifting that creates Sunday-night stress',
    'Ignoring reset habits because the day feels unstructured',
  ],
};

const Map<String, List<String>> _seasonFoodLibrary = {
  'spring': [
    'Lighter meals with greens and herbs',
    'Fresh produce that still feels balanced',
    'Meals that support movement without heaviness',
  ],
  'summer': [
    'Hydrating food with minerals and water content',
    'Cooling simple meals that do not add heat',
    'Extra fluids and lighter portions if the day runs hot',
  ],
  'autumn': [
    'Simple warming meals with steady structure',
    'Moisture-supportive foods if everything feels dry',
    'Gentle soups and cooked foods that settle the body',
  ],
  'winter': [
    'Warmer deeper meals with enough protein',
    'Comforting foods that support restoration',
    'Cooked meals that reduce cold and depletion',
  ],
};

const Map<String, List<String>> _seasonSupportLibrary = {
  'spring': [
    'Let growth stay organized rather than scattered.',
    'A little movement and a little order will help more than intensity.',
  ],
  'summer': [
    'Cool the system before it gets loud or depleted.',
    'Hydration matters more when the day and season both run outward.',
  ],
  'autumn': [
    'Protect your rhythm and keep choices cleaner than usual.',
    'Use the season\'s structure to make your habits simpler.',
  ],
  'winter': [
    'Recovery deserves more respect in a lower-energy season.',
    'Choose warmth, rest, and enough nourishment before output.',
  ],
};

const Map<String, List<String>> _seasonAvoidLibrary = {
  'spring': [
    'Too many new starts with no follow-through',
    'Scattered energy disguised as inspiration',
  ],
  'summer': [
    'Overheating your schedule',
    'Too much stimulation on top of social energy',
  ],
  'autumn': [
    'Becoming rigid when a little softness would work better',
    'Dry repetitive routines with no reset built in',
  ],
  'winter': [
    'Running on empty just because the day demands it',
    'Treating rest like a reward instead of a requirement',
  ],
};

const Map<String, List<String>> _traitAvoidLibrary = {
  'Analytical': [
    'Turning self-care into another optimization project',
    'Thinking past the point of useful action',
  ],
  'Sensitive': [
    'Letting overstimulation pile up quietly',
    'Forcing yourself to put up with more noise than you need to',
  ],
  'Calm': [
    'Absorbing other people\'s urgency by default',
    'Staying agreeable when your body wants limits',
  ],
  'Curious': [
    'Too much novelty when a little steadiness would help more',
    'Switching tracks before one thing settles',
  ],
  'Driven': [
    'Making productivity the measure of the whole day',
    'Skipping recovery because momentum feels good',
  ],
  'Warm': [
    'Giving emotional labor past the point of capacity',
    'Supporting everyone else before feeding yourself',
  ],
  'Independent': [
    'Doing everything alone when support would reduce strain',
    'Ignoring friction until it becomes exhaustion',
  ],
  'Social': [
    'Too much outward energy without decompression',
    'Letting plans crowd out your baseline habits',
  ],
  'Cautious': [
    'Waiting for certainty instead of making the next simple move',
    'Shrinking choices until the day feels smaller than it is',
  ],
  'Creative': [
    'Letting inspiration replace follow-through',
    'More stimulation when your mind is already full',
  ],
};

const recommendationData = {
  OhaengElement.wood: {
    'boost': {
      'explanation':
          'Today supports your Wood energy. This is a strong time for growth, planning, and trying something new.',
      'k': ['Mugwort tea', 'Seasoned greens', 'Perilla leaves', 'Bibimbap'],
      'global': ['Green tea', 'Fresh vegetables', 'Light salad', 'Kiwi'],
      'supplement': ['B-complex', 'Vitamin C'],
      'avoid': ['Overcommitting', 'Late-night screen time'],
    },
    'support': {
      'explanation':
          'You may feel busy helping the day move forward. Protect your focus so your energy does not scatter.',
      'k': ['Ginger tea', 'Rice porridge', 'Japchae', 'Cucumber sides'],
      'global': ['Warm lemon water', 'Whole grains', 'Avocado toast', 'Pear'],
      'supplement': ['Magnesium', 'Multivitamin'],
      'avoid': ['Overworking', 'Too much caffeine'],
    },
    'control': {
      'explanation':
          'You are trying to direct today\'s flow, which can feel demanding. Move steadily and simplify decisions.',
      'k': ['Pear tea', 'Lotus root dishes', 'Kongnamul soup', 'Tteok'],
      'global': ['Chamomile tea', 'Simple soups', 'Roasted carrots', 'Oatmeal'],
      'supplement': ['Magnesium', 'Vitamin B6'],
      'avoid': ['Rigid schedules', 'Emotional overload'],
    },
    'suppressed': {
      'explanation':
          'Your Wood energy may feel blocked today. Choose gentle movement and recovery over pressure.',
      'k': ['Warm jujube tea', 'Soft tofu soup', 'Pumpkin juk', 'Steamed egg'],
      'global': ['Ginger tea', 'Warm oatmeal', 'Mashed sweet potato', 'Broth'],
      'supplement': ['Vitamin D', 'Magnesium'],
      'avoid': ['Cold drinks', 'Heavy arguments'],
    },
  },
  OhaengElement.fire: {
    'boost': {
      'explanation':
          'Today gives extra warmth to your Fire energy. Expression, confidence, and motivation can come naturally.',
      'k': [
        'Yuja tea',
        'Red bean porridge',
        'Pomegranate salad',
        'Bibim naengmyeon',
      ],
      'global': ['Citrus tea', 'Berry snacks', 'Orange slices', 'Greek yogurt'],
      'supplement': ['CoQ10', 'B-complex'],
      'avoid': ['Impulsive choices', 'Sleep debt'],
    },
    'support': {
      'explanation':
          'You may spend energy uplifting the day around you. Stay bright, but do not burn yourself out.',
      'k': [
        'Ginseng tea',
        'Steamed sweet potato',
        'Chicken porridge',
        'Tomato kimchi salad',
      ],
      'global': [
        'Warm water',
        'Balanced meals',
        'Eggs',
        'Banana with peanut butter',
      ],
      'supplement': ['Vitamin C', 'Electrolytes'],
      'avoid': ['Too much sugar', 'Skipping rest'],
    },
    'control': {
      'explanation':
          'Fire is pushing against the day\'s energy. This can feel intense, so pace yourself and cool your mind.',
      'k': ['Omija tea', 'Cucumber sides', 'Cold tofu', 'Radish water kimchi'],
      'global': ['Mint tea', 'Fresh fruit', 'Watermelon', 'Celery sticks'],
      'supplement': ['Magnesium', 'Omega-3'],
      'avoid': ['Hot tempers', 'Excess caffeine'],
    },
    'suppressed': {
      'explanation':
          'Your Fire energy may feel dimmed today. Choose warmth, encouragement, and small wins.',
      'k': ['Ginger tea', 'Seaweed soup', 'Abalone porridge', 'Hotteok'],
      'global': [
        'Warm soup',
        'Roasted nuts',
        'Dark chocolate',
        'Toast with honey',
      ],
      'supplement': ['Iron', 'Vitamin B12'],
      'avoid': ['Isolation', 'Overstimulation'],
    },
  },
  OhaengElement.earth: {
    'boost': {
      'explanation':
          'Today strengthens your Earth energy. Stability, nourishment, and dependable habits will feel natural.',
      'k': [
        'Roasted barley tea',
        'Pumpkin porridge',
        'Doenjang stew',
        'Brown rice',
      ],
      'global': [
        'Root vegetables',
        'Warm grain bowls',
        'Lentils',
        'Baked squash',
      ],
      'supplement': ['Probiotics', 'Vitamin D'],
      'avoid': ['Overeating', 'Staying inactive too long'],
    },
    'support': {
      'explanation':
          'You may be carrying and grounding the day for others. Offer support without ignoring your own needs.',
      'k': ['Doenjang soup', 'Brown rice', 'Vegetable jeon', 'Chestnut rice'],
      'global': ['Bone broth', 'Bananas', 'Granola', 'Roasted chickpeas'],
      'supplement': ['Magnesium', 'Digestive enzymes'],
      'avoid': ['Taking on everyone\'s stress', 'Heavy late meals'],
    },
    'control': {
      'explanation':
          'Earth is trying to stabilize a day that resists structure. Keep things simple and practical.',
      'k': ['Jujube tea', 'Steamed squash', 'Soft tofu', 'Mild juk'],
      'global': ['Herbal tea', 'Simple proteins', 'Rice cakes', 'Boiled eggs'],
      'supplement': ['Zinc', 'Magnesium'],
      'avoid': ['Perfectionism', 'Decision fatigue'],
    },
    'suppressed': {
      'explanation':
          'Your Earth energy may feel unsettled today. Focus on grounding routines and gentle nourishment.',
      'k': ['Jujube tea', 'Rice soup', 'Potato stew', 'Steamed pumpkin'],
      'global': ['Warm milk', 'Plain toast', 'Applesauce', 'Rice crackers'],
      'supplement': ['Probiotics', 'Vitamin B6'],
      'avoid': ['Cold foods', 'Overthinking'],
    },
  },
  OhaengElement.metal: {
    'boost': {
      'explanation':
          'Today sharpens your Metal energy. Clarity, boundaries, and clean decision-making are supported.',
      'k': [
        'Bellflower root tea',
        'Radish soup',
        'White kimchi',
        'Buckwheat noodles',
      ],
      'global': [
        'Peppermint tea',
        'Light salads',
        'Apple slices',
        'Cauliflower',
      ],
      'supplement': ['Zinc', 'Vitamin C'],
      'avoid': ['Harsh self-criticism', 'Dry environments'],
    },
    'support': {
      'explanation':
          'You may spend energy refining the day and bringing order. Stay organized without becoming rigid.',
      'k': ['Pear tea', 'White kimchi', 'Bean sprout bap', 'Mild mandu soup'],
      'global': [
        'Warm water',
        'Steamed vegetables',
        'Rice noodles',
        'Tofu salad',
      ],
      'supplement': ['Omega-3', 'Multivitamin'],
      'avoid': ['Overcontrolling', 'Skipping breaks'],
    },
    'control': {
      'explanation':
          'Metal is trying to cut through the day\'s energy, which can feel tense. Choose precision without pressure.',
      'k': [
        'Honey ginger tea',
        'Mild soups',
        'Egg drop soup',
        'Braised radish',
      ],
      'global': [
        'Chamomile tea',
        'Soft fruits',
        'Soup dumplings',
        'Poached pear',
      ],
      'supplement': ['Magnesium', 'Vitamin D'],
      'avoid': ['Conflict', 'Too much multitasking'],
    },
    'suppressed': {
      'explanation':
          'Your Metal energy may feel restricted today. Give yourself more room, rest, and clean breathing space.',
      'k': ['Warm pear juice', 'Seaweed rice', 'Miyuk soup', 'Soft congee'],
      'global': [
        'Warm herbal tea',
        'Simple hydration',
        'Broth',
        'Cucumber water',
      ],
      'supplement': ['Vitamin C', 'Magnesium'],
      'avoid': ['Dry foods', 'Holding everything in'],
    },
  },
  OhaengElement.water: {
    'boost': {
      'explanation':
          'Today nourishes your Water energy. Reflection, wisdom, and quiet resilience are easier to access.',
      'k': [
        'Seaweed soup',
        'Black sesame tea',
        'Black bean rice',
        'Grilled mackerel',
      ],
      'global': ['Green tea', 'Warm lemon water', 'Blueberries', 'Miso soup'],
      'supplement': ['Omega-3', 'Magnesium'],
      'avoid': ['Oversleeping', 'Withdrawing too much'],
    },
    'support': {
      'explanation':
          'You may feel drained while supporting growth around you. Keep your pace gentle and protect recovery time.',
      'k': ['Ginseng tea', 'Miyeok-guk', 'Samgyetang', 'Black sesame porridge'],
      'global': ['Herbal tea', 'Warm soup', 'Salmon', 'Edamame'],
      'supplement': ['B-complex', 'Multivitamin'],
      'avoid': ['Overworking', 'Too much caffeine'],
    },
    'control': {
      'explanation':
          'Water is working hard to manage today\'s heat. Slow down and conserve your emotional energy.',
      'k': ['Barley tea', 'Tofu stew', 'Cold soba', 'Cabbage wraps'],
      'global': ['Chamomile tea', 'Coconut water', 'Melon', 'Yogurt'],
      'supplement': ['Magnesium', 'Electrolytes'],
      'avoid': ['Conflict', 'Mental overload'],
    },
    'suppressed': {
      'explanation':
          'Your Water energy may feel pressed down today. Restore yourself with warmth, stillness, and consistent care.',
      'k': [
        'Warm jujube tea',
        'Soft rice porridge',
        'Bone broth',
        'Steamed dumplings',
      ],
      'global': [
        'Chamomile tea',
        'Warm oatmeal',
        'Baked pear',
        'Soft scrambled eggs',
      ],
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

int _dateSeed(DateTime date) {
  return date.year * 10000 + date.month * 100 + date.day;
}

String _dayStateFor({
  required OhaengElement user,
  required OhaengElement today,
  required String interaction,
  required DateTime date,
}) {
  final states = switch (interaction) {
    'boost' => ['spark', 'focus', 'steady', 'cool'],
    'support' => ['steady', 'focus', 'restore', 'lift'],
    'control' => ['focus', 'cool', 'steady', 'restore'],
    'suppressed' => ['restore', 'lift', 'cool', 'steady'],
    _ => ['steady', 'focus', 'lift', 'restore'],
  };

  final seed = _dateSeed(date) + user.index * 19 + today.index * 31;
  return states[seed % states.length];
}

String _seasonFor(DateTime date) {
  final month = date.month;
  if (month >= 3 && month <= 5) {
    return 'spring';
  }
  if (month >= 6 && month <= 8) {
    return 'summer';
  }
  if (month >= 9 && month <= 11) {
    return 'autumn';
  }
  return 'winter';
}

List<String> _pickItems(
  List<String> source, {
  required int count,
  required int seed,
}) {
  final pool = source.toSet().toList(growable: false);
  if (pool.length <= count) {
    return pool;
  }

  final result = <String>[];
  var offset = seed;
  while (result.length < count && result.length < pool.length) {
    final item = pool[offset % pool.length];
    if (!result.contains(item)) {
      result.add(item);
    }
    offset += 3;
  }
  return result;
}

String _normalizeSuggestion(String value) {
  const replacements = {
    'Chicken porridge': 'A warm protein-rich porridge',
    'Eggs': 'A simple protein-rich option',
    'Boiled eggs': 'A simple protein-rich option',
    'Soft scrambled eggs': 'A gentle protein-rich option',
    'Grilled mackerel': 'An omega-3 supportive protein option',
    'Salmon': 'An omega-3 supportive protein option',
    'Samgyetang': 'A restorative warm protein meal',
    'Bone broth': 'A restorative mineral-rich broth',
    'Soup dumplings': 'A soft comforting meal with some protein',
    'Steamed dumplings': 'A soft comforting meal with some protein',
    'Egg drop soup': 'A light savory soup with protein support',
    'Greek yogurt': 'A cooling protein-supportive snack',
    'Yogurt': 'A protein-supportive cooling snack',
    'Yogurt or kefir if it suits you':
        'A cooling protein-supportive option if it suits you',
    'Abalone porridge': 'A restorative savory porridge',
  };

  return replacements[value] ?? value;
}

Map<String, dynamic> getRecommendation(
  OhaengElement user,
  OhaengElement today, {
  List<String> personalityTraits = const <String>[],
  List<String> stressTriggers = const <String>[],
}) {
  final interaction = getInteraction(user, today);
  final base = recommendationData[user]?[interaction] as Map<String, dynamic>?;
  final now = DateTime.now();
  final state = _dayStateFor(
    user: user,
    today: today,
    interaction: interaction,
    date: now,
  );
  final season = _seasonFor(now);
  final baseMap = {
    ...defaultRecommendation,
    ...?base,
    'interaction': interaction,
  };
  final foodPool = <String>[
    ...(baseMap['k'] as List<dynamic>).whereType<String>(),
    ...(defaultRecommendation['k'] as List<dynamic>).whereType<String>(),
    ...?_elementFoodLibrary[user],
    ...?_stateFoodLibrary[state],
    ...?_weekdayFoodLibrary[now.weekday],
    ...?_seasonFoodLibrary[season],
    ...personalityTraits.expand(
      (trait) => _traitFoodLibrary[trait] ?? const [],
    ),
  ];
  final supportPool = <String>[
    ...(baseMap['global'] as List<dynamic>).whereType<String>(),
    ...?_supportFocusLibrary[state],
    ...?_weekdaySupportLibrary[now.weekday],
    ...?_seasonSupportLibrary[season],
    ...personalityTraits.expand(
      (trait) => _traitSupportLibrary[trait] ?? const [],
    ),
    ...stressTriggers.expand(
      (trigger) => _stressSupportLibrary[trigger] ?? const [],
    ),
  ];
  final supplementPool = <String>[
    ...(baseMap['supplement'] as List<dynamic>).whereType<String>(),
  ];
  final avoidPool = <String>[
    ...(baseMap['avoid'] as List<dynamic>).whereType<String>(),
    ...(defaultRecommendation['avoid'] as List<dynamic>).whereType<String>(),
    ...?_stateAvoidLibrary[state],
    ...?_weekdayAvoidLibrary[now.weekday],
    ...?_seasonAvoidLibrary[season],
    ...personalityTraits.expand(
      (trait) => _traitAvoidLibrary[trait] ?? const [],
    ),
    ...stressTriggers.expand(
      (trigger) => _stressAvoidLibrary[trigger] ?? const [],
    ),
  ];
  final seed = _dateSeed(now) + user.index * 101 + today.index * 17;
  final supplementHint = _pickItems(
    supplementPool,
    count: supplementPool.length > 1 ? 2 : 1,
    seed: seed + 11,
  );
  final supportItems = _pickItems(supportPool, count: 2, seed: seed + 23);
  final supportWithSupplement = <String>[
    ...supportItems,
    if (supplementHint.isNotEmpty)
      'Supplement note: ${supplementHint.join(' or ')} can fit this kind of day.',
  ];

  return {
    ...baseMap,
    'interaction': interaction,
    'dayState': state,
    'reasonLine': <String>[
      (_stateLeadLines[state] ?? defaultRecommendation['reasonLine']) as String,
      if (personalityTraits.isNotEmpty)
        'Your ${personalityTraits[seed % personalityTraits.length].toLowerCase()} side also benefits from a cleaner rhythm today.',
      if (stressTriggers.isNotEmpty)
        'It also leans around ${stressTriggers[seed % stressTriggers.length].toLowerCase()} today.',
    ].join(' '),
    'k': _pickItems(
      foodPool,
      count: 5,
      seed: seed + 5,
    ).map(_normalizeSuggestion).toList(growable: false),
    'global': supportWithSupplement
        .map(_normalizeSuggestion)
        .toList(growable: false),
    'supplement': supplementHint,
    'avoid': _pickItems(
      avoidPool,
      count: 4,
      seed: seed + 37,
    ).map(_normalizeSuggestion).toList(growable: false),
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
