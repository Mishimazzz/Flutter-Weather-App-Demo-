import 'package:flutter/material.dart';
import '../weatherApi.dart';
import '../weather.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final api = WeatherApi();
  WeatherNow ?now;//保存结果
  bool loading = false;
  String ? err;

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async
  {
    //开始前loading == true, err == null
    setState(() {
      loading = true;
      err = null;
    });

    try {
      final w = await api.fetchNow(45.5017, -73.5673); // Montreal
      setState(() => now = w);
    }catch (e)
    {
      setState(() => err = e.toString());
    } finally {
    setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather Demo"),
        actions: [
        IconButton(
          onPressed: loading ? null : loadWeather,
          icon: const Icon(Icons.refresh),
        )
      ],
      ),
      body: Center(
      child: loading
          ? const CircularProgressIndicator()//如果在loading，就显示转转icon
          : err != null
              ? Text(err!, style: const TextStyle(color: Colors.red))//如果有error就显示error
              : now == null
                  ? const Text('No data')
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${now!.temp.toStringAsFixed(1)} °C',
                          style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('wind: ${now!.wind.toStringAsFixed(1)} km/h'),
                        Text('code: ${now!.code}'),
                      ],
                    ),
    ),
    );
  }
}