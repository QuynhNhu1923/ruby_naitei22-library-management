# db/seeds.rb
require 'faker'

puts "Clearing existing data..."
BorrowRequestItem.delete_all
BorrowRequest.delete_all
BookCategory.delete_all
Book.delete_all
Category.delete_all
Author.delete_all
Publisher.delete_all
User.delete_all

# ==== USERS ====
puts "Seeding users..."
admin = User.create!(
  name: "Admin",
  email: "admin@example.com",
  password: "password",
  role: 1, # admin
  gender: 0,
  date_of_birth: Date.new(1990, 1, 1),
  status: 1
)

users = 10.times.map do |i|
  User.create!(
    name: Faker::Name.name,
    email: "user#{i+1}@example.com",
    password: "password",
    role: 0,
    gender: [0, 1].sample,
    date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 60),
    status: 1
  )
end

# ==== AUTHORS ====
puts "Seeding authors..."
authors = 5.times.map do
  Author.create!(
    name: Faker::Book.author,
    bio: Faker::Lorem.paragraph,
    birth_date: Faker::Date.birthday(min_age: 40, max_age: 80),
    nationality: Faker::Nation.nationality
  )
end

# ==== PUBLISHERS ====
puts "Seeding publishers..."
publishers = 5.times.map do
  Publisher.create!(
    name: Faker::Book.publisher,
    address: Faker::Address.full_address,
    phone_number: Faker::PhoneNumber.phone_number[0, 10],
    email: Faker::Internet.email,
    website: Faker::Internet.url
  )
end

# ==== CATEGORIES ====
puts "Seeding categories..."
categories = 6.times.map do
  Category.create!(
    name: Faker::Book.genre,
    description: Faker::Lorem.sentence
  )
end

# ==== BOOKS ====
puts "Seeding books..."
books = 20.times.map do
  book = Book.create!(
    title: Faker::Book.title,
    description: Faker::Lorem.paragraph,
    publication_year: rand(1990..2025),
    total_quantity: total_q = rand(5..15),
    available_quantity: total_q,
    borrow_count: 0,
    author: authors.sample,
    publisher: publishers.sample
  )
  # Gắn 1-3 category cho mỗi book
  categories.sample(rand(1..3)).each do |cat|
    BookCategory.create!(book: book, category: cat)
  end
  book
end

# ==== BORROW REQUESTS & ITEMS ====
puts "Seeding borrow requests..."
statuses = [0, 1, 2, 3, 4] # theo enum của bạn nếu có
30.times do
  user = users.sample
  start_date = Faker::Date.backward(days: rand(1..30))
  end_date = start_date + rand(5..10).days

  br = BorrowRequest.create!(
    user: user,
    request_date: start_date - rand(1..3).days,
    status: statuses.sample,
    start_date: start_date,
    end_date: end_date
  )

  rand(1..3).times do
    BorrowRequestItem.create!(
      borrow_request: br,
      book: books.sample,
      quantity: rand(1..2)
    )
  end
end

puts "✅ Seeding completed!"
