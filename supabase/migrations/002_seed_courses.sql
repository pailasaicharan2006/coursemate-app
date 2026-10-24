-- ============================================
-- CourseMate V2 — Course Seed Data (50+ courses)
-- Run AFTER 001_initial_schema.sql
-- ============================================

INSERT INTO public.courses (
  title, provider, description, category, difficulty, duration_hours,
  rating, review_count, skills, interests, prerequisites, learning_outcomes,
  curriculum, course_url, image_url, is_free
) VALUES

-- ============================================
-- DATA SCIENCE
-- ============================================
(
  'Python for Data Science and Machine Learning Bootcamp',
  'Udemy / Jose Portilla',
  'Learn how to use Python for data science and machine learning. Master NumPy, Pandas, Matplotlib, Seaborn, Scikit-Learn, and more. Build real-world projects including a recommendation system, classification models, and data visualizations.',
  'Data Science',
  'Beginner',
  25.0,
  4.6,
  45000,
  ARRAY['Python', 'Data Analysis', 'Machine Learning', 'Statistics'],
  ARRAY['Data Science', 'Machine Learning', 'Programming'],
  ARRAY[],
  ARRAY['Master Python for data science', 'Use NumPy and Pandas for data manipulation', 'Create visualizations with Matplotlib and Seaborn', 'Build ML models with Scikit-Learn', 'Implement Linear and Logistic Regression'],
  ARRAY['Python Crash Course', 'NumPy', 'Pandas', 'Matplotlib & Seaborn', 'Scikit-Learn', 'Linear Regression', 'Logistic Regression', 'K-Nearest Neighbours', 'Decision Trees', 'Random Forests', 'Support Vector Machines', 'K-Means Clustering', 'Principal Component Analysis'],
  'https://www.udemy.com/course/python-for-data-science-and-machine-learning-bootcamp/',
  'https://picsum.photos/seed/ds1/800/400',
  false
),

(
  'IBM Data Science Professional Certificate',
  'Coursera / IBM',
  'Kickstart your career in data science with IBM. Learn Python, SQL, data analysis, visualization, machine learning, and build a portfolio of real-world projects. This 10-course program prepares you for a career as a data scientist.',
  'Data Science',
  'Beginner',
  40.0,
  4.5,
  120000,
  ARRAY['Python', 'SQL', 'Data Analysis', 'Machine Learning', 'Statistics'],
  ARRAY['Data Science', 'Data Analytics', 'Machine Learning'],
  ARRAY[],
  ARRAY['Apply data science methodology', 'Work with Python and SQL', 'Collect and wrangle data', 'Conduct exploratory data analysis', 'Build machine learning models', 'Create data visualizations'],
  ARRAY['What is Data Science?', 'Tools for Data Science', 'Data Science Methodology', 'Python for Data Science', 'Databases and SQL', 'Data Analysis with Python', 'Data Visualization', 'Machine Learning with Python', 'Applied Data Science Capstone', 'Data Science Project'],
  'https://www.coursera.org/professional-certificates/ibm-data-science',
  'https://picsum.photos/seed/ds2/800/400',
  false
),

(
  'Data Science: R Basics',
  'edX / Harvard University',
  'Start learning R programming for data science from Harvard University. This is the first course in the HarvardX Data Science program. Topics include R syntax, data types, vectors, sorting, plots, probability, and inference.',
  'Data Science',
  'Beginner',
  8.0,
  4.4,
  85000,
  ARRAY['Statistics', 'Data Analysis'],
  ARRAY['Data Science', 'Data Analytics'],
  ARRAY[],
  ARRAY['Learn R programming basics', 'Work with data in R', 'Create statistical summaries', 'Build basic data visualizations'],
  ARRAY['R Basics', 'Vectors', 'Sorting', 'Vector Arithmetic', 'Indexing', 'Data Frames', 'Basic Plots', 'Programming Basics'],
  'https://www.edx.org/learn/r-programming/harvard-university-data-science-r-basics',
  'https://picsum.photos/seed/ds3/800/400',
  true
),

(
  'Google Data Analytics Professional Certificate',
  'Coursera / Google',
  'Get the skills you need to qualify for an entry-level data analytics job. Learn from Google employees whose work includes data analytics. You will learn key analytical skills including data cleaning, analysis, and visualization, and use tools like spreadsheets, SQL, R, and Tableau.',
  'Data Analytics',
  'Beginner',
  42.0,
  4.7,
  200000,
  ARRAY['SQL', 'Data Analysis', 'Statistics'],
  ARRAY['Data Analytics', 'Data Science'],
  ARRAY[],
  ARRAY['Gain an immersive understanding of data analytics practices', 'Learn to clean and organize data', 'Identify trends and relationships using SQL', 'Create visualizations with Tableau and R'],
  ARRAY['Foundations: Data, Data, Everywhere', 'Ask Questions to Make Data-Driven Decisions', 'Prepare Data for Exploration', 'Process Data from Dirty to Clean', 'Analyze Data to Answer Questions', 'Share Data Through the Art of Visualization', 'Data Analysis with R Programming', 'Capstone: Complete a Case Study'],
  'https://www.coursera.org/professional-certificates/google-data-analytics',
  'https://picsum.photos/seed/da1/800/400',
  false
),

-- ============================================
-- ARTIFICIAL INTELLIGENCE
-- ============================================
(
  'AI For Everyone',
  'Coursera / DeepLearning.AI',
  'AI is not only for engineers. If you want your organization to become better at using AI, this is the course to tell everyone—especially your non-technical colleagues—to take. In this course, you will learn what AI can and cannot do, how to spot opportunities to apply AI in your organization, and how to navigate ethical and societal discussions about AI.',
  'Artificial Intelligence',
  'Beginner',
  6.0,
  4.8,
  350000,
  ARRAY['Machine Learning'],
  ARRAY['Artificial Intelligence', 'Machine Learning'],
  ARRAY[],
  ARRAY['Understand what AI is and can do', 'Identify AI opportunities in business', 'Build an AI strategy', 'Navigate AI ethics and societal impacts'],
  ARRAY['What is AI?', 'Building AI Projects', 'Building AI in Your Company', 'AI and Society'],
  'https://www.coursera.org/learn/ai-for-everyone',
  'https://picsum.photos/seed/ai1/800/400',
  false
),

