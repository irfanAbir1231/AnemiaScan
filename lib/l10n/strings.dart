import 'app_language.dart';

/// All app copy, one language at a time (see AppLocale). Every getter reads
/// the current language fresh — no caching — so screens just need to
/// rebuild (which they do automatically: AnemiaScanApp listens to
/// AppLocale.language and rebuilds the whole tree on toggle).
class S {
  S._();
  static bool get _bn => AppLocale.isBn;

  // Home
  static String get appName => 'AnemiaScan';
  static String get tagline =>
      _bn ? 'কমিউনিটি স্ক্রিনিং সহায়তা' : 'Community screening aid';
  static String get offline => _bn ? 'অফলাইন' : 'Offline';
  static String get homeHeadline => _bn
      ? 'ফোনের ক্যামেরা দিয়ে রক্তস্বল্পতা ও নবজাতকের জন্ডিস পরীক্ষা করুন।'
      : 'Check for anemia and newborn jaundice with the phone camera.';
  static String get screenAnemiaTitle =>
      _bn ? 'রক্তস্বল্পতা পরীক্ষা করুন' : 'Screen for Anemia';
  static String get screenAnemiaDesc => _bn
      ? 'চোখের ভেতরের নিচের পাতার ছবি · ৩০ সেকেন্ড'
      : 'Photo of the inner lower eyelid · 30 seconds';
  static String get screenJaundiceTitle =>
      _bn ? 'জন্ডিস পরীক্ষা করুন' : 'Screen for Jaundice';
  static String get screenJaundiceDesc => _bn
      ? 'নবজাতকের বুক বা নাকের ছবি · ৩০ সেকেন্ড'
      : "Photo of the newborn's chest or nose · 30 seconds";
  static String get pastScreenings =>
      _bn ? 'আগের পরীক্ষার ফলাফল' : 'Past screenings';
  static String savedOnPhone(int n) =>
      _bn ? '$n টি এই ফোনে সংরক্ষিত আছে' : '$n saved on this phone';
  static String get trySamples =>
      _bn ? 'নমুনা ছবি দেখুন (ডেমোর জন্য)' : 'Try sample photos (for demos)';
  static String get homeDisclaimer => _bn
      ? 'অ্যানিমিয়াস্ক্যান একটি স্ক্রিনিং সহায়ক টুল। এটি রোগ নির্ণয় করে না।'
      : 'AnemiaScan is a screening aid. It does not give a diagnosis.';

  // Onboarding
  static String get onboardingSkip => _bn ? 'এড়িয়ে যান' : 'Skip';
  static String get onboardingNext => _bn ? 'পরবর্তী' : 'Next';
  static String get onboardingStart => _bn ? 'শুরু করুন' : 'Get started';
  static String get onboardingWelcome => _bn
      ? 'সহজ স্ক্রিনিং, পরিষ্কার পরবর্তী পদক্ষেপ'
      : 'Simple screening, clear next steps';
  static String get onboardingWelcomeBody => _bn
      ? 'রক্তস্বল্পতা বা নবজাতকের জন্ডিস পরীক্ষার ধরন বেছে নিন। সব বিশ্লেষণ আপনার ফোনেই হয়।'
      : 'Choose an anemia or newborn jaundice screening. Every analysis runs privately on your phone.';
  static String get onboardingCapture =>
      _bn ? 'ছবিটি সঠিকভাবে তুলুন' : 'Capture the right area';
  static String get onboardingCaptureBody => _bn
      ? 'দিনের আলো বা ভালো আলো ব্যবহার করুন, গাইডের মধ্যে অংশটি রাখুন এবং ফোন স্থির রাখুন।'
      : 'Use daylight or good lighting, place the target inside the guide, and hold the phone steady.';
  static String get onboardingResult =>
      _bn ? 'ফল বুঝুন ও পদক্ষেপ নিন' : 'Understand and act';
  static String get onboardingResultBody => _bn
      ? 'ঝুঁকির মাত্রা, আনুমানিক মান এবং কখন স্বাস্থ্যকর্মীর পরামর্শ নিতে হবে তা দেখুন।'
      : 'See the risk level, estimated value, and clear guidance on when to seek clinical care.';

  // Nav
  static String get navHome => _bn ? 'হোম' : 'Home';
  static String get navHistory => _bn ? 'ইতিহাস' : 'History';
  static String get navHelp => _bn ? 'সহায়তা' : 'Help';
  static String get helpComingSoon =>
      _bn ? 'সহায়তা — শীঘ্রই আসছে' : 'Help — coming soon';

