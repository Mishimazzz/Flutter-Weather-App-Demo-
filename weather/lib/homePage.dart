import 'package:flutter/material.dart';
import '../weatherApi.dart';
import '../weather.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final api = WeatherApi();

  WeatherNow? now;
  bool loading = false;
  String? err;

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    setState(() {
      loading = true;
      err = null;
    });

    try {
      final w = await api.fetchNow(45.5017, -73.5673);
      setState(() => now = w);
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
        title: const Text('Weather Demo'),
        actions: [
          IconButton(
            onPressed: loading ? null : loadWeather,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : err != null
                ? Text(err!, style: const TextStyle(color: Colors.red))
                : now == null
                    ? const Text('No data')
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${now!.temp.toStringAsFixed(1)} °C',
                              style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('wind: ${now!.wind.toStringAsFixed(1)} km/h'),
                          Text('code: ${now!.code}'),
                        ],
                      ),
      ),
    );
  }
}