(
  'Introduction to Artificial Intelligence (AI)',
  'Coursera / IBM',
  'In this course, you will learn what Artificial Intelligence is, explore use cases and applications of AI, understand AI concepts and terms like machine learning, deep learning, and neural networks. You will be exposed to various issues and concerns surrounding AI such as ethics and bias.',
  'Artificial Intelligence',
  'Beginner',
  9.0,
  4.4,
  60000,
  ARRAY['Machine Learning'],
  ARRAY['Artificial Intelligence', 'Data Science'],
  ARRAY[],
  ARRAY['Describe what AI is and when it is applied', 'Explain terms like Machine Learning and Deep Learning', 'Identify use cases for AI', 'Understand AI ethics and bias'],
  ARRAY['What is AI?', 'AI Concepts, Terminology, and Application Areas', 'AI: Issues, Concerns and Ethical Considerations', 'The Future of AI', 'AI in Action (Applications)'],
  'https://www.coursera.org/learn/introduction-to-ai',
  'https://picsum.photos/seed/ai2/800/400',
  false
),

(
  'Elements of AI',
  'University of Helsinki',
  'A free online course for everyone interested in learning what AI is, what is possible (and not possible) with AI, and how it affects our lives. No programming or mathematics required.',
  'Artificial Intelligence',
  'Beginner',
  15.0,
  4.7,
  750000,
  ARRAY['Machine Learning'],
  ARRAY['Artificial Intelligence'],
  ARRAY[],
  ARRAY['Define AI and understand its scope', 'Use machine learning terminology', 'Apply probability-based reasoning', 'Understand AI decision making'],
  ARRAY['What is AI?', 'AI Problem Solving', 'Real World AI', 'Machine Learning', 'Neural Networks', 'Implications of AI'],
  'https://www.elementsofai.com/',
  'https://picsum.photos/seed/ai3/800/400',
  true
),

-- ============================================
-- MACHINE LEARNING
-- ============================================
(
  'Machine Learning Specialization',
  'Coursera / Stanford / Andrew Ng',
  'The Machine Learning Specialization is a foundational online program created in collaboration between DeepLearning.AI and Stanford Online. This beginner-friendly program will teach you the fundamentals of machine learning and how to use these techniques to build real-world AI applications.',
  'Machine Learning',
  'Intermediate',
  35.0,
  4.9,
  180000,
  ARRAY['Python', 'Machine Learning', 'Statistics'],
  ARRAY['Machine Learning', 'Artificial Intelligence', 'Data Science'],
  ARRAY['Python'],
  ARRAY['Build ML models with NumPy and Scikit-Learn', 'Implement supervised learning algorithms', 'Build recommender systems', 'Build decision trees', 'Use unsupervised learning techniques'],
  ARRAY['Supervised Machine Learning', 'Advanced Learning Algorithms', 'Unsupervised Learning & Recommenders & Reinforcement Learning'],
  'https://www.coursera.org/specializations/machine-learning-introduction',
  'https://picsum.photos/seed/ml1/800/400',
  false
),

(
  'Deep Learning Specialization',
  'Coursera / DeepLearning.AI',
  'The Deep Learning Specialization is a foundational program that will help you understand the capabilities, challenges, and consequences of deep learning. You will learn to build and train deep neural networks and identify key architecture parameters.',
  'Machine Learning',
  'Advanced',
  45.0,
  4.8,
  140000,
  ARRAY['Python', 'Machine Learning'],
  ARRAY['Machine Learning', 'Artificial Intelligence'],
  ARRAY['Python', 'Machine Learning'],
  ARRAY['Build and train deep neural networks', 'Implement vectorized neural networks', 'Identify key architecture parameters', 'Apply deep learning to applications including image recognition and NLP'],
  ARRAY['Neural Networks and Deep Learning', 'Improving Deep Neural Networks', 'Structuring Machine Learning Projects', 'Convolutional Neural Networks', 'Sequence Models'],
  'https://www.coursera.org/specializations/deep-learning',
  'https://picsum.photos/seed/ml2/800/400',
  false
),

(
  'Practical Machine Learning with Python',
  'freeCodeCamp',
  'Learn machine learning with Python in this full course for beginners. You will learn the basics of machine learning and how to apply them to real-world problems using Python, Scikit-Learn, and TensorFlow.',
  'Machine Learning',
  'Beginner',
  12.0,
  4.5,
  95000,
  ARRAY['Python', 'Machine Learning', 'Statistics'],
  ARRAY['Machine Learning', 'Data Science', 'Programming'],
  ARRAY['Python'],
  ARRAY['Understand machine learning concepts', 'Use Scikit-Learn for ML', 'Build regression and classification models', 'Evaluate model performance'],
  ARRAY['Introduction to ML', 'Data Preprocessing', 'Linear Regression', 'Logistic Regression', 'Decision Trees', 'Random Forests', 'Model Evaluation'],
  'https://www.youtube.com/watch?v=7eh4d6sabA0',
  'https://picsum.photos/seed/ml3/800/400',
  true
),

-- ============================================
-- WEB DEVELOPMENT
-- ============================================
(
  'The Web Developer Bootcamp 2024',
  'Udemy / Colt Steele',
  'The only course you need to become a full stack web developer. With 67+ hours of instruction, this is the most comprehensive, beginner-friendly web development bootcamp! You will learn HTML, CSS, JavaScript, Node, Express, MongoDB, and more.',
  'Web Development',
  'Beginner',
  67.0,
  4.7,
  280000,
  ARRAY['JavaScript', 'Git'],
  ARRAY['Web Development', 'Programming'],
  ARRAY[],
  ARRAY['Build responsive websites with HTML and CSS', 'Use JavaScript for dynamic content', 'Build full-stack apps with Node and Express', 'Work with databases using MongoDB'],
  ARRAY['HTML Fundamentals', 'CSS Fundamentals', 'Flexbox & Grid', 'JavaScript Basics', 'DOM Manipulation', 'Node.js', 'Express', 'MongoDB', 'REST APIs', 'Authentication', 'Deployment'],
  'https://www.udemy.com/course/the-web-developer-bootcamp/',
  'https://picsum.photos/seed/wd1/800/400',
  false
),

