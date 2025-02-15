# db/seeds.rb

require 'faker'

puts "Clearing existing data..."

# Order is important to respect foreign key constraints
Reaction.destroy_all
Comment.destroy_all
ForumThread.destroy_all
Project.destroy_all
Tag.destroy_all
Category.destroy_all
Follow.destroy_all
ClusterAssignment.destroy_all
UserQuizResponse.destroy_all
QuizAnswer.destroy_all
QuizQuestion.destroy_all
Quiz.destroy_all
User.destroy_all

puts "Seeding Users..."
user1 = User.create!(
  username: "john_doe",
  name: "John Doe",
  email: "john@example.com",
  bio: "I love coding and building communities!",
  created_at: Faker::Time.backward(days: 30)
)

user2 = User.create!(
  username: "jane_smith",
  name: "Jane Smith",
  email: "jane@example.com",
  bio: "Enthusiast of Ruby on Rails!",
  created_at: Faker::Time.backward(days: 30)
)

user3 = User.create!(
  username: "geeky_girl",
  name: "Alice Wonderland",
  email: "alice@example.com",
  bio: "React, Node, and all things JS!",
  created_at: Faker::Time.backward(days: 15)
)

puts "Seeding Categories..."
cat1 = Category.create!(name: "General", description: "General discussions")
cat2 = Category.create!(name: "Ruby on Rails", description: "Rails-specific threads")
cat3 = Category.create!(name: "JavaScript", description: "Talk about JS frameworks and libraries")

puts "Seeding Tags..."
tag1 = Tag.create!(name: "Rails")
tag2 = Tag.create!(name: "React")
tag3 = Tag.create!(name: "Beginner")
tag4 = Tag.create!(name: "Advanced")

puts "Seeding ForumThreads..."
thread1 = ForumThread.create!(
  title: "How to get started with Rails?",
  content: "Any good tutorials or docs for a total beginner?",
  user: user1,
  category: cat2,
  mood: "chill",
  created_at: Faker::Time.backward(days: 10)
)

thread2 = ForumThread.create!(
  title: "React vs Vue vs Angular",
  content: "Which front-end framework do you prefer and why?",
  user: user2,
  category: cat3,
  mood: "excited",
  created_at: Faker::Time.backward(days: 8)
)

thread3 = ForumThread.create!(
  title: "Best coding practices for 2025",
  content: "Share your tips and best practices for maintainable code.",
  user: user3,
  category: cat1,
  mood: "curious",
  created_at: Faker::Time.backward(days: 5)
)

puts "Attaching tags to ForumThreads..."
thread1.tags << tag1  # "Rails"
thread1.tags << tag3  # "Beginner"

thread2.tags << tag2  # "React"
thread2.tags << tag4  # "Advanced"

thread3.tags << tag1  # "Rails"
thread3.tags << tag2  # "React"

puts "Seeding Projects..."
project1 = Project.create!(
  title: "Awesome Rails Blog",
  description: "A sample blog built with Rails 7",
  repo_link: "https://github.com/john_doe/rails_blog",
  live_site_link: "https://myrailsblog.example.com",
  user: user1
)

project2 = Project.create!(
  title: "React Photo Gallery",
  description: "A photo gallery in React using hooks and context",
  repo_link: "https://github.com/jane_smith/react_gallery",
  live_site_link: "https://reactgallery.example.com",
  user: user2
)

puts "Seeding Comments for ForumThreads and Projects..."
# Comments on thread1
c1 = Comment.create!(
  content: "Rails is awesome. Definitely check out the official docs!",
  user: user2,
  commentable: thread1,
  mood: 1 # thoughtful
)

c2 = Comment.create!(
  content: "Yes, freeCodeCamp has a nice tutorial too.",
  user: user3,
  commentable: thread1,
  mood: 3 # helpful
)

# Nested reply on c1
Comment.create!(
  content: "Agree with that, docs are the best place to start!",
  user: user1,
  commentable: thread1,
  parent: c1,
  mood: 0 # friendly
)

# Comments on project1
p_comment1 = Comment.create!(
  content: "Great project, John! Learned a lot from it.",
  user: user3,
  commentable: project1,
  mood: 4 # insightful
)

# Comments on thread2
Comment.create!(
  content: "I love React because of the community and ecosystem.",
  user: user1,
  commentable: thread2,
  mood: 5 # excited
)

# Comments on thread3
Comment.create!(
  content: "Automated testing and code reviews are key for maintainability!",
  user: user2,
  commentable: thread3,
  mood: 3 # helpful
)

# Nested reply example
parent_comment = Comment.create!(
  content: "Could you share some code style guides?",
  user: user1,
  commentable: thread3,
  mood: 1 # thoughtful
)
Comment.create!(
  content: "Sure! I'll post a link: https://github.com/rubocop/rails-style-guide",
  user: user2,
  commentable: thread3,
  parent: parent_comment,
  mood: 2 # funny
)

# Comments on project2
Comment.create!(
  content: "Awesome UI, Jane! The lazy loading is smooth.",
  user: user3,
  commentable: project2,
  mood: 5 # excited
)

puts "Seeding Reactions (like/chill) for some forum threads..."
Reaction.create!(
  user: user1,
  forum_thread: thread2,
  reaction_type: "like"
)

Reaction.create!(
  user: user3,
  forum_thread: thread2,
  reaction_type: "chill"
)

Reaction.create!(
  user: user2,
  forum_thread: thread1,
  reaction_type: "like"
)

puts "Seeding Follows (users following each other)..."
Follow.create!(follower_id: user1.id, followed_user_id: user2.id)
Follow.create!(follower_id: user1.id, followed_user_id: user3.id)
Follow.create!(follower_id: user2.id, followed_user_id: user3.id)

puts "Seeding ClusterAssignments (example usage)..."
ClusterAssignment.create!(user: user1, cluster_id: 123, version: 1)
ClusterAssignment.create!(user: user2, cluster_id: 456, version: 1)

puts "Seeding Quizzes with Questions & Answers..."
quiz1 = Quiz.create!(
  title: "Tech Preferences",
  description: "A quiz to find out your tech stack preference",
  active: true
)

q1 = QuizQuestion.create!(
  quiz: quiz1,
  content: "Which language do you prefer for backend?",
  order: 1
)

a1 = QuizAnswer.create!(
  quiz_question: q1,
  content: "Ruby",
  impact: { preference: "Ruby" }
)
a2 = QuizAnswer.create!(
  quiz_question: q1,
  content: "JavaScript",
  impact: { preference: "JavaScript" }
)

q2 = QuizQuestion.create!(
  quiz: quiz1,
  content: "How experienced are you with Rails?",
  order: 2
)
a3 = QuizAnswer.create!(
  quiz_question: q2,
  content: "Beginner",
  impact: { level: "beginner" }
)
a4 = QuizAnswer.create!(
  quiz_question: q2,
  content: "Pro",
  impact: { level: "pro" }
)

puts "Seeding UserQuizResponses..."
UserQuizResponse.create!(
  user: user1,
  quiz: quiz1,
  quiz_question: q1,
  quiz_answer: a1
)

UserQuizResponse.create!(
  user: user1,
  quiz: quiz1,
  quiz_question: q2,
  quiz_answer: a4
)

UserQuizResponse.create!(
  user: user2,
  quiz: quiz1,
  quiz_question: q1,
  quiz_answer: a2
)

UserQuizResponse.create!(
  user: user2,
  quiz: quiz1,
  quiz_question: q2,
  quiz_answer: a3
)

puts "Seeding complete!"
