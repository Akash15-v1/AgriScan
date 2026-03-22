import 'package:flutter/material.dart';
import 'dart:io';
import '../screens/camera_screen.dart';

class ResultScreen extends StatelessWidget {
  final String imagePath;
  final String diseaseName;
  final double confidence;
  final String language;

  const ResultScreen({
    Key? key,
    required this.imagePath,
    required this.diseaseName,
    required this.confidence,
    required this.language,
  }) : super(key: key);

  Map<String, String> _getDiseaseInfo(String disease) {
    final diseaseData = {
      'Cercospora Leaf Spot': {
        'name_en': 'Cercospora Leaf Spot',
        'name_hi': 'सर्कोस्पोरा पत्ती धब्बा',
        'name_te': 'సర్కోస్పోరా ఆకు మచ్చ',
        'what_is_en':
            'A fungal disease that causes small, circular spots on the leaves, which can make them turn yellow and fall off.',
        'what_is_hi':
            'एक कवक रोग जो पत्तियों पर छोटे गोलाकार धब्बे पैदा करता है, जिससे वे पीले पड़ जाते हैं और गिर जाते हैं।',
        'what_is_te':
            'పెద్ద ఆకులపై చిన్న వృత్తాకార మచ్చలను ఉత్పత్తి చేసే ఫంగల్ వ్యాధి, ఇది పసుపు పడి పడిపోతుంది.',
        'cause_en':
            'It\'s caused by a fungus that loves warm and humid (muggy) weather. The disease spreads easily when water splashes from an infected leaf to a healthy one.',
        'cause_hi':
            'यह एक ऐसे कवक के कारण होता है जो गर्म और आर्द्र मौसम को पसंद करता है। बीमारी आसानी से फैलती है जब संक्रमित पत्ती से पानी स्वस्थ पत्ती पर छिड़कता है।',
        'cause_te':
            'ఇది ఉష్ణ మరియు తేమ వాతావరణాన్ని ఇష్టపడే ఫంగస్ కారణంగా ఉంటుంది. సంక్రమిత ఆకు నుండి నీరు ఆరోగ్యకరమైన ఆకుపై చిందినప్పుడు వ్యాధి సులభంగా ఆయా చెందుతుంది.',
        'prevention1_title_en': 'Change Planting Location',
        'prevention1_title_hi': 'रोपण स्थान बदलें',
        'prevention1_title_te': 'నాటే స్థలం మార్చండి',
        'prevention1_en':
            'Avoid planting chilis in the same soil for at least two years. This helps starve the fungus.',
        'prevention1_hi':
            'कम से कम दो साल तक उसी मिट्टी में मिर्च न लगाएं। यह कवक को भूखा रखने में मदद करता है।',
        'prevention1_te':
            'కనీసం రెండు సంవత్సరాలు ఒకే నేల నుండి మిరపకాయలను నాటవద్దు. ఇది ఫంగస్‌ను ఆకలి కొరకు సహాయం చేస్తుంది.',
        'prevention2_title_en': 'Give Plants Space',
        'prevention2_title_hi': 'पौधों को जगह दें',
        'prevention2_title_te': 'మొక్కలకు స్థలం ఇవ్వండి',
        'prevention2_en':
            'Don\'t plant your chilis too close together. Good airflow helps the leaves dry faster, making it harder for the fungus to grow.',
        'prevention2_hi':
            'अपनी मिर्च को बहुत करीब न लगाएं। अच्छा वायु प्रवाह पत्तियों को तेजी से सूखने में मदद करता है, जिससे कवक को बढ़ना मुश्किल हो जाता है।',
        'prevention2_te':
            'మీ మిరపకాయలను చాలా దగ్గరగా నాటవద్దు. మంచి గాలి ప్రవాహం ఆకులను వేగంగా ఎండబెట్టడానికి సహాయం చేస్తుంది, ఇది ఫంగస్‌ను పెరుగుటకు కష్టతరం చేస్తుంది.',
        'solution1_title_en': 'Neem Oil Spray',
        'solution1_title_hi': 'नीम का तेल स्प्रे',
        'solution1_title_te': 'నీమ్ నూనె స్ప్రే',
        'solution1_en':
            'A natural and effective option. Mix a small amount of neem oil with water and spray on the plants every 10-15 days.',
        'solution1_hi':
            'एक प्राकृतिक और प्रभावी विकल्प। नीम का तेल पानी के साथ मिलाएं और हर 10-15 दिन में पौधों पर छिड़कें।',
        'solution1_te':
            'ఒక సహజ మరియు సమర్థవంతమైన ఎంపిక. నీమ్ నూనెను నీటితో కలపండి మరియు ప్రతి 10-15 రోజుల కు మొక్కలపై చిందించండి.',
        'solution2_title_en': 'Use Fungicide',
        'solution2_title_hi': 'कवकनाशी का उपयोग करें',
        'solution2_title_te': 'శిలీందరనాశకం ఉపయోగించండి',
        'solution2_en':
            'If the infection is severe, use a fungicide containing Mancozeb or Copper Oxychloride as directed on the package.',
        'solution2_hi':
            'यदि संक्रमण गंभीर है, तो पैकेज पर निर्देशानुसार Mancozeb या Copper Oxychloride युक्त कवकनाशी का उपयोग करें।',
        'solution2_te':
            'సంక్రమణ తీవ్రమైతే, ప్యాకేజీలో సూచించిన విధంగా Mancozeb లేదా Copper Oxychloride కలిగిన శిలీందరనాశకం ఉపయోగించండి.',
      },
      'Leaf Curl': {
        'name_en': 'Leaf Curl Virus',
        'name_hi': 'पत्ती मोड़ वायरस',
        'name_te': 'ఆకు చుట్టుకు వైరస్',
        'what_is_en':
            'A viral disease that makes the leaves curl upwards, become thick, and turn yellow. It severely stunts the plant\'s growth.',
        'what_is_hi':
            'एक वायरल रोग जो पत्तियों को ऊपर की ओर मोड़ देता है, मोटा कर देता है और पीला कर देता है। यह पौधे की वृद्धि को गंभीर रूप से रोक देता है।',
        'what_is_te':
            'ఆకులను ఎగువకు కర్ల్ చేసే, మందపాటిచేసే మరియు పసుపు చేసే వైరల్ వ్యాధి. ఇది మొక్క యొక్క పెరుగుటను తీవ్రంగా ఆపివేస్తుంది.',
        'cause_en':
            'It is spread by a tiny insect called the whitefly. When whiteflies feed on a plant, they inject the virus, similar to how a mosquito spreads malaria.',
        'cause_hi':
            'यह सफेद मक्खी नामक एक छोटे कीट द्वारा फैलाया जाता है। जब सफेद मक्खियां पौधे पर भोजन करती हैं, तो वे वायरस को इंजेक्ट करती हैं, जैसे मच्छर मलेरिया फैलाता है।',
        'cause_te':
            'ఇది ఆకుపచ్చ పురుగు అని పిలువబడే చిన్న కీటకం ద్వారా ఆయా చెందుతుంది. ఆకుపచ్చ పురుగులు మొక్కపై భోజనం చేసినప్పుడు, అవి వైరస్‌ను ఇంజెక్ట్ చేస్తాయి, దీనిలో దోమ మలేరియా ఆయా చెందుతుంది.',
        'prevention1_title_en': 'Use Sticky Traps',
        'prevention1_title_hi': 'चिपचिपे जाल का उपयोग करें',
        'prevention1_title_te': 'స్టిక్కీ ట్రాప్‌లను ఉపయోగించండి',
        'prevention1_en':
            'Hang yellow-colored sticky cards in your field. Whiteflies are attracted to the color and will get stuck.',
        'prevention1_hi':
            'अपने खेत में पीले रंग के चिपचिपे कार्ड लगाएं। सफेद मक्खियां रंग की ओर आकर्षित होती हैं और फंस जाती हैं।',
        'prevention1_te':
            'మీ పొలలో పసుపు రంగు స్టిక్కీ కార్డులను నిలిపండి. ఆకుపచ్చ పురుగులు రంగ వైపు ఆకర్షితమైనవి మరియు దానిలో చిక్కుకుపోతాయి.',
        'prevention2_title_en': 'Plant a Guard Crop',
        'prevention2_title_hi': 'सुरक्षा फसल लगाएं',
        'prevention2_title_te': 'రక్షణ పంట నాటండి',
        'prevention2_en':
            'Plant taller crops like corn (maize) or jowar (sorghum) around your chili field. These act as a wall to block the whiteflies from entering.',
        'prevention2_hi':
            'अपने मिर्च के खेत के चारों ओर मकई (मक्का) या ज्वार जैसी लंबी फसलें लगाएं। ये सफेद मक्खियों को रोकने के लिए एक दीवार के रूप में कार्य करती हैं।',
        'prevention2_te':
            'మీ మిరపకాయ పొలం చుట్టూ మక్క (మక్క) లేదా జోలస (సోర్ఘం) వంటి ఎత్తైన పంటలను నాటండి. ఇవి ఆకుపచ్చ పురుగులను ప్రవేశం నుండి నిరోధించడానికి గోడ వలె పనిచేస్తాయి.',
        'solution1_title_en': 'Control Whiteflies',
        'solution1_title_hi': 'सफेद मक्खियों पर नियंत्रण रखें',
        'solution1_title_te': 'ఆకుపచ్చ పురుగులను నియంత్రించండి',
        'solution1_en':
            'Spray an insecticide containing Imidacloprid to kill the whiteflies and stop them from spreading the virus further.',
        'solution1_hi':
            'Imidacloprid युक्त कीटनाशक का छिड़काव करें ताकि सफेद मक्खियों को मारा जा सके और वे वायरस को आगे न फैला सकें।',
        'solution1_te':
            'Imidacloprid కలిగిన కీటకనాశకం చిందించండి ఆకుపచ్చ పురుగులను చంపడానికి మరియు వారు వైరస్‌ను మరింత ఆయా చెందకుండా ఆపడానికి.',
        'solution2_title_en': 'Remove Infected Plants',
        'solution2_title_hi': 'संक्रमित पौधों को हटाएं',
        'solution2_title_te': 'సంక్రమిత మొక్కలను తొలిగించండి',
        'solution2_en':
            'If you see a plant with leaf curl, pull it out and burn it immediately. This is crucial to prevent the disease from spreading to healthy plants.',
        'solution2_hi':
            'यदि आप पत्ती मोड़ वाला पौधा देखते हैं, तो उसे तुरंत निकालें और जला दें। यह बीमारी को स्वस्थ पौधों तक फैलने से रोकने के लिए महत्वपूर्ण है।',
        'solution2_te':
            'మీరు ఆకు చుట్టుకు ఉన్న మొక్కను చూస్తే, దానిని తక్షణమే బయటకు తీసి కాలిపోయండి. ఇది వ్యాధిని ఆరోగ్యకరమైన మొక్కలకు ఆయా చెందకుండా నిరోధించడానికి కీలకమైనది.',
      },
      'Murda Complex': {
        'name_en': 'Murda Complex',
        'name_hi': 'मुर्दा रोग समूह',
        'name_te': 'ముర్దా సంక్లిష్ట రోగం',
        'what_is_en':
            'A complex problem where the top leaves of the chili plant curl downwards, become brittle, and look distorted. It\'s caused by tiny pests called thrips and mites.',
        'what_is_hi':
            'एक जटिल समस्या जहां मिर्च के पौधे की शीर्ष पत्तियां नीचे की ओर मुड़ जाती हैं, नाजुक हो जाती हैं और विकृत दिखाई देती हैं। यह thrips और mites नामक छोटे कीटों के कारण होता है।',
        'what_is_te':
            'మిరపకాయ మొక్క యొక్క పై ఆకులు క్రిందికి కర్ల్ చేసే, నిటారుగా ఉండే మరియు వక్రీకృతమైన జటిల సమస్య. దీనిని థ్రిప్స్ మరియు పీటలు అనే చిన్న కీటకాలు కారణం చేస్తాయి.',
        'cause_en':
            'Thrips and mites are very small pests that suck the sap from new leaves, causing them to deform. These pests thrive in hot and dry weather.',
        'cause_hi':
            'Thrips और mites बहुत छोटे कीट हैं जो नई पत्तियों से रस चूसते हैं, जिससे वे विकृत हो जाती हैं। ये कीट गर्म और शुष्क मौसम में पनपते हैं।',
        'cause_te':
            'థ్రిప్స్ మరియు పీటలు చిన్న కీటకాలు నూతన ఆకుల నుండి రసం పీయుట, వాటిని వక్రీకృతం చేస్తాయి. ఈ కీటకాలు వేడిచేసిన మరియు건조 తరుపులో విస్తరిస్తాయి.',
        'prevention1_title_en': 'Keep Field Clean',
        'prevention1_title_hi': 'खेत को साफ रखें',
        'prevention1_title_te': 'పొలాన్ని స్వచ్ఛంగా ఉంచండి',
        'prevention1_en':
            'Remove all weeds from your field, as they provide a hiding place for these pests.',
        'prevention1_hi':
            'अपने खेत से सभी खरपतवार हटाएं, क्योंकि वे इन कीटों के लिए एक छिपने की जगह प्रदान करते हैं।',
        'prevention1_te':
            'మీ పొలం నుండి అన్ని కలుపులను తొలిగించండి, ఎందుకంటే అవి ఈ కీటకాల కోసం ఒక లుకుచుक్కको స్థానాన్ని అందిస్తాయి.',
        'prevention2_title_en': 'Plant with Friends',
        'prevention2_title_hi': 'दोस्तों के साथ पौधा लगाएं',
        'prevention2_title_te': 'స్నేహితుల సంఘ లాంటిది నాటండి',
        'prevention2_en':
            'Intercropping with onions or marigolds can help repel thrips and protect your chili plants.',
        'prevention2_hi':
            'प्याज या गेंदा के साथ अंतरफसल thrips को दूर करने और आपके मिर्च के पौधों की रक्षा करने में मदद कर सकता है।',
        'prevention2_te':
            'ఉల్లి లేదా గూలంద సంఘ లాంటిది ఫసల్ థ్రిప్స్‌ను దూరం చేయడానికి మరియు మీ మిరపకాయ మొక్కలను రక్షించడానికి సహాయం చేస్తుంది.',
        'solution1_title_en': 'Spray Pesticide',
        'solution1_title_hi': 'कीटनाशी का छिड़काव करें',
        'solution1_title_te': 'కీటకనాశకం చిందించండి',
        'solution1_en':
            'Use a pesticide like Fipronil or Spinosad to control the thrips.',
        'solution1_hi':
            'Thrips को नियंत्रित करने के लिए Fipronil या Spinosad जैसे कीटनाशी का उपयोग करें।',
        'solution1_te':
            'థ్రిప్స్‌ను నియంత్రించడానికి Fipronil లేదా Spinosad వంటి కీటకనాశకం ఉపయోగించండి.',
        'solution2_title_en': 'Control Mites',
        'solution2_title_hi': 'माइट्स को नियंत्रित करें',
        'solution2_title_te': 'పీటలను నియంత్రించండి',
        'solution2_en':
            'For mites, which often accompany thrips, spraying with wettable sulfur is an effective control measure.',
        'solution2_hi':
            'माइट्स के लिए, जो अक्सर thrips के साथ होते हैं, wettable sulfur के साथ छिड़काव एक प्रभावी नियंत्रण उपाय है।',
        'solution2_te':
            'పీటల కోసం, ఇవి చాలా సార్లు థ్రిప్స్‌తో సంభవిస్తాయి, చేపట్టిన సల్ఫర్‌తో చిందించడం సమర్థవంతమైన నియంత్రణ చర్య.',
      },
      'Powdery Mildew': {
        'name_en': 'Powdery Mildew',
        'name_hi': 'चूर्णिल आसिता',
        'name_te': 'పౌడర్ మిల్డ్యూ',
        'what_is_en':
            'A fungal disease that looks like a white, powdery coating on the leaves and stems.',
        'what_is_hi':
            'एक कवक रोग जो पत्तियों और तनों पर सफेद, पाउडर जैसी कोटिंग दिखता है।',
        'what_is_te':
            'ఆకులు మరియు కాండ్ల పై సफేద, చక్కర పోషక పూత లాగా కనిపించే ఫంగల్ వ్యాధి.',
        'cause_en':
            'This fungus prefers dry conditions but with high humidity, especially during cool nights. It spreads through the air from one plant to another.',
        'cause_hi':
            'यह कवक शुष्क परिस्थितियों को पसंद करता है लेकिन उच्च आर्द्रता के साथ, विशेष रूप से ठंडी रातों में। यह हवा के माध्यम से एक पौधे से दूसरे पौधे में फैलता है।',
        'cause_te':
            'ఈ ఫంగస్ ఆర్ద్ర పరిస్థితులను ఇష్టపడుతుంది కానీ అధిక ఆర్ద్రత, ముఖ్యంగా చల్లని రాత్రుల్లో. ఇది ఆకాశంలో ఒక మొక్క నుండి మరొక మొక్కకు ఆయా చెందుతుంది.',
        'prevention1_title_en': 'Ensure Good Sunlight',
        'prevention1_title_hi': 'अच्छी धूप सुनिश्चित करें',
        'prevention1_title_te': 'మంచి సూర్యకాంతిని నిశ్చితం చేయండి',
        'prevention1_en':
            'Plant your chilis in a spot where they receive plenty of direct sunlight, which helps kill the fungus.',
        'prevention1_hi':
            'अपनी मिर्च को एक ऐसी जगह पर लगाएं जहां उन्हें सीधी धूप की भरपूर मात्रा मिले, जिससे कवक को मारने में मदद मिलती है।',
        'prevention1_te':
            'మీ మిరపకాయలను ఎక్కువ సరళ సూర్యకాంతిని పొందే స్థానంలో నాటండి, ఇది ఫంగస్‌ను చంపడానికి సహాయం చేస్తుంది.',
        'prevention2_title_en': 'Balanced Nutrition',
        'prevention2_title_hi': 'संतुलित पोषण',
        'prevention2_title_te': 'సమతుల్య పోషణ',
        'prevention2_en':
            'Avoid using too much nitrogen fertilizer, as it makes the leaves soft and more attractive to the fungus.',
        'prevention2_hi':
            'बहुत अधिक नाइट्रोजन खाद का उपयोग न करें, क्योंकि यह पत्तियों को नरम बना देता है और कवक के लिए अधिक आकर्षक बना देता है।',
        'prevention2_te':
            'చాలా ఎక్కువ నైట్రోజన్ ఫర్టిలైజర్‌ను ఉపయోగించవద్దు, ఎందుకంటే ఇది ఆకులను మృదువుగా చేస్తుంది మరియు ఫంగస్‌కు మరింత ఆకర్షణీయంగా చేస్తుంది.',
        'solution1_title_en': 'Buttermilk Spray',
        'solution1_title_hi': 'छाछ का छिड़काव',
        'solution1_title_te': 'పెరుగు చిందించుట',
        'solution1_en':
            'A traditional and effective home remedy. Mix 1 liter of sour buttermilk with 4 liters of water and spray it on the affected plants.',
        'solution1_hi':
            'एक पारंपरिक और प्रभावी घरेलू उपचार। 1 लीटर खट्टी छाछ को 4 लीटर पानी के साथ मिलाएं और इसे प्रभावित पौधों पर छिड़कें।',
        'solution1_te':
            'ఒక సాంప్రదాయక మరియు సమర్థవంతమైన గృహ నివారణ. 1 లీటర ఆమ్లిక పెరుగును 4 లీటర నీటితో కలపండి మరియు దానిని ప్రభావితమైన మొక్కలపై చిందించండి.',
        'solution2_title_en': 'Sulfur Treatment',
        'solution2_title_hi': 'सल्फर उपचार',
        'solution2_title_te': 'సల్ఫర్ చికిత్స',
        'solution2_en':
            'If the problem persists, spray wettable sulfur in the evening. Avoid spraying during hot, sunny days as it can burn the leaves.',
        'solution2_hi':
            'यदि समस्या बनी रहती है, तो शाम को wettable sulfur का छिड़काव करें। गर्म, धूप वाले दिनों में छिड़काव न करें क्योंकि इससे पत्तियां जल सकती हैं।',
        'solution2_te':
            'సమస్య కొనసాగితే, సాయంకాలంలో చేపట్టిన సల్ఫర్‌ను చిందించండి. వేడి, సూర్యుడు రోజుల్లో చిందించవద్దు ఎందుకంటే ఇది ఆకులను కాలిచేస్తుంది.',
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
      },
    };

    return diseaseData[disease] ??
        {
          'name_en': 'Unknown Disease',
          'name_hi': 'अज्ञात रोग',
          'name_te': 'తెలియని రోగం',
          'what_is_en': 'Information not available for this disease.',
          'what_is_hi': 'इस रोग के लिए जानकारी उपलब्ध नहीं है।',
          'what_is_te': 'ఈ రోగం కోసం సమాచారం లేదు.',
        };
  }