(
  'Full Stack Open',
  'University of Helsinki',
  'This course serves as an introduction to modern web application development with JavaScript. The main focus is on building single page applications with ReactJS that use REST APIs built with Node.js. The course also contains a section on GraphQL, a modern alternative to REST APIs.',
  'Web Development',
  'Intermediate',
  50.0,
  4.8,
  200000,
  ARRAY['JavaScript', 'Git'],
  ARRAY['Web Development', 'Programming'],
  ARRAY['JavaScript'],
  ARRAY['Build full-stack web applications', 'Use React for frontend development', 'Build REST APIs with Node.js', 'Work with databases', 'Implement testing'],
  ARRAY['Introduction to React', 'Communicating with server', 'Programming a server with NodeJS and Express', 'Testing Express servers', 'User administration', 'Advanced state management', 'React router and custom hooks', 'GraphQL', 'TypeScript'],
  'https://fullstackopen.com/',
  'https://picsum.photos/seed/wd2/800/400',
  true
),

(
  'React - The Complete Guide 2024',
  'Udemy / Maximilian Schwarzmüller',
  'Dive in and learn React.js from scratch! Learn Reactjs, Redux, React Routing, Animations, Next.js and way more. This course includes React Hooks, Context API, Redux Toolkit, React Router 6, and Next.js.',
  'Web Development',
  'Intermediate',
  48.0,
  4.8,
  200000,
  ARRAY['JavaScript'],
  ARRAY['Web Development', 'Programming'],
  ARRAY['JavaScript'],
  ARRAY['Build powerful, fast, user-friendly, and reactive web apps', 'Apply for high-paid jobs or work as a freelancer', 'Understand the theory behind React and use it in real projects'],
  ARRAY['Getting Started', 'React Basics', 'React State & Events', 'Rendering Lists & Conditionals', 'Styling Components', 'Debugging', 'React Hooks', 'Context API', 'Redux', 'React Router', 'Authentication', 'Deployment', 'Next.js'],
  'https://www.udemy.com/course/react-the-complete-guide-incl-redux/',
  'https://picsum.photos/seed/wd3/800/400',
  false
),

-- ============================================
-- MOBILE DEVELOPMENT
-- ============================================
(
  'The Complete Flutter Development Bootcamp with Dart',
  'Udemy / Angela Yu',
  'Fully updated for Flutter 3.16 and Dart 3.2! Master Flutter and Dart programming to build iOS and Android apps. Over 28 hours of premium video tutorials and build real-world apps including a weather app, chat app, and more.',
  'Mobile Development',
  'Beginner',
  28.0,
  4.8,
  120000,
  ARRAY['Dart/Flutter', 'Git'],
  ARRAY['Mobile Development', 'Programming'],
  ARRAY[],
  ARRAY['Build iOS and Android apps using Flutter', 'Use Flutter widgets to build UIs', 'Apply the MVC design pattern', 'Use Dart to program Flutter apps', 'Work with APIs and JSON data'],
  ARRAY['Introduction to Flutter', 'Dart Programming', 'Stateless Widgets', 'Stateful Widgets', 'State Management', 'Navigation', 'HTTP Requests', 'Firebase', 'Authentication', 'Deployment'],
  'https://www.udemy.com/course/flutter-bootcamp-with-dart/',
  'https://picsum.photos/seed/mob1/800/400',
  false
),

(
  'Android Development for Beginners',
  'Google / Udacity',
  'Learn the fundamentals of Android development with Kotlin. By the end of this course, you will be able to build a simple Android app. This course is designed for students with no experience with mobile development.',
  'Mobile Development',
  'Beginner',
  20.0,
  4.5,
  85000,
  ARRAY['Git'],
  ARRAY['Mobile Development', 'Programming'],
  ARRAY[],
  ARRAY['Understand Android app architecture', 'Build Android UIs with Kotlin', 'Work with Android Studio', 'Implement navigation in Android apps'],
  ARRAY['Introduction to Android', 'Building Layouts', 'App Navigation', 'Activity Lifecycle', 'RecyclerView', 'Connecting to the Internet', 'Behind the Scenes', 'Persistence', 'WorkManager', 'Designing for Everyone'],
  'https://www.udacity.com/course/android-basics-in-kotlin--ud9012',
  'https://picsum.photos/seed/mob2/800/400',
  true
),

(
  'React Native - The Practical Guide 2024',
  'Udemy / Maximilian Schwarzmüller',
  'Use React Native and your React knowledge and take your web development skills to build native iOS and Android Apps. Build native mobile apps with JavaScript and React.',
  'Mobile Development',
  'Intermediate',
  35.0,
  4.7,
  75000,
  ARRAY['JavaScript'],
  ARRAY['Mobile Development', 'Web Development', 'Programming'],
  ARRAY['JavaScript'],
  ARRAY['Build native Android and iOS apps with React Native', 'Deep dive into the theory', 'Learn how to use and link third-party libraries'],
  ARRAY['Getting Started', 'React Native Basics', 'Debugging', 'Components, Styling, and Layouts', 'Navigation', 'State Management', 'User Input', 'HTTP Requests', 'Authentication', 'Deployment'],
  'https://www.udemy.com/course/react-native-the-practical-guide/',
  'https://picsum.photos/seed/mob3/800/400',
  false
),

