# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

10.times do |n|
  User.create!(
    name: "hogefuga#{n + 1}",
    password: "password#{n + 1}",
    uid: "uid#{n + 1}",
    profile: "detail#{n + 1}"
  )
end

[
  ["content1", 1],
  ["content2", 2],
  ["content3", 3],
  ["content4", 1],
  ["content5", 2],
  ["content6", 3],
  ["content7", 1],
  ["content8", 2],
  ["content9", 3],
].each do |content, user_id|
  Post.create!(
    {content: content, user_id: user_id}
  )
end

[
  [1, 1],
  [2, 1],
  [3, 1],
  [1, 8],
  [1, 3],
  [4, 6],
  [2, 4],
  [1, 2]
].each do |user_id, post_id|
  Like.create!(
    {user_id: user_id, post_id: post_id}
  )
end

[
  [1, 3],
  [3, 7],
  [4, 3],
  [9, 3],
  [2, 4],
  [1, 9],
  [2, 3],
  [1, 5],
  [1, 8]
].each do |follower_id, followee_id|
  Follow.create!(
    {follower_id: follower_id, followee_id: followee_id}
  )
end