  // Capture
  static String get modeAnemia => _bn ? 'রক্তস্বল্পতা' : 'Anemia';
  static String get modeJaundice => _bn ? 'জন্ডিস' : 'Jaundice';
  static String get goodLighting => _bn ? 'ভালো আলো' : 'Good lighting';
  static String get instructionAnemia => _bn
      ? 'আলতো করে নিচের চোখের পাতাটি টেনে নামান এবং গাইডের মধ্যে আনুন।'
      : 'Gently pull the lower eyelid down and fill the guide.';
  static String get instructionJaundice => _bn
      ? 'দিনের আলোয় ফ্রেমটি শিশুর বুকের উপর সমতলভাবে ধরুন।'
      : "Hold the frame flat on the baby's chest, in daylight.";
  static String get torch => _bn ? 'ফ্ল্যাশ' : 'Torch';
  static String get upload => _bn ? 'আপলোড' : 'Upload';
  static String get noCameraFound => _bn
      ? 'এই ডিভাইসে কোনো ক্যামেরা পাওয়া যায়নি।'
      : 'No camera found on this device.';
  static String get cameraPermissionNeeded => _bn
      ? 'পরীক্ষা করতে ক্যামেরার অনুমতি প্রয়োজন। সিস্টেম সেটিংসে এটি চালু করুন।'
      : 'Camera permission is needed to screen. Enable it in system settings.';
  static String cameraStartFailed(String detail) => _bn
      ? 'ক্যামেরা চালু করা যায়নি।\n$detail'
      : 'Could not start the camera.\n$detail';
  static String captureFailed(String e) =>
      _bn ? 'ছবি তোলা ব্যর্থ হয়েছে: $e' : 'Capture failed: $e';
  static String galleryFailed(String e) =>
      _bn ? 'গ্যালারি খোলা যায়নি: $e' : 'Could not open gallery: $e';
  static String get innerEyelid => _bn ? 'ভেতরের চোখের পাতা' : 'inner eyelid';
  static String get skinPatch => _bn ? 'ত্বকের অংশ' : 'skin patch';

  // Analyzing
  static String get capturedImage => _bn ? 'তোলা ছবি' : 'Captured image';
  static String get onDeviceAnalysis =>
      _bn ? 'অন-ডিভাইস বিশ্লেষণ' : 'on-device analysis';
  static String get analyzingImage =>
      _bn ? 'ছবি বিশ্লেষণ করা হচ্ছে…' : 'Analyzing image…';
  static String get runsOnPhone => _bn
      ? 'এই ফোনেই চলে। ইন্টারনেট বা ডেটার দরকার নেই।'
      : 'Runs on this phone. No internet or data needed.';
  static String get stepQuality =>
      _bn ? 'ছবির মান পরীক্ষা করা হয়েছে' : 'Image quality checked';
  static String get stepColor =>
      _bn ? 'রঙের মান পড়া হচ্ছে' : 'Reading colour values';
  static String get stepRisk =>
      _bn ? 'ঝুঁকির মাত্রা নির্ণয় করা হচ্ছে' : 'Estimating risk level';
  static String get cancel => _bn ? 'বাতিল' : 'Cancel';
  static String get analysisFailedTitle =>
      _bn ? 'এই ছবিটি বিশ্লেষণ করা যায়নি' : 'Could not analyze this image';
  static String get photoTooDark => _bn
      ? 'ছবিটি খুব অন্ধকার। ভালো আলোতে লক্ষ্যস্থলটি গাইডের মধ্যে রেখে আবার তুলুন।'
      : 'The photo is too dark. Retake it in good light with the target inside the guide.';
  static String get photoTooBright => _bn
      ? 'ছবিটি অতিরিক্ত উজ্জ্বল। ঝলক এড়িয়ে আবার তুলুন।'
      : 'The photo is overexposed. Avoid glare and retake it.';
  static String get photoNotClear => _bn
      ? 'ছবিতে যথেষ্ট স্পষ্টতা নেই। ফোন স্থির রেখে ফোকাস করে আবার তুলুন।'
      : 'The photo is not clear enough. Hold still, focus, and retake it.';
  static String get eyeNotDetected => _bn
      ? 'গাইডের মধ্যে চোখের মণি, সাদা অংশ ও নিচের পাতার গোলাপি অংশ স্পষ্ট দেখা যায়নি।'
      : 'The guide must clearly contain the pupil, white of the eye, and exposed pink lower eyelid.';
  static String get skinNotDetected => _bn
      ? 'গাইডের মধ্যে যথেষ্ট ত্বক পাওয়া যায়নি। বুক বা নাকের ত্বক দিয়ে ফ্রেমটি পূরণ করুন।'
      : 'Not enough skin was found inside the guide. Fill it with skin from the chest or nose.';
  static String get strongColorCast => _bn
      ? 'আলোর রঙ ছবিটিকে বিকৃত করেছে। সাদা বা প্রাকৃতিক দিনের আলোতে আবার তুলুন।'
      : 'The lighting has a strong colour cast. Retake in white or natural daylight.';

