import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpineHealthScreen extends StatefulWidget {
  const SpineHealthScreen({Key? key}) : super(key: key);

  @override
  State<SpineHealthScreen> createState() => _SpineHealthScreenState();
}

class _SpineHealthScreenState extends State<SpineHealthScreen> {
  bool _is3DMode = false;
  List<dynamic> _metadata = [];
  int _currentSeriesIndex = 0;

  // State
  double _currentSlice = 0.0;
  double _currentFrame = 0.0;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      final String response = await rootBundle.loadString('assets/mri_metadata.json');
      final data = await json.decode(response);
      setState(() {
        _metadata = data;
        _currentSeriesIndex = 0;
      });
    } catch (e) {
      debugPrint('Error loading metadata: $e');
    }
  }

  Widget _build2DViewer(Map<String, dynamic> seriesData) {
    int totalSlices = seriesData['slice_count'] ?? 1;
    int sliceIndex = _currentSlice.toInt().clamp(0, totalSlices - 1);
    
    String formattedIndex = sliceIndex.toString().padLeft(3, '0');
    int seriesId = seriesData['id'];
    String assetPath = 'assets/mri_images/s${seriesId}_$formattedIndex.png';

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                _currentSlice -= details.delta.dy * 0.5;
                if (_currentSlice < 0) _currentSlice = 0;
                if (_currentSlice > totalSlices - 1) {
                  _currentSlice = (totalSlices - 1).toDouble();
                }
              });
            },
            child: Center(
              child: InteractiveViewer(
                maxScale: 5.0,
                child: Image.asset(
                  assetPath,
                  gaplessPlayback: true,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              const Text(
                'Slice:',
                style: TextStyle(color: Colors.white),
              ),
              Expanded(
                child: Slider(
                  value: _currentSlice.clamp(0, totalSlices - 1.0).toDouble(),
                  min: 0,
                  max: (totalSlices - 1).toDouble(),
                  divisions: totalSlices > 1 ? totalSlices - 1 : 1,
                  onChanged: (value) {
                    setState(() {
                      _currentSlice = value;
                    });
                  },
                ),
              ),
              Text(
                '$sliceIndex / ${totalSlices - 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Text(
            'Drag vertically to scroll through slices',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        )
      ],
    );
  }

  Widget _build3DViewer(Map<String, dynamic> seriesData) {
    int totalFrames = seriesData['frame_count'] ?? 0;
    if (totalFrames == 0) {
       return const Center(
         child: Text(
           '3D Volume not available for this series.', 
           style: TextStyle(color: Colors.white)
         )
       );
    }

    int frameIndex = _currentFrame.toInt().clamp(0, totalFrames - 1);
    String formattedIndex = frameIndex.toString().padLeft(3, '0');
    int seriesId = seriesData['id'];
    String assetPath = 'assets/mri_3d/s${seriesId}_$formattedIndex.png';

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _currentFrame -= details.delta.dx * 0.2;
                if (_currentFrame < 0) _currentFrame += totalFrames;
                if (_currentFrame >= totalFrames) _currentFrame -= totalFrames;
              });
            },
            child: Center(
              child: InteractiveViewer(
                maxScale: 5.0,
                child: Image.asset(
                  assetPath,
                  gaplessPlayback: true,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'Drag horizontally to rotate 3D volume',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_metadata.isEmpty) {
       return const Scaffold(
         backgroundColor: Colors.black,
         body: Center(child: CircularProgressIndicator()),
       );
    }

    var seriesData = _metadata[_currentSeriesIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Spine Health MRI'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            icon: Icon(_is3DMode ? Icons.layers : Icons.view_in_ar, color: Colors.white),
            label: Text(_is3DMode ? 'View 2D' : 'View 3D', style: const TextStyle(color: Colors.white)),
            onPressed: () {
              setState(() {
                 _is3DMode = !_is3DMode;
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 16.0),
             child: DropdownButton<int>(
               value: _currentSeriesIndex,
               dropdownColor: Colors.grey[900],
               isExpanded: true,
               icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
               underline: Container(height: 1, color: Colors.white24),
               style: const TextStyle(color: Colors.white, fontSize: 16),
               items: _metadata.map((s) {
                  return DropdownMenuItem<int>(
                    value: s['id'],
                    child: Text(s['name']),
                  );
               }).toList(),
               onChanged: (val) {
                 if (val != null) {
                    setState(() {
                       _currentSeriesIndex = val;
                       _currentSlice = 0;
                       _currentFrame = 0;
                    });
                 }
               }
             )
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _is3DMode ? _build3DViewer(seriesData) : _build2DViewer(seriesData),
            ),
          ),
        ],
      ),
    );
  }
}