-- ============================================
-- PYTHON
-- ============================================
(
  'Complete Python Bootcamp: Go from Zero to Hero',
  'Udemy / Jose Portilla',
  'Learn Python like a professional! Start from the basics and go all the way to creating your own applications and games! Learn Python with 100+ exercises and learn how to build games, apps, and more!',
  'Programming',
  'Beginner',
  22.0,
  4.6,
  300000,
  ARRAY['Python', 'Git'],
  ARRAY['Programming', 'Data Science'],
  ARRAY[],
  ARRAY['Learn Python fundamentals', 'Use Python for object-oriented programming', 'Build games and scripts', 'Understand decorators and generators'],
  ARRAY['Python Setup', 'Python Basics', 'Control Flow', 'Methods and Functions', 'OOP', 'Modules and Packages', 'Errors and Exceptions', 'Decorators', 'Generators', 'Advanced Modules', 'Built-in Functions', 'Python Scripts', 'Final Capstone Projects'],
  'https://www.udemy.com/course/complete-python-bootcamp/',
  'https://picsum.photos/seed/py1/800/400',
  false
),

(
  'Python for Everybody Specialization',
  'Coursera / University of Michigan',
  'This Specialization builds on the success of the Python for Everybody course and will introduce fundamental programming concepts including data structures, networked application program interfaces, and databases, using the Python programming language.',
  'Programming',
  'Beginner',
  30.0,
  4.8,
  400000,
  ARRAY['Python', 'SQL'],
  ARRAY['Programming', 'Data Science'],
  ARRAY[],
  ARRAY['Describe the basics of Python programming language', 'Install Python and write your first program', 'Use Python to access the web', 'Use Python to query databases'],
  ARRAY['Programming for Everybody (Getting Started with Python)', 'Python Data Structures', 'Using Python to Access Web Data', 'Using Databases with Python', 'Capstone: Retrieving, Processing, and Visualizing Data with Python'],
  'https://www.coursera.org/specializations/python',
  'https://picsum.photos/seed/py2/800/400',
  false
),

(
  'Automate the Boring Stuff with Python',
  'Al Sweigart (free online)',
  'A practical programming book for office workers, academics, and anyone who needs to do computing but doesn''t have a CS degree. Learn Python to automate everyday tasks like searching through files, renaming files, copying and pasting text, and filling out forms.',
  'Programming',
  'Beginner',
  12.0,
  4.7,
  50000,
  ARRAY['Python'],
  ARRAY['Programming'],
  ARRAY['Python'],
  ARRAY['Automate file operations', 'Work with PDFs and spreadsheets', 'Schedule tasks', 'Build web scrapers', 'Send automated emails'],
  ARRAY['Python Basics', 'Flow Control', 'Functions', 'Lists', 'Dictionaries and Structuring Data', 'String Manipulation', 'Pattern Matching with Regex', 'Input Validation', 'Reading and Writing Files', 'Organizing Files', 'Web Scraping', 'Excel Spreadsheets', 'PDF and Word Documents', 'Email'],
  'https://automatetheboringstuff.com/',
  'https://picsum.photos/seed/py3/800/400',
  true
),

-- ============================================
-- SQL & DATABASES
-- ============================================
(
  'SQL and PostgreSQL: The Complete Developer''s Guide',
  'Udemy / Stephen Grider',
  'Become an expert with SQL and PostgreSQL. Store and retrieve data quickly and accurately! Learn to write complex queries and design efficient database schemas for any application.',
  'Data Analytics',
  'Beginner',
  22.0,
  4.7,
  65000,
  ARRAY['SQL'],
  ARRAY['Data Science', 'Data Analytics', 'Web Development'],
  ARRAY[],
  ARRAY['Understand when to use different kinds of SQL queries', 'Build complex queries to retrieve and manipulate data', 'Write efficient queries using PostgreSQL features', 'Design and implement database schemas'],
  ARRAY['Simple But Powerful SQL', 'Filtering Records', 'Working with Tables', 'Relating Records with Joins', 'Grouping and Aggregation', 'Sorting Records', 'Unions and Intersections', 'Assembling Queries with SubQueries', 'Selecting Distinct Records', 'PostgreSQL Utility Operators', 'Recursive Common Table Expressions', 'Database Design', 'Database Migrations', 'Schema Design Patterns'],
  'https://www.udemy.com/course/sql-and-postgresql/',
  'https://picsum.photos/seed/sql1/800/400',
  false
),

(
  'Intro to SQL: Querying and Managing Data',
  'Khan Academy',
  'Learn how to use SQL to store, query, and manipulate data. SQL is a special-purpose programming language designed for managing data in a relational database, and is used by a huge number of apps and organizations.',
  'Data Analytics',
  'Beginner',
  10.0,
  4.6,
  200000,
  ARRAY['SQL'],
  ARRAY['Data Analytics', 'Data Science'],
  ARRAY[],
  ARRAY['Query a database', 'Restrict and sort results', 'Aggregate data', 'Combine multiple tables'],
  ARRAY['Intro to SQL', 'More advanced SQL queries', 'Relational queries in SQL', 'Modifying databases with SQL', 'SQL for data scientists'],
  'https://www.khanacademy.org/computing/computer-programming/sql',
  'https://picsum.photos/seed/sql2/800/400',
  true
),

-- ============================================
-- CYBERSECURITY
-- ============================================
(
  'Google Cybersecurity Professional Certificate',
  'Coursera / Google',
  'Prepare for a career in cybersecurity with a professional certificate from Google. Learn at your own pace. No degree or experience required. Get job-ready in less than 6 months.',
  'Cybersecurity',
  'Beginner',
  45.0,
  4.8,
  100000,
  ARRAY['Python', 'SQL'],
  ARRAY['Cybersecurity'],
  ARRAY[],
  ARRAY['Understand the importance of cybersecurity practices', 'Identify common risks, threats, and vulnerabilities', 'Use SIEM tools to protect business operations', 'Understand how to protect networks and data'],
  ARRAY['Foundations of Cybersecurity', 'Play It Safe: Manage Security Risks', 'Connect and Protect: Networks and Network Security', 'Tools of the Trade: Linux and SQL', 'Assets, Threats, and Vulnerabilities', 'Sound the Alarm: Detection and Response', 'Automate Cybersecurity Tasks with Python', 'Put It to Work: Prepare for Cybersecurity Jobs'],
  'https://www.coursera.org/professional-certificates/google-cybersecurity',
  'https://picsum.photos/seed/cyber1/800/400',
  false
),

