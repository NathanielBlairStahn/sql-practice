-- Problem 1.
-- You have two tables specifying a user's friends and which pages they like:
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


-- Problem 2. You have two tables specifying users and friends:
-- users      friends
-- -----      -----
-- user_id    user_id
-- user_name  friend_id
--
-- Given two users, find a list of their mutual friends.
-- Assume that if A and B are friends, both (A,B) and (B,A)
-- appear in the friends table.
-- Assume user 1's id is 42 and user 2's id is 1411.
--
-- Note: C is a mutual friend of A and B if (A,C) and (B,C)
-- both appear in the friends table.

SELECT users.user_id, users.user_name
FROM users
JOIN friends AS u1_friends
ON users.user_id = u1_friends.friend_id
JOIN friends AS u2_friends
ON u1_friends.friend_id = u2_friends.friend_id
WHERE u1_friends.user_id = 42
AND u2_friends.user_id = 1411

-- Problem 3.
-- Suppose you have 4 tables:
-- users      friends     events    attendance
-- -----      -------     ------    ----------
-- id         user1_id    id        event_id
-- name       user2_id    host_id   user_id
--                        date
--
-- Assume that if A and B are friends, then either (A,B)
-- or (B,A) appears in the friends table, but not both.
--
-- a. For each user id, find all events that user's friends attended
-- within the last 7 days.

SELECT friends.user1_id AS user_id, events.id
FROM friends JOIN attendance
ON friends.user2_id = attendance.user_id
JOIN events
ON attendance.event_id = events.id
WHERE events.date >= DATE_SUB(CURRENT_DATE, INTERVAL 7 days)

-- Need union because the friends table is asymmetric -
-- each user will appear in either the query above or the
-- query below, but not both.
UNION

SELECT friends.user2_id AS user_id, events.id
FROM friends JOIN attendance
ON friends.user1_id = attendance.user_id
JOIN events
ON attendance.event_id = events.id
WHERE events.date >= DATE_SUB(CURRENT_DATE, INTERVAL 7 days)

-- b. What if we wanted to exclude the events that the user attended?
SELECT friends.user1_id AS user_id, events.id
FROM friends JOIN attendance AS friend_attendance
ON friends.user2_id = friend_attendance.user_id
JOIN events
ON friend_attendance.event_id = events.id
LEFT JOIN attendance AS self_attendance
ON friends.user1_id = self_attendance.user_id
WHERE events.date >= DATE_SUB(CURRENT_DATE, INTERVAL 7 days)
AND self_attendance.user_id IS NULL

UNION

SELECT friends.user2_id AS user_id, events.id
FROM friends JOIN attendance AS friend_attendance
ON friends.user1_id = friend_attendance.user_id
JOIN events
ON attendance.event_id = events.id
LEFT JOIN attendance AS self_attendance
ON friends.user2_id = self_attendance.user_id
WHERE events.date >= DATE_SUB(CURRENT_DATE, INTERVAL 7 days)
AND self_attendance.user_id IS NULL

-- c. What if also wanted the names of the friends who attended each event?
SELECT friends.user1_id AS user_id, events.id, users.name AS friend_name
FROM friends JOIN attendance AS friend_attendance
ON friends.user2_id = friend_attendance.user_id
JOIN events
ON friend_attendance.event_id = events.id
JOIN users
ON users.id = friend_attendance.user_id
LEFT JOIN attendance AS self_attendance
ON friends.user1_id = self_attendance.user_id
WHERE self_attendance.user_id IS NULL
AND events.date >= DATE_SUB(CURRENT_DATE, INTERVAL 7 days)

UNION

SELECT friends.user2_id AS user_id, events.id, users.name AS friend_name
FROM friends JOIN attendance AS friend_attendance
ON friends.user1_id = friend_attendance.user_id
JOIN events
ON attendance.event_id = events.id
JOIN users
ON users.id = friend_attendance.user_id
LEFT JOIN attendance AS self_attendance
ON friends.user2_id = self_attendance.user_id
WHERE self_attendance.user_id IS NULL
AND events.date >= DATE_SUB(CURRENT_DATE, INTERVAL 7 days)

-- Problem 4.
 -- You have 2 tables:
