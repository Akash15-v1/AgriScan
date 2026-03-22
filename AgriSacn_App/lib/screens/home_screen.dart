import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'camera_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedLanguage = 'English';
  List<Map<String, dynamic>> _analysisResults = [];
  bool _isLoading = true;

  // SharedPreferences key for storing results
  static const String _resultsKey = 'analysis_results';

  @override
  void initState() {
    super.initState();
    _loadSavedResults();
  }

  // Load saved results from SharedPreferences
  Future<void> _loadSavedResults() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString(_resultsKey);

      print('=== LOADING DATA ===');
      print('Saved data exists: ${savedData != null}');

      if (savedData != null) {
        print('Saved data length: ${savedData.length}');
        print(
          'Saved data preview: ${savedData.substring(0, savedData.length > 100 ? 100 : savedData.length)}',
        );

        final List<dynamic> decodedData = jsonDecode(savedData);
        print('Decoded ${decodedData.length} results');

        setState(() {
          _analysisResults = decodedData
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
          _isLoading = false;
        });
        print('Successfully loaded ${_analysisResults.length} results');
      } else {
        print('No saved data found');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('ERROR loading saved results: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Save results to SharedPreferences
  Future<void> _saveResults() async {
    try {
      print('=== SAVING DATA ===');
      print('Number of results to save: ${_analysisResults.length}');

      // Make sure the data is serializable by creating a clean copy
      final List<Map<String, dynamic>> cleanResults = _analysisResults.map((
        result,
      ) {
        return {
          'diseaseName': result['diseaseName']?.toString() ?? '',
          'confidence': result['confidence'] is double
              ? result['confidence']
              : (result['confidence'] is int
                    ? (result['confidence'] as int).toDouble()
                    : 0.0),
          'imagePath': result['imagePath']?.toString() ?? '',
          'timestamp':
              result['timestamp']?.toString() ??
              DateTime.now().toIso8601String(),
        };
      }).toList();

      final prefs = await SharedPreferences.getInstance();
      final String encodedData = jsonEncode(cleanResults);

      print('Encoded data length: ${encodedData.length}');
      print(
        'Encoded data preview: ${encodedData.substring(0, encodedData.length > 100 ? 100 : encodedData.length)}',
      );

      final bool success = await prefs.setString(_resultsKey, encodedData);
      print('Save successful: $success');

      // Verify the save
      final String? verifyData = prefs.getString(_resultsKey);
      print('Verification - Data saved: ${verifyData != null}');
    } catch (e, stackTrace) {
      print('ERROR saving results: $e');
      print('Stack trace: $stackTrace');

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving data: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Clear all saved data (for testing)
  Future<void> _clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_resultsKey);
      setState(() {
        _analysisResults.clear();
      });
      print('All data cleared');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  // Disease info map for detailed information
  final Map<String, Map<String, String>> diseaseDataMap = {
    'Cercospora Leaf Spot': {
      'name_en': 'Cercospora Leaf Spot',
      'name_hi': 'सर्कोस्पोरा पत्ती धब्बा',
      'name_te': 'సర్కోస్పోరా ఆకు మచ్చ',
      'what_is_en':
          'A fungal disease that causes small, circular spots on the leaves, which can make them turn yellow and fall off.',
      'cause_en':
          'It\'s caused by a fungus that loves warm and humid (muggy) weather. The disease spreads easily when water splashes from an infected leaf to a healthy one.',
      'cause_hi':
          'यह एक ऐसे कवक के कारण होता है जो गर्म और आर्द्र मौसम को पसंद करता है। बीमारी आसानी से फैलती है जब संक्रमित पत्ती से पानी स्वस्थ पत्ती पर छिड़कता है।',
      'cause_te':
          'ఇది ఉష్ణ మరియు తేమ వాతావరణాన్ని ఇష్టపడే ఫంగస్ కారణంగా ఉంటుంది. సంక్రమిత ఆకు నుండి నీరు ఆరోగ్యకరమైన ఆకుపై చిందినప్పుడు వ్యాధి సులభంగా ఆయా చెందుతుంది.',
      'prevention_en':
          '1. Change Planting Location: Avoid planting chilis in the same soil for at least two years. This helps starve the fungus.\n2. Give Plants Space: Don\'t plant your chilis too close together. Good airflow helps the leaves dry faster, making it harder for the fungus to grow.',
      'prevention_hi':
          '1. रोपण स्थान बदलें: कम से कम दो साल तक उसी मिट्टी में मिर्च न लगाएं। यह कवक को भूखा रखने में मदद करता है।\n2. पौधों को जगह दें: अपनी मिर्च को बहुत करीब न लगाएं। अच्छा वायु प्रवाह पत्तियों को तेजी से सूखने में मदद करता है।',
      'prevention_te':
          '1. నాటే స్థలం మార్చండి: కనీసం రెండు సంవత్సరాలు ఒకే నేల నుండి మిరపకాయలను నాటవద్దు.\n2. మొక్కలకు స్థలం ఇవ్వండి: మీ మిరపకాయలను చాలా దగ్గరగా నాటవద్దు.',
      'solution_en':
          '1. Neem Oil Spray: A natural and effective option. Mix a small amount of neem oil with water and spray on the plants every 10-15 days.\n2. Use Fungicide: If the infection is severe, use a fungicide containing Mancozeb or Copper Oxychloride as directed on the package.',
      'solution_hi':
          '1. नीम का तेल स्प्रे: एक प्राकृतिक और प्रभावी विकल्प। नीम का तेल पानी के साथ मिलाएं और हर 10-15 दिन में पौधों पर छिड़कें।\n2. कवकनाशी का उपयोग करें: यदि संक्रमण गंभीर है, तो Mancozeb या Copper Oxychloride युक्त कवकनाशी का उपयोग करें।',
      'solution_te':
          '1. నీమ్ నూనె స్ప్రే: ఒక సహజ మరియు సమర్థవంతమైన ఎంపిక. నీమ్ నూనెను నీటితో కలపండి మరియు ప్రతి 10-15 రోజుల కు చిందించండి.\n2. శిలీందరనాశకం ఉపయోగించండి: సంక్రమణ తీవ్రమైతే, Mancozeb లేదా Copper Oxychloride కలిగిన శిలీందరనాశకం ఉపయోగించండి.',
    },
    'Leaf Curl': {
      'name_en': 'Leaf Curl Virus',
      'name_hi': 'पत्ती मोड़ वायरस',
      'name_te': 'ఆకు చుట్టుకు వైరస్',
      'what_is_en':
          'A viral disease that makes the leaves curl upwards, become thick, and turn yellow. It severely stunts the plant\'s growth.',
      'cause_en':
          'It is spread by a tiny insect called the whitefly. When whiteflies feed on a plant, they inject the virus, similar to how a mosquito spreads malaria.',
      'cause_hi':
          'यह सफेद मक्खी नामक एक छोटे कीट द्वारा फैलाया जाता है। जब सफेद मक्खियां पौधे पर भोजन करती हैं, तो वे वायरस को इंजेक्ट करती हैं।',
      'cause_te':
          'ఇది ఆకుపచ్చ పురుగు అని పిలువబడే చిన్న కీటకం ద్వారా ఆయా చెందుతుంది. ఆకుపచ్చ పురుగులు మొక్కపై భోజనం చేసినప్పుడు, అవి వైరస్‌ను ఇంజెక్ట్ చేస్తాయి.',
      'prevention_en':
          '1. Use Sticky Traps: Hang yellow-colored sticky cards in your field. Whiteflies are attracted to the color and will get stuck.\n2. Plant a Guard Crop: Plant taller crops like corn (maize) or jowar (sorghum) around your chili field to block whiteflies.',
      'prevention_hi':
          '1. चिपचिपे जाल का उपयोग करें: अपने खेत में पीले रंग के चिपचिपे कार्ड लगाएं।\n2. सुरक्षा फसल लगाएं: अपने मिर्च के खेत के चारों ओर मकई या ज्वार लगाएं।',
      'prevention_te':
          '1. స్టిక్కీ ట్రాప్‌లను ఉపయోగించండి: మీ పొలలో పసుపు రంగు స్టిక్కీ కార్డులను నిలిపండి.\n2. రక్షణ పంట నాటండి: మీ మిరపకాయ పొలం చుట్టూ మక్క లేదా జోలస నాటండి.',
      'solution_en':
          '1. Control Whiteflies: Spray an insecticide containing Imidacloprid to kill the whiteflies and stop them from spreading the virus further.\n2. Remove Infected Plants: If you see a plant with leaf curl, pull it out and burn it immediately to prevent spread.',
      'solution_hi':
          '1. सफेद मक्खियों पर नियंत्रण रखें: Imidacloprid युक्त कीटनाशक का छिड़काव करें।\n2. संक्रमित पौधों को हटाएं: यदि आप पत्ती मोड़ वाला पौधा देखते हैं, तो उसे तुरंत हटा दें।',
      'solution_te':
          '1. ఆకుపచ్చ పురుగులను నియంత్రించండి: Imidacloprid కలిగిన కీటకనాశకం చిందించండి.\n2. సంక్రమిత మొక్కలను తొలిగించండి: ఆకు చుట్టుకు ఉన్న మొక్కను చూస్తే, దానిని తక్షణమే తొలిగించండి.',
    },
    'Murda Complex': {
      'name_en': 'Murda Complex',
      'name_hi': 'मुर्दा रोग समूह',
      'name_te': 'ముర్దా సంక్లిష్ట రోగం',
      'what_is_en':
          'A complex problem where the top leaves of the chili plant curl downwards, become brittle, and look distorted.',
      'cause_en':
          'Thrips and mites are very small pests that suck the sap from new leaves, causing them to deform. These pests thrive in hot and dry weather.',
      'cause_hi':
          'Thrips और mites बहुत छोटे कीट हैं जो नई पत्तियों से रस चूसते हैं। ये कीट गर्म और शुष्क मौसम में पनपते हैं।',
      'cause_te':
          'థ్రిప్స్ మరియు పీటలు చిన్న కీటకాలు నూతన ఆకుల నుండి రసం పీయుట, వాటిని వక్రీకృతం చేస్తాయి.',
      'prevention_en':
          '1. Keep Field Clean: Remove all weeds from your field, as they provide a hiding place for these pests.\n2. Plant with Friends: Intercropping with onions or marigolds can help repel thrips and protect your chili plants.',
      'prevention_hi':
          '1. खेत को साफ रखें: अपने खेत से सभी खरपतवार हटाएं।\n2. दोस्तों के साथ पौधा लगाएं: प्याज या गेंदा के साथ अंतरफसल करें।',
      'prevention_te':
          '1. పొలాన్ని స్వచ్ఛంగా ఉంచండి: మీ పొలం నుండి అన్ని కలుపులను తొలిగించండి.\n2. స్నేహితుల సంఘ లాంటిది నాటండి: ఉల్లి లేదా గూలంద సంఘ లాంటిది ఫసల్ చేయండి.',
      'solution_en':
          '1. Spray Pesticide: Use a pesticide like Fipronil or Spinosad to control the thrips.\n2. Control Mites: For mites, spraying with wettable sulfur is an effective control measure.',
      'solution_hi':
          '1. कीटनाशी का छिड़काव करें: Fipronil या Spinosad जैसे कीटनाशी का उपयोग करें।\n2. माइट्स को नियंत्रित करें: wettable sulfur के साथ छिड़काव करें।',
      'solution_te':
          '1. కీటకనాశకం చిందించండి: Fipronil లేదా Spinosad ఉపయోగించండి.\n2. పీటలను నియంత్రించండి: చేపట్టిన సల్ఫర్‌తో చిందించండి.',
    },
    'Powdery Mildew': {
      'name_en': 'Powdery Mildew',
      'name_hi': 'चूर्णिल आसिता',
      'name_te': 'పౌడర్ మిల్డ్యూ',
      'what_is_en':
          'A fungal disease that looks like a white, powdery coating on the leaves and stems.',
      'cause_en':
          'This fungus prefers dry conditions but with high humidity, especially during cool nights. It spreads through the air from one plant to another.',
      'cause_hi':
          'यह कवक शुष्क परिस्थितियों को पसंद करता है लेकिन उच्च आर्द्रता के साथ। यह हवा के माध्यम से फैलता है।',
      'cause_te':
          'ఈ ఫంగస్ ఆర్ద్ర పరిస్థితులను ఇష్టపడుతుంది. ఇది ఆకాశంలో ఆయా చెందుతుంది.',
      'prevention_en':
          '1. Ensure Good Sunlight: Plant your chilis in a spot where they receive plenty of direct sunlight, which helps kill the fungus.\n2. Balanced Nutrition: Avoid using too much nitrogen fertilizer, as it makes the leaves soft and more attractive to the fungus.',
      'prevention_hi':
          '1. अच्छी धूप सुनिश्चित करें: अपनी मिर्च को एक ऐसी जगह पर लगाएं जहां उन्हें सीधी धूप मिले।\n2. संतुलित पोषण: बहुत अधिक नाइट्रोजन खाद का उपयोग न करें।',
      'prevention_te':
          '1. మంచి సూర్యకాంతిని నిశ్చితం చేయండి: మీ మిరపకాయలను సూర్యకాంతిని పొందే స్థానంలో నాటండి.\n2. సమతుల్య పోషణ: చాలా ఎక్కువ నైట్రోజన్ ఫర్టిలైజర్‌ను ఉపయోగించవద్దు.',
      'solution_en':
          '1. Buttermilk Spray: A traditional home remedy. Mix 1 liter of sour buttermilk with 4 liters of water and spray it on affected plants.\n2. Sulfur Treatment: If the problem persists, spray wettable sulfur in the evening.',
      'solution_hi':
          '1. छाछ का छिड़काव: एक पारंपरिक घरेलू उपचार। 1 लीटर खट्टी छाछ को 4 लीटर पानी के साथ मिलाएं।\n2. सल्फर उपचार: यदि समस्या बनी रहती है, तो शाम को wettable sulfur का छिड़काव करें।',
      'solution_te':
          '1. పెరుగు చిందించుట: ఒక సాంప్రదాయక ఘర నివారణ. 1 లీటర ఆమ్లిక పెరుగును 4 లీటర నీటితో కలపండి.\n2. సల్ఫర్ చికిత్స: సమస్య కొనసాగితే, సాయంకాలంలో చేపట్టిన సల్ఫర్‌ను చిందించండి.',
    },
    'Healthy': {
      'name_en': 'Healthy Plant',
      'name_hi': 'स्वस्थ पौधा',
      'name_te': 'ఆరోగ్యకరమైన మొక్క',
      'what_is_en':
          'Great! Your plant is healthy and disease-free. Keep providing good care to maintain its health.',
      'what_is_hi':
          'शानदार! आपका पौधा स्वस्थ और रोग-मुक्त है। इसके स्वास्थ्य को बनाए रखने के लिए अच्छी देखभाल प्रदान करते रहें।',
      'what_is_te':
          'గొప్పది! మీ మొక్క ఆరోగ్యకరమైనది మరియు వ్యాధి-రహితం. దీని ఆరోగ్యాన్ని నిర్వహించడానికి మంచి సంరక్షణ ఇవ్వడం కొనసాగించండి.',
      'cause_en': 'No disease detected',
      'cause_hi': 'कोई बीमारी नहीं पाई गई',
      'cause_te': 'ఎటువంటి రోగం గుర్తించబడలేదు',
      'prevention_en': 'Continue regular care and monitoring',
      'prevention_hi': 'नियमित देखभाल जारी रखें',
      'prevention_te': 'సాధారణ సంరక్షణ కొనసాగించండి',
      'solution_en': 'Maintain current care routine',
      'solution_hi': 'वर्तमान देखभाल दिनचर्या बनाए रखें',
      'solution_te': 'ప్రస్తుత సంరక్షణ దినచర్య నిర్వహించండి',
    },
  };

  void _selectLanguage(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
  }

  Future<void> _startAnalysis() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(language: _selectedLanguage),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      print('=== NEW RESULT RECEIVED ===');
      print('Result data: $result');

      setState(() {
        _analysisResults.insert(0, result);
      });

      // Save results after adding new one
      await _saveResults();

      // Show confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Result saved! Total: ${_analysisResults.length}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      print('No result returned or invalid format');
    }
  }

  void _deleteResult(int index) {
    setState(() {
      _analysisResults.removeAt(index);
    });
    // Save results after deletion
    _saveResults();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getTranslation('resultDeleted')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteConfirmDialog(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_getTranslation('deleteResult')),
        content: Text(_getTranslation('deleteConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_getTranslation('cancel')),
          ),
          TextButton(
            onPressed: () {
              _deleteResult(index);
              Navigator.pop(ctx);
            },
            child: Text(
              _getTranslation('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _getDetailedInfo(String diseaseName, String key) {
    final diseaseInfo = diseaseDataMap[diseaseName];
    if (diseaseInfo == null) return 'N/A';

    String langKey = key;
    if (_selectedLanguage == 'Hindi') {
      langKey = '${key}_hi';
    } else if (_selectedLanguage == 'Telugu') {
      langKey = '${key}_te';
    } else {
      langKey = '${key}_en';
    }

    return diseaseInfo[langKey] ?? 'N/A';
  }

  void _showResultDialog(Map<String, dynamic> result) {
    final diseaseName = result['diseaseName'] ?? 'Unknown';
    final isHealthy = diseaseName == 'Healthy';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_getTranslation('resultTitle')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image preview
              if (result['imagePath'] != null)
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(result['imagePath']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 15),

              // ✅ FIX: Show disease name differently for Healthy vs Diseased
              if (isHealthy) ...[
                // For Healthy - Show centered with icon, no label
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getDetailedInfo(diseaseName, 'name'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getDetailedInfo(diseaseName, 'what_is'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // For Diseased - Show with label and translated name
                _buildDialogField(
                  label: _getTranslation('diseaseName'),
                  value: _getDetailedInfo(diseaseName, 'name'),
                ),
              ],

              const SizedBox(height: 10),
              _buildDialogField(
                label: _getTranslation('confidence'),
                value: result['confidence'] != null
                    ? '${(result['confidence'] * 100).toStringAsFixed(1)}%'
                    : 'N/A',
              ),
              const SizedBox(height: 10),

              // Show cause, prevention, solution only if not healthy
              if (!isHealthy) ...[
                _buildDialogField(
                  label: _getTranslation('cause'),
                  value: _getDetailedInfo(diseaseName, 'cause'),
                ),
                const SizedBox(height: 10),
                _buildDialogField(
                  label: _getTranslation('prevention'),
                  value: _getDetailedInfo(diseaseName, 'prevention'),
                ),
                const SizedBox(height: 10),
                _buildDialogField(
                  label: _getTranslation('solution'),
                  value: _getDetailedInfo(diseaseName, 'solution'),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                '${_getTranslation('time')}: ${_formatTime(result['timestamp'] ?? '')}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_getTranslation('ok')),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  String _formatTime(String timestamp) {
    if (timestamp.isEmpty) return '';
    try {
      final dt = DateTime.parse(timestamp);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getTranslation(String key) {
    final translations = {
      'English': {
        'welcome': 'Detect Disease',
        'selectLanguage': 'Select Language',
        'analyzeLeaf': ' Analyze Leaf',
        'previousResults': 'Previous Results',
        'resultTitle': 'Analysis Result',
        'diseaseName': 'Disease Name:',
        'confidence': 'Confidence:',
        'cause': 'Why it happens:',
        'prevention': 'How to prevent it:',
        'solution': 'How to fix it:',
        'time': 'Time',
        'ok': 'OK',
        'noResults': 'No previous results',
        'deleteResult': 'Delete Result',
        'deleteConfirm':
            'Are you sure you want to delete this analysis result?',
        'delete': 'Delete',
        'cancel': 'Cancel',
        'resultDeleted': 'Result deleted successfully',
        'clearAll': 'Clear All',
      },
      'Hindi': {
        'welcome': 'रोग का पता लगाएं',
        'selectLanguage': 'भाषा चुनें',
        'analyzeLeaf': ' पत्ती का विश्लेषण करें',
        'previousResults': 'पिछले परिणाम',
        'resultTitle': 'विश्लेषण परिणाम',
        'diseaseName': 'रोग का नाम:',
        'confidence': 'विश्वास:',
        'cause': 'यह क्यों होता है:',
        'prevention': 'इसे कैसे रोकें:',
        'solution': 'इसे कैसे ठीक करें:',
        'time': 'समय',
        'ok': 'ठीक है',
        'noResults': 'कोई पिछला परिणाम नहीं',
        'deleteResult': 'परिणाम हटाएं',
        'deleteConfirm':
            'क्या आप सुनिश्चित हैं कि आप इस विश्लेषण परिणाम को हटाना चाहते हैं?',
        'delete': 'हटाएं',
        'cancel': 'रद्द करें',
        'resultDeleted': 'परिणाम सफलतापूर्वक हटा दिया गया',
        'clearAll': 'सभी हटाएं',
      },
      'Telugu': {
        'welcome': 'రోగాన్ని గుర్తించండి',
        'selectLanguage': 'భాషను ఎంచుకోండి',
        'analyzeLeaf': ' ఆకును విశ్లేషించండి',
        'previousResults': 'మునుపటి ఫలితాలు',
        'resultTitle': 'విశ్లేషణ ఫలితం',
        'diseaseName': 'రోగం పేరు:',
        'confidence': 'విశ్వాసం:',
        'cause': 'ఇది ఎందుకు జరుగుతుంది:',
        'prevention': 'దీనిని ఎలా నివారించాలి:',
        'solution': 'దీనిని ఎలా సరిచేయాలి:',
        'time': 'సమయం',
        'ok': 'సరే',
        'noResults': 'మునుపటి ఫలితాలు లేవు',
        'deleteResult': 'ఫలితం తొలిగించండి',
        'deleteConfirm': 'ఈ విశ్లేషణ ఫలితాన్ని తొలిగించాలని మీరు ఖచ్చితమైనదా?',
        'delete': 'తొలిగించండి',
        'cancel': 'రద్దు చేయండి',
        'resultDeleted': 'ఫలితం విజయవంతంగా తొలిగించబడింది',
        'clearAll': 'అన్నింటినీ తొలిగించండి',
      },
    };

    return translations[_selectedLanguage]?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTranslation('welcome'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 2,
        actions: [
          // Add clear all button for testing
          if (_analysisResults.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(_getTranslation('clearAll')),
                    content: const Text('Delete all saved results?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(_getTranslation('cancel')),
                      ),
                      TextButton(
                        onPressed: () {
                          _clearAllData();
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          _getTranslation('delete'),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    _selectedLanguage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            onSelected: _selectLanguage,
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'English',
                child: Row(
                  children: [
                    Icon(Icons.flag, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('English'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'Hindi',
                child: Row(
                  children: [
                    Icon(Icons.flag, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('हिंदी'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'Telugu',
                child: Row(
                  children: [
                    Icon(Icons.flag, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('తెలుగు'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green.shade50, Colors.white],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.add,
                        size: 28,
                        color: Colors.white,
                      ),
                      label: Text(
                        _getTranslation('analyzeLeaf'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 30,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        shadowColor: Colors.blue.withOpacity(0.5),
                      ),
                      onPressed: _startAnalysis,
                    ),
                    const SizedBox(height: 30),
                    if (_analysisResults.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _getTranslation('previousResults'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                    Expanded(
                      child: _analysisResults.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 80,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _getTranslation('noResults'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 0.75,
                                  ),
                              itemCount: _analysisResults.length,
                              itemBuilder: (context, index) {
                                final result = _analysisResults[index];
                                return GestureDetector(
                                  onTap: () => _showResultDialog(result),
                                  onLongPress: () =>
                                      _showDeleteConfirmDialog(index),
                                  child: Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                ),
                                            child:
                                                result['imagePath'] != null &&
                                                    File(
                                                      result['imagePath'],
                                                    ).existsSync()
                                                ? Image.file(
                                                    File(result['imagePath']),
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    color: Colors.grey.shade200,
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                      size: 40,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // ✅ FIX: Show translated disease name in grid
                                              Text(
                                                _getDetailedInfo(
                                                  result['diseaseName'] ??
                                                      'Unknown',
                                                  'name',
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  result['confidence'] != null
                                                      ? '${(result['confidence'] * 100).toStringAsFixed(1)}%'
                                                      : 'N/A',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.blue.shade700,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                _formatTime(
                                                  result['timestamp'] ?? '',
                                                ),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