(
  'Introduction to Cybersecurity',
  'Cisco Networking Academy',
  'This introductory course is meant for anyone curious about the world of cybersecurity. Develop a basic understanding of cybersecurity, threats and vulnerabilities, and how to stay safe online. Earn a badge on completion.',
  'Cybersecurity',
  'Beginner',
  15.0,
  4.5,
  120000,
  ARRAY[],
  ARRAY['Cybersecurity'],
  ARRAY[],
  ARRAY['Explain the personal impact of cybercrime', 'Describe top cybersecurity threats', 'Recognize opportunities in the cybersecurity field', 'Understand the power of firewalls and encryption'],
  ARRAY['Personal Data and Privacy', 'Organizational Data and Privacy', 'Attacks, Concepts and Techniques', 'Network Layer Security', 'Endpoint Security and Systems', 'The Art of Protecting Secrets', 'Cybersecurity - Will It Be My Career?'],
  'https://skillsforall.com/course/introduction-to-cybersecurity',
  'https://picsum.photos/seed/cyber2/800/400',
  true
),

-- ============================================
-- CLOUD COMPUTING
-- ============================================
(
  'AWS Cloud Practitioner Essentials',
  'AWS Training',
  'This course is for individuals who seek an overall understanding of the Amazon Web Services (AWS) Cloud, independent of specific technical roles. You will learn about AWS Cloud concepts, AWS services, security, architecture, pricing, and support.',
  'Cloud Computing',
  'Beginner',
  10.0,
  4.7,
  150000,
  ARRAY['Git'],
  ARRAY['Cloud Computing'],
  ARRAY[],
  ARRAY['Define what the AWS Cloud is and the basic global infrastructure', 'Describe basic AWS Cloud architectural principles', 'Describe the AWS Cloud value proposition', 'Describe key services on the AWS platform'],
  ARRAY['Introduction to Amazon Web Services', 'Compute in the Cloud', 'Global Infrastructure and Reliability', 'Networking', 'Storage and Databases', 'Security', 'Monitoring and Analytics', 'Pricing and Support', 'Migration and Innovation', 'Cloud Journey'],
  'https://aws.amazon.com/training/digital/aws-cloud-practitioner-essentials/',
  'https://picsum.photos/seed/cloud1/800/400',
  true
),

(
  'Google Cloud Digital Leader',
  'Coursera / Google Cloud',
  'Prepare for the Google Cloud Digital Leader certification. This program introduces you to the range of Google Cloud products and services, digital transformation with Google Cloud, infrastructure and application modernization.',
  'Cloud Computing',
  'Beginner',
  15.0,
  4.6,
  80000,
  ARRAY[],
  ARRAY['Cloud Computing'],
  ARRAY[],
  ARRAY['Understand cloud concepts', 'Identify Google Cloud products', 'Explain cloud infrastructure', 'Understand cloud security and compliance'],
  ARRAY['Digital Transformation with Google Cloud', 'Exploring Data Transformation with Google Cloud', 'Innovating with Google Cloud AI', 'Modernize Infrastructure and Applications with Google Cloud', 'Trust and Security with Google Cloud', 'Scaling with Google Cloud Operations'],
  'https://www.coursera.org/professional-certificates/google-cloud-digital-leader-training',
  'https://picsum.photos/seed/cloud2/800/400',
  false
),

(
  'Docker and Kubernetes: The Complete Guide',
  'Udemy / Stephen Grider',
  'Build, test, and deploy Docker applications with Kubernetes while learning production-style development workflows. Master Docker and Kubernetes by building a production-grade application and deploying it to AWS.',
  'Cloud Computing',
  'Advanced',
  22.0,
  4.7,
  90000,
  ARRAY['Git'],
  ARRAY['Cloud Computing', 'Web Development'],
  ARRAY['Git'],
  ARRAY['Build a CI/CD pipeline', 'Understand Docker and containerization', 'Use Kubernetes to deploy complex apps', 'Deploy applications to AWS'],
  ARRAY['Dive into Docker', 'Manipulating Containers with Docker Client', 'Building Custom Images Through Docker Server', 'Making Real Projects with Docker', 'Docker Compose with Multiple Local Containers', 'Creating a Production-Grade Workflow', 'Continuous Integration and Deployment with AWS', 'Building a Multi-Container Application', 'Kubernetes'],
  'https://www.udemy.com/course/docker-and-kubernetes-the-complete-guide/',
  'https://picsum.photos/seed/cloud3/800/400',
  false
),

-- ============================================
-- UI/UX DESIGN
-- ============================================
(
  'Google UX Design Professional Certificate',
  'Coursera / Google',
  'Start your career in UX design with a Professional Certificate from Google. Learn the foundations of UX design, including empathizing with users, building wireframes and prototypes, and conducting usability studies.',
  'UI/UX Design',
  'Beginner',
  35.0,
  4.8,
  120000,
  ARRAY['UI/UX Design'],
  ARRAY['UI/UX Design'],
  ARRAY[],
  ARRAY['Understand the basics of UX design', 'Apply foundational UX concepts', 'Complete a design sprint', 'Build wireframes, prototypes, and mockups', 'Conduct UX research'],
  ARRAY['Foundations of User Experience (UX) Design', 'Start the UX Design Process: Empathize, Define, Ideate', 'Build Wireframes and Low-Fidelity Prototypes', 'Conduct UX Research and Test Early Concepts', 'Create High-Fidelity Designs and Prototypes in Figma', 'Responsive Web Design in Adobe XD', 'Design for Social Good and Prepare for Jobs'],
  'https://www.coursera.org/professional-certificates/google-ux-design',
  'https://picsum.photos/seed/ux1/800/400',
  false
),

(
  'UI Design Fundamentals',
  'Scrimba',
  'In this course, you will learn the fundamental UI design principles for making designs that work well. You will learn about spacing and the grid, typography, color, and more, and in every chapter you will get hands-on practice applying these concepts to real-world design challenges.',
  'UI/UX Design',
  'Beginner',
  8.0,
  4.6,
  45000,
  ARRAY['UI/UX Design'],
  ARRAY['UI/UX Design', 'Web Development'],
  ARRAY[],
  ARRAY['Understand and apply spacing and grid principles', 'Use typography effectively', 'Apply color theory', 'Design with visual hierarchy in mind'],
  ARRAY['Spacing and the Grid', 'Typography', 'Color', 'Imagery', 'Visual Hierarchy', 'User Experience Design'],
  'https://scrimba.com/learn/design',
  'https://picsum.photos/seed/ux2/800/400',
  true
),

