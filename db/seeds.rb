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
  ["content1", 9],
  ["content2", 8],
  ["content3", 7],
  ["content4", 6],
  ["content5", 5],
  ["content6", 4],
  ["content7", 3],
  ["content8", 2],
  ["content9", 1],
  ["content10", 1]
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

10.times do |n|
  user = User.find_by(id: n+1)
  user.follower_count = Follow.where(followee_id: n+1).count
  user.followee_count = Follow.where(follower_id: n+1).count
  user.save
end