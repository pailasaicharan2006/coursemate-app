/// Central mapping from Course ID to locally stored verified course images.
/// 
/// Every course in CourseMate (all 44 courses) is mapped here to its dedicated
/// local thumbnail asset stored in assets/images/courses/.
class CourseImageMapping {
  static const Map<String, String> courseThumbnailAssets = {
    // 1. IBM Data Science Professional Certificate
    '4dcd49fd-7589-4d8c-a37d-ee04a8835450':
        'assets/images/courses/ibm_data_science.png',

    // 2. Google Data Analytics Professional Certificate
    'ecfe386e-524c-4705-a281-404dc926e9a6':
        'assets/images/courses/google_data_analytics.png',

    // 3. Google UX Design Professional Certificate
    '51d46f05-6065-442a-876c-194876381df4':
        'assets/images/courses/google_ux_design.png',

    // 4. Machine Learning Specialization
    'df1dedb2-bfc5-4958-ae4e-2cdff7a1e56b':
        'assets/images/courses/machine_learning_specialization.png',

    // 5. Deep Learning Specialization
    '627bddfa-7208-4322-af30-0fb4e9a121af':
        'assets/images/courses/deep_learning_specialization.png',

    // 6. Python for Everybody Specialization
    '58cc5f41-ed4a-4dfa-b96b-f929fe21897a':
        'assets/images/courses/python_for_everybody.png',

    // 7. Natural Language Processing Specialization
    'd49551f9-b36d-484d-8c01-cfa56a76a4b5':
        'assets/images/courses/nlp_specialization.png',

    // 8. AI For Everyone
    '954b27ad-3bf5-42e6-ac3b-6c4ce62eaba0':
        'assets/images/courses/ai_for_everyone.png',

    // 9. Google Cloud Digital Leader
    '4fef7b3c-eda3-4e85-b70a-f58bc119ad84':
        'assets/images/courses/google_cloud_digital_leader.png',

    // 10. TensorFlow Developer Certificate
    'a147f066-3de8-4698-bc2c-a866d63e22ac':
        'assets/images/courses/tensorflow_developer_certificate.png',

    // 11. Introduction to Artificial Intelligence (AI)
    '0ef59335-3bd1-4314-abbc-0b49d84e3eb9':
        'assets/images/courses/intro_to_ai_ibm.jpg',

    // 12. Automate the Boring Stuff with Python
    '184299c1-1188-498f-ac18-78a093f4ca3b':
        'assets/images/courses/automate_boring_stuff.webp',

    // 13. Statistics with Python Specialization
    '817cc4f6-a8ad-40f9-9291-6a831a089f4f':
        'assets/images/courses/statistics_with_python.png',

    // --- Batch 2 ---

    // 14. Google Cybersecurity Professional Certificate
    '4aadb278-d6c0-44ef-b06b-371179ae5255':
        'assets/images/courses/google_cybersecurity.png',

    // 15. Prompt Engineering for Developers
    '5efb247a-5ca8-42c2-b98a-f4198ef324d4':
        'assets/images/courses/prompt_engineering_dlai.png',

    // 16. Cracking the Coding Interview — Data Structures & Algorithms
    'a16fcf7a-52b7-46d4-8873-c89d62fb14e2':
        'assets/images/courses/cracking_the_coding_interview.jpg',

    // 17. LeetCode Patterns: From Beginner to Advanced
    '87148df2-6a68-493e-938e-e53229e7a11e':
        'assets/images/courses/leetcode_patterns.jpg',

    // 18. Practical Machine Learning with Python
    'e6e14acd-3684-4600-95ee-cac7d0c1f202':
        'assets/images/courses/practical_machine_learning.jpg',

    // 19. Version Control with Git
    '1e6107a3-bb1f-4e9e-91b5-04dc12d3cefb':
        'assets/images/courses/version_control_git_atlassian.jpg',

    // 20. Data Science: R Basics
    '03a8427d-4edc-4c63-b6a4-c249ff2c3aa3':
        'assets/images/courses/harvard_data_science_r_basics.jpg',

    // 21. Docker and Kubernetes: The Complete Guide
    'cb8a2ec8-ec3d-4e4c-9413-c871fe55a89f':
        'assets/images/courses/docker_and_kubernetes.jpg',

    // 22. Complete Python Bootcamp: Go from Zero to Hero
    '48ae307f-0d70-4a45-8470-c4446cfc0c85':
        'assets/images/courses/complete_python_bootcamp.jpg',

    // 23. The Complete Flutter Development Bootcamp with Dart
    '447069f9-5e72-4e87-a7a7-5d90b3ddfa3b':
        'assets/images/courses/flutter_bootcamp_angela_yu.jpg',

    // --- Batch 3 ---

    // 24. Android Development for Beginners
    '986cc7d3-774f-4c96-b4c2-44d8ea320502':
        'assets/images/courses/android_basics_udacity.jpg',

    // 25. Flutter & Firebase: Build a Complete App for iOS & Android
    'b11bc701-e5d9-4861-a0f2-f44240cb77e3':
        'assets/images/courses/flutter_firebase_bizzotto.png',

    // 26. Git and GitHub - The Complete Git & GitHub Course
    'b924c871-6692-49e2-8c06-f53b83373b5d':
        'assets/images/courses/git_github_practical_guide.jpg',

    // 27. Java Programming Masterclass
    '3933267d-3633-4bf8-93b7-388f8cab82bc':
        'assets/images/courses/java_masterclass_buchalka.jpg',

    // 28. Microsoft Power BI Desktop for Business Intelligence
    'bd5725a0-73ec-44e6-95e7-b65cd79a6fba':
        'assets/images/courses/power_bi_desktop_maven.jpg',

    // 29. Python for Data Science and Machine Learning Bootcamp
    '49474974-9ad9-4f2c-8c6f-a1c9dd745668':
        'assets/images/courses/python_data_science_bootcamp.jpg',

    // 30. React - The Complete Guide 2024
    'de9c81ec-ad94-470e-a64d-3059806c9caa':
        'assets/images/courses/react_complete_guide_max.jpg',

    // 31. React Native - The Practical Guide 2024
    '02b489ac-61f4-4c60-84bc-bdd6dd08787f':
        'assets/images/courses/react_native_guide_max.jpg',

    // 32. SQL and PostgreSQL: The Complete Developer's Guide
    'f11ebfec-371b-48eb-8046-7045cb9b2a56':
        'assets/images/courses/sql_postgresql_grider.jpg',

    // 33. Tableau 2024 A-Z: Hands-On Tableau Training
    '868e8bb6-12d4-4068-8a01-5f4c6d3ce4ee':
        'assets/images/courses/tableau_hands_on_eremenko.jpg',

    // 34. The Web Developer Bootcamp 2024
    '2a5c40ac-affb-4c5f-ab04-f20215c31298':
        'assets/images/courses/web_developer_bootcamp_colt.jpg',

    // --- Batch 4 (Final 10 Courses) ---

    // 35. AI Ethics
    '6fc53725-32b9-49ce-988f-8576514ebdf7':
        'assets/images/courses/ai_ethics_harvard.webp',

    // 36. Applied Data Science with Python Specialization
    'f3574c95-a6fa-420d-98f6-2d247a090f1f':
        'assets/images/courses/applied_data_science_python_umich.jpg',

    // 37. AWS Cloud Practitioner Essentials
    '909cf35c-196c-4713-be80-867a9288561d':
        'assets/images/courses/aws_cloud_practitioner_essentials.jpg',

    // 38. Elements of AI
    'fe803939-9b62-4259-939f-857add93635b':
        'assets/images/courses/elements_of_ai.png',

    // 39. Full Stack Open
    '0d111478-8cc3-4926-85df-869b77b565df':
        'assets/images/courses/full_stack_open.jpg',

    // 40. Intro to SQL: Querying and Managing Data
    '75e3c8c7-d9cd-4a6e-915d-4cc7fca94fb0':
        'assets/images/courses/intro_to_sql_khan.jpg',

    // 41. Introduction to Cybersecurity
    '4177487b-e6d2-4f7c-9ce9-b5cd1447d6f2':
        'assets/images/courses/cisco_intro_to_cybersecurity.png',

    // 42. Khan Academy Statistics & Probability
    'cdf1d3ee-b828-456f-ad18-e272b76be7f5':
        'assets/images/courses/statistics_probability_khan.jpg',

    // 43. The Complete JavaScript Course 2024: From Zero to Expert!
    'fe75510d-81c3-4df0-84a1-03e566514ad6':
        'assets/images/courses/complete_javascript_jonas.jpg',

    // 44. UI Design Fundamentals
    'ba5b7b2a-0997-41f3-8cb9-959546f55900':
        'assets/images/courses/ui_design_fundamentals_scrimba.jpg',
  };

  /// Returns the verified local image asset path for [courseId] if available.
  static String? getAssetForCourse(String? courseId) {
    if (courseId == null) return null;
    return courseThumbnailAssets[courseId];
  }

  /// Whether [courseId] has a verified local thumbnail asset.
  static bool hasThumbnail(String? courseId) {
    if (courseId == null) return false;
    return courseThumbnailAssets.containsKey(courseId);
  }
}