-- ============================================
-- STATISTICS
-- ============================================
(
  'Statistics with Python Specialization',
  'Coursera / University of Michigan',
  'This specialization is designed to teach learners beginning and intermediate concepts of statistical analysis using the Python programming language. Learners will learn where data comes from, what types of data can be collected, study data design, data management, and begin exploring and visualizing data.',
  'Data Analytics',
  'Intermediate',
  25.0,
  4.5,
  75000,
  ARRAY['Python', 'Statistics', 'Data Analysis'],
  ARRAY['Data Science', 'Data Analytics'],
  ARRAY['Python'],
  ARRAY['Understand basics of data and statistical concepts', 'Perform statistical data analysis', 'Build confidence intervals and perform hypothesis testing', 'Fit and interpret linear and logistic regression models'],
  ARRAY['Understanding and Visualizing Data with Python', 'Inferential Statistical Analysis with Python', 'Fitting Statistical Models to Data with Python'],
  'https://www.coursera.org/specializations/statistics-with-python',
  'https://picsum.photos/seed/stat1/800/400',
  false
),

(
  'Khan Academy Statistics & Probability',
  'Khan Academy',
  'Learn statistics and probability—everything you would want to know about descriptive and inferential statistics. A great foundation course for anyone going into data science, machine learning, or research.',
  'Data Analytics',
  'Beginner',
  18.0,
  4.7,
  300000,
  ARRAY['Statistics'],
  ARRAY['Data Science', 'Data Analytics'],
  ARRAY[],
  ARRAY['Understand measures of central tendency', 'Use probability concepts', 'Interpret statistical displays', 'Apply statistical inference'],
  ARRAY['Analyzing categorical data', 'Displaying and comparing quantitative data', 'Summarizing quantitative data', 'Modeling data distributions', 'Exploring bivariate data', 'Study design', 'Probability', 'Counting, permutations, and combinations', 'Random variables', 'Inference'],
  'https://www.khanacademy.org/math/statistics-probability',
  'https://picsum.photos/seed/stat2/800/400',
  true
),

-- ============================================
-- GIT & VERSION CONTROL
-- ============================================
(
  'Git and GitHub - The Complete Git & GitHub Course',
  'Udemy / George Lomidze',
  'Master Git and GitHub with a hands-on course. Learn version control, branching, merging, rebasing, and collaboration on GitHub. This is an essential skill for all software developers.',
  'Programming',
  'Beginner',
  10.0,
  4.7,
  85000,
  ARRAY['Git'],
  ARRAY['Programming', 'Web Development', 'Mobile Development'],
  ARRAY[],
  ARRAY['Use Git to track changes to code', 'Work with branches for parallel development', 'Collaborate using GitHub', 'Resolve merge conflicts'],
  ARRAY['Git Basics', 'Creating Snapshots', 'Browsing History', 'Branching', 'Collaboration', 'Rewriting History', 'Git on GitHub', 'Open Source Projects'],
  'https://www.udemy.com/course/git-github-practical-guide/',
  'https://picsum.photos/seed/git1/800/400',
  false
),

(
  'Version Control with Git',
  'Coursera / Atlassian',
  'In this course, you will not learn everything there is to know about Git, but you will build a strong conceptual understanding of the technology, and be fluent with the key skills needed to use Git in a professional environment.',
  'Programming',
  'Beginner',
  13.0,
  4.6,
  55000,
  ARRAY['Git'],
  ARRAY['Programming'],
  ARRAY[],
  ARRAY['Understand core Git concepts', 'Use git commands to manage files', 'Collaborate using remote repositories', 'Use branching strategies'],
  ARRAY['Our First Repository', 'Git Locations', 'Branches and Merging I', 'Branches and Merging II', 'Resolving Merge Conflicts', 'Git Workflows'],
  'https://www.coursera.org/learn/version-control-with-git',
  'https://picsum.photos/seed/git2/800/400',
  false
),

-- ============================================
-- JAVA
-- ============================================
(
  'Java Programming Masterclass',
  'Udemy / Tim Buchalka',
  'Learn Java In This Course And Become a Computer Programmer. Obtain valuable Core Java Skills and Java Certification! Covers Core Java concepts including OOP, multithreading, generics, and JavaFX.',
  'Programming',
  'Beginner',
  80.0,
  4.6,
  200000,
  ARRAY['Java'],
  ARRAY['Programming'],
  ARRAY[],
  ARRAY['Learn the fundamentals and advanced concepts of Java', 'Develop Java programs', 'Write Java programs using OOP principles', 'Use Java Collections framework'],
  ARRAY['Setup and First Steps', 'Variables, Datatypes and Operators', 'Expressions, Statements, Code Blocks, Methods', 'Control Flow', 'OOP Part 1', 'OOP Part 2', 'Arrays', 'List, ArrayList, LinkedList', 'Inheritance', 'Polymorphism', 'Generics', 'Iterators, Autoboxing', 'Collections', 'Multithreading', 'JavaFX'],
  'https://www.udemy.com/course/java-the-complete-java-developer-course/',
  'https://picsum.photos/seed/java1/800/400',
  false
),

