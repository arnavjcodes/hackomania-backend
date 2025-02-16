# db/seeds.rb

puts "Clearing existing data..."
Comment.delete_all
Reaction.delete_all
Follow.delete_all
ForumThread.delete_all
Tag.delete_all
Category.delete_all
User.delete_all

puts "Seeding Categories..."
categories = Category.create!([
  { name: "Programming Languages", description: "Discuss and compare programming languages" },
  { name: "Web Development", description: "Frontend, backend, and full-stack discussions" },
  { name: "DevOps & Cloud", description: "Infrastructure, CI/CD, and cloud platforms" },
  { name: "Data Science & AI", description: "Machine learning, data analysis, and AI" },
  { name: "Cybersecurity", description: "Security best practices and threat discussions" },
  { name: "Mobile Development", description: "iOS, Android, and cross-platform development" },
  { name: "Game Development", description: "Game engines, graphics, and game design" },
  { name: "Tech Careers", description: "Job advice, interviews, and career growth" }
])

puts "Seeding Tags..."
tags = Tag.create!([
  { name: "python" },
  { name: "javascript" },
  { name: "react" },
  { name: "aws" },
  { name: "docker" },
  { name: "machine-learning" },
  { name: "rust" },
  { name: "kubernetes" },
  { name: "typescript" },
  { name: "graphql" }
])

puts "Seeding Users..."
# Create tech-savvy users
users = [
  { username: "code_wizard", name: "Alice Developer", email: "alice@dev.com", bio: "Full-stack developer with a passion for clean code", language: "en", timezone: "UTC", dark_mode: true },
  { username: "devops_guru", name: "Bob Ops", email: "bob@ops.com", bio: "Cloud architect and Kubernetes enthusiast", language: "en", timezone: "EST", dark_mode: false },
  { username: "ai_master", name: "Charlie Data", email: "charlie@ai.com", bio: "Machine learning engineer specializing in NLP", language: "en", timezone: "PST", dark_mode: true },
  { username: "security_pro", name: "Dana Secure", email: "dana@sec.com", bio: "Cybersecurity consultant and ethical hacker", language: "en", timezone: "CET", dark_mode: true },
  { username: "game_dev", name: "Eve Creator", email: "eve@game.com", bio: "Unity developer and game designer", language: "en", timezone: "GMT", dark_mode: false },
  { username: "rustacean", name: "Frank Systems", email: "frank@sys.com", bio: "Low-level programming enthusiast", language: "en", timezone: "UTC", dark_mode: true }
].map { |attrs| User.create!(attrs) }

puts "Seeding Follows..."
# Create meaningful follow relationships
follows = [
  { follower: users[0], followed_user: users[1] }, # Alice follows Bob
  { follower: users[1], followed_user: users[2] }, # Bob follows Charlie
  { follower: users[2], followed_user: users[3] }, # Charlie follows Dana
  { follower: users[3], followed_user: users[4] }, # Dana follows Eve
  { follower: users[4], followed_user: users[5] }, # Eve follows Frank
  { follower: users[5], followed_user: users[0] }  # Frank follows Alice
].each { |attrs| Follow.create!(attrs) }

puts "Seeding Forum Threads..."
forum_threads = [
  {
    title: "Best practices for React state management in 2024?",
    content: "With so many options available (Redux, Context API, Zustand, etc.), what's your preferred way to manage state in large React applications?",
    mood: "Curious",
    user: users[0],
    category: categories[1],
    tags: [ "react", "javascript" ]
  },
  {
    title: "Transitioning from Monolith to Microservices",
    content: "We're considering breaking our monolith into microservices. What are the key things we should consider before making the jump?",
    mood: "Supportive",
    user: users[1],
    category: categories[2],
    tags: [ "docker", "kubernetes" ]
  },
  {
    title: "Career advice: Specialist vs Generalist in tech",
    content: "I'm at a crossroads in my career. Should I go deep into one technology or maintain a broader skill set?",
    mood: "Curious",
    user: users[5],
    category: categories[7],
    tags: []
  }
].map do |attrs|
  thread = ForumThread.create!(attrs.except(:tags))
  thread.tags << Tag.where(name: attrs[:tags])
  thread
end

puts "Seeding Comments..."
comments = [
  {
    content: "I've had great success with Zustand for smaller projects, but for enterprise-level apps, Redux Toolkit is still my go-to.",
    user: users[1],
    commentable: forum_threads[0]
  },
  {
    content: "Don't forget about testing! Each microservice should have its own comprehensive test suite.",
    user: users[2],
    commentable: forum_threads[1]
  },
  {
    content: "I'd recommend starting as a generalist and then specializing once you find your passion.",
    user: users[3],
    commentable: forum_threads[2]
  }
].each { |attrs| Comment.create!(attrs) }

puts "Seeding Reactions..."
reactions = [
  { user: users[1], forum_thread: forum_threads[0], reaction_type: "like" },
  { user: users[2], forum_thread: forum_threads[0], reaction_type: "chill" },
  { user: users[3], forum_thread: forum_threads[1], reaction_type: "like" }
].each { |attrs| Reaction.create!(attrs) }

puts "Seeding Quizzes..."
quiz = Quiz.create!(
  title: "Tech Personality Quiz",
  description: "Discover your tech personality type!",
  active: true
)

puts "Seeding Quiz Questions..."
questions = [
  {
    content: "When starting a new project, you:",
    quiz: quiz,
    order: 1,
    quiz_answers: [
      { content: "Dive right into coding", impact: { "hacker": 5 } },
      { content: "Spend time designing the architecture", impact: { "architect": 5 } },
      { content: "Write tests first", impact: { "engineer": 5 } },
      { content: "Research best practices", impact: { "researcher": 5 } }
    ]
  },
  {
    content: "Your favorite type of tech meetup is:",
    quiz: quiz,
    order: 2,
    quiz_answers: [
      { content: "Hands-on coding workshops", impact: { "hacker": 5 } },
      { content: "System design deep dives", impact: { "architect": 5 } },
      { content: "Case studies of production systems", impact: { "engineer": 5 } },
      { content: "Emerging tech presentations", impact: { "researcher": 5 } }
    ]
  },
  {
    content: "When debugging, you:",
    quiz: quiz,
    order: 3,
    quiz_answers: [
      { content: "Try random fixes until it works", impact: { "hacker": 5 } },
      { content: "Analyze the system architecture", impact: { "architect": 5 } },
      { content: "Write tests to reproduce the issue", impact: { "engineer": 5 } },
      { content: "Research similar issues online", impact: { "researcher": 5 } }
    ]
  }
].each do |question_attrs|
  answers = question_attrs.delete(:quiz_answers)
  question = QuizQuestion.create!(question_attrs)
  answers.each { |answer| question.quiz_answers.create!(answer) }
end

puts "Done seeding!"
