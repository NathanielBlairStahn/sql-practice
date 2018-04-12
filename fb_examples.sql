-- 1. You have two tables specifying a user's friends and which pages they like:
--
-- users      likes
-- -----      -----
-- user_id    user_id
-- friend_id  page_id
--
-- Given a user id, recommend pages based on what the user's friends liked.
-- Order the pages by which are more popular, and don't include pages
-- already liked by the user.

-- Sample tables and output:
-- users               likes             recommendations
-- user_id friend_id   user_id page_id   user_id page_id count_friend_likes
-- 1       2           1       41        1       42      2
-- 2       1           1       45        2       45      2
-- 1       3           2       41        1       47      1
-- 3       1           3       42
--                     3       41
--                     3       45
--                     3       47
-- Alternate data:  --------------------------------------------------------
-- 42      5           5       A         42      A       2
-- 42      7           5       B         42      B       1
--                     5       C         42      E       1
--                     7       A
--                     7       C
--                     7       D
--                     7       E
--                     42      C
--                     42      D
--                     42      F

SELECT users.user_id, f_likes.page_id, COUNT(f_likes.user_id)
FROM users
JOIN likes AS f_likes
ON users.friend_id = f_likes.user_id
LEFT JOIN likes AS self_likes
ON users.user_id = self_likes.user_id
AND f_likes.page_id = self_likes.page_id
WHERE self_likes.user_id IS NULL
GROUP BY users.user_id, f_likes.page_id
ORDER BY COUNT(f_likes.user_id) DESC;


-- 2. You have two tables specifying users and friends:
-- users      friends
-- -----      -----
-- user_id    user_id
-- user_name  friend_id
--
-- Given two users, find a list of their mutual friends.
-- Assume that if A and B are friends, both (A,B) and (B,A)
-- appear in the friends table.

SELECT 