-- ============================================
-- JAVASCRIPT
-- ============================================
(
  'The Complete JavaScript Course 2024: From Zero to Expert!',
  'Udemy / Jonas Schmedtmann',
  'The modern JavaScript course for everyone! Master JavaScript with projects, challenges and theory; many courses in one! Covers ES6+, OOP, AJAX, Webpack, and more.',
  'Programming',
  'Beginner',
  68.0,
  4.7,
  250000,
  ARRAY['JavaScript', 'Git'],
  ARRAY['Web Development', 'Programming'],
  ARRAY[],
  ARRAY['Go from beginner to advanced JavaScript developer', 'JavaScript fundamentals: variables, if/else, operators, functions, arrays, objects, loops', 'Asynchronous JavaScript: event loop, promises, async/await', 'Modern JavaScript: ES6+'],
  ARRAY['JavaScript Fundamentals Part 1', 'JavaScript Fundamentals Part 2', 'How JavaScript Works Behind the Scenes', 'Data Structures, Modern Operators, and Strings', 'A Closer Look at Functions', 'Working with Arrays', 'Numbers, Dates, Timers', 'Advanced DOM and Events', 'Object-Oriented Programming (OOP) with JavaScript', 'Asynchronous JavaScript: Promises, Async/Await, and AJAX', 'Modern JavaScript Modules and Tooling', 'Forkify App: Building a Modern Application'],
  'https://www.udemy.com/course/the-complete-javascript-course/',
  'https://picsum.photos/seed/js1/800/400',
  false
),

-- ============================================
-- DART / FLUTTER ADVANCED
-- ============================================
(
  'Flutter & Firebase: Build a Complete App for iOS & Android',
  'Udemy / Andrea Bizzotto',
  'Learn Flutter and Firebase by building a time tracking app step by step. Includes topics such as Stream builders, user authentication, and Cloud Firestore. Goes from beginner to advanced.',
  'Mobile Development',
  'Advanced',
  32.0,
  4.6,
  45000,
  ARRAY['Dart/Flutter', 'Git'],
  ARRAY['Mobile Development', 'Programming'],
  ARRAY['Dart/Flutter'],
  ARRAY['Build complete Flutter + Firebase apps', 'Use Firebase Auth for user authentication', 'Store data with Cloud Firestore', 'Implement complex UI with custom widgets'],
  ARRAY['Course Introduction', 'Flutter App Architecture', 'Firebase Setup', 'User Authentication', 'State Management with Riverpod', 'Cloud Firestore CRUD', 'Real-time Data with Streams', 'UI/UX Polish', 'Testing', 'App Deployment'],
  'https://www.udemy.com/course/flutter-firebase-build-a-complete-app-for-ios-android/',
  'https://picsum.photos/seed/flutter1/800/400',
  false
),

-- ============================================
-- ADVANCED DATA SCIENCE
-- ============================================
(
  'Applied Data Science with Python Specialization',
  'Coursera / University of Michigan',
  'The 5 courses in this University of Michigan Specialization introduce learners to data science through the python programming language. This skills-based specialization is intended for learners who have a basic python or programming background.',
  'Data Science',
  'Intermediate',
  30.0,
  4.4,
  90000,
  ARRAY['Python', 'Data Analysis', 'Machine Learning', 'Statistics'],
  ARRAY['Data Science', 'Machine Learning', 'Data Analytics'],
  ARRAY['Python'],
  ARRAY['Apply data manipulation and cleaning', 'Create charting and visualization tools', 'Apply statistical techniques to data', 'Build machine learning models'],
  ARRAY['Introduction to Data Science in Python', 'Applied Plotting, Charting & Data Representation in Python', 'Applied Machine Learning in Python', 'Applied Text Mining in Python', 'Applied Social Network Analysis in Python'],
  'https://www.coursera.org/specializations/data-science-python',
  'https://picsum.photos/seed/ads1/800/400',
  false
),

(
  'Natural Language Processing Specialization',
  'Coursera / DeepLearning.AI',
  'Break into the NLP space. Master cutting-edge NLP techniques through four hands-on courses! You will learn how to design NLP applications that perform question-answering and sentiment analysis, create tools to translate languages and summarize text.',
  'Machine Learning',
  'Advanced',
  40.0,
  4.6,
  60000,
  ARRAY['Python', 'Machine Learning'],
  ARRAY['Machine Learning', 'Artificial Intelligence', 'Data Science'],
  ARRAY['Python', 'Machine Learning'],
  ARRAY['Use logistic regression, naïve Bayes, and word vectors', 'Use dynamic programming, hidden Markov models', 'Apply neural networks and attention models', 'Build encoder-decoder architecture for machine translation'],
  ARRAY['Natural Language Processing with Classification and Vector Spaces', 'Natural Language Processing with Probabilistic Models', 'Natural Language Processing with Sequence Models', 'Natural Language Processing with Attention Models'],
  'https://www.coursera.org/specializations/natural-language-processing',
  'https://picsum.photos/seed/nlp1/800/400',
  false
),

(
  'TensorFlow Developer Certificate',
  'Coursera / DeepLearning.AI',
  'Prepare for the TensorFlow Developer Certificate exam by building and training neural networks for image classification, natural language processing, and time series analysis.',
  'Machine Learning',
  'Intermediate',
  28.0,
  4.7,
  85000,
  ARRAY['Python', 'Machine Learning'],
  ARRAY['Machine Learning', 'Artificial Intelligence'],
  ARRAY['Python', 'Machine Learning'],
  ARRAY['Build and train neural networks using TensorFlow', 'Use datasets from real-world scenarios', 'Build natural language processing systems', 'Apply RNNs, GRUs, LSTMs for sequence problems'],
  ARRAY['Introduction to TensorFlow for AI, ML and Deep Learning', 'Convolutional Neural Networks in TensorFlow', 'Natural Language Processing in TensorFlow', 'Sequences, Time Series and Prediction'],
  'https://www.coursera.org/professional-certificates/tensorflow-in-practice',
  'https://picsum.photos/seed/tf1/800/400',
  false
),

-- ============================================
-- INTERVIEW PREP
-- ============================================
(
  'Cracking the Coding Interview — Data Structures & Algorithms',
  'freeCodeCamp',
  'Prepare for technical interviews with this comprehensive course on data structures and algorithms. Covers arrays, linked lists, trees, graphs, sorting algorithms, and dynamic programming with practice problems.',
  'Programming',
  'Intermediate',
  20.0,
  4.6,
  180000,
  ARRAY['Python', 'Java', 'JavaScript'],
  ARRAY['Programming'],
  ARRAY['Python'],
  ARRAY['Solve coding problems efficiently', 'Understand time and space complexity', 'Master essential data structures', 'Implement common algorithms'],
  ARRAY['Big O Notation', 'Arrays', 'Linked Lists', 'Stacks and Queues', 'Trees', 'Graphs', 'Sorting Algorithms', 'Searching Algorithms', 'Dynamic Programming', 'Recursion', 'Interview Problem-Solving Strategies'],
  'https://www.youtube.com/watch?v=8hly31xKli0',
  'https://picsum.photos/seed/algo1/800/400',
  true
),

