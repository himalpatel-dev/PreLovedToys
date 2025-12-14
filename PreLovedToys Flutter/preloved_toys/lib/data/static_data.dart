class StaticData {
  // Categories
  static final List<Map<String, dynamic>> categories = [
    {
      'id': 1,
      'name': 'Vehicles',
      'image': 'assets/categoryimages/vehicles.png',
    },
    {
      'id': 2,
      'name': 'Soft Toys',
      'image': 'assets/categoryimages/softtoys.png',
    },
    {'id': 3, 'name': 'Gun', 'image': 'assets/categoryimages/gun.png'},
    {'id': 4, 'name': 'Puzzles', 'image': 'assets/categoryimages/puzzles.png'},
    {
      'id': 5,
      'name': 'Block Games',
      'image': 'assets/categoryimages/blockgames.png',
    },
    {
      'id': 6,
      'name': 'Art & Craft',
      'image': 'assets/categoryimages/artcraft.png',
    },
    {
      'id': 7,
      'name': 'Board Games',
      'image': 'assets/categoryimages/boardgames.png',
    },
    {
      'id': 8,
      'name': 'Educational Toys',
      'image': 'assets/categoryimages/educationaltoys.png',
    },
    {'id': 9, 'name': 'Sports', 'image': 'assets/categoryimages/sports.png'},
    {
      'id': 10,
      'name': 'Activity Games',
      'image': 'assets/categoryimages/activitygames.png',
    },
    {
      'id': 11,
      'name': 'Musical Toys',
      'image': 'assets/categoryimages/musicaltoys.png',
    },
    {'id': 12, 'name': 'Others', 'image': 'assets/categoryimages/others.png'},
    {
      'id': 13,
      'name': 'Push & Pull Toys',
      'image': 'assets/categoryimages/pushpulltoys.png',
    },
    {'id': 14, 'name': 'Riders', 'image': 'assets/categoryimages/rider.png'},
    {
      'id': 15,
      'name': 'Electronic Toys',
      'image': 'assets/categoryimages/electronic.png',
    },
  ];

  // Subcategories
  // Format: { 'id': X, 'name': 'Name', 'categoryId': Y, 'image': 'assets/...' }
  static final List<Map<String, dynamic>> subCategories = [
    // Vehicles (ID: 1)
    {'id': 101, 'name': 'Remote Control Cars', 'categoryId': 1, 'image': ''},
    {'id': 102, 'name': 'Die-Cast Models', 'categoryId': 1, 'image': ''},
    {'id': 103, 'name': 'Trains & Tracks', 'categoryId': 1, 'image': ''},
    {'id': 104, 'name': 'Drones', 'categoryId': 1, 'image': ''},
    {'id': 105, 'name': 'Trucks', 'categoryId': 1, 'image': ''},

    // Soft Toys (ID: 2)
    {'id': 201, 'name': 'Teddy Bears', 'categoryId': 2, 'image': ''},
    {'id': 202, 'name': 'Animals', 'categoryId': 2, 'image': ''},
    {'id': 203, 'name': 'Cartoon Characters', 'categoryId': 2, 'image': ''},
    {'id': 204, 'name': 'Interactive Plush', 'categoryId': 2, 'image': ''},
    {'id': 205, 'name': 'Dolls', 'categoryId': 2, 'image': ''},

    // Gun (ID: 3)
    {'id': 301, 'name': 'Bullet', 'categoryId': 3, 'image': ''},
    {'id': 302, 'name': 'Air Pressure', 'categoryId': 3, 'image': ''},
    {'id': 303, 'name': 'Musical', 'categoryId': 3, 'image': ''},

    // Puzzles (ID: 4)
    {'id': 401, 'name': 'Fruit & Vegetable', 'categoryId': 4, 'image': ''},
    {'id': 402, 'name': 'Transport', 'categoryId': 4, 'image': ''},
    {'id': 403, 'name': 'Animal & Bird', 'categoryId': 4, 'image': ''},
    {'id': 404, 'name': 'Educational', 'categoryId': 4, 'image': ''},
    {'id': 405, 'name': 'Magnetic', 'categoryId': 4, 'image': ''},
    {'id': 406, 'name': 'Story', 'categoryId': 4, 'image': ''},
    {'id': 407, 'name': 'Fun Puzzle Games', 'categoryId': 4, 'image': ''},

    // Block Games (ID: 5)
    {'id': 501, 'name': 'Activity Blocks', 'categoryId': 5, 'image': ''},
    {'id': 502, 'name': 'Building Blocks', 'categoryId': 5, 'image': ''},
    {'id': 503, 'name': 'Magnetic Blocks', 'categoryId': 5, 'image': ''},
    {'id': 504, 'name': 'Stick Blocks', 'categoryId': 5, 'image': ''},
    {'id': 505, 'name': 'Bullet Blocks', 'categoryId': 5, 'image': ''},

    // Art & Craft (ID: 6)
    {'id': 601, 'name': 'Jewellery Making Games', 'categoryId': 6, 'image': ''},
    {'id': 602, 'name': 'Clay Toys', 'categoryId': 6, 'image': ''},
    {
      'id': 603,
      'name': 'Scratching/ Colouring Games',
      'categoryId': 6,
      'image': '',
    },
    {'id': 604, 'name': 'Quilling Games', 'categoryId': 6, 'image': ''},
    {'id': 605, 'name': 'Others', 'categoryId': 6, 'image': ''},

    // Board Games (ID: 7)
    {'id': 701, 'name': 'Educational Board', 'categoryId': 7, 'image': ''},
    {'id': 702, 'name': 'Chess', 'categoryId': 7, 'image': ''},
    {'id': 703, 'name': 'Ludo & Snakes', 'categoryId': 7, 'image': ''},
    {'id': 704, 'name': 'Wooden Board Games', 'categoryId': 7, 'image': ''},
    {'id': 705, 'name': 'Carrom', 'categoryId': 7, 'image': ''},
    {'id': 706, 'name': 'Business', 'categoryId': 7, 'image': ''},
    {'id': 707, 'name': 'Monopoly', 'categoryId': 7, 'image': ''},
    {'id': 708, 'name': 'Sequence', 'categoryId': 7, 'image': ''},
    {'id': 709, 'name': 'Word Games', 'categoryId': 7, 'image': ''},
    {'id': 710, 'name': 'D-Dart', 'categoryId': 7, 'image': ''},
    {'id': 711, 'name': 'Housie', 'categoryId': 7, 'image': ''},
    {'id': 712, 'name': 'Chinese Checker', 'categoryId': 7, 'image': ''},
    {'id': 713, 'name': 'Tic Tac Toe', 'categoryId': 7, 'image': ''},
    {'id': 714, 'name': 'Adventure Games', 'categoryId': 7, 'image': ''},
    {'id': 715, 'name': 'Combos', 'categoryId': 7, 'image': ''},

    // Educational Toys (ID: 8)
    {'id': 801, 'name': 'Mechanical Games', 'categoryId': 8, 'image': ''},
    {
      'id': 802,
      'name': 'Magnetic Shapes & Colours',
      'categoryId': 8,
      'image': '',
    },
    {'id': 803, 'name': 'Globes', 'categoryId': 8, 'image': ''},
    {'id': 804, 'name': 'Brainvita', 'categoryId': 8, 'image': ''},
    {'id': 805, 'name': 'Flash Cards', 'categoryId': 8, 'image': ''},
    {'id': 806, 'name': 'Abacus', 'categoryId': 8, 'image': ''},
    {'id': 807, 'name': 'Educational Shapes', 'categoryId': 8, 'image': ''},
    {'id': 808, 'name': 'Preschool Toys', 'categoryId': 8, 'image': ''},
    {'id': 809, 'name': 'Memory Games', 'categoryId': 8, 'image': ''},
    {
      'id': 810,
      'name': 'Educational Numbers & Alphabets',
      'categoryId': 8,
      'image': '',
    },
    {'id': 811, 'name': '3D Books', 'categoryId': 8, 'image': ''},
    {'id': 812, 'name': 'Science Games', 'categoryId': 8, 'image': ''},

    // Sports (ID: 9)
    {'id': 901, 'name': 'Basket Ball', 'categoryId': 9, 'image': ''},
    {'id': 902, 'name': 'Cricket Sets', 'categoryId': 9, 'image': ''},
    {'id': 903, 'name': 'Bowling Games', 'categoryId': 9, 'image': ''},
    {'id': 904, 'name': 'Bow & Arrow', 'categoryId': 9, 'image': ''},
    {'id': 905, 'name': 'Golf Set', 'categoryId': 9, 'image': ''},
    {'id': 906, 'name': 'Table Tennis', 'categoryId': 9, 'image': ''},
    {'id': 907, 'name': 'Hockey', 'categoryId': 9, 'image': ''},
    {'id': 908, 'name': 'Challenge Sports', 'categoryId': 9, 'image': ''},

    // Activity Games (ID: 10)
    {'id': 1001, 'name': 'Flying Disk', 'categoryId': 10, 'image': ''},
    {'id': 1002, 'name': 'Bladders', 'categoryId': 10, 'image': ''},
    {'id': 1003, 'name': 'Play Tent House', 'categoryId': 10, 'image': ''},
    {'id': 1004, 'name': 'Ringtoss', 'categoryId': 10, 'image': ''},
    {'id': 1005, 'name': 'Hoopla Ring', 'categoryId': 10, 'image': ''},
    {'id': 1006, 'name': 'Play Gym', 'categoryId': 10, 'image': ''},
    {'id': 1007, 'name': 'Spiral Fun', 'categoryId': 10, 'image': ''},
    {'id': 1008, 'name': 'Hopscotch', 'categoryId': 10, 'image': ''},
    {'id': 1009, 'name': 'Ball Pool', 'categoryId': 10, 'image': ''},
    {'id': 1010, 'name': 'Spinner', 'categoryId': 10, 'image': ''},
    {'id': 1011, 'name': 'Rolling Fun', 'categoryId': 10, 'image': ''},
    {'id': 1012, 'name': 'Teddy Ring', 'categoryId': 10, 'image': ''},
    {'id': 1013, 'name': 'Magic Game', 'categoryId': 10, 'image': ''},
    {'id': 1014, 'name': 'Cycle', 'categoryId': 10, 'image': ''},
    {'id': 1015, 'name': 'Other Activity Game', 'categoryId': 10, 'image': ''},
    {'id': 1016, 'name': 'Target & Aim Games', 'categoryId': 10, 'image': ''},
    {'id': 1017, 'name': 'Rings Toys', 'categoryId': 10, 'image': ''},

    // // Musical Toys (ID: 11)
    // {'id': 1101, 'name': 'Rattles', 'categoryId': 11, 'image': ''},
    // {'id': 1102, 'name': 'Roly Poly', 'categoryId': 11, 'image': ''},
    // {'id': 1103, 'name': 'Musical Drum', 'categoryId': 11, 'image': ''},
    // {'id': 1104, 'name': 'Xylophone', 'categoryId': 11, 'image': ''},
    // {'id': 1105, 'name': 'Jhoomer', 'categoryId': 11, 'image': ''},
    // {'id': 1106, 'name': 'Musical Animals', 'categoryId': 11, 'image': ''},
    // {'id': 1107, 'name': 'Musical Vehicles', 'categoryId': 11, 'image': ''},
    // {
    //   'id': 1108,
    //   'name': 'Musical Instrument Toys',
    //   'categoryId': 11,
    //   'image': '',
    // },
    // {'id': 1109, 'name': 'Musical Teddy', 'categoryId': 11, 'image': ''},

    // // Others (ID: 12)
    // {'id': 1201, 'name': 'Kitchen Set', 'categoryId': 12, 'image': ''},
    // {'id': 1202, 'name': 'Dolls', 'categoryId': 12, 'image': ''},
    // {'id': 1203, 'name': 'Piggy Bank', 'categoryId': 12, 'image': ''},
    // {'id': 1204, 'name': 'Cup Stackers', 'categoryId': 12, 'image': ''},
    // {'id': 1205, 'name': 'Cube', 'categoryId': 12, 'image': ''},
    // {'id': 1206, 'name': 'Almirah', 'categoryId': 12, 'image': ''},
    // {'id': 1207, 'name': 'Carry Cot', 'categoryId': 12, 'image': ''},
    // {'id': 1208, 'name': 'Doctor Set', 'categoryId': 12, 'image': ''},
    // {'id': 1209, 'name': 'Pen Stand', 'categoryId': 12, 'image': ''},
    // {'id': 1210, 'name': 'Beauty Set', 'categoryId': 12, 'image': ''},
    // {'id': 1211, 'name': 'Sofa', 'categoryId': 12, 'image': ''},
    // {'id': 1212, 'name': 'Activity Toys', 'categoryId': 12, 'image': ''},
    // {'id': 1213, 'name': 'Warrior Fighter Set', 'categoryId': 12, 'image': ''},
    // {'id': 1214, 'name': 'Teether', 'categoryId': 12, 'image': ''},
    // {'id': 1215, 'name': 'Baby Suitcase', 'categoryId': 12, 'image': ''},

    // // Push & Pull Toys (ID: 13)
    // {'id': 1301, 'name': 'Cars', 'categoryId': 13, 'image': ''},
    // {'id': 1302, 'name': 'Trucks & Dumpers', 'categoryId': 13, 'image': ''},
    // {'id': 1303, 'name': 'Bike', 'categoryId': 13, 'image': ''},
    // {'id': 1304, 'name': 'Boats & Ships', 'categoryId': 13, 'image': ''},
    // {'id': 1305, 'name': 'Plane', 'categoryId': 13, 'image': ''},
    // {'id': 1306, 'name': 'Pull Along Toys', 'categoryId': 13, 'image': ''},
    // {'id': 1307, 'name': 'Push & Go Toys', 'categoryId': 13, 'image': ''},
    // {'id': 1308, 'name': 'Animals', 'categoryId': 13, 'image': ''},
    // {'id': 1309, 'name': 'Trains', 'categoryId': 13, 'image': ''},
    // {'id': 1310, 'name': 'Cranes', 'categoryId': 13, 'image': ''},
    // {'id': 1311, 'name': 'Bus', 'categoryId': 13, 'image': ''},
    // {'id': 1312, 'name': 'Friction Toys', 'categoryId': 13, 'image': ''},
    // {'id': 1313, 'name': 'Fire Brigade', 'categoryId': 13, 'image': ''},
    // {'id': 1314, 'name': 'Auto Rikshaw', 'categoryId': 13, 'image': ''},
    // {'id': 1315, 'name': 'Jeep', 'categoryId': 13, 'image': ''},
    // {'id': 1316, 'name': 'Ambulance', 'categoryId': 13, 'image': ''},
    // {'id': 1317, 'name': 'Helicopter', 'categoryId': 13, 'image': ''},
    // {'id': 1318, 'name': 'Tractor', 'categoryId': 13, 'image': ''},

    // // Riders (ID: 14)
    // {'id': 1401, 'name': 'Ride On Cars', 'categoryId': 14, 'image': ''},
    // {'id': 1402, 'name': 'Tricycle', 'categoryId': 14, 'image': ''},
    // {'id': 1403, 'name': 'Rockers', 'categoryId': 14, 'image': ''},

    // // Electronic Toys (ID: 15)
    // {'id': 1501, 'name': 'Electronic Gun', 'categoryId': 15, 'image': ''},
    // {
    //   'id': 1502,
    //   'name': 'Electronic Educational Toys',
    //   'categoryId': 15,
    //   'image': '',
    // },
    // {
    //   'id': 1503,
    //   'name': 'Electronic Musical Toys',
    //   'categoryId': 15,
    //   'image': '',
    // },
    // {
    //   'id': 1504,
    //   'name': 'Electronic Activity Toys',
    //   'categoryId': 15,
    //   'image': '',
    // },
    // {
    //   'id': 1505,
    //   'name': 'Other Electronic Toys',
    //   'categoryId': 15,
    //   'image': '',
    // },
  ];

  // Age Groups
  static final List<String> ageGroups = [
    '0-2 Years',
    '3-5 Years',
    '6-8 Years',
    '9-12 Years',
    '12+ Years',
  ];

  // Conditions
  static final List<String> conditions = ['New', 'Like New', 'Good', 'Fair'];
}