  // Result
  static String screeningTitle(bool jaundice) => jaundice
      ? (_bn ? 'জন্ডিস পরীক্ষা' : 'Jaundice screening')
      : (_bn ? 'রক্তস্বল্পতা পরীক্ষা' : 'Anemia screening');
  static String get justNowSaved =>
      _bn ? 'এইমাত্র · সংরক্ষিত' : 'Just now · saved';
  static String get low => _bn ? 'কম' : 'Low';
  static String get moderate => _bn ? 'মাঝারি' : 'Moderate';
  static String get high => _bn ? 'বেশি' : 'High';
  static String get whatThisMeans => _bn ? 'এর অর্থ কী' : 'What this means';
  static String get nextStep => _bn ? 'পরবর্তী পদক্ষেপ' : 'NEXT STEP';
  static String get screened => _bn ? 'পরীক্ষা করা হয়েছে' : 'Screened';
  static String get savedToHistory => _bn
      ? 'এই ফোনের ইতিহাসে সংরক্ষিত হয়েছে'
      : 'Saved to history on this phone';
  static String get resultDisclaimer => _bn
      ? 'স্ক্রিনিং সহায়ক, রোগ নির্ণয় নয়। আস্থা স্কোরটি ছবির মান বোঝায়। হিমোগ্লোবিন বা বিলিরুবিন শুধুমাত্র রক্ত পরীক্ষায় নিশ্চিত হয়।'
      : 'Screening aid, not a diagnosis. The confidence score describes the image analysis. Only a blood test can measure haemoglobin or bilirubin.';
  static String get done => _bn ? 'সম্পন্ন' : 'Done';
  static String get screenAgain => _bn ? 'আবার পরীক্ষা করুন' : 'Screen again';
  static String get analysisConfidence =>
      _bn ? 'বিশ্লেষণের আস্থা' : 'Analysis confidence';
  static String get confidenceMeaning => _bn
      ? 'ছবির মান ও রঙের সীমা থেকে দূরত্ব বোঝায়—রোগ থাকার সম্ভাবনা নয়।'
      : 'Based on image quality and distance from a colour threshold—not the probability of disease.';
  static String colourSignal(bool jaundice) => jaundice
      ? (_bn ? 'হলুদ রঙের সংকেত (Lab b*)' : 'Yellow colour signal (Lab b*)')
      : (_bn ? 'লাল রঙের সংকেত (Lab a*)' : 'Red colour signal (Lab a*)');
  static String get notRecorded => _bn ? 'রেকর্ড করা হয়নি' : 'Not recorded';

  // History
  static String get historyTitle => _bn ? 'ইতিহাস' : 'History';
  static String get historySubtitle =>
      _bn ? 'পূর্বের পরীক্ষাগুলো' : 'Past screenings';
  static String get filterAll => _bn ? 'সব' : 'All';
  static String get recent => _bn ? 'সাম্প্রতিক' : 'RECENT';
  static String get noScreeningsYet =>
      _bn ? 'এখনো কোনো পরীক্ষা নেই' : 'No screenings yet';
  static String get noScreeningsSub => _bn
      ? 'আপনার সংরক্ষিত পরীক্ষাগুলো এখানে দেখা যাবে, শুধুমাত্র এই ফোনে জমা থাকবে।'
      : 'Screenings you save will show up here, stored only on this phone.';
  static String get screeningsCountLabel => _bn ? 'মোট পরীক্ষা' : 'screenings';

  // Samples
  static String get samplePhotosTitle => _bn ? 'নমুনা ছবি' : 'Sample photos';
  static String get samplePhotosSubtitle => _bn
      ? 'সরাসরি বিষয় ছাড়া ডেমো দেখাতে'
      : 'For demoing without a live subject';
  static String get sampleInfo => _bn
      ? 'সবগুলো বাস্তব রেফারেন্স ছবি — রক্তস্বল্পতার জন্য ক্লিনিক্যাল Hb-লেবেলযুক্ত কনজাংটিভা ছবি '
            '(CP-AnemiC ডেটাসেট, ঘানা), জন্ডিসের জন্য বাস্তব নবজাতক/প্রাপ্তবয়স্ক কেস। উৎসের জন্য '
            'calibration/README.md দেখুন।'
      : 'All real reference photos — clinical Hb-labeled conjunctiva images (CP-AnemiC dataset, '
            'Ghana) for anemia, real newborn/adult jaundice cases for jaundice. See '
            'calibration/README.md for sources.';
  static String get realReferencePhoto =>
      _bn ? 'বাস্তব রেফারেন্স ছবি' : 'Real reference photo';

  /// e.g. "Anemia — Low" / "রক্তস্বল্পতা — কম"
  static String sampleLabel({
    required bool jaundice,
    required String riskWord,
  }) {
    final mode = jaundice ? modeJaundice : modeAnemia;
    return '$mode — $riskWord';
  }
}
