class Dish {
  final String name;
  final num price;
  final String color;
  final bool isNotFixedPrice;

  const Dish({
    required this.name,
    required this.price,
    required this.color,
    required this.isNotFixedPrice
  });

  // factory Dish.fromJson(Map<String, dynamic> json) {
  //   final properties = json['properties'] as Map<String, dynamic>;

  //   return switch (json) {
  //     {
  //       'name': String name,
  //       'price': num price,
  //       'color': String color,
  //     } =>
  //       Dish(
  //         // name: name,
  //         name: properties['Name']?['title']?[0]?['plain_text'] ?? '?',
  //         // price: price,
  //         price: (properties['Price']?['number'] ?? 0).toDouble(),
  //         color: properties['Color']?['Select']?['name'] ?? '?',
  //         isNotFixedPrice:  properties['isNotFixedPrice']?['checkbox'],
  //       ),
  //     _ => throw const FormatException('Failed to load dish.'),
  //   };
  // }

  factory Dish.fromMap(Map<String, dynamic> map) {
    final properties = map['properties'] as Map<String, dynamic>;
    return Dish(
      name: properties['Name']?['title']?[0]?['plain_text'] ?? '?',
      price: (properties['Price']?['number'] ?? 0).toDouble(),
      // price: properties['Price']?['number'] ? (properties['Price']?['number']).toDouble() : null,
      color: properties['Color']?['select']?['name'] ?? '?',
      isNotFixedPrice:  properties['isNotFixedPrice']?['checkbox']
    );
  }
}
