import 'dart:async';
import 'dart:convert';

// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dish.dart';
import 'package:sushiro_calculator/src/settings/settings_view.dart';

import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

Future<List<Dish>> fetchDish() async {
  // const String _baseUrl = 'https://api.notion.com/v1/';
  // final url = '${_baseUrl}databases/${dotenv.env['NOTION_DATABASE_ID']}/query';

  try {
    // final response = await http.post(
    //   Uri.parse(url),
    //   headers: {
    //     HttpHeaders.authorizationHeader: 'Bearer ${dotenv.env['NOTION_API_KEY']}',
    //     'Notion-Version': '2022-02-22',
    //   },
    // );
    final response = await http.post(
      Uri.parse('https://notion-cors.ronaldchunyin.workers.dev/'),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // return Dish.fromJson(data) as Map<String, dynamic>;

      return (data['results'] as List).map((e) => Dish.fromMap(e)).toList();
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load dish');
    }
  } catch (_) {
    throw Exception('Fail');
  }
}

// Future<Map<dynamic, int>> fetchDishes() async {
//   // try {
//   final data = await fetchDish();

//   // setState(() {
//   //   _dishCounts = Map.fromIterable(
//   //     data,
//   //     key: (item) => item.name,
//   //     value: (item) => 0,
//   //   );
//   // });
//   // return Map.fromIterable(data, key: (item) => item.name, value: (item) => 0);
//   return { for (var item in data) item.name : 0 };
//   // // } catch (e) {
//   //   print('Error: $e');
//   // }
// }

class SushiroView extends StatefulWidget {
  const SushiroView({super.key});

  static const routeName = '/sushiro';

  @override
  State<SushiroView> createState() => _SushiroViewState();
}