(
  'LeetCode Patterns: From Beginner to Advanced',
  'freeCodeCamp',
  'Learn to recognize patterns in LeetCode problems and solve them systematically. This course teaches you common patterns like sliding window, two pointers, BFS/DFS, and dynamic programming that appear repeatedly in coding interviews.',
  'Programming',
  'Intermediate',
  15.0,
  4.5,
  95000,
  ARRAY['Python', 'Java', 'JavaScript'],
  ARRAY['Programming'],
  ARRAY['Python'],
  ARRAY['Identify common problem patterns', 'Apply sliding window technique', 'Use two-pointer approach', 'Solve DP problems systematically'],
  ARRAY['Two Pointers', 'Sliding Window', 'Binary Search', 'BFS & DFS', 'Backtracking', 'Dynamic Programming', 'Graphs', 'Greedy Algorithms'],
  'https://www.youtube.com/watch?v=DjYZk8nrXVY',
  'https://picsum.photos/seed/algo2/800/400',
  true
),

-- ============================================
-- POWER BI / TABLEAU (Data Visualization)
-- ============================================
(
  'Microsoft Power BI Desktop for Business Intelligence',
  'Udemy / Maven Analytics',
  'Learn Business Intelligence with Microsoft Power BI! Create stunning reports and dashboards, master DAX, and drive data-driven decisions.',
  'Data Analytics',
  'Beginner',
  18.0,
  4.6,
  75000,
  ARRAY['SQL', 'Data Analysis', 'Statistics'],
  ARRAY['Data Analytics', 'Data Science'],
  ARRAY[],
  ARRAY['Connect and transform data', 'Build data models in Power BI', 'Write DAX measures', 'Design professional dashboards'],
  ARRAY['Getting Started with Power BI', 'Connecting & Shaping Data', 'Creating a Data Model', 'Adding DAX Measures', 'Visualizing Data with Reports', 'Publishing & Sharing Dashboards'],
  'https://www.udemy.com/course/microsoft-power-bi-up-running-with-power-bi-desktop/',
  'https://picsum.photos/seed/bi1/800/400',
  false
),

(
  'Tableau 2024 A-Z: Hands-On Tableau Training',
  'Udemy / Kirill Eremenko',
  'Learn data visualization and business intelligence with Tableau 2024. Connect to various data sources, create interactive dashboards, and gain actionable insights from your data.',
  'Data Analytics',
  'Beginner',
  15.0,
  4.6,
  120000,
  ARRAY['Data Analysis', 'Statistics'],
  ARRAY['Data Analytics', 'Data Science'],
  ARRAY[],
  ARRAY['Connect Tableau to various data sources', 'Create compelling data visualizations', 'Build interactive dashboards', 'Use calculated fields and parameters'],
  ARRAY['Getting Started with Tableau', 'Connecting to Data Sources', 'Data Visualization Fundamentals', 'Time Series and Aggregation', 'Maps in Tableau', 'Joining and Blending Data', 'Table Calculations', 'Advanced Analytics', 'Interactive Dashboards'],
  'https://www.udemy.com/course/tableau10/',
  'https://picsum.photos/seed/bi2/800/400',
  false
),

-- ============================================
-- PROMPT ENGINEERING / AI TOOLS
-- ============================================
(
  'Prompt Engineering for Developers',
  'DeepLearning.AI',
  'Learn how to write effective prompts for large language models (LLMs). This course covers prompting principles, iterative prompt development, summarizing, inferring, transforming, and building a chatbot.',
  'Artificial Intelligence',
  'Beginner',
  5.0,
  4.8,
  200000,
  ARRAY['Python'],
  ARRAY['Artificial Intelligence', 'Machine Learning'],
  ARRAY[],
  ARRAY['Write effective prompts', 'Use iterative prompt development', 'Apply prompting for summarization and inference', 'Build a chatbot with system and user messages'],
  ARRAY['Introduction', 'Guidelines for Prompting', 'Iterative Prompt Development', 'Summarizing', 'Inferring', 'Transforming', 'Expanding', 'Chatbot', 'Conclusion'],
  'https://www.deeplearning.ai/short-courses/chatgpt-prompt-engineering-for-developers/',
  'https://picsum.photos/seed/prompt1/800/400',
  true
),

-- ============================================
-- ETHICAL AI / RESPONSIBLE AI
-- ============================================
(
  'AI Ethics',
  'edX / Harvard University',
  'Gain a foundational understanding of AI ethics to tackle difficult and complex ethical questions that arise in technology today. Designed for practitioners, policymakers, and interested individuals.',
  'Artificial Intelligence',
  'Beginner',
  4.0,
  4.5,
  35000,
  ARRAY['Machine Learning'],
  ARRAY['Artificial Intelligence'],
  ARRAY[],
  ARRAY['Identify ethical issues in AI systems', 'Apply ethical frameworks to technology decisions', 'Evaluate fairness in algorithms', 'Understand privacy and data governance'],
  ARRAY['Introduction to AI Ethics', 'Fairness and Bias', 'Privacy and Data', 'Accountability and Transparency', 'Safety and Reliability', 'Economic Impact', 'Future of AI Ethics'],
  'https://online-learning.harvard.edu/course/ai-ethics',
  'https://picsum.photos/seed/ethics1/800/400',
  true
);

-- ============================================
-- WELCOME NOTIFICATIONS FOR SEEDED USERS
-- ============================================
-- (Notifications are created dynamically per user, no seed needed for notifications)

-- Verify data
SELECT COUNT(*) as total_courses FROM public.courses;