  String _getLocalizedText(String key, String lang) {
    final texts = {
      'resultTitle': {
        'English': 'Detection Results',
        'Hindi': 'पहचान परिणाम',
        'Telugu': 'గుర్తింపు ఫలితాలు',
      },
      'error': {'English': 'Error', 'Hindi': 'त्रुटि', 'Telugu': 'లోపం'},
      'errorMessage': {
        'English': 'Image classification failed. Please go back and try again.',
        'Hindi': 'छवि वर्गीकरण विफल रहा। कृपया वापस जाएं और पुनः प्रयास करें।',
        'Telugu':
            'చిత్ర వర్గీకరణ విఫలమైంది. దయచేసి తిరిగి వెళ్లి మళ్లీ ప్రయత్నించండి.',
      },
      'scanAgain': {
        'English': 'Scan Again',
        'Hindi': 'फिर से स्कैन करें',
        'Telugu': 'మళ్లీ స్కాన్ చేయండి',
      },
      'home': {'English': 'Home', 'Hindi': 'होम', 'Telugu': 'హోమ్'},
      'whatIs': {
        'English': 'What is it?',
        'Hindi': 'यह क्या है?',
        'Telugu': 'ఇది ఏమిటి?',
      },
      'cause': {
        'English': 'Why it happens',
        'Hindi': 'यह क्यों होता है',
        'Telugu': 'ఇది ఎందుకు జరుగుతుంది',
      },
      'prevention': {
        'English': 'How to prevent it',
        'Hindi': 'इसे कैसे रोकें',
        'Telugu': 'దీనిని ఎలా నివారించాలి',
      },
      'solution': {
        'English': 'How to fix it',
        'Hindi': 'इसे कैसे ठीक करें',
        'Telugu': 'దీనిని ఎలా సరిచేయాలి',
      },
    };

    return texts[key]?[lang] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    if (diseaseName == 'Error') {
      return Scaffold(
        appBar: AppBar(title: Text(_getLocalizedText('error', language))),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              _getLocalizedText('errorMessage', language),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    final diseaseInfo = _getDiseaseInfo(diseaseName);
    final isEnglish = language == 'English';
    final isHindi = language == 'Hindi';
    final isHealthy = diseaseName == 'Healthy';

    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedText('resultTitle', language)),
        backgroundColor: isHealthy ? Colors.green : Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Go back to camera screen
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(File(imagePath), fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Conditional Display based on Healthy or Disease
            if (isHealthy) ...[
              // For Healthy Plant - Show without title
              Center(
                child: Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 3,
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isEnglish
                              ? (diseaseInfo['name_en'] ?? 'Healthy')
                              : isHindi
                              ? (diseaseInfo['name_hi'] ?? 'स्वस्थ पौधा')
                              : (diseaseInfo['name_te'] ?? 'ఆరోగ్యకరమైన మొక్క'),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isEnglish
                              ? (diseaseInfo['what_is_en'] ?? '')
                              : isHindi
                              ? (diseaseInfo['what_is_hi'] ?? '')
                              : (diseaseInfo['what_is_te'] ?? ''),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Confidence Card for Healthy
              _buildInfoCard(
                title: isEnglish
                    ? 'Confidence'
                    : isHindi
                    ? 'विश्वास'
                    : 'విశ్వాసం',
                content: '${(confidence * 100).toStringAsFixed(1)}%',
                icon: Icons.analytics,
                color: Colors.blue,
              ),
            ] else ...[
              // For Diseased Plant - Show with title
              _buildInfoCard(
                title: isEnglish
                    ? 'Disease Name'
                    : isHindi
                    ? 'रोग का नाम'
                    : 'రోగం పేరు',
                content: isEnglish
                    ? (diseaseInfo['name_en'] ?? '')
                    : isHindi
                    ? (diseaseInfo['name_hi'] ?? '')
                    : (diseaseInfo['name_te'] ?? ''),
                icon: Icons.bug_report,
                color: Colors.red,
              ),
              // Confidence Card
              _buildInfoCard(
                title: isEnglish
                    ? 'Confidence'
                    : isHindi
                    ? 'विश्वास'
                    : 'విశ్వాసం',
                content: '${(confidence * 100).toStringAsFixed(1)}%',
                icon: Icons.analytics,
                color: Colors.blue,
              ),
              // What is it Card
              _buildExpandableCard(
                title: _getLocalizedText('whatIs', language),
                content: isEnglish
                    ? (diseaseInfo['what_is_en'] ?? '')
                    : isHindi
                    ? (diseaseInfo['what_is_hi'] ?? '')
                    : (diseaseInfo['what_is_te'] ?? ''),
                icon: Icons.info,
                color: Colors.teal,
              ),
              // Cause, Prevention, Solution cards for diseased plants
              _buildExpandableCard(
                title: _getLocalizedText('cause', language),
                content: isEnglish
                    ? (diseaseInfo['cause_en'] ?? '')
                    : isHindi
                    ? (diseaseInfo['cause_hi'] ?? '')
                    : (diseaseInfo['cause_te'] ?? ''),
                icon: Icons.warning,
                color: Colors.orange,
              ),
              _buildPreventionCard(diseaseInfo, isEnglish, isHindi, language),
              _buildSolutionCard(diseaseInfo, isEnglish, isHindi, language),
            ],

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to camera screen again
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(language: language),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: Text(
                    _getLocalizedText('scanAgain', language),
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // ✅ CRITICAL FIX: Return result data to HomeScreen
                    final resultData = {
                      'diseaseName': diseaseName,
                      'confidence': confidence,
                      'imagePath': imagePath,
                      'timestamp': DateTime.now().toIso8601String(),
                    };

                    print('=== RETURNING RESULT TO HOME ===');
                    print('Result data: $resultData');

                    // Pop back with the result data
                    Navigator.pop(context, resultData);
                  },
                  icon: const Icon(Icons.home, color: Colors.white),
                  label: Text(
                    _getLocalizedText('home', language),
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 14, height: 1.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildPreventionCard(
    Map<String, String> diseaseInfo,
    bool isEnglish,
    bool isHindi,
    String language,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shield, color: Colors.purple, size: 24),
                const SizedBox(width: 10),
                Text(
                  _getLocalizedText('prevention', language),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Prevention 1
            _buildBulletPoint(
              title: isEnglish
                  ? (diseaseInfo['prevention1_title_en'] ?? '')
                  : isHindi
                  ? (diseaseInfo['prevention1_title_hi'] ?? '')
                  : (diseaseInfo['prevention1_title_te'] ?? ''),
              content: isEnglish
                  ? (diseaseInfo['prevention1_en'] ?? '')
                  : isHindi
                  ? (diseaseInfo['prevention1_hi'] ?? '')
                  : (diseaseInfo['prevention1_te'] ?? ''),
            ),
            const SizedBox(height: 12),
            // Prevention 2
            _buildBulletPoint(
              title: isEnglish
                  ? (diseaseInfo['prevention2_title_en'] ?? '')
                  : isHindi
                  ? (diseaseInfo['prevention2_title_hi'] ?? '')
                  : (diseaseInfo['prevention2_title_te'] ?? ''),
              content: isEnglish
                  ? (diseaseInfo['prevention2_en'] ?? '')
                  : isHindi
                  ? (diseaseInfo['prevention2_hi'] ?? '')
                  : (diseaseInfo['prevention2_te'] ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionCard(
    Map<String, String> diseaseInfo,
    bool isEnglish,
    bool isHindi,
    String language,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.medical_services,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  _getLocalizedText('solution', language),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Solution 1
            _buildBulletPoint(
              title: isEnglish
                  ? (diseaseInfo['solution1_title_en'] ?? '')
                  : isHindi
                  ? (diseaseInfo['solution1_title_hi'] ?? '')
                  : (diseaseInfo['solution1_title_te'] ?? ''),
              content: isEnglish
                  ? (diseaseInfo['solution1_en'] ?? '')
                  : isHindi
                  ? (diseaseInfo['solution1_hi'] ?? '')
                  : (diseaseInfo['solution1_te'] ?? ''),
            ),
            const SizedBox(height: 12),
            // Solution 2
            _buildBulletPoint(
              title: isEnglish
                  ? (diseaseInfo['solution2_title_en'] ?? '')
                  : isHindi
                  ? (diseaseInfo['solution2_title_hi'] ?? '')
                  : (diseaseInfo['solution2_title_te'] ?? ''),
              content: isEnglish
                  ? (diseaseInfo['solution2_en'] ?? '')
                  : isHindi
                  ? (diseaseInfo['solution2_hi'] ?? '')
                  : (diseaseInfo['solution2_te'] ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '•',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