class _SushiroViewState extends State<SushiroView> {
  late Future<List<Dish>> futureDish;
  List<Dish> _futureDish2 = [];
  // late Future<Map<dynamic, int>> _orderedDishes;
  Map<String, int> _orderedDishes2 = {};
  bool _isExpended = false;
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    // futureDish = fetchDish();
    // _orderedDishes = fetchDishes();
    _fetchDishes();
  }

  Future<void> _fetchDishes() async {
    try {
      final data = await fetchDish();
      data.sort((a, b) => a.price.compareTo(b.price));

      setState(() {
        // _orderedDishes2 = Map.fromIterable(data,
        //     key: (item) => item.name, value: (item) => 0);
        _futureDish2 = data;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void _clickDish(String name) {
    try {
      var data = _orderedDishes2;
      if (data.containsKey(name)) {
        data[name] = (data[name]! + 1);
        setState(() {
          _orderedDishes2 = data;
        });
      } else {
        data.putIfAbsent(name, () => 1);
        setState(() {
          _orderedDishes2 = data;
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _addDish(String name) {
    try {
      var data = _orderedDishes2;
      data[name] = (data[name]! + 1);

      setState(() {
        _orderedDishes2 = data;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void _removeDish(String name) {
    try {
      var data = _orderedDishes2;
      data[name] = (data[name]! - 1);
      if (data[name]! <= 0) {
        data.remove(name);
      }

      setState(() {
        _orderedDishes2 = data;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  double _getTotal() {
    double total = 0;

    for (var dish in _orderedDishes2.entries) {
      _futureDish2
              .where((d) => d.name == dish.key.split('-')[0])
              .first
              .isNotFixedPrice
          ? total += int.parse(dish.key.split('-')[1]) * dish.value
          : total +=
              (_futureDish2.where((d) => d.name == dish.key).first).price *
                  dish.value;
    }
    return total;
  }

  void _resetDishes() {
    setState(() {
      _orderedDishes2 = <String, int>{};
    });
  }

  final TextEditingController _textFieldController = TextEditingController();
  Future<void> _displayTextInputDialog(BuildContext context, Dish dish) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('加一個${dish.name}'),
          content: TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(
              prefix: Text('\$ '),
              hintText: '輸入價錢',
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                var name =
                    '${dish.name}-${_textFieldController.text.isNotEmpty ? _textFieldController.text : 0}';

                try {
                  var data = _orderedDishes2;

                  if (data.containsKey(name)) {
                    data[name] = (data[name]! + 1);
                    setState(() {
                      _orderedDishes2 = data;
                    });
                  } else {
                    data.putIfAbsent(name, () => 1);
                    setState(() {
                      _orderedDishes2 = data;
                    });
                  }
                } catch (e) {
                  print('Error: $e');
                }

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('壽司郎計算機'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      // floatingActionButton: _isExpended ? Container() : FloatingActionButton(
      //     child: const Icon(Icons.add),
      //     onPressed: () {
      //       print('press');
      //     }),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: _isExpended
          ? Container()
          : ExpandableFab(
              distance: _futureDish2.length * 10,
              openButtonBuilder: RotateFloatingActionButtonBuilder(
                child: const Icon(Icons.add),
                fabSize: ExpandableFabSize.small,
              ),
              type: ExpandableFabType.up,
              overlayStyle: ExpandableFabOverlayStyle(
                color: Colors.grey.shade800.withOpacity(0.4),
              ),
              initialOpen: _isInit,
              children: [
                for (var dish in _futureDish2)
                  FloatingActionButton.small(
                    shape: const RoundedRectangleBorder(
                      // <= Change BeveledRectangleBorder to RoundedRectangularBorder
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(30.0),
                      ),
                    ),
                    onPressed: () {
                      dish.isNotFixedPrice
                          ? _displayTextInputDialog(context, dish)
                          : _clickDish(dish.name);
                    },
                    backgroundColor: Color(int.parse(dish.color)),
                    child: ColoredBox(
                      color: const Color.fromARGB(173, 255, 255, 255),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Text(
                          dish.name.replaceAll('碟', '').trim(),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                // for (var dish in _futureDish2)
                //   Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 16),
                //     child: Column(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         ElevatedButton(
                //           onPressed: () {
                //             dish.isNotFixedPrice
                //                 ? _displayTextInputDialog(context, dish)
                //                 : _clickDish(dish.name);
                //           },
                //           style: ElevatedButton.styleFrom(
                //             shape: const CircleBorder(),
                //             padding: const EdgeInsets.all(20),
                //             backgroundColor: Color(
                //               int.parse(dish.color),
                //             ),
                //           ),
                //           child: Icon(Icons.circle_outlined,
                //               color: Colors.grey.shade100),
                //         ),
                //         Text(
                //           '${dish.name} - \$${dish.price != 0 ? dish.price.toString() : '???'}',
                //         )
                //       ],
                //     ),
                //   ),
              ],
            ),
      body: Column(
        children: [
          // Container(
          //   color: Colors.grey.shade900,
          //   width: double.infinity,
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: FutureBuilder<List<Dish>>(
          //       future: futureDish,
          //       builder: (context, snapshot) {
          //         if (snapshot.hasData) {
          //           return Wrap(
          //             alignment: WrapAlignment.center,
          //             spacing: 4, // gap between adjacent chips
          //             runSpacing: 8, // gap between lines
          //             children: [
          //               for (var dish in snapshot.data!)
          //                 Container(
          //                   child: Padding(
          //                     padding:
          //                         const EdgeInsets.symmetric(horizontal: 16),
          //                     child: Column(
          //                       mainAxisSize: MainAxisSize.min,
          //                       children: [
          //                         ElevatedButton(
          //                           onPressed: () {
          //                             print('---> Button clicked: ${dish.name}');
          //                             _clickDish(dish.name);
          //                           },
          //                           child: Icon(Icons.circle_outlined,
          //                               color: Colors.grey.shade100),
          //                           style: ElevatedButton.styleFrom(
          //                             shape: CircleBorder(),
          //                             padding: EdgeInsets.all(20),
          //                             backgroundColor: Color(
          //                               int.parse(dish.color),
          //                             ),
          //                           ),
          //                         ),
          //                         Text(
          //                           dish.name +
          //                               ' - \$' +
          //                               (dish.price != 0
          //                                   ? dish.price.toString()
          //                                   : '???'),
          //                         )
          //                       ],
          //                     ),
          //                   ),
          //                 ),
          //             ],
          //           );
          //         } else if (snapshot.hasError) {
          //           return Text('${snapshot.error}');
          //         }

          //         // By default, show a loading spinner.
          //         return Row(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             const CircularProgressIndicator(),
          //           ],
          //         );
          //       },
          //     ),
          //   ),
          // ),
          ExpansionTile(
            title: const Text('價目表🍽️🧾'),
            initiallyExpanded: _isExpended,
            onExpansionChanged: (val) => setState(() {
              _isExpended = val;
              _isInit = false;
            }),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _futureDish2.isNotEmpty
                    ? Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 4, // gap between adjacent chips
                        runSpacing: 8, // gap between lines
                        children: [
                          for (var dish in _futureDish2)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      dish.isNotFixedPrice
                                          ? _displayTextInputDialog(
                                              context, dish)
                                          : _clickDish(dish.name);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: const CircleBorder(),
                                      padding: const EdgeInsets.all(20),
                                      backgroundColor: Color(
                                        int.parse(dish.color),
                                      ),
                                    ),
                                    child: Icon(Icons.circle_outlined,
                                        color: Colors.grey.shade100),
                                  ),
                                  Text(
                                    '${dish.name} - \$${dish.price != 0 ? dish.price.toString() : '???'}',
                                  )
                                ],
                              ),
                            ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                        ],
                      ),
              ),
            ],
          ),
          // Container(
          //   // color: Colors.grey.shade900,
          //   color: Theme.of(context).cardColor,
          //   width: double.infinity,
          //   child: Padding(
          //       padding: const EdgeInsets.all(16.0),
          //       child: _futureDish2.isNotEmpty
          //           ? Wrap(
          //               alignment: WrapAlignment.center,
          //               spacing: 4, // gap between adjacent chips
          //               runSpacing: 8, // gap between lines
          //               children: [
          //                 for (var dish in _futureDish2)
          //                   Padding(
          //                     padding:
          //                         const EdgeInsets.symmetric(horizontal: 16),
          //                     child: Column(
          //                       mainAxisSize: MainAxisSize.min,
          //                       children: [
          //                         ElevatedButton(
          //                           onPressed: () {
          //                             dish.isNotFixedPrice
          //                                 ? _displayTextInputDialog(
          //                                     context, dish)
          //                                 : _clickDish(dish.name);
          //                           },
          //                           style: ElevatedButton.styleFrom(
          //                             shape: const CircleBorder(),
          //                             padding: const EdgeInsets.all(20),
          //                             backgroundColor: Color(
          //                               int.parse(dish.color),
          //                             ),
          //                           ),
          //                           child: Icon(Icons.circle_outlined,
          //                               color: Colors.grey.shade100),
          //                         ),
          //                         Text(
          //                           '${dish.name} - \$${dish.price != 0 ? dish.price.toString() : '???'}',
          //                         )
          //                       ],
          //                     ),
          //                   ),
          //               ],
          //             )
          //           : const Row(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 CircularProgressIndicator(),
          //               ],
          //             )
          //       // By default, show a loading spinner.
          //       // return Row(
          //       //   mainAxisAlignment: MainAxisAlignment.center,
          //       //   children: [
          //       //     const CircularProgressIndicator(),
          //       //   ],
          //       // );
          //       ),
          // ),
          // Container(
          //   color: Colors.grey,
          //   width: double.infinity,
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         _futureDish2.isNotEmpty
          //             ? Text('Price: ${_futureDish2.toString()}')
          //             : const Text('Loading the price'),
          //       ],
          //     ),
          //   ),
          // ),
          // Container(
          //   color: Colors.red,
          //   width: double.infinity,
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         _orderedDishes2.isNotEmpty
          //             ? Text('Data: ${_orderedDishes2.toString()}')
          //             : const Text('Added the dishes you ordered'),
          //       ],
          //     ),
          //   ),
          // ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _orderedDishes2.isNotEmpty
                  ? ListView(
                      children: [
                        for (var dish in _orderedDishes2.entries)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${dish.key.split('-')[0]} - \$${(_futureDish2.where((d) => d.name == dish.key.split('-')[0]).first).isNotFixedPrice ? dish.key.split('-')[1] : (_futureDish2.where((d) => d.name == dish.key).first).price}',
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () => _addDish(dish.key),
                                            icon: const Icon(Icons.add),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Text(
                                              dish.value.toString(),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _removeDish(dish.key),
                                            icon: const Icon(Icons.remove),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '\$ ${(_futureDish2.where((d) => d.name == dish.key.split('-')[0]).first).isNotFixedPrice ? int.parse(dish.key.split('-')[1]) * dish.value : (_futureDish2.where((d) => d.name == dish.key).first).price * dish.value}',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('總數: \$ ${_getTotal()}'),
                                  Text(
                                      '總數 + 加一服務費(10%): \$ ${(_getTotal() * 1.1).toStringAsFixed(1)}'),
                                  TextButton(
                                    onPressed: _resetDishes,
                                    child: const Text('重新計算🧮'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      "你仲未嗌野食🍣",
                      style: TextStyle(fontSize: 24),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
