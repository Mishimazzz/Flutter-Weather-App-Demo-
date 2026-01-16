import 'package:flutter/material.dart';
import '../weatherApi.dart';
import '../weather.dart';
import 'user_repo.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

enum Sky { sunny, cloudy, rainy, snowy, unknown}

Sky mapCode(int code) {
  if (code == 0) return Sky.sunny;
  if ([1,2,3,45,48].contains(code)) return Sky.cloudy;
  if ([51,53,55,61,63,65,80,81,82,95,96,99].contains(code)) return Sky.rainy;
  if ([71,73,75,77,85,86].contains(code)) return Sky.snowy;
  return Sky.unknown;
}

List<Color> bgFor(Sky s) {
  switch (s) {
    case Sky.sunny:
      return [Colors.lightBlue, Colors.yellow];
    case Sky.cloudy:
      return [Colors.blueGrey, Colors.grey];
    case Sky.rainy:
      return [Colors.indigo, Colors.black54];
    case Sky.snowy:
      return [Colors.white, Colors.lightBlueAccent];
    default:
      return [Colors.grey, Colors.black];
  }
}


class _HomepageState extends State<Homepage> {
  final api = WeatherApi();
  WeatherNow ?now;//保存结果
  bool loading = false;
  String ? err;
  Sky sky = Sky.unknown;
  final searchC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _restoreLastCityAndLoad();
  }

  @override
  void dispose() {
    searchC.dispose();
    super.dispose();
  }

  // 启动时，优先恢复上次城市，没有就默认 Montreal
  Future<void> _restoreLastCityAndLoad() async {
    try {
      final last = await UserRepo().loadLastCity();
      if (!mounted) return;

      if (last != null && last['lat'] != null && last['lon'] != null) {
        await loadWeatherByLatLon(
          (last['lat'] as num).toDouble(),
          (last['lon'] as num).toDouble(),
        );
      } else {
        await loadWeatherByLatLon(45.5017, -73.5673); // Montreal
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => err = e.toString());
      await loadWeatherByLatLon(45.5017, -73.5673);
    }
  }

  Future<void> loadWeatherByLatLon(double lat, double lon) async {
    setState(() {
      loading = true;
      err = null;
    });

    try {
      final w = await api.fetchNow(lat, lon);
      if (!mounted) return;
      setState(() {
        now = w;
        sky = mapCode(w.code);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => err = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> loadWeather() async {
    try {
      final last = await UserRepo().loadLastCity();
      if (last != null && last['lat'] != null && last['lon'] != null) {
        await loadWeatherByLatLon(
          (last['lat'] as num).toDouble(),
          (last['lon'] as num).toDouble(),
        );
      } else {
        await loadWeatherByLatLon(45.5017, -73.5673);
      }
    } catch (e) {
      setState(() => err = e.toString());
    }
  }

  Future<void> searchCityFlow() async {
    final q = searchC.text.trim();
    if (q.isEmpty) return;

    setState(() {
      loading = true;
      err = null;
    });

    try {
      final results = await api.searchCity(q);
      if (results.isEmpty) throw Exception('No results');

      //底部弹窗，picked = c， c未返回值
      final picked = await showModalBottomSheet(
        context: context,
        builder: (_) => ListView.separated(
          itemCount: results.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final c = results[i];
            return ListTile(
              title: Text(c.name),
              subtitle: Text(c.country),
              onTap: () => Navigator.pop(context, c),
            );
          },
        ),
      );

      if (picked == null) return;

      await UserRepo().saveLastCity(
        name: picked.name,
        country: picked.country,
        lat: picked.lat,
        lon: picked.lon,
      );


      final w = await api.fetchNow(picked.lat, picked.lon);
      setState(() {
        now = w;
        sky = mapCode(w.code);
      });
    } catch (e) {
      setState(() => err = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Demo"),
        actions: [
          IconButton(
            onPressed: loading ? null : loadWeather,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgFor(sky),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchC,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => searchCityFlow(),
                        decoration: InputDecoration(
                          hintText: 'Search city (e.g. Montreal)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: loading ? null : searchCityFlow,
                      icon: const Icon(Icons.search),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 主体：loading / error / data
                Expanded(
                  child: Center(
                    child: loading
                        ? const CircularProgressIndicator()
                        : err != null
                            ? Text(err!, style: const TextStyle(color: Colors.red))
                            : now == null
                                ? const Text(
                                    'No data',
                                    style: TextStyle(color: Colors.white),
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        sky == Sky.sunny
                                            ? Icons.wb_sunny
                                            : sky == Sky.cloudy
                                                ? Icons.cloud
                                                : sky == Sky.rainy
                                                    ? Icons.umbrella
                                                    : sky == Sky.snowy
                                                        ? Icons.ac_unit
                                                        : Icons.help,
                                        size: 72,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '${now!.temp.toStringAsFixed(1)} °C',
                                        style: const TextStyle(
                                          fontSize: 44,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'wind: ${now!.wind.toStringAsFixed(1)} km/h',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'code: ${now!.code}',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}