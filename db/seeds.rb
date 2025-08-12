# Clear existing data (optional - be careful in production!)
puts "Clearing existing users..."
BorrowRequestItem.destroy_all
BorrowRequest.destroy_all
Review.destroy_all
Favorite.destroy_all
BookCategory.destroy_all
Book.destroy_all
Category.destroy_all
Publisher.destroy_all
Author.destroy_all
User.destroy_all

users = []
30.times do
  users << User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: "password",
    password_confirmation: "password",
    role: 0, # user
    gender: [0, 1, 2].sample, # male, female, other
    date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 80),
    status: [0, 1].sample,
    activated_at: [nil, Time.zone.now].sample
  )
end
# Admins
admins = []
3.times do
  admins << User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: "password",
    password_confirmation: "password",
    role: 1, # admin
    gender: [0, 1, 2].sample,
    date_of_birth: Faker::Date.birthday(min_age: 25, max_age: 60),
    status: 1,
    activated_at: Time.zone.now
  )
end

# =============================
# Authors
# =============================
puts "Seeding authors..."
authors = []
10.times do
  authors << Author.create!(
    name: Faker::Book.author,
    bio: Faker::Lorem.paragraph(sentence_count: 5),
    birth_date: Faker::Date.birthday(min_age: 40, max_age: 90),
    death_date: [nil, Faker::Date.between(from: 20.years.ago, to: Date.today)].sample,
    nationality: Faker::Address.country
  )
end

# =============================
# Publishers
# =============================
puts "Seeding publishers..."
publishers = []
5.times do
  publishers << Publisher.create!(
    name: Faker::Book.publisher,
    address: Faker::Address.full_address,
    phone_number: Faker::Number.number(digits: 10),
    email: Faker::Internet.email,
    website: Faker::Internet.url
  )
end

# =============================
# Categories
# =============================
puts "Seeding categories..."
categories = []
10.times do
  categories << Category.create!(
    name: Faker::Book.unique.genre,
    description: Faker::Lorem.sentence(word_count: 10)
  )
end

# =============================
# Books
# =============================
puts "Seeding books..."
books = []
50.times do
  books << Book.create!(
    title: Faker::Book.title,
    description: Faker::Lorem.paragraph(sentence_count: 8),
    publication_year: rand(1950..2025),
    total_quantity: rand(5..20),
    available_quantity: rand(1..5),
    borrow_count: rand(0..50),
    author: authors.sample,
    publisher: publishers.sample
  )
end

# =============================
# Book - Categories
# =============================
puts "Linking books with categories..."
books.each do |book|
  categories.sample(rand(1..3)).each do |category|
    BookCategory.create!(book: book, category: category)
  end
end

# =============================
# Borrow Requests (chi tiết theo trạng thái)
# =============================
puts "Seeding borrow requests (by status)..."

# Helper: tạo items cho request
add_items_for = lambda do |br, books|
  eligible = books.select { |b| b.available_quantity.to_i > 0 }
  return if eligible.empty?

  selected = eligible.sample(rand(1..[3, eligible.size].min))
  selected.each do |book|
    max_q = [book.available_quantity.to_i, 2].min
    q = [1, max_q].max
    BorrowRequestItem.create!(borrow_request: br, book: book, quantity: q)
  end
end

n_pending  = 5
n_approved = 5
n_rejected = 5
n_returned = 5
n_overdue  = 5

# PENDING: chưa duyệt, chưa trả
n_pending.times do
  start_date = Faker::Date.between(from: 90.days.ago, to: Date.today)
  end_date   = start_date + rand(7..21).days

  br = BorrowRequest.create!(
    user: users.sample,
    request_date: start_date - 1.day,
    status: :pending,
    start_date: start_date,
    end_date: end_date,
    admin_note: nil,
    approved_by_admin_id: nil,
    rejected_by_admin_id: nil,
    returned_by_admin_id: nil
  )
  add_items_for.call(br, books)
end