-- people: id, name
-- friends: id1, id2
--
-- Note: Each friend pair shows up once, so either (1,3) or (3,1) could be in friends table, but not both.
--
-- a. Return all id's in friends of friends. Include both orderings of id pairs in the result.
--
-- The pairs (A,B) and (B,A) should be included if:
-- i. (A,C) and (B,C) are both in friends for some C, or
-- ii. (A,C) and (C,B) are both in friends for some C, or
-- iii. (C,A) and (B,C) are both in friends for some C, or
-- iv. (C,A) and (C,B) are both in friends for some C.
-- Note: A=me, C=my friend, B=friend of my friend C.
--
-- Make 2 copies of the friends table, my_friends and friends_of_friends.
-- Translating the above, we want to include:
-- i. (my_friends.id1, friends_of_friends.id1) if my_friends.id2 = friends_of_friends.id2
-- ii. (my_friends.id1, friends_of_friends.id2) if my_friends.id2 = friends_of_friends.id1
-- iii. (my_friends.id2, friends_of_friends.id1) if my_friends.id1 = friends_of_friends.id2
-- iv. (my_friends.id2, friends_of_friends.id2) if my_friends.id1 = friends_of_friends.id1
--
-- Note that when we join the talbes, both orderings of id's will show up because, e.g.
-- if both (A,C) and (B,C) are in the friends table, then we will get
-- (A,C) in my_friends and (B,C) in friends_of_friends, so (A,B) shows up,
-- and also (B,C) in my_friends and (A,C) in friends_of_friends, so (B,A) will show up.

-- case i.
SELECT my_friends.id1, friends_friends.id1
FROM friends AS my_friends
JOIN friends AS friends_friends
ON my_friends.id2 = friends_friends.id2
AND my_friends.id1 <> friends_friends.id1
UNION
-- case ii. Note that the 2 id's can't be equal in this case.
SELECT my_friends.id1, friends_friends.id2
FROM friends AS my_friends
JOIN friends AS friends_friends
ON my_friends.id2 = friends_friends.id1
UNION
-- case iii. Note that the 2 id's can't be equal in this case.
SELECT my_friends.id2, friends_friends.id1
FROM friends AS my_friends
JOIN friends AS friends_friends
ON my_friends.id1 = friends_friends.id2
UNION
-- case iv.
SELECT my_friends.id2, friends_friends.id2
FROM friends AS my_friends
JOIN friends AS friends_friends
ON my_friends.id1 = friends_friends.id1
AND my_friends.id2 <> friends_friends.id2;

-- b. What if we DON'T want to include both orderings of id pairs in the result?
--
-- Hmm, not sure - probably you would NOT want to do this in practice because for
-- each user you'd want a list of their friends of friends...
-- An equivalent question is, "If you have a table that contains pairs (A,B) and
-- (possibly) also the reverse pair (B,A), how would you get unique unordered pairs?"
--
-- Assuming the data has an ordering, you could do:
SELECT id1, id2
FROM friends
WHERE id1 < id2;

-- And to go the other way, from unordered to ordered:
SELECT id1, id2
FROM friends
UNION
SELECT id2, id1
FROM friends;

-- Ok, so in the above query, just add comparison operators to the 2
-- id's in each SELECT statement:
-- (Is it better to put these in the ON clause or in a WHERE clause?)
-- case i.
SELECT my_friends.id1, friends_friends.id1
FROM friends AS my_friends
JOIN friends AS friends_friends
ON my_friends.id2 = friends_friends.id2
AND my_friends.id1 < friends_friends.id1
UNION
-- case ii. (Note that the 2 id's can't be equal in this case.)
SELECT my_friends.id1, friends_friends.id2
FROM friends AS my_friends
JOIN friends AS friends_friends
ON my_friends.id2 = friends_friends.id1
AND my_friends.id1 < friends_friends.id1
UNION
-- case iii. (Note that the 2 id's can't be equal in this case.)
SELECT my_friends.id2, friends_friends.id1
FROM friends AS my_friends
JOIN friends AS friends_friends
ON my_friends.id1 = friends_friends.id2
AND my_friends.id1 < friends_friends.id1
UNION
-- case iv.
SELECT my_friends.id2, friends_friends.id2
FROM friends AS my_friends
JOIN friends AS friends_friends
ON my_friends.id1 = friends_friends.id1
AND my_friends.id2 < friends_friends.id2;

-- c. What if the friends table were bidirectional,
--i.e. both (A,B) and (B,A) appear in the table if A and B are friends?

-- We want to include (A,B) and (B,A) if:
-- i. Both (A,C) and (B,C) appear for some C
-- (in which case (C,A) and (C,B) also appear) or
--ii. Both (A,C) and (C,B) appear for some c
-- (in which case (C,A) and (B,C) also appear).